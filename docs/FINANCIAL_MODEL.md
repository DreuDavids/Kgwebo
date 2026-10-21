# Kgwebo financial-domain model (Phase 4–7)

Grounded in the repository on 21 October 2026 and updated for forecasts and recommendations. Remote public tables now include `profiles`, `businesses`, `transactions`, `obligations`, `products`, `sale_items`, `stock_movements`, and `recommendations`.

This document is the accounting contract for recorded sales, expenses, owner cash movements, inventory, and dashboard totals. Widgets and Supabase clients must not invent a second set of rules.

## Currency and minor units

- Authoritative amounts are integer **minor units** plus an ISO currency code.
- For **BWP**, `1.00` pula is `100` thebe. Display uses two decimal places.
- The business currency is stored on `businesses.currency_code` (default `BWP`). A transaction is stored in that currency and cannot silently change it.
- Binary `double` is not used for arithmetic or persistence.
- Display formatting is separate from arithmetic. Totals are never summed from formatted strings.
- Future currencies may use a different minor-unit scale. Phase 4 formatters assume two decimals, which is correct for BWP, ZAR, NAD and USD as offered in onboarding. Do not treat that as a universal rule.

Single-transaction limit: `1` to `99_999_999_999_999` minor units (BWP `0.01` to `999,999,999,999.99`). Totals that would overflow signed 64-bit storage are rejected.

## Transaction types

| Type                 | User meaning                                | Recorded sales | Operating expense | Cash if paid |
| -------------------- | ------------------------------------------- | -------------- | ----------------- | ------------ |
| `sale`               | Money earned from selling goods or services | + amount       | no                | + amount     |
| `expense`            | Operating cost of running the business      | no             | + amount          | − amount     |
| `refund`             | Money returned to a customer                | − amount       | no                | − amount     |
| `owner_contribution` | Owner puts personal money into the business | no             | no                | + amount     |
| `owner_withdrawal`   | Owner takes money out of the business       | no             | no                | − amount     |

Opening cash (`businesses.opening_balance_minor`) is a starting position. It is **not** a transaction, **not** a sale and **not** revenue.

## Payment status

| Status   | Meaning                                     |
| -------- | ------------------------------------------- |
| `paid`   | Cash (or cash-equivalent) has already moved |
| `unpaid` | Recorded, but cash has not moved yet        |

- An unpaid sale is recorded revenue, not cash received.
- An unpaid expense is a recognised operating cost for the period, not a cash outflow.
- Partial payments are not modelled. A transaction is fully paid or fully unpaid.
- Payment method (`cash`, `mobile_money`, `bank_transfer`, `other`) is descriptive. It does not change the cash rule; `payment_status` does.

## Period and timezone

- Business calendar: **Africa/Gaborone** (UTC+2, no daylight-saving time).
- A dashboard/history period is `[startInclusive, endExclusive)` in UTC, aligned to Gaborone calendar days.
- Default dashboard period: the current Gaborone calendar month.
- A transaction dated on the first or last day of the period is included.
- A transaction at the exclusive end instant belongs to the next period.

## Formulas

Let `T` be confirmed transactions for the authorised business, after removing duplicates by `id`. Pending or unconfirmed rows are never included. Deleted rows are gone.

**Recorded sales (period)**  
Sum of `sale` amounts whose `occurred_at` falls in the period, in the business currency.

**Recorded refunds (period)**  
Sum of `refund` amounts in the period.

**Net recorded sales (period)**  
Recorded sales − recorded refunds.

**Recorded operating expenses (period)**  
Sum of `expense` amounts in the period, paid and unpaid.

**Net recorded operating result (period)**  
Net recorded sales − recorded operating expenses.

This is **not** audited profit, taxable income, or cash on hand. It excludes owner movements, opening cash, unrecorded costs, tax, inventory COGS (informational only in Phase 6) and any amount in another currency.

**Current recorded cash position**  
Opening cash

- paid sales
- paid owner contributions  
  − paid expenses  
  − paid owner withdrawals  
  − paid refunds

Unpaid rows do not affect cash. Opening cash is included here and excluded from sales. This figure is only as complete as the records the owner has entered.

**Example (spec fixture, all paid, BWP):**

