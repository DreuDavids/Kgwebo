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
  - Public tables: none
  - Remote migrations: none
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
- Session restore, sign-out, password-reset request, recovery completion, and email-confirmation pending state.
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

## Phase 4 — Transactions and financial engine

- Domain `Money` and `FinancialEngine` with TDD first.
- Record sale, expense, refund, owner contribution, owner withdrawal.
- Idempotency keys; disable double-submit.
- Paid vs unpaid expenses.
- History, edit, delete, recalculation.

**Exit:** Spec cash example `2000 + 500 − 100 + 200 − 50 = 2550` and related cases pass independently of UI.

## Phase 5 — Dashboard and responsive layouts

- Cash, sales, expenses, profit, recent activity, outlook, recommendations, quick actions.
- Period selector updates figures from the engine.
- Empty businesses get setup guidance, not a false loss warning.
- Widget tests at 320, 390, 600, 840, 1024 widths and landscape.

**Exit:** Displayed totals match the engine; layouts do not overflow in tested sizes.

## Phase 6 — Inventory

- Products, stock movements, product sales.
- COGS from snapshotted unit cost.
- Reject oversell unless backorders are enabled.
- Low-stock recommendations.

**Exit:** Sale and stock stay consistent after success and failure.

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
| Auth redirect URL           | Add `bw.kgwebo.kgwebo://login-callback` under Auth → URL Configuration → Additional Redirect URLs.                                   |
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
