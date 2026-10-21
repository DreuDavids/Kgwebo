# Kgwebo Test Plan

**Source of truth:** `docs/MASTER_PROJECT_SPEC.md`  
**Commands:** `dart format`, `flutter analyze`, `flutter test`, and targeted files under `test/` and `integration_test/`.  
**Rule:** A test is only reported as passing after it is executed in this workspace and the output is inspected. A successful build is not proof of correctness.

## 1. Layers

| Layer          | What it proves                                                                               | Location                                                 |
| -------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Unit           | Money, rounding, period totals, forecast, recommendations, validators                        | `test/core/`, `test/features/**/domain/`                 |
| Widget         | Forms, empty/error/loading, semantics, responsive shell, no overflow                         | `test/app/`, `test/shared/`, `test/features/**/`         |
| Persistence    | Drift writes, idempotency, opening-balance treatment                                         | `test/core/persistence/`                                 |
| Backend        | Constraints, RLS, unauthorized access                                                        | SQL against `hhwxajxjmyjntxykptvs` once migrations exist |
| Integration    | Register → profile → sale → expense → product sale → dashboard → forecast → report → restart | `integration_test/` when a device is available           |
| Manual Android | Insets, keyboard, font scale, emulator profiles                                              | Device/emulator, recorded in limitations if skipped      |

## 2. Financial fixtures

All money in tests is integer minor units. BWP uses two decimals: `P 2,000.00` = `200000`.

### 2.1 Spec cash position

| Input                  | Minor units |
| ---------------------- | ----------- |
| Opening cash           | 200000      |
| Cash sale              | 50000       |
| Cash operating expense | 10000       |
| Owner contribution     | 20000       |
| Owner withdrawal       | 5000        |
| **Expected cash**      | **255000**  |

Independent check: `2000 + 500 − 100 + 200 − 50 = 2550` pula.

Must also assert:

- Revenue = 50000 (contribution excluded)
- Operating expenses = 10000 (withdrawal excluded)
- Opening cash is not revenue

### 2.2 Additional engine cases

- Decimal amounts that would fail in binary floating point (`0.10 + 0.20`)
- Negative operating profit
- Refund reduces revenue and cash consistently
- Unpaid expense does not reduce current cash and does appear as an upcoming obligation
- Editing or deleting a sale recalculates cash and period totals
- Duplicate idempotency keys insert one transaction
- Date boundaries use `Africa/Gaborone`
- Product sale COGS uses snapshotted unit cost after a later cost edit
- Oversell rejected when backorders are disabled
- Forecast never writes over actuals and never invents sales

## 3. Feature acceptance mapping

| Feature           | Automated evidence                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| A Onboarding      | First launch, skip, persist input across rebuild, compact-width CTA visible                       |
| B Auth            | Valid/invalid register and login, logout, restore, reset request, guard on protected routes       |
| C Business        | Create, reopen, edit existing row, opening cash excluded from sales, stale cache labelled         |
| D Dashboard       | Seeded totals match engine; empty setup state; period changes; failed save does not change totals |
| E Transactions    | Validation, single save on repeated tap, edit/delete, refunds, owner flows, timezone period       |
| F Products        | Persist, stock delta, low-stock threshold, historical cost freeze                                 |
| G Engine          | Section 2 fixtures                                                                                |
| H Forecast        | Known due dates, shortage date, overdue, incomplete-data copy                                     |
| I Recommendations | Trigger / non-trigger per rule, evidence ids, dismiss window, no empty-data scare                 |
| J AI entry        | Out of MVP unless added later                                                                     |
| K Reports         | Figures equal engine; empty, negative profit, long name                                           |
| L Offline         | Local record survives process restart; retry does not duplicate                                   |
| M History         | Combined filters against known rows                                                               |
| N Settings        | Working actions only; sign-out clears session                                                     |

## 4. Responsive widget matrix

Render key screens at logical sizes `{320, 390, 600, 840, 1024}` in portrait and `{640, 900}` in landscape, and at text scaler `1.0` and `1.3`.

Screens: onboarding, login, dashboard, business profile, business edit, sale form, expense form, product form, cash-flow, history, report preview, settings.

Fail the test on exceptions, `RenderFlex` overflow, missing primary action, or non-scrollable keyboard obstruction where the harness can detect it.

