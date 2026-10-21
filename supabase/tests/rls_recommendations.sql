-- Phase 7 RLS verification for public.recommendations.
-- Catalog checks below can run without dedicated users.
-- Two-user JWT isolation should repeat the Phase 5 obligation checklist:
-- B sees 0 of A's rows; B insert against A's business_id is rejected;
-- B update/delete of A's rows affect 0 rows; created_by is forced to auth.uid().

select has_table_privilege('anon', 'public.recommendations', 'select') as anon_can_read_recommendations,
       has_table_privilege('anon', 'public.recommendations', 'insert') as anon_can_insert_recommendations,
       has_table_privilege('anon', 'public.recommendations', 'update') as anon_can_update_recommendations,
       has_table_privilege('anon', 'public.recommendations', 'delete') as anon_can_delete_recommendations,
       has_table_privilege('anon', 'public.recommendations', 'truncate') as anon_can_truncate_recommendations,
       has_table_privilege('authenticated', 'public.recommendations', 'select') as authenticated_can_select_recommendations,
       has_table_privilege('authenticated', 'public.recommendations', 'insert') as authenticated_can_insert_recommendations,
       has_table_privilege('authenticated', 'public.recommendations', 'truncate') as authenticated_can_truncate_recommendations;
