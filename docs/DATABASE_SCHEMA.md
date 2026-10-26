# Kgwebo database schema

Authoritative SQL is under `supabase/migrations/`. Accounting rules are in `docs/FINANCIAL_MODEL.md`.

## Public tables (FORCE RLS on each)

| Table             | Role                                                                                              |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| `profiles`        | One row per Auth user, created by trigger. Clients cannot insert.                                 |
| `businesses`      | One business per owner. `opening_balance_minor` is starting cash, not a sale.                     |
| `transactions`    | Sales, expenses, refunds, owner contribution/withdrawal. Unique `(business_id, idempotency_key)`. |
| `obligations`     | Planned payments. Unpaid rows do not reduce recorded cash.                                        |
| `products`        | Catalogue. `stock_quantity_milli` is server-owned.                                                |
| `sale_items`      | Line snapshots. Select-only for clients.                                                          |
| `stock_movements` | Quantity ledger. Select-only for clients.                                                         |
| `recommendations` | `rule_key`, `condition_key`, status. Unique `(business_id, rule_key)`.                            |

## Server functions (authenticated)

- `create_catalog_product`
- `record_stock_movement`
- `record_product_sale` (sale + lines + sold movements in one transaction)
- `private.uuid_from_md5` for deterministic UUIDs on Postgres 17

## Local Drift (not the ledger)

Confirmed caches plus `sync_outbox` (schema v6). Outbox rows are never confirmed financial records.
