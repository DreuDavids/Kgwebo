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

Phase 4 RLS catalog (21 Oct 2026): `public.transactions` has FORCE RLS; anon has no select/insert/update/delete; authenticated has those four privileges; policies `transactions_select_own`, `transactions_insert_own`, `transactions_update_own`, `transactions_delete_own` exist. Two-user payload tests were not run (no staging users). Repeat `supabase/tests/rls_transactions.sql` with two Auth users before claiming empirical cross-account isolation.

Phase 5 minimum: period helpers (this/last month, last 3 months, this year, custom inclusive days); engine last-month vs this-month and unpaid-refund cases; cash outlook (unpaid commitments do not change recorded cash, overdue vs upcoming, paid/cancelled excluded, mixed currency skip); empty businesses get no false loss insight; overdue copy does not call commitments operating expenses; dashboard period selector recalculates sales while cash stays all-time; unpaid commitment estimate is labelled; obligation validators, idempotent create, owner isolation, stale cache; form validation and duplicate-tap guard; responsive dashboard including the cash-flow commitments screen at 320×568, 360×800, 800×360, 768×1024, 1024×768.

Phase 5 RLS catalog (21 Oct 2026): `public.obligations` has FORCE RLS; anon has no select/insert/update/delete; authenticated can select/insert; policies `obligations_select_own`, `obligations_insert_own`, `obligations_update_own`, `obligations_delete_own` exist. Two-user payload tests for transactions and obligations were not run (no staging users). Repeat `supabase/tests/rls_transactions.sql` and `supabase/tests/rls_obligations.sql` with two Auth users before claiming empirical cross-account isolation.

Do not mark a phase complete if these commands were not run or if they failed.

## 7. Environment notes

- Unit and widget tests must not require a live network by default.
- Tests that hit Supabase are tagged and skipped when credentials are absent.
- Demo seed data is allowed only in explicit demo tests and the labelled demo mode.
- Android licenses were incomplete at audit; emulator tests may be blocked until licenses are accepted or a device is attached.
