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

Phase 6 RLS catalog (21 Oct 2026, re-checked 21 Oct 2026 during Phase 7, live two-user replay 24 Oct 2026): FORCE RLS on `products`, `sale_items`, and `stock_movements`. Anon has no select/insert/update/delete/truncate. Authenticated can select/insert/update/delete products and cannot TRUNCATE. Authenticated can select `sale_items` and `stock_movements` and cannot insert or TRUNCATE them. Writes go through `create_catalog_product`, `record_stock_movement`, and `record_product_sale`. On 24 Oct 2026 two confirmed Auth users (`kgwebo.phase8.a.*` / `kgwebo.phase8.b.*`) signed in through GoTrue password grant and called PostgREST with their access tokens: B could not select A's products, sale items, stock movements or recommendations; B could not mutate A's rows. Service-role was not used as a user-level identity. Concurrent last-unit oversell (qty 1 remaining): one request returned 200 and the other 400 “not enough stock”; remaining stock 0; two sales only. A Postgres 17 `bit(128)::uuid` failure in `record_product_sale` was patched first (`private.uuid_from_md5`, remote migration `uuid_from_md5`).

Phase 7 minimum: `CashForecastEngine` inclusive 7/14/30 local-day windows; recorded cash unchanged by unpaid bills; unpaid sales not treated as receipts; inventory value not treated as cash; overdue vs upcoming vs beyond-horizon; paid/cancelled excluded; no double-count of paid expenses; incomplete history labelled; recommendation rules fire only on evidence; lifecycle insert/dedupe/dismiss/resolve/reactivate; Drift owner isolation and stale cache; dashboard horizon switch (14-day bill excluded from 7 days); failed recommendation refresh is not an empty list; recommendations screen usable at 320×568 with keyboard inset; Outlook tab layouts at 320×568, 360×800, 800×360, 768×1024, 1024×768.

Phase 7 RLS catalog (21 Oct 2026, live two-user replay 24 Oct 2026): FORCE RLS on `recommendations`. Anon has no select/insert/update/delete/truncate. Authenticated has select/insert/update/delete and not TRUNCATE. Policies `recommendations_select_own`, `recommendations_insert_own`, `recommendations_update_own`, `recommendations_delete_own`. Two confirmed Auth users with JWTs: B could not select or mutate A's recommendations. Flutter fakes are still not a substitute for that live check.

Phase 8 minimum: Drift v6 outbox persist after close/reopen; duplicate enqueue; owner/business isolation of queued rows; interrupted `syncing` recovery; automatic retry pause then manual retry; coordinator ordering and dependency wait; timeout-after-commit retries the same idempotency key without a second row; network loss before commit then later success; permanent validation quarantined; other-owner/sign-out skip; cached create queues on retryable failure and does not cache as confirmed; list reconcile hides pending when the server copy arrives; engine totals ignore pending; unpaid pending sales are not cash; pending commitments are not expenses or outlook inputs; sync-queue empty and action-required UI with text status (not colour only); dashboard/Cash Flow show confirmed Drift cache immediately while a remote refresh is pending; cached commitments remain visible when refresh fails; stale-cache copy is distinct from pending synchronisation; cache stays owner-scoped after an account switch; Settings pending-review control does not overflow at 320×568. Widget tests use fakes, Completers instead of sleeps, and an in-memory Drift database.

Phase 8 security/concurrency (24 Oct 2026): two-user JWT isolation for products, sale_items, stock_movements and recommendations **passed** with real authenticated sessions. Two-client last-unit oversell **passed** after `private.uuid_from_md5`. Product sales and stock writes remain online-only because stock is server-authoritative and `record_product_sale` is atomic, not because isolation is unproven. Throwaway Phase 8 test users and businesses were left on the project after the audit and should be removed when no longer needed.

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

## 8b. Android manual checklist (Phase 8 offline writes)

Executed 24 Oct 2026 on API 37 emulator `emulator-5554` (compact 1080×2340, no physical handset) against isolated businesses **Phase 8 Stall A / B**. Do not treat this as a physical-device pass.