```text
Opening cash              2,000.00
Cash sale                   500.00
Cash operating expense      100.00
Owner contribution          200.00
Owner withdrawal             50.00
──────────────────────────────────
Current recorded cash     2,550.00
Recorded sales              500.00
Recorded operating expenses 100.00
Net recorded operating result 400.00
```

`2,000 + 500 − 100 + 200 − 50 = 2,550`. The contribution is not sales. The withdrawal is not an operating expense.

## What this phase does not calculate

Do not display these as verified facts:

- Tax
- Profit margin
- Inventory cost of goods sold as an operating expense (Phase 6 snapshots unit cost on sale lines but does not post COGS)
- Formal profit after unmodelled costs
- Bank-confirmed cash
- Outstanding customer debt beyond unpaid recorded sales
- Multi-currency converted totals
- Expected customer receipts on a particular date
- Report packs (Phase 8)

If a mixed-currency row is present in a summary input, it is excluded from the total and counted as `skippedMixedCurrency`. The UI must not present a mixed total as a single BWP figure.

## Upcoming commitments (Phase 5)

An obligation is a planned payment (`rent`, `supplier`, `loan`, `utilities`, `wages`, `other`). Status is stored as `unpaid`, `paid` or `cancelled`. Overdue is derived: unpaid and `due_date` before the business calendar day of `asOf`.

- An unpaid commitment is **not** a recorded expense.
- An unpaid commitment does **not** reduce current recorded cash.
- Marking a commitment paid does **not** create an expense or move cash. Record an expense separately if money left the business.
- Cancelled and paid commitments are excluded from the cash estimate.
- **Estimated cash after unpaid commitments** = current recorded cash − unpaid (upcoming + overdue) commitment amounts. This is labelled an estimate and is not guaranteed future cash. It never invents future sales.
- Unpaid recorded expenses stay in the period operating result and are not listed again as upcoming bills.

Phase 5’s lump-sum **estimated cash after unpaid commitments** remains available as `CashOutlookEngine`. Phase 7 adds horizon-scoped forecasts on top of the same unpaid-commitment inputs.

## Inventory (Phase 6)

Stock is a movement ledger. The product `stock_quantity_milli` column is the derived on-hand balance and is not client-writable.

**Quantity:** integer milli-units. `1000` = 1 unit. `each` and `pack` must be whole units. Kilogram, litre and metre may use up to three decimal places.

**Costing:** weighted-average unit cost on the product card when stock is received or opening stock is recorded with a cost. Historical sale lines store the unit selling price and unit cost that were current at the time of the sale. Later cost edits do not rewrite those snapshots.

**Estimated inventory value:** sum of `recorded cost × quantity` for active products that have a cost. Products with no cost are excluded and counted. This estimate is not cash, sales, profit, or a recorded operating expense.

**Sales:** a product sale is still one `transactions` row of type `sale`. Paid product sales increase recorded cash; unpaid product sales increase recorded sales and not cash. Stock decreases for both. Amount-only sales with no `sale_items` keep their previous behaviour. Deleting a product sale reverses its stock movements. Line quantities cannot be edited after save.

**Returns:** a resellable customer return increases stock. A damaged return is stored with quantity delta `0` (history only). Record a refund transaction separately if money was returned. Damaged/lost stock decreases available units and requires a reason.

**Oversell:** rejected. Backorders are not enabled.

**Idempotency:** stock movements and product sales use a unique `(business_id, idempotency_key)`. Retries return the existing row.

## Short-term cash forecasts (Phase 7)

`CashForecastEngine` projects known unpaid commitments over inclusive local calendar windows: 7, 14 or 30 days, from the business-zone wall date of `asOf` through `asOfDate + (dayCount − 1)`. Botswana uses Africa/Gaborone. Amounts stay integer minor units.

| Figure                                 | Source                                                                                 | Recorded or estimate      |
| -------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------- |
| Current recorded cash                  | `FinancialEngine` all-time paid movements + opening cash                               | Recorded                  |
| Expected incoming                      | Always `0` in this phase                                                               | Not forecast              |
| Overdue commitments                    | Unpaid, due before `asOfDate`, same currency                                           | Known, not yet cash       |
| Upcoming in the window                 | Unpaid, due from today through horizon end                                             | Known, not yet cash       |
| Upcoming after the window              | Unpaid, due after horizon end                                                          | Disclosed, not subtracted |
| Estimated cash after known commitments | Recorded cash − overdue − upcoming-in-window                                           | Estimate                  |
| Daily path                             | Running recorded cash minus overdue on day 0, then amounts due on each later wall date | Estimate                  |

