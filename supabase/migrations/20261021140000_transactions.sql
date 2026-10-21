-- Phase 4: confirmed money movements with ownership RLS and idempotency.
-- Security-definer helpers stay in the unexposed `private` schema.

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_by uuid not null references public.profiles (id),
  idempotency_key uuid not null,
  type text not null check (
    type in (
      'sale',
      'expense',
      'refund',
      'owner_contribution',
      'owner_withdrawal'
    )
  ),
  amount_minor bigint not null check (
    amount_minor > 0
    and amount_minor <= 99999999999999
  ),
  currency_code text not null check (currency_code ~ '^[A-Z]{3}$'),
  category text not null check (char_length(btrim(category)) between 1 and 80),
  description text check (
    description is null
    or char_length(btrim(description)) <= 500
  ),
  occurred_at timestamptz not null,
  payment_method text not null check (
    payment_method in ('cash', 'mobile_money', 'bank_transfer', 'other')
  ),
  payment_status text not null check (payment_status in ('paid', 'unpaid')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint transactions_idempotency_unique unique (business_id, idempotency_key)
);

create index if not exists transactions_business_occurred_idx
  on public.transactions (business_id, occurred_at desc, id desc);

create index if not exists transactions_business_type_occurred_idx
  on public.transactions (business_id, type, occurred_at desc);

create or replace function private.owns_business(p_business_id uuid)
returns boolean
language sql
stable
security invoker
set search_path = public
as $$
  select exists (
    select 1
    from public.businesses b
    where b.id = p_business_id
      and b.owner_id = (select auth.uid())
  );
$$;

create or replace function private.set_transaction_defaults()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  business_currency text;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select b.currency_code
    into business_currency
  from public.businesses b
  where b.id = new.business_id
    and b.owner_id = (select auth.uid());

  if business_currency is null then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;

  if tg_op = 'INSERT' then
    new.created_by := (select auth.uid());
    new.currency_code := business_currency;
  elsif tg_op = 'UPDATE' then
    new.business_id := old.business_id;
    new.created_by := old.created_by;
    new.idempotency_key := old.idempotency_key;
    new.currency_code := old.currency_code;
    if new.currency_code <> business_currency then
      raise exception 'Transaction currency must match the business currency';
    end if;
  end if;

  new.category := btrim(new.category);
  if new.description is not null then
    new.description := nullif(btrim(new.description), '');
  end if;
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.owns_business(uuid) from public, anon;
revoke all on function private.set_transaction_defaults() from public, anon;

grant execute on function private.owns_business(uuid) to authenticated;
grant execute on function private.set_transaction_defaults() to authenticated;

drop trigger if exists transactions_set_defaults on public.transactions;
create trigger transactions_set_defaults
  before insert or update on public.transactions
  for each row execute function private.set_transaction_defaults();

alter table public.transactions enable row level security;
alter table public.transactions force row level security;

revoke all on table public.transactions from public, anon;
grant select, insert, update, delete on table public.transactions to authenticated;

drop policy if exists transactions_select_own on public.transactions;
create policy transactions_select_own
  on public.transactions
  for select
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists transactions_insert_own on public.transactions;
create policy transactions_insert_own
  on public.transactions
  for insert
  to authenticated
  with check (private.owns_business(business_id));

drop policy if exists transactions_update_own on public.transactions;
create policy transactions_update_own
  on public.transactions
  for update
  to authenticated
  using (private.owns_business(business_id))
  with check (private.owns_business(business_id));

drop policy if exists transactions_delete_own on public.transactions;
create policy transactions_delete_own
  on public.transactions
  for delete
  to authenticated
  using (private.owns_business(business_id));