## 5. Security tests

After migrations on `hhwxajxjmyjntxykptvs`:

- User A cannot select, insert, update, or delete user B's business, transactions, products, obligations, or recommendations.
- Anon role cannot read business tables.
- Service role is not present in the Flutter app or committed files.

## 6. Phase exit checks

After every meaningful stage:

```text
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Phase 1 minimum: design-system widgets, breakpoint helper, shell navigation, env missing-config behaviour.

Phase 2 minimum: email/password validators, `redirectFor` policy, session restore/sign-out with fakes, form validation, password visibility, reset request, onboarding validation, live-guest route guard, demo isolation, and the Phase 1 regression suite. Widget tests must not use a live production account.

Phase 3 minimum: remote/local mapping, opening-cash preservation, business update without insert, Drift insert/update/owner filter/empty DB/unverified rows, cache fallback vs missing-cache network failure, account switching, sign-out cache retention, profile view/edit/validation/save/cancel/loading/stale/offline copy, and the listed viewport sizes. Widget tests use fakes, not production credentials.

Phase 4 minimum: `FinancialEngine` spec cash fixture and related cases; sale/expense create; update keeps id; delete; idempotent retry; cache preserved after failed read; owner isolation in the repository; sale/expense form validation and duplicate-tap guard; history empty/populated; delete confirmation; dashboard loading/empty/stale/populated/failed-load. Widget tests use fakes, not production credentials.

RLS verification on `hhwxajxjmyjntxykptvs` (21 Oct 2026): User B could not select, update, or delete User A's business; inserts by B could not keep `owner_id` = A (trigger forced `auth.uid()`); anon has no SELECT on `profiles` or `businesses`.

Phase 4 RLS catalog (21 Oct 2026): `public.transactions` has FORCE RLS; anon has no select/insert/update/delete; authenticated has those four privileges; policies `transactions_select_own`, `transactions_insert_own`, `transactions_update_own`, `transactions_delete_own` exist.

Phase 5 minimum: period helpers (this/last month, last 3 months, this year, custom inclusive days); engine last-month vs this-month and unpaid-refund cases; cash outlook (unpaid commitments do not change recorded cash, overdue vs upcoming, paid/cancelled excluded, mixed currency skip); unpaid commitment is not an operating expense; marking paid does not create an expense; recording the matching expense does not double-count; empty businesses get no false loss insight; overdue copy does not call commitments operating expenses; dashboard period selector recalculates sales while cash stays all-time; unpaid commitment estimate is labelled; failed commitment refresh is not shown as zero unpaid bills; obligation validators, idempotent create, owner isolation, stale cache; form validation, duplicate-tap guard, and keyboard inset at 320×568; responsive dashboard including the cash-flow commitments screen at 320×568, 360×800, 800×360, 768×1024, 1024×768.

Phase 5 RLS (21 Oct 2026): FORCE RLS on `transactions` and `obligations`; anon has no select/insert/update/delete/truncate; authenticated has select/insert/update/delete and not truncate. Two dedicated Auth users signed in through GoTrue (`grant_type=password`) and called PostgREST with their access tokens: B saw 0 of A's rows; B insert against A's `business_id` returned 400; B update/delete of A's rows affected 0 rows; `created_by` was forced to `auth.uid()`; duplicate idempotency keys returned 409; A's own inserts and reads succeeded. Service-role was not used as a test identity. Throwaway users and their businesses were deleted after the run.

Phase 6 minimum: product validators; milli-unit parse/format; zero stock is out of stock even when the threshold is 0; weighted-average cost; missing cost excluded from estimated value; snapshot COGS after a later cost change; oversell rejected; resellable vs damaged returns; reversal restores stock; failed multi-line sale leaves no partial rows; unpaid product sales increase recorded sales not cash; product sale counted once in the engine; Drift owner/business isolation and stale cache; product form validation and duplicate-tap guard; stock write-off confirmation; product list usable at 320×568; sale form product line uses the inventory RPC; dashboard restock notice is not treated as cash.

Phase 6 RLS catalog (21 Oct 2026, re-checked 21 Oct 2026 during Phase 7): FORCE RLS on `products`, `sale_items`, and `stock_movements`. Anon has no select/insert/update/delete/truncate. Authenticated can select/insert/update/delete products and cannot TRUNCATE. Authenticated can select `sale_items` and `stock_movements` and cannot insert or TRUNCATE them. Writes go through `create_catalog_product`, `record_stock_movement`, and `record_product_sale`. Two-user JWT isolation for inventory was not re-run: the live project has one Auth user. Concurrent oversell was not replayed with two clients; `record_product_sale` locks matching products `FOR UPDATE` in id order before decreasing stock.

Phase 7 minimum: `CashForecastEngine` inclusive 7/14/30 local-day windows; recorded cash unchanged by unpaid bills; unpaid sales not treated as receipts; inventory value not treated as cash; overdue vs upcoming vs beyond-horizon; paid/cancelled excluded; no double-count of paid expenses; incomplete history labelled; recommendation rules fire only on evidence; lifecycle insert/dedupe/dismiss/resolve/reactivate; Drift owner isolation and stale cache; dashboard horizon switch (14-day bill excluded from 7 days); failed recommendation refresh is not an empty list; recommendations screen usable at 320×568 with keyboard inset; Outlook tab layouts at 320×568, 360×800, 800×360, 768×1024, 1024×768.

Phase 7 RLS catalog (21 Oct 2026): FORCE RLS on `recommendations`. Anon has no select/insert/update/delete/truncate. Authenticated has select/insert/update/delete and not TRUNCATE. Policies `recommendations_select_own`, `recommendations_insert_own`, `recommendations_update_own`, `recommendations_delete_own`. Two-user JWT isolation was not executed: one Auth user and one business exist; new sign-ups require email OTP confirmation. Flutter fakes do not prove database isolation.

## 8. Android manual checklist (Phase 7)

Run on a phone or emulator after a debug APK built with `--dart-define-from-file=.env`. Do not claim a physical device pass if only an emulator was used.

- [ ] Portrait dashboard Overview: recorded cash first; opening cash labelled as not revenue; compact bottom bar (Home / Activity / Products / More).
- [ ] Outlook tab: 7 / 14 / 30 day chips; recorded cash unchanged; estimate labelled; incoming cash copy says it is not forecast; no decorative chart when there are no dated outflows.
- [ ] Add an unpaid commitment due in 10 days: 14-day estimate subtracts it; 7-day estimate does not; beyond-horizon copy appears on 7 days.
- [ ] Overdue commitment: recommendation with evidence; dismiss on Recommendations; pull-to-refresh does not bring the same condition back; a new overdue bill may.
- [ ] Products: catalogue, search, filters, stock overview labelled as an estimate. Two low-stock products surface a restock recommendation.
- [ ] Product form and stock receipt/adjustment: keyboard does not overflow; write-offs ask for a reason and confirmation.
- [ ] Sale form: amount-only sale still works; adding a product decreases stock once; unpaid product sale does not increase cash.
- [ ] Expense form: labelled as an operating expense; same keyboard behaviour.
- [ ] More → Cash Flow: horizon chips; unpaid bills are not expenses; empty commitments do not invent bills.
- [ ] More → Cash Flow → Recommendations: failed refresh is not an empty-success state; disclaimer is visible.
- [ ] Commitment form: planned-payment copy; keyboard keeps the focused field usable.
- [ ] Landscape: navigation rail appears at width ≥ 600; Cash Flow, dashboard Outlook and Recommendations remain scrollable.
- [ ] Airplane mode / failed refresh: last saved cash, products and recommendation status remain; stale/error copy appears; stock and forecasts are not presented as unquestionably current.
- [ ] Cancel form edits without saving if using a live account.

Do not mark a phase complete if these commands were not run or if they failed.

## 7. Environment notes

- Unit and widget tests must not require a live network by default.
- Tests that hit Supabase are tagged and skipped when credentials are absent.
- Demo seed data is allowed only in explicit demo tests and the labelled demo mode.
- Android licenses were incomplete at the original audit. An API 37 x86_64 emulator (`emulator-5554`) was available on 21 Oct 2026. The Phase 7 debug APK installed and launched to the welcome screen. No physical handset was attached. Signed-in forecast and recommendation QA on device remains a manual checklist.
