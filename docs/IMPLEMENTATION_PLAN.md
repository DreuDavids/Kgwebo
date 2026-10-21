# Kgwebo Implementation Plan

> Grounded in the repository as inspected on 21 October 2026 and in `docs/MASTER_PROJECT_SPEC.md`.

**Goal:** Deliver a working Android Flutter product a judge can install, with independently tested financial calculations and real persistence.

**Architecture:** Feature-oriented Flutter app, Riverpod, GoRouter, Drift for on-device records, Supabase for auth and cloud sync. Financial math lives in a pure Dart engine.

**Tech stack:** Flutter 3.29.2, Dart 3.7.2, Material 3 custom design system, Riverpod, GoRouter, Drift, Supabase, `intl`, `fl_chart`.

## Global constraints

- Flutter/Dart only for the application.
- Android layouts adapt to width, orientation, font scale, and insets. Orientation is not locked.
- No fake financial totals, fake buttons, or success messages for failed operations.
- Money uses integer minor units. `double` is not authoritative.
- Opening cash is not revenue. Owner flows are not operating sales/expenses.
- Unpaid obligations do not reduce current cash.
- Do not embed a Supabase service-role key.
- Do not claim tests passed unless they were executed and inspected.
- If a human decision or extra credential is missing, document the blocker and continue independent work.

## Repository facts

Inspected before implementation:

- The repo began as `docs/MASTER_PROJECT_SPEC.md` only.
- `flutter create . --org bw.kgwebo --project-name kgwebo --platforms android` produced the current Flutter tree.
- Default counter app and `test/widget_test.dart` still exist until Phase 1 replaces them.
- No feature code, Drift schema, or tests existed at audit.
- Flutter doctor: Android SDK 37, some licenses not accepted, no Android device currently connected.
- Supabase project **does exist** (correction from MCP):
  - MCP: `user-supabaseAndreuModise`
  - Name: `Kgwebo`
  - Ref: `hhwxajxjmyjntxykptvs`
  - URL: `https://hhwxajxjmyjntxykptvs.supabase.co`
  - Status: `ACTIVE_HEALTHY`
  - Public tables: `profiles`, `businesses`, `transactions`, `obligations`
  - Remote migrations: applied through Phase 5 (`obligations`)
- Publishable client keys are available. They belong in local `.env`, not in git.

MVP boundary for a demonstrable first slice:

1. Design system and responsive shell
2. Onboarding and authentication against the existing project
3. Business profile persistence
4. Sales, expenses, and the financial engine
5. Dashboard with real totals
6. Products and consistent stock
7. Cash-flow forecast and deterministic recommendations
8. Report preview/PDF and honest offline/pending status

Optional AI entry is deferred.

## File map

| Area                               | Path                    |
| ---------------------------------- | ----------------------- |
| Bootstrap / router / theme         | `lib/app/`              |
| Money, finance, errors, responsive | `lib/core/`             |
| Features                           | `lib/features/<name>/`  |
| Shared widgets                     | `lib/shared/widgets/`   |
| Drift database                     | `lib/core/persistence/` |
| Supabase SQL                       | `supabase/migrations/`  |
| Unit / widget tests                | `test/`                 |
| Integration tests                  | `integration_test/`     |

## Phase 0 — Audit — complete as of this document

- [x] Inspect repository
- [x] Record Flutter 3.29.2 / Dart 3.7.2
- [x] Confirm Android project `bw.kgwebo.kgwebo`
- [x] Locate Supabase project via MCP `user-supabaseAndreuModise`
- [x] Confirm public schema is empty
- [x] Write `docs/IMPLEMENTATION_PLAN.md`, `docs/TEST_PLAN.md`, `docs/ARCHITECTURE.md`

**Exit:** Plan matches the actual repository and the existing empty Kgwebo backend.

## Phase 1 — Foundation and design system — complete

Implemented in the existing Flutter tree (Flutter 3.29.2 / Dart 3.7.2). The counter demo is gone.

