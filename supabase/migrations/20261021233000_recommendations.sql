-- Phase 7: persisted recommendation lifecycle. Display copy is derived from
-- current records. This table stores ownership, rule key, condition fingerprint
-- and status only — not financial amounts.

create table if not exists public.recommendations (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_by uuid not null references public.profiles (id),
  rule_key text not null check (char_length(btrim(rule_key)) between 1 and 80),
  condition_key text not null check (
    char_length(btrim(condition_key)) between 1 and 500
  ),
  status text not null check (status in ('active', 'dismissed', 'resolved')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint recommendations_rule_unique unique (business_id, rule_key)
);

create index if not exists recommendations_business_status_idx
  on public.recommendations (business_id, status, rule_key);

create or replace function private.set_recommendation_defaults()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1
    from public.businesses b
    where b.id = new.business_id
      and b.owner_id = (select auth.uid())
  ) then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;

  if tg_op = 'INSERT' then
    new.created_by := (select auth.uid());
  elsif tg_op = 'UPDATE' then
    new.business_id := old.business_id;
    new.created_by := old.created_by;
    new.rule_key := old.rule_key;
  end if;

  new.rule_key := btrim(new.rule_key);
  new.condition_key := btrim(new.condition_key);
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.set_recommendation_defaults() from public, anon, authenticated;
grant execute on function private.set_recommendation_defaults() to authenticated;

drop trigger if exists recommendations_set_defaults on public.recommendations;
create trigger recommendations_set_defaults
  before insert or update on public.recommendations
  for each row execute function private.set_recommendation_defaults();

alter table public.recommendations enable row level security;
alter table public.recommendations force row level security;

revoke all on table public.recommendations from public, anon, authenticated;
grant select, insert, update, delete on table public.recommendations to authenticated;

drop policy if exists recommendations_select_own on public.recommendations;
create policy recommendations_select_own
  on public.recommendations
  for select
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists recommendations_insert_own on public.recommendations;
create policy recommendations_insert_own
  on public.recommendations
  for insert
  to authenticated
  with check (private.owns_business(business_id));

drop policy if exists recommendations_update_own on public.recommendations;
create policy recommendations_update_own
  on public.recommendations
  for update
  to authenticated
  using (private.owns_business(business_id))
  with check (private.owns_business(business_id));

drop policy if exists recommendations_delete_own on public.recommendations;
create policy recommendations_delete_own
  on public.recommendations
  for delete
  to authenticated
  using (private.owns_business(business_id));
