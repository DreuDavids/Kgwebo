-- Phase 6 RLS catalog checks. Two-user JWT verification is recorded in
-- TEST_PLAN.md after a live GoTrue run against hhwxajxjmyjntxykptvs.
--
-- Expected:
-- anon has no SELECT/INSERT/UPDATE/DELETE/TRUNCATE on products, sale_items,
-- or stock_movements.
-- authenticated can select/insert/update/delete products, select sale_items
-- and stock_movements, and cannot TRUNCATE any of them.

select has_table_privilege('anon', 'public.products', 'select') as anon_can_read_products,
       has_table_privilege('anon', 'public.products', 'insert') as anon_can_insert_products,
       has_table_privilege('anon', 'public.products', 'truncate') as anon_can_truncate_products,
       has_table_privilege('authenticated', 'public.products', 'select') as authenticated_can_select_products,
       has_table_privilege('authenticated', 'public.products', 'insert') as authenticated_can_insert_products,
       has_table_privilege('authenticated', 'public.products', 'truncate') as authenticated_can_truncate_products,
       has_table_privilege('anon', 'public.stock_movements', 'select') as anon_can_read_movements,
       has_table_privilege('anon', 'public.stock_movements', 'insert') as anon_can_insert_movements,
       has_table_privilege('authenticated', 'public.stock_movements', 'select') as authenticated_can_select_movements,
       has_table_privilege('authenticated', 'public.stock_movements', 'insert') as authenticated_can_insert_movements,
       has_table_privilege('authenticated', 'public.stock_movements', 'truncate') as authenticated_can_truncate_movements,
       has_table_privilege('anon', 'public.sale_items', 'select') as anon_can_read_sale_items,
       has_table_privilege('authenticated', 'public.sale_items', 'insert') as authenticated_can_insert_sale_items,
       has_table_privilege('authenticated', 'public.sale_items', 'truncate') as authenticated_can_truncate_sale_items;
