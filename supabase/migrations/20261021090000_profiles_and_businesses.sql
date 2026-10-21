-- Phase 2: profiles, businesses, ownership triggers, and RLS.
-- Security-definer helpers live in an unexposed `private` schema.

create schema if not exists private;

revoke all on schema private from public, anon, authenticated;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 120),
  business_type text not null check (char_length(btrim(business_type)) between 1 and 80),
  country_code text not null default 'BW' check (country_code ~ '^[A-Z]{2}$'),
  currency_code text not null default 'BWP' check (currency_code ~ '^[A-Z]{3}$'),
  description text,
  started_on date,
  opening_balance_minor bigint not null default 0 check (opening_balance_minor >= 0),
  contact_phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint businesses_one_per_owner unique (owner_id)
);

create index if not exists businesses_owner_id_idx on public.businesses (owner_id);

create or replace function private.touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    split_part(coalesce(new.email, ''), '@', 1)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace function private.set_business_owner()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  if tg_op = 'INSERT' then
    new.owner_id := auth.uid();
  elsif tg_op = 'UPDATE' then
    new.owner_id := old.owner_id;
  end if;
  new.name := btrim(new.name);
  new.business_type := btrim(new.business_type);
  new.country_code := upper(btrim(new.country_code));
  new.currency_code := upper(btrim(new.currency_code));
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.touch_updated_at() from public, anon;
revoke all on function private.handle_new_user() from public, anon, authenticated;
revoke all on function private.set_business_owner() from public, anon;

grant usage on schema private to authenticated, supabase_auth_admin;
grant execute on function private.touch_updated_at() to authenticated;
grant execute on function private.set_business_owner() to authenticated;
grant execute on function private.handle_new_user() to supabase_auth_admin;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function private.touch_updated_at();

drop trigger if exists businesses_set_owner on public.businesses;
create trigger businesses_set_owner
  before insert or update on public.businesses
  for each row execute function private.set_business_owner();

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;

alter table public.profiles force row level security;
alter table public.businesses force row level security;

revoke all on table public.profiles from public, anon;
revoke all on table public.businesses from public, anon;

grant select, update on table public.profiles to authenticated;
grant select, insert, update, delete on table public.businesses to authenticated;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using (id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists businesses_select_own on public.businesses;
create policy businesses_select_own
  on public.businesses
  for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists businesses_insert_own on public.businesses;
create policy businesses_insert_own
  on public.businesses
  for insert
  to authenticated
  with check (owner_id = (select auth.uid()));

drop policy if exists businesses_update_own on public.businesses;
create policy businesses_update_own
  on public.businesses
  for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists businesses_delete_own on public.businesses;
create policy businesses_delete_own
  on public.businesses
  for delete
  to authenticated
  using (owner_id = (select auth.uid()));