- Design tokens live in `lib/app/theme/` (colour, type, spacing, radii, elevation). Light mode only. Fraunces for brand/editorial; Plus Jakarta Sans for UI.
- `AppConfig` is a testable map-based abstraction. Load order: bundled `.env.example`, optional `.env` asset if present, then `--dart-define`. Service-role keys are rejected. Secrets never appear in `toString` or logs.
- Phase 1 does not initialise a Supabase client. Development missing-key → labelled local preview. Production/staging missing-key → blocking config screen. Demo only when `APP_ENV=demo`.
- GoRouter `StatefulShellRoute` with named routes for Dashboard, Transactions, Products, Cash Flow, Reports, Settings, plus compact-only More.
- Compact width (`< 600`) uses a 4-item bottom bar (Home, Activity, Products, More) so six destinations are not squeezed. `600–1023` uses a rail; `≥ 1024` an extended rail. Indexed stack preserves destination and text-field state across resize.
- Shared widgets: buttons, text field, section heading, empty state, loading state, status banner, metric card.
- Dashboard is a product-purpose shell. Metric tiles show em dashes and “preview, not live data” copy. Quick actions navigate; they do not fake saves.
- Tests: theme, config, env loader, routing, breakpoints, shared widgets, and dashboard/navigation at 320×568, 360×800, 800×360, 768×1024, 1024×768.

**Exit:** App shell starts; design system, routing, and configuration are covered by automated tests.

## Phase 2 — Onboarding and authentication — complete

Implemented against the existing Kgwebo Supabase project (`hhwxajxjmyjntxykptvs`).

- Welcome plus two skippable education screens, then email/password sign-up and sign-in.
- Session restore, sign-out, password-reset request, 6-character recovery OTP, recovery completion, and email-confirmation pending state with a 6-character signup OTP.
- `AppSession` + pure `redirectFor` policy. Live guests cannot open the shell. Preview (demo/local) still can, labelled.
- Supabase initialises only when `runtimeMode == live` and the publishable/anon key is valid. Demo never connects.
- `profiles` and `businesses` (one per owner) with RLS. Onboarding saves name, type, country (default BW), currency (default BWP), optional opening cash (not revenue) and description. Retries update the same row.
- Remote migrations applied: `profiles_and_businesses`, `fix_touch_updated_at_search_path`, `revoke_profile_insert`.
- Automated tests cover validators, session/routing policy, forms, preview isolation, and the Phase 1 regression suite.

**Exit:** Auth flows work; unauthenticated users cannot open business records.

## Phase 3 — Business profile and database — complete

Implemented against the existing Kgwebo schema. No new remote migration was required.

- Settings → Business profile view/edit at `/settings/business` and `/settings/business/edit`.
- Reuses `BusinessProfile`, `OnboardingDraft` and `OnboardingRepository`. Updates call `updateExisting` (never insert). Payloads omit `owner_id`.
- Drift schema v1 `cached_businesses`: unique remote id, unique owner, integer opening cash, `syncStatus = confirmed`.
- `CachedOnboardingRepository` wraps Supabase. Offline reads use confirmed cache and show a stale banner. Edits require a successful remote write.
- Opening cash is `opening_balance_minor` (integer thebe). UI labels it opening/starting cash, not revenue. No sale/transaction is created.
- Sign-out keeps on-disk cache by owner id and clears in-memory session/profile state.
- Remote catalog re-checked 21 Oct 2026: `businesses_one_per_owner UNIQUE (owner_id)`, RLS select/insert/update/delete own rows, owner trigger intact. No remote migration applied.

**Exit:** A user can reopen and edit their own profile. Opening cash is not treated as a sale.

Verification executed 21 Oct 2026:

- `dart format --set-exit-if-changed .` — pass
- `flutter analyze` — No issues found
- `flutter test` — All tests passed (126)
- `flutter build apk --debug` — `build\app\outputs\flutter-apk\app-debug.apk`
- Drift codegen: `dart run build_runner build` wrote `lib/core/persistence/kgwebo_database.g.dart`

## Phase 4 — Transactions and financial engine — complete

Implemented against the existing Kgwebo schema. `public.transactions` did not exist before this phase.

