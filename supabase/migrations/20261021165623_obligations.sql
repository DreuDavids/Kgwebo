-- Phase 5: upcoming business commitments. Unpaid rows are not expenses and
-- do not reduce recorded cash. Overdue is derived from due_date, not stored.

create table if not exists public.obligations (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_by uuid not null references public.profiles (id),
  idempotency_key uuid not null,
  title text not null check (char_length(btrim(title)) between 1 and 120),
  amount_minor bigint not null check (
    amount_minor > 0
    and amount_minor <= 99999999999999
  ),
  currency_code text not null check (currency_code ~ '^[A-Z]{3}$'),
  due_date date not null,
  status text not null check (status in ('unpaid', 'paid', 'cancelled')),
  category text not null check (char_length(btrim(category)) between 1 and 80),
  notes text check (
    notes is null
    or char_length(btrim(notes)) <= 500
  ),
  recorded_transaction_id uuid references public.transactions (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint obligations_idempotency_unique unique (business_id, idempotency_key)
);

create index if not exists obligations_business_due_idx
  on public.obligations (business_id, due_date asc, id asc);

create index if not exists obligations_business_status_due_idx
  on public.obligations (business_id, status, due_date asc);

create or replace function private.set_obligation_defaults()
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
      raise exception 'Commitment currency must match the business currency';
    end if;
  end if;

  new.title := btrim(new.title);
  new.category := btrim(new.category);
  if new.notes is not null then
    new.notes := nullif(btrim(new.notes), '');
  end if;
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.set_obligation_defaults() from public, anon;
grant execute on function private.set_obligation_defaults() to authenticated;

drop trigger if exists obligations_set_defaults on public.obligations;
create trigger obligations_set_defaults
  before insert or update on public.obligations
  for each row execute function private.set_obligation_defaults();

alter table public.obligations enable row level security;
alter table public.obligations force row level security;

revoke all on table public.obligations from public, anon;
grant select, insert, update, delete on table public.obligations to authenticated;

drop policy if exists obligations_select_own on public.obligations;
create policy obligations_select_own
  on public.obligations
  for select
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists obligations_insert_own on public.obligations;
create policy obligations_insert_own
  on public.obligations
  for insert
  to authenticated
  with check (private.owns_business(business_id));

drop policy if exists obligations_update_own on public.obligations;
create policy obligations_update_own
  on public.obligations
  for update
  to authenticated
  using (private.owns_business(business_id))
  with check (private.owns_business(business_id));

drop policy if exists obligations_delete_own on public.obligations;
create policy obligations_delete_own
  on public.obligations
  for delete
  to authenticated
  using (private.owns_business(business_id));
