revoke insert, delete on table public.profiles from public, anon, authenticated;
grant select, update on table public.profiles to authenticated;
