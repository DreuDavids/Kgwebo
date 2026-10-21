-- Phase 5 RLS verification against hhwxajxjmyjntxykptvs.
-- Repeat with two Auth users that each own a business.
--
-- Observed checklist:
-- 1. User A inserts an unpaid rent commitment for A's business.
-- 2. User B selects 0 of A's obligations.
-- 3. User B insert with A's business_id is rejected.
-- 4. User B update/delete of A's obligation affects 0 rows.
-- 5. User B cannot set created_by to A's id (trigger forces auth.uid()).
-- 6. anon has no SELECT/INSERT/UPDATE/DELETE on public.obligations.
-- 7. Duplicate (business_id, idempotency_key) does not create a second row.
--
-- Payload impersonation requires two dedicated staging users. Catalog checks
-- below can run without those users.

select has_table_privilege('anon', 'public.obligations', 'select') as anon_can_read_obligations,
       has_table_privilege('anon', 'public.obligations', 'insert') as anon_can_insert_obligations,
       has_table_privilege('anon', 'public.obligations', 'update') as anon_can_update_obligations,
       has_table_privilege('anon', 'public.obligations', 'delete') as anon_can_delete_obligations,
       has_table_privilege('authenticated', 'public.obligations', 'select') as authenticated_can_select_obligations,
       has_table_privilege('authenticated', 'public.obligations', 'insert') as authenticated_can_insert_obligations;
