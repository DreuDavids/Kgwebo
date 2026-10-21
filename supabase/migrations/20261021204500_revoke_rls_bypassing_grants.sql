-- Postgres TRUNCATE is not filtered by RLS. Supabase's default GRANT ALL left
-- TRUNCATE/TRIGGER/REFERENCES on authenticated even after DML-only GRANTs.
-- Keep ordinary row privileges; strip privileges that bypass or ignore RLS.

revoke all on table public.profiles from public, anon, authenticated;
grant select, update on table public.profiles to authenticated;

revoke all on table public.businesses from public, anon, authenticated;
grant select, insert, update, delete on table public.businesses to authenticated;

revoke all on table public.transactions from public, anon, authenticated;
grant select, insert, update, delete on table public.transactions to authenticated;

revoke all on table public.obligations from public, anon, authenticated;
grant select, insert, update, delete on table public.obligations to authenticated;
