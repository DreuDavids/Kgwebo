-- Phase 2 RLS verification (executed 21 Oct 2026 against hhwxajxjmyjntxykptvs).
-- Phase 3 catalog re-check (21 Oct 2026): policies and UNIQUE (owner_id) unchanged.
-- No new remote migration was applied.
-- Result: rls_ok
--
-- Observed:
-- 1. User A selected only A's business.
-- 2. User B saw 0 rows, and update/delete of A's business affected 0 rows.
-- 3. Insert with owner_id = A as User B stored owner_id = B (trigger).
-- 4. anon has no SELECT on public.profiles or public.businesses.
--
-- Repeat against two Auth users:
--
-- select set_config('request.jwt.claims', json_build_object('sub', :user_a, 'role', 'authenticated')::text, true);
-- set role authenticated;
-- insert into public.businesses (name, business_type) values ('A Stall', 'Informal trader');
-- select count(*) from public.businesses; -- 1
--
-- select set_config('request.jwt.claims', json_build_object('sub', :user_b, 'role', 'authenticated')::text, true);
-- select count(*) from public.businesses; -- 0
-- update public.businesses set name = 'Stolen' where owner_id = :user_a; -- 0 rows
--
-- select has_table_privilege('anon', 'public.businesses', 'select'); -- false
--
-- Reset role when finished. Do not leave test businesses in place.

select has_table_privilege('anon', 'public.businesses', 'select') as anon_can_read_businesses,
       has_table_privilege('anon', 'public.profiles', 'select') as anon_can_read_profiles,
       has_table_privilege('authenticated', 'public.profiles', 'insert') as authenticated_can_insert_profiles;
