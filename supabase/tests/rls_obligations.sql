-- Phase 5 RLS verification against hhwxajxjmyjntxykptvs.
-- Two-user payload test (21 Oct 2026): dedicated Auth users signed in through
-- GoTrue (grant_type=password) and called PostgREST with their access tokens.
-- Service-role was not used as a test identity. Throwaway users were removed
-- after the run.
--
-- Observed checklist:
-- 1. User A inserts an unpaid rent commitment for A's business. (201)
-- 2. User B selects 0 of A's obligations.
-- 3. User B insert with A's business_id is rejected. (400)
-- 4. User B update/delete of A's obligation affects 0 rows. (200, 0 rows)
-- 5. User B cannot set created_by to A's id (trigger forces auth.uid()).
-- 6. anon has no SELECT/INSERT/UPDATE/DELETE on public.obligations. (401)
-- 7. Duplicate (business_id, idempotency_key) does not create a second row. (409)
--
-- Catalog checks below can run without dedicated users.

select has_table_privilege('anon', 'public.obligations', 'select') as anon_can_read_obligations,
       has_table_privilege('anon', 'public.obligations', 'insert') as anon_can_insert_obligations,
       has_table_privilege('anon', 'public.obligations', 'update') as anon_can_update_obligations,
       has_table_privilege('anon', 'public.obligations', 'delete') as anon_can_delete_obligations,
       has_table_privilege('anon', 'public.obligations', 'truncate') as anon_can_truncate_obligations,
       has_table_privilege('authenticated', 'public.obligations', 'select') as authenticated_can_select_obligations,
       has_table_privilege('authenticated', 'public.obligations', 'insert') as authenticated_can_insert_obligations,
       has_table_privilege('authenticated', 'public.obligations', 'truncate') as authenticated_can_truncate_obligations;