- Pure `Money` + `FinancialEngine` in `lib/core/`. Integer thebe, Africa/Gaborone periods, opening cash excluded from sales. Definitions: `docs/FINANCIAL_MODEL.md`.
- Remote table `public.transactions` with RLS, ownership trigger, amount/type checks, unique `(business_id, idempotency_key)`.
- Sale, expense, refund, owner contribution and owner withdrawal forms. Paid vs unpaid is modelled; unpaid sales are not cash received; unpaid expenses do not reduce cash.
- History, details, edit (same id) and confirmed delete.
- Drift schema **v2** `cached_transactions`. Online-only writes; confirmed history may be read stale from cache. No write-outbox (Phase 8).
- Dashboard tiles now show recorded cash, sales, expenses and net operating result from the engine, with an explicit month period. Empty, failed and stale states are distinct from a genuine zero.

**Exit:** Spec cash example `2000 + 500 − 100 + 200 − 50 = 2550` and related engine cases pass independently of UI.

Verification executed 21 Oct 2026:

- Remote migrations applied: `transactions`, `transactions_created_by_idx`
- `dart format --set-exit-if-changed .` — pass
- `flutter analyze` — No issues found
- `flutter test` — All tests passed (170)
- `flutter build apk --debug` — `build\app\outputs\flutter-apk\app-debug.apk`
- Drift codegen: `dart run build_runner build` wrote `lib/core/persistence/kgwebo_database.g.dart`
- RLS catalog: FORCE RLS on `transactions`; anon has no table privileges; authenticated has select/insert/update/delete; four ownership policies present; security advisors returned no lints
- Two-user payload RLS: not executed (no dedicated staging users on this project). Repeat `supabase/tests/rls_transactions.sql` with two Auth users before treating cross-account isolation as empirically proven.

## Phase 5 — Dashboard and responsive layouts

Phase 4 already replaced preview metric tiles with recorded cash, sales, expenses, net operating result and recent transactions. Phase 5 added a period selector, a thin persisted obligation model, and evidence-backed dashboard notices — not a rebuilt dashboard.

**Scope conflict resolved:** `MASTER_PROJECT_SPEC` puts full obligations and recommendation persistence in Phase 7. This plan asked Phase 5 for outlook from real obligations rather than hardcoded copy. Phase 5 therefore ships CRUD + dashboard outlook for commitments, and leaves 7/14/30 forecasts and dismissible persisted recommendations to Phase 7.

- Period chips: This month, Last month, Last 3 months, This year, custom inclusive range. Calendar uses `BusinessZone` (Africa/Gaborone for BW, fallback for unknown countries).
- Period sales, expenses, refunds, net operating result and sparkline come from `FinancialEngine` / `SparklineSeries`. Cash stays all-time recorded cash.
- `public.obligations` with FORCE RLS, ownership trigger, idempotency, Drift schema v3 cache. Writes remain online-only.
- Unpaid commitments never reduce recorded cash or the operating result. Estimated cash after unpaid commitments is labelled an estimate.
- Empty businesses get setup guidance, not a false loss warning. 5,000-row cap and mixed-currency skips stay labelled incomplete.
- Widget tests at 320×568, 360×800, 800×360, 768×1024, 1024×768.

**Exit:** Displayed totals match the engine; layouts do not overflow in tested sizes.

Verification executed 21 Oct 2026, then re-run as the Phase 5 gate before Phase 6:

- Remote migrations on `hhwxajxjmyjntxykptvs`: `obligations`, then `revoke_rls_bypassing_grants` (authenticated no longer has TRUNCATE, which bypasses RLS)
- FORCE RLS on `obligations` and `transactions`; anon has no table privileges; authenticated has select/insert/update/delete
- Two-user JWT payload tests: dedicated Auth users, GoTrue password grant, PostgREST with access tokens. Cross-account select/insert/update/delete denied; own-business writes succeeded; throwaway users deleted
- Security advisors: existing leaked-password warning only
- `dart format --set-exit-if-changed lib test` — pass
- `flutter analyze` — No issues found
- `flutter test` — All tests passed (229)
- `flutter build apk --debug --dart-define-from-file=.env` — `build\app\outputs\flutter-apk\app-debug.apk`
- Emulator (API 37, no physical handset): dashboard, sale form, cash-flow, commitment form, keyboard, landscape rail, airplane-mode stale cash}

## Phase 6 — Inventory