Rules:

- Do not subtract unpaid commitments from recorded cash.
- Do not treat unpaid sales as receipts. The model has no customer payment due date, so incoming cash is not invented.
- Do not treat inventory valuation as cash.
- Do not subtract unpaid recorded expenses again as dated outflows; they stay in the period operating result.
- Paid and cancelled commitments, paid expenses, and duplicate ids are not projected outflows.
- Mixed-currency commitment rows are skipped and counted.
- A 5,000-row history cap is labelled incomplete; the engine does not invent the missing history.
- If there are no unpaid commitments in the window, estimated cash equals recorded cash. That is still not a sales forecast.
- The first date projected cash is negative is an estimate from saved commitments only.

Default dashboard horizon is 14 days. Switching horizon only changes which unpaid due dates fall inside the window.

## Recommendations (Phase 7)

Recommendations are derived from current records. `public.recommendations` and Drift `cached_recommendations` store `rule_key`, `condition_key`, status, ownership and timestamps — not titles, amounts, or personal data.

| Rule                           | Fires when                                                                 | Severity |
| ------------------------------ | -------------------------------------------------------------------------- | -------- |
| `overdue_commitments`          | Unpaid commitments past due                                                | high     |
| `cash_shortfall`               | 14-day known outflows leave estimated cash ≤ 0                             | high     |
| `tight_cash_after_commitments` | After 14-day known bills, remaining cash is > 0 and < 20% of recorded cash | medium   |
| `expenses_exceed_sales`        | Last completed calendar month has activity and net operating result < 0    | medium   |
| `low_stock`                    | At least two active products at or below restock threshold                 | medium   |
| `incomplete_product_cost`      | At least one active product has no recorded cost                           | low      |

Lifecycle:

- Unique `(business_id, rule_key)` so a refresh does not insert a second active row.
- Dismissal is kept while `condition_key` is unchanged.
- A new fingerprint (different overdue ids, different products, different period) reactivates a dismissed row.
- When the rule no longer fires, status becomes `resolved`. It can become `active` again later.
- Empty businesses do not receive scare copy.
- Language uses “estimate” and “saved records”. It is not accounting, tax or investment advice.

## Idempotency

Each create uses a client-generated `idempotency_key` unique per business. The form keeps that key for retries of the same save. The database unique constraint `(business_id, idempotency_key)` plus “on conflict, return the existing row” prevents duplicate inserts after a timeout. Edits keep the existing `id` and do not mint a new row.

## Offline / cache policy (Phase 4)

- **Writes are online-only.** A save, edit or delete is confirmed only after Supabase accepts it. There is no durable write-outbox in this phase (that is Phase 8). The same rule applies to products, stock movements, product sales and recommendation status.
- **Reads may use Drift.** Confirmed transactions, obligations, products, stock movements and recommendation status are cached per `owner_id` + `business_id`. A failed refresh keeps the last confirmed cache and labels it stale. A failed refresh never wipes cache. Forecasts are recalculated from those records and are not cached as a separate table.
- Cached rows are never shown as server-confirmed when the snapshot is stale.
- Sign-out clears in-memory transaction state. On-disk rows stay keyed by owner; the next account cannot read them because queries require the current owner id.
- Demo/local preview never writes to Supabase.

## Ownership

RLS on `public.transactions` allows an authenticated user to select, insert, update or delete a row only when `businesses.owner_id = auth.uid()` for that `business_id`. `created_by` is forced to `auth.uid()` on insert. `business_id`, `created_by`, `currency_code` and `idempotency_key` cannot be reassigned on update.

The same ownership function scopes `products`, `sale_items`, `stock_movements`, and `recommendations`. Authenticated clients cannot insert sale lines or stock movements directly. Product `stock_quantity_milli` cannot be changed by an ordinary update. Recommendation `business_id`, `created_by`, and `rule_key` cannot be reassigned on update.
