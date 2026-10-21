# Kgwebo financial-domain model (Phase 4–5)

Grounded in the repository on 21 October 2026. Remote public tables at that time were only `profiles` and `businesses`. There was no `transactions` table until the Phase 4 migration.

This document is the accounting contract for recorded sales, expenses, owner cash movements and dashboard totals. Widgets and Supabase clients must not invent a second set of rules.

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

This is **not** audited profit, taxable income, or cash on hand. It excludes owner movements, opening cash, unrecorded costs, tax, inventory COGS (Phase 6) and any amount in another currency.

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
- Inventory cost of goods sold
- Formal profit after unmodelled costs
- Bank-confirmed cash
- Outstanding customer debt beyond unpaid recorded sales
- Multi-currency converted totals
- 7/14/30 day forecasts, persisted recommendations, or report packs (later phases)

If a mixed-currency row is present in a summary input, it is excluded from the total and counted as `skippedMixedCurrency`. The UI must not present a mixed total as a single BWP figure.

## Upcoming commitments (Phase 5)

An obligation is a planned payment (`rent`, `supplier`, `loan`, `utilities`, `wages`, `other`). Status is stored as `unpaid`, `paid` or `cancelled`. Overdue is derived: unpaid and `due_date` before the business calendar day of `asOf`.

- An unpaid commitment is **not** a recorded expense.
- An unpaid commitment does **not** reduce current recorded cash.
- Marking a commitment paid does **not** create an expense or move cash. Record an expense separately if money left the business.
- Cancelled and paid commitments are excluded from the cash estimate.
- **Estimated cash after unpaid commitments** = current recorded cash − unpaid (upcoming + overdue) commitment amounts. This is labelled an estimate and is not guaranteed future cash. It never invents future sales.
- Unpaid recorded expenses stay in the period operating result and are not listed again as upcoming bills.

Phase 7 still owns 7/14/30 day forecasts and persisted, dismissible recommendations.

## Idempotency

Each create uses a client-generated `idempotency_key` unique per business. The form keeps that key for retries of the same save. The database unique constraint `(business_id, idempotency_key)` plus “on conflict, return the existing row” prevents duplicate inserts after a timeout. Edits keep the existing `id` and do not mint a new row.

## Offline / cache policy (Phase 4)

- **Writes are online-only.** A save, edit or delete is confirmed only after Supabase accepts it. There is no durable write-outbox in this phase (that is Phase 8).
- **Reads may use Drift.** Confirmed transactions are cached per `owner_id` + `business_id`. A failed refresh keeps the last confirmed cache and labels it stale. A failed refresh never wipes cache.
- Cached rows are never shown as server-confirmed when the snapshot is stale.
- Sign-out clears in-memory transaction state. On-disk rows stay keyed by owner; the next account cannot read them because queries require the current owner id.
- Demo/local preview never writes to Supabase.

## Ownership

RLS on `public.transactions` allows an authenticated user to select, insert, update or delete a row only when `businesses.owner_id = auth.uid()` for that `business_id`. `created_by` is forced to `auth.uid()` on insert. `business_id`, `created_by`, `currency_code` and `idempotency_key` cannot be reassigned on update.