- Product catalogue: name, optional SKU, description, selling price, optional cost, quantity milli-units, low-stock threshold, unit of measure, active/archived. SKU is optional; duplicate SKUs are unique per business when present.
- Stock is a ledger, not an editable balance. Movements: opening, received, sold, customer return, damaged return, damaged/lost, manual increase/decrease, reversal. Manual corrections and write-offs require a reason.
- Quantities are integer milli-units (`1000` = 1). Money stays integer minor units. Weighted-average cost updates on restock; sale lines freeze unit price and unit cost.
- Atomic product sales through `public.record_product_sale`: one PostgreSQL transaction writes the sale, line items, sold movements, and stock decrease. Amount-only sales without lines keep Phase 4 behaviour. Deleting a product sale reverses stock. Editing a product-line sale can change payment details only; line quantities are not rewritten.
- Inventory overview (active / low / out of stock, estimated value at recorded cost) lives on Products. Dashboard shows a restock notice. Estimated inventory value is not cash, sales, profit, or an operating expense. COGS is informational and is not posted as an expense.
- Drift schema **v4** caches confirmed products and stock movements per owner and business. Inventory writes are online-only.
- Backorders are off. Oversell is rejected. Resellable returns increase stock; damaged returns are recorded with delta 0.

**Exit:** Sale and stock stay consistent after success and failure.

Verification executed 21 Oct 2026:

- Remote migrations on `hhwxajxjmyjntxykptvs`: `inventory` tables, indexes, RPCs, triggers, FORCE RLS and grants, plus `inventory_function_search_path`
- FORCE RLS on `products`, `sale_items`, `stock_movements`; anon has no table privileges; authenticated can select/insert/update/delete products, select sale lines and movements, and cannot TRUNCATE or insert movements/sale lines
- Privilege catalog SQL executed against the live project. Two-user JWT isolation for inventory was not re-run in this session (email OTP confirmation is required for new Auth users)
- Security advisors: intended `SECURITY DEFINER` RPCs callable by `authenticated`; leaked-password warning unchanged
- `dart format --set-exit-if-changed lib test` — pass
- `flutter analyze` — No issues found
- `flutter test` — All tests passed (270)
- `flutter build apk --debug --dart-define-from-file=.env` — `build\app\outputs\flutter-apk\app-debug.apk`

## Phase 7 — Cash-flow intelligence

- Obligations, 7/14/30 day deterministic forecast.
- Chart plus non-chart summary.
- Rule-based recommendations with evidence.
- No invented future sales.

**Exit:** Forecast dates and warnings are reproducible from fixtures.

## Phase 8 — Reports and offline

- In-app report from the engine.
- PDF export/share.
- Local queue with pending status.
- Duplicate-safe retry.

**Exit:** Report figures match the engine. Advertised offline behaviour has tests.

## Phase 9 — Quality and demo polish

- Format, analyze, unit, widget, and feasible integration tests.
- Release APK only after a successful build whose output path is verified.
- Demo seed and demonstration script.
- Document remaining limitations.

## Current blockers

| Item                        | Status                                                                                                                               |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Kgwebo Supabase project     | **Resolved.** Use `hhwxajxjmyjntxykptvs`. Phase 2 schema (`profiles`, `businesses`) is applied with RLS.                             |
| Auth email templates        | Styled OTP HTML is in `supabase/templates/`. Paste confirmation.html and recovery.html into Auth → Email Templates. OTP length is 6. |
| Leaked-password protection  | Supabase advisor warning. Enable HaveIBeenPwned checks in the Auth dashboard if desired.                                             |
| Service-role key in the app | Not required. Client uses publishable/anon key only.                                                                                 |
| Android device attached     | None attached during Phase 3. Widget tests and a debug APK build are used. Visual device QA of the profile form remains outstanding. |
| Android NDK mismatch        | Debug APK built with a plugin NDK warning. `android/app/build.gradle.kts` now pins `ndkVersion` to `27.0.12077973` for later builds. |
| Optional AI entry           | Deferred by spec if it threatens core reliability.                                                                                   |

## Verification command after each phase

```text
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Run a narrower test file while a phase is in progress, then the suite before calling the phase done.
