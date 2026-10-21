# Phase 2 — Authentication, Onboarding & Secure Sessions

> Implement in this repository. Do not rebuild Phase 1.

**Goal:** Real Supabase email/password auth, session-aware routing, and first-business onboarding, with explicit labelled demo/local preview remaining isolated.

**Architecture:** Keep GoRouter + Riverpod. Add a testable `AppSession` plus a pure `redirectFor` policy. Initialise `supabase_flutter` only when `runtimeMode == live` and client config is valid. Persist one business per owner in Postgres with RLS. Widget tests use fake repositories, never a live account.

**Tech stack:** Flutter 3.29.2, Dart 3.7.2, Riverpod 2.6, GoRouter 14.8, supabase_flutter 2.8.4, existing Kgwebo design system.

## Global constraints

- Existing project `hhwxajxjmyjntxykptvs` only. Never create a new Supabase project.
- Publishable/anon key only. Reject service-role keys. Never log tokens or passwords.
- Demo only when `APP_ENV=demo`. Local preview stays labelled. Invalid production config still blocks; it does not become demo.
- Client route guards are UX, not a substitute for RLS.
- Do not build sales, expenses, inventory, or financial engine work.
- Preserve Phase 1 adaptive navigation and regression tests.

## Repository facts (21 Oct 2026)

- Phase 1 shell, theme, config, and 32 tests exist.
- `AppConfig.connectsToBackend` is currently always `false` (Phase 1). Phase 2 must connect in **live** mode only.
- Default widget tests use `testConfig()` → development without a key → **local preview**. Those tests must still reach the dashboard.
- Public schema is empty. Remote migrations: none.
- `supabase_flutter` is already in `pubspec.yaml`. No `supabase/` folder yet.
- Android application id: `bw.kgwebo.kgwebo`. Deep link: `bw.kgwebo.kgwebo://login-callback`.

## File map

| Area | Path |
| --- | --- |
| Route policy | `lib/core/auth/route_access.dart` |
| Validators | `lib/core/validation/` |
| Session | `lib/features/authentication/application/` |
| Auth UI | `lib/features/authentication/presentation/` |
| Onboarding | `lib/features/onboarding/` |
| SQL | `supabase/migrations/` |
| RLS check | `supabase/tests/rls_profiles_businesses.sql` |

## Routing policy

| Session | Unauthenticated / auth routes | Protected shell |
| --- | --- | --- |
| Loading / resolving | `/session` | `/session` |
| Preview (demo or local) | Redirect to dashboard | Allow (labelled) |
| Guest | Allow welcome/sign-in/up/reset/confirm | `/welcome` |
| Email confirmation | `/confirm-email` | `/confirm-email` |
| Password recovery | `/reset-password` | `/reset-password` |
| Needs onboarding | `/onboarding` | `/onboarding` |
| Ready | Dashboard | Allow |

## Schema (Phase 2 only)

- `private` schema for security-definer/invoker triggers (not exposed to Data API).
- `public.profiles` (`id` → `auth.users`, display name, timestamps). Inserted by trigger on signup; clients cannot choose another user's id.
- `public.businesses` (one row per `owner_id`): name, type, country default `BW`, currency default `BWP`, optional description/start date/contact, `opening_balance_minor >= 0`.
- BEFORE INSERT/UPDATE forces `owner_id = auth.uid()` and freezes owner on update.
- RLS: authenticated users read/update own profile; CRUD own business. Anon has no access.
- Onboarding is complete when a business exists with required fields. Unique `owner_id` makes retries update, not duplicate.

## Auth UX

Welcome (skippable education) → sign-up / sign-in → email confirmation when the project requires it → business setup → dashboard. Password-reset request + completion via the recovery deep link. Settings sign-out.

Onboarding fields: required name and type; country/currency shown with Botswana/BWP defaults; opening cash optional (default 0, labelled as starting cash not revenue); description optional.

## Tests

- Unit: validators, `redirectFor`, onboarding completion, live-vs-demo connect rules, auth error mapping, secret redaction.
- Widget: forms, loading/disabled submit, visibility toggle, reset request, onboarding validation, keyboard/narrow layouts, live guest cannot open dashboard, preview still can.
- Service: fake repository sign-in/up/out/restore/retry onboarding; demo repository refuses live writes.
- SQL: User A cannot read/write User B's profile or business; anon cannot select.

## Manual dashboard leftover

Additional Redirect URL `bw.kgwebo.kgwebo://login-callback` cannot be set from SQL. Document it. Email-confirmation toggle is a project setting; the app must handle both states.
