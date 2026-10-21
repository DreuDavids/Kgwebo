# Phase 3 — Business Profile, Drift Cache & Offline Reads

> Grounded in the repository and remote schema on 21 October 2026.

**Goal:** Authenticated owners can view and edit their existing business, with a Drift cache for offline reads, without starting Phase 4.

**Architecture:** Extend the existing `BusinessProfile` / `OnboardingRepository` stack. Wrap the Supabase repository with a Drift-backed cache. Add a Settings-nested profile UI. Do not create a second business model, a second navigation shell, or an offline write queue.

**Tech stack:** Flutter 3.29.2, Dart 3.7.2, Riverpod, GoRouter, Drift 2.24, Supabase project `hhwxajxjmyjntxykptvs`.

## Repository facts

- Phase 2 already created `public.profiles` and `public.businesses` with RLS. Applied remote migrations: `profiles_and_businesses`, `fix_touch_updated_at_search_path`, `revoke_profile_insert`. **No new remote migration is required.**
- `businesses_one_per_owner UNIQUE (owner_id)` matches one-business-per-owner.
- `private.set_business_owner()` forces `owner_id = auth.uid()` on insert and freezes it on update.
- RLS: select/insert/update/delete own rows only. `opening_balance_minor` is `bigint >= 0`, not revenue.
- Drift is in `pubspec.yaml` (`drift` 2.24, `drift_flutter` 0.2.4, `drift_dev` 2.24) but **no database files exist yet**.
- Domain model already has spec fields: name, type, country, currency, opening cash, description, start date, contact phone.
- Session restore currently fails closed on network errors (`AppSessionFailure`). Profile editing does not exist. Settings has account/runtime cards only.

## Synchronization policy (chosen)

- **Supabase is authoritative** for confirmed remote business data.
- **Drift is a confirmed-read cache**, scoped by owner id.
- **Edits require a successful remote write.** Save always attempts Supabase. The request result is the connectivity check. There is no pending-write queue in this phase.
- On remote read success: upsert the server representation into Drift (`syncStatus = confirmed`).
- On remote read failure: if a confirmed cache row exists for the current owner, show it as **stale**. Never invent a business. Never mark onboarding complete from an unverified/empty cache.
- On remote write success: persist the server-confirmed row. On write failure: keep the last confirmed cache and keep the form values for retry.
- Never present a local-only change as synchronized.
- **Sign-out retains** on-disk cache rows keyed by `ownerId`, and **must** clear in-memory session/profile state. Account B cannot read account A’s rows.

## File map

| Area                  | Path                                                                 |
| --------------------- | -------------------------------------------------------------------- |
| Minor-unit formatting | `lib/core/money/minor_units.dart`                                    |
| Drift database        | `lib/core/persistence/kgwebo_database.dart`                          |
| Cache access          | `lib/core/persistence/business_cache.dart`                           |
| Snapshot / origin     | `lib/features/onboarding/domain/business_snapshot.dart`              |
| Cached repository     | `lib/features/onboarding/data/cached_onboarding_repository.dart`     |
| Profile UI            | `lib/features/business/presentation/`                                |
| Profile controller    | `lib/features/business/application/business_profile_controller.dart` |

## Out of scope

Phase 4+ : sales, expenses, inventory, forecasts, reports, offline write queue, business deletion UI.

## Verification (executed 21 Oct 2026)

- `dart format --set-exit-if-changed .` — pass
- `flutter analyze` — No issues found
- `flutter test` — All tests passed (126)
- Remote migrations: none applied in Phase 3; catalog re-checked
- Visual device QA: outstanding (no Android device attached)
