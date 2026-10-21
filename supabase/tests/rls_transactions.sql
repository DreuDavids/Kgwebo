-- Phase 4 RLS verification against hhwxajxjmyjntxykptvs.
-- Repeat with two Auth users that each own a business.
--
-- Observed checklist:
-- 1. User A inserts a sale for A's business.
-- 2. User B selects 0 of A's transactions.
-- 3. User B insert with A's business_id is rejected.
-- 4. User B update/delete of A's transaction affects 0 rows.
-- 5. anon has no SELECT/INSERT on public.transactions.
-- 6. Duplicate (business_id, idempotency_key) does not create a second row.
--
-- select has_table_privilege('anon', 'public.transactions', 'select'); -- false
-- select has_table_privilege('anon', 'public.transactions', 'insert'); -- false

select has_table_privilege('anon', 'public.transactions', 'select') as anon_can_read_transactions,
       has_table_privilege('anon', 'public.transactions', 'insert') as anon_can_insert_transactions,
       has_table_privilege('anon', 'public.transactions', 'update') as anon_can_update_transactions,
       has_table_privilege('anon', 'public.transactions', 'delete') as anon_can_delete_transactions,
       has_table_privilege('authenticated', 'public.transactions', 'select') as authenticated_can_select_transactions,
       has_table_privilege('authenticated', 'public.transactions', 'insert') as authenticated_can_insert_transactions;