| #   | Check                                                 | Result                                                                                                                                                                                                | Evidence                                                                                                                                                                                |
| --- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Airplane-mode amount-only sale                        | **PASS**                                                                                                                                                                                              | Sale of P 77.00 saved on-device while `ping 8.8.8.8` was unreachable.                                                                                                                   |
| 2   | Pending sale excluded from confirmed cash/totals      | **PASS**                                                                                                                                                                                              | Banner “1 change waiting to sync”; cash stayed P 2,025.00; sales stayed P 25.00.                                                                                                        |
| 3   | Offline unpaid commitment excluded from cash/forecast | **PASS**                                                                                                                                                                                              | OfflineQARent P 88.00 Unpaid; 14-day estimate stayed P 2,025.00.                                                                                                                        |
| 4   | Force-stop then reopen; pending persist               | **PASS**                                                                                                                                                                                              | After `am force-stop`, both the P 77.00 sale and OfflineQARent remained with “Sync failed and will retry”; cash still P 2,025.00.                                                       |
| 5   | Restore connectivity; each op syncs once              | **PASS**                                                                                                                                                                                              | After A signed back in online: cash P 2,102.00 (= 2025+77); sales P 102.00; forecast P 2,014.00 (= 2102−88). Server count: one `amount_minor=7700` row, one `OfflineQARent` obligation. |
| 6   | Timeout after server commit, no duplicate             | **NOT TESTED** on device. Covered by `sync_coordinator_test` (“retries with the original idempotency key after a timeout”) and unique `(business_id, idempotency_key)`.                               |
| 7   | History shows confirmed records, no duplication       | **PASS**                                                                                                                                                                                              | One confirmed “Sale · +P 77.00”; one “OfflineQARent · Unpaid · P 88.00”. `loadMore` now re-merges pending vs confirmed so a later page cannot keep both.                                |
| 8   | Product sales and stock writes stay online-only       | **PASS**                                                                                                                                                                                              | Product create: “Check your connection and try again.” Product-line sale: “Product sales need a live connection. Stock is not queued offline.” Pending count stayed 2.                  |
| 9   | Sign out/in as original owner; pending remain         | **PASS**                                                                                                                                                                                              | After B, A’s cash/sales absorbed the queued P 77.00 once. Queue was not lost or applied to B. Pending list was already empty on A because connectivity was restored at sign-in.         |
| 10  | Other owner cannot see or submit A’s queue            | **PASS**                                                                                                                                                                                              | Stall B: “No transactions yet”, Settings “Nothing waiting”, cash P 1,000.00, no OfflineQARent.                                                                                          |
| 11  | Settings → Pending changes readable states            | **PASS** for retryable (“Sync failed and will retry”, “Retry now”, connection error). **NOT TESTED** for action-required/permanent on device (widget coverage exists). After sync: “Nothing waiting”. |
| 12  | Stale-cache vs pending-sync banners distinct          | **PASS**                                                                                                                                                                                              | Simultaneous “N changes waiting to sync…” and “Showing saved transactions/figures/stock from this device…”.                                                                             |

Do not mark Phase 8 completely verified: item 6 was not executed on a device, action-required was not produced on a device, no physical handset was used, and report PDF remains outstanding.

## 8c. Phase 8 closure evidence split (24 Oct 2026)

- **Automated tests passed:** `dart format --set-exit-if-changed .`; `flutter analyze` (no issues); `flutter test` (355 passed after the history-merge follow-up). Debug APK `e:\Personal Apps\Kgwebo\build\app\outputs\flutter-apk\app-debug.apk` (122,791,753 bytes, 24 Oct 2026 09:37, includes `mergeHistoryPages`).
- **Manual device tests passed:** items 1–5, 7–10, 12, and retryable copy in 11, on emulator `emulator-5554` only.
- **Live security tests passed:** two-user JWT isolation for products, sale_items, stock_movements, recommendations; two-client last-unit oversell after `uuid_from_md5`.
- **Blocked or not executed:** device timeout-after-commit (item 6); device permanent/action-required queue state; physical handset; in-app report PDF.
- **Known limitations:** product details `findById` failed offline (“Product not found”) even though the list showed a cached product. Residual code risks not closed in this follow-up: an in-flight owner switch can mark a valid op permanent, overlapping `process()` after owner change can drop `_runAgain`, and `requestManualRetry` is not owner-scoped (listing still cannot leak).

## 8d. Offline reopen UX polish (24 Oct 2026)

Automated coverage only. No physical-device QA and no timeout-after-commit device run were repeated in this pass.

- Dashboard and Cash Flow load owner-scoped confirmed Drift cache immediately, then refresh from Supabase. Completer-gated widget tests cover cached cash while remote is pending, cached commitments remaining after a failed refresh, stale-cache vs pending-sync banners, pending rows excluded from confirmed cash, and cache isolation after an account switch.
- Settings → Pending changes uses a filled, wrapping layout. Widget tests at 320×568 (compact shell) and 1024×768 assert no overflow and that “Review pending changes” stays on-screen.
- Quality gates (24 Oct 2026): `dart format --set-exit-if-changed .` pass; `flutter analyze` no issues; `flutter test` 384 passed; debug APK `E:\Personal Apps\Kgwebo\build\app\outputs\flutter-apk\app-debug.apk` (122,812,093 bytes, 24 Oct 2026 18:27). Report PDF remains out of scope. Physical-device QA and timeout-after-commit device testing were not repeated.

Do not mark a phase complete if these commands were not run or if they failed.

## 7. Environment notes

- Unit and widget tests must not require a live network by default.
- Tests that hit Supabase are tagged and skipped when credentials are absent.
- Demo seed data is allowed only in explicit demo tests and the labelled demo mode.
- Android licenses were incomplete at the original audit. An API 37 x86_64 emulator (`emulator-5554`) was used on 21 Oct 2026 (Phase 7) and 24 Oct 2026 (Phase 8 offline-write QA, compact 1080×2340). No physical handset was attached.
