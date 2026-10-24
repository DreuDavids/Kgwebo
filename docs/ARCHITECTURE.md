# Kgwebo Architecture

**Source of truth:** `docs/MASTER_PROJECT_SPEC.md`  
**Repository state at authorship:** Flutter 3.29.2 / Dart 3.7.2 Android project, plus this document set.  
**Backend:** existing Supabase project `Kgwebo` (`hhwxajxjmyjntxykptvs`, `eu-west-1`, `ACTIVE_HEALTHY`). Phase 2 applied `profiles` and `businesses` with RLS.

## 1. Purpose

Kgwebo is a Flutter Android application for informal traders and small retailers in Botswana. It records business activity, computes cash and profit figures, and explains what those figures mean.

The architecture keeps financial rules out of widgets, persists every implemented business operation, and treats Supabase Row Level Security as the authorization boundary for cloud data.

## 2. Installed environment

| Item                       | Value                                                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Flutter                    | 3.29.2 (Dart 3.7.2)                                                                                                                  |
| Application id             | `bw.kgwebo.kgwebo`                                                                                                                   |
| Android                    | `compileSdk` / `minSdk` / `targetSdk` from the installed Flutter toolchain                                                           |
| Connected devices at audit | Windows desktop, Chrome, Edge. Phase 7 and Phase 8 verification used Android emulator `emulator-5554` (API 37). No physical handset. |
| Doctor notes               | Some Android licenses not accepted; Flutter is on a user-managed channel at `C:\tools\flutter`                                       |

## 3. Runtime modes

The app must never silently substitute demo figures for live records.

| Mode    | When                                                     | Persistence                                                       |
| ------- | -------------------------------------------------------- | ----------------------------------------------------------------- |
| `live`  | `SUPABASE_URL` and a publishable or anon key are present | Supabase Auth + PostgreSQL; Drift caches confirmed business rows  |
| `local` | Backend config missing                                   | Drift only, labelled in Settings                                  |
| `demo`  | User explicitly chooses Explore demo                     | Seeded Drift dataset, labelled on every screen that shows numbers |

Missing backend configuration is a visible degraded mode, not a crash and not a fake-success path.

## 4. Layering

Feature-oriented layout:

```text
lib/
  app/          bootstrap, router, theme, env
  core/         money, finance, errors, formatting, validation, responsive, logging
  features/     onboarding, auth, business, dashboard, transactions, products,
                cash_flow, recommendations, reports, settings
  shared/       reusable widgets
```

Each feature separates:

1. Presentation (widgets)
2. Application state (Riverpod notifiers)
3. Domain models and pure financial rules
4. Repository interfaces
5. Drift / Supabase data sources

Widgets do not compute profit, cash, COGS, or forecasts. They render values produced by `core/finance`.

## 5. State, routing, and configuration

- **Riverpod** for state and dependency injection, without code generation.
- **GoRouter** for navigation, auth guards, and onboarding redirects.
- **Environment** from `--dart-define` overrides, then `.env` if present, then safe defaults that select `local` mode.
- Privileged Supabase keys never enter the Flutter app. Only the project URL and publishable/anon key are client-side.

## 6. Persistence

### Local (Drift / SQLite)

Phase 3 ships Drift schema **v1** in `lib/core/persistence/kgwebo_database.dart`. It caches confirmed business profiles only:

- Primary key: remote business UUID (`remoteId`)
- Unique `ownerId` (one cached business per owner)
- Name, type, country, currency, `openingBalanceMinor` (integer thebe), description, start date, contact phone
- Server `createdAt` / `updatedAt` (conflict detection later)
- Local `cachedAt` and `syncStatus` (`confirmed` only in this phase)

Monetary columns use integer minor units. For BWP, `1.00` pula is `100` thebe. Passwords, tokens and service-role keys are never stored in this cache.

Phase 4 adds Drift schema **v2** `cached_transactions`: remote UUID, owner id, business id, type, integer `amountMinor`, currency, category, description, `occurredAt`, payment method/status, idempotency key, and `syncStatus = confirmed`. Queries always filter by the current owner and business. A write-outbox is still not present.

Phase 5 adds Drift schema **v3** `cached_obligations`: remote UUID, owner id, business id, title, integer `amountMinor`, currency, `dueOn`, status, category, notes, optional `recordedTransactionId`, idempotency key, and `syncStatus = confirmed`. Queries always filter by the current owner and business.

Phase 6 adds Drift schema **v4** `cached_products` and `cached_stock_movements`: remote UUID, owner id, business id, integer money and milli-unit quantities, and `syncStatus = confirmed`. Queries always filter by the current owner and business. Inventory writes remain online-only.

Phase 7 adds Drift schema **v5** `cached_recommendations`: remote UUID, owner id, business id, `ruleKey`, `conditionKey`, status (`active` / `dismissed` / `resolved`), and `syncStatus = confirmed`. Display copy is derived from current records. The cache stores lifecycle state only. Queries always filter by the current owner and business. Recommendation writes remain online-only.

Phase 8 adds Drift schema **v6** `sync_outbox`: operation UUID, owner id, business id, operation type (`create_transaction.v1` / `create_obligation.v1`), JSON payload, idempotency key, created time, state (`pending` / `syncing` / `succeeded` / `retryable_failure` / `permanent_failure`), attempt count, next attempt time, redacted error fields, and optional dependency id. Unique `(ownerId, businessId, idempotencyKey)`. Outbox rows are never confirmed ledger entries. Confirmed caches stay `syncStatus = confirmed` only.

### Remote (Supabase / PostgreSQL)

Project:

- Name: `Kgwebo`
- Ref: `hhwxajxjmyjntxykptvs`
- API: `https://hhwxajxjmyjntxykptvs.supabase.co`
- Database host: `db.hhwxajxjmyjntxykptvs.supabase.co`
- Postgres 17
- MCP account used: `user-supabaseAndreuModise`

Phase 2 tables live in `public.profiles` and `public.businesses`. Phase 4 adds `public.transactions` with FORCE RLS, an ownership trigger (`private.set_transaction_defaults`), and `private.owns_business(business_id)` on SELECT/INSERT/UPDATE/DELETE. Phase 5 adds `public.obligations` with the same ownership pattern (`private.set_obligation_defaults`). Phase 6 adds `public.products`, `public.sale_items`, and `public.stock_movements` with FORCE RLS. Clients may select/insert/update/delete own products; `stock_quantity_milli` is frozen unless `kgwebo.allow_stock_update` is set inside a SECURITY DEFINER function. Sale lines and stock movements are select-only for `authenticated`; writes go through `create_catalog_product`, `record_stock_movement`, and `record_product_sale`. Phase 7 adds `public.recommendations` with FORCE RLS, unique `(business_id, rule_key)`, and `private.set_recommendation_defaults()`. Rows store `rule_key`, `condition_key`, and status only — not amounts or titles. Versioned SQL is under `supabase/migrations/` and has been applied to this project. Every exposed table enables RLS. Policies authorize through `auth.uid()` and business ownership, never through user-editable JWT metadata. A `private` schema holds trigger functions that are not exposed on the Data API.

Ownership of a business is forced to `auth.uid()` on insert and frozen on update. Clients cannot assign another user's id. Profile rows are created by a trigger on `auth.users`; authenticated clients may select/update their own profile but not insert or delete it.

Atomic remote operations (product sale + line items + stock movement) use a PostgreSQL function or a single transaction. Partial writes are not acceptable.

### Sync (Phase 3 business profile)

**Supabase is authoritative** for confirmed remote business data. Drift is a confirmed-read cache.

1. Load prefers a confirmed owner-scoped cache for an immediate display, then refreshes from Supabase.
2. A successful remote read or write upserts the server representation into Drift (`syncStatus = confirmed`).
3. A failed remote read keeps the last confirmed cache and marks it **stale**. It does not invent a business and does not treat a missing cache as “business does not exist” when the failure is retryable.
4. **Edits require a successful remote update.** There is no pending-write queue in this phase. Save always attempts Supabase; the request result is the connectivity check. A failed save leaves the confirmed cache unchanged and keeps the form values for retry.
5. The UI never presents a local-only change as synchronized.
6. Onboarding completeness is decided from a successful remote read, or from a **confirmed** cache row for the current owner after a retryable remote failure. An empty or unverified cache cannot complete onboarding.

Sign-out **retains** on-disk rows keyed by `ownerId` and clears in-memory session/profile providers. Queries always filter by the current owner; account B cannot read account A’s cache. Remote `owner_id` is never taken from the client payload; `private.set_business_owner()` freezes it.

Phase 4 transaction writes are **online-only**. The client sends a stable `idempotency_key` per create; unique `(business_id, idempotency_key)` plus fetch-on-conflict prevents duplicate inserts after a timeout. Edits keep the existing `id`. Failed reads keep the last confirmed cache and label it stale. A durable write queue remains Phase 8. Conflicting financial edits are not last-write-wins.

Phase 5 obligation writes follow the same online-only and idempotency rules. Dashboard periods are `[startInclusive, endExclusive)` in the business zone (`BusinessZone.forCountry`, currently Africa/Gaborone for BW). Period totals come from `FinancialEngine`; cash is all-time recorded cash. Unpaid obligations never reduce that cash figure.

Phase 6 product and stock writes are **online-only**. The UI states that stock changes are not queued offline. Confirmed catalogue and movement reads are cached per owner and business; a failed refresh keeps the last confirmed cache and labels it stale. Product sales use one RPC so a retry with the same idempotency key cannot double-count revenue or stock. Deterministic line and reversal keys are built with `private.uuid_from_md5` (Postgres 17 rejects `bit(128)::uuid`). Live two-user JWT isolation and two-client last-unit oversell passed on 24 Oct 2026.

Phase 7 recommendation writes are **online-only**. Forecasts are computed from confirmed transactions and obligations; they are not a stored table. A failed recommendation refresh keeps the last confirmed status cache, labels it stale, and never presents an empty list as “no recommendations” when the load failed. Dashboard forecast horizon is UI state (default 14 days) and does not change recorded cash.

### Sync (Phase 8 outbox)

Supabase remains authoritative. Drift confirmed caches are still confirmed-read only.

1. Simple transaction **creates** (sale without product lines, expense, refund, contribution, withdrawal) and **new unpaid commitment creates** try the server first. A retryable network/timeout failure enqueues a durable outbox row with the original idempotency key and shows **Pending sync**. The row is not upserted into confirmed caches and is not a ledger entry.
2. `SyncCoordinator` runs on app resume (signed-in shell), after enqueue, and from Settings → Pending changes. Connectivity is not treated as proof that Supabase is reachable; success is a server confirmation. Interrupted `syncing` rows return to `pending` on the next run.
3. Operations for the current owner and business are processed sequentially by `createdAt` then operation id. A dependency that is not succeeded is skipped. Retries reuse the same idempotency key. After a timeout where the server may have committed, the unique constraint plus fetch-on-conflict (or a later confirmed list) reconciles to one row.
4. Transient failures stay `retryable_failure` with bounded automatic backoff (8 attempts, then paused until the user taps Retry). Validation and ownership failures become `permanent_failure` for review. Operations are never dropped silently.
5. **Online-only:** product sales, stock movements, catalogue writes, transaction/commitment edits and deletes, recommendation dismissals, and business profile saves. Product sales stay online-only because stock is server-authoritative, `record_product_sale` is atomic, and an optimistic sale would misrepresent stock. Two-client last-unit oversell and two-user inventory/recommendation JWT isolation passed on 24 Oct 2026; that does not make inventory safe to queue offline.
6. Sign-out retains owner-scoped outbox rows on disk. The coordinator refuses to submit another owner’s queue. Account B cannot list account A’s pending financial data. A deleted or inaccessible business surfaces as a permanent, reviewable failure rather than a silent overwrite.
7. Forecasts, cash, recorded sales and recommendations use confirmed records only. Pending items can appear in history/commitment lists with an explicit status; they are excluded from `FinancialEngine` and `CashForecastEngine`. History pagination uses `mergeHistoryPages`: a later confirmed page drops the matching pending display so both cannot remain visible.

## 7. Money and accounting scope

Authoritative money is `Money`: integer `minorUnits` plus `currencyCode`. Binary `double` is not used for totals.

MVP accounting is **cash basis**, not IFRS/GAAP:

- Opening cash is a starting position, not revenue. Spec copy says “opening cash balance”; the remote/local field is `opening_balance_minor` (integer thebe). The UI labels it “Opening / starting cash”. It is never converted into a sale, income row or revenue total.
- Owner contributions increase cash and are not sales.
- Owner withdrawals decrease cash and are not operating expenses.
- Unpaid obligations do not reduce current cash.
- Product COGS uses the unit cost snapshotted at sale time. It is informational. Phase 6 does not post a cost-of-goods expense. Inventory value is estimated as recorded weighted-average cost × quantity for products that have a cost; missing costs are excluded and counted, never invented. Estimated inventory value is not cash, sales, profit, or an operating expense.
- Business reporting timezone is resolved from the business country (`BusinessZone.forCountry`). Botswana uses `Africa/Gaborone` (UTC+2, no DST). Unknown countries currently fall back to Gaborone until regional zones ship.
- Default currency is BWP with two decimal places; the currency is stored per business, not hardcoded into the engine.

These limitations must appear in reports and cash-flow copy. The app does not present simplified cash figures as audited statements.

## 8. Design system and layout

Tokens live in `lib/app/theme/`. Screens consume shared widgets; they do not restyle the same control independently.

Responsive navigation uses available logical width:

| Width      | Shell                                                      |
| ---------- | ---------------------------------------------------------- |
| `< 600`    | Compact bottom bar with Home, Activity, Products, and More |
| `600–1023` | Navigation rail with all six primary destinations          |
| `>= 1024`  | Extended rail plus a max-width content column              |

On compact widths, Cash Flow, Reports, and Settings are reached from More so six labelled destinations are never packed into a 320-wide bar. `StatefulShellRoute.indexedStack` keeps the selected destination and in-progress text across orientation and size changes.

Dashboard cards wrap. Forms scroll with the keyboard. `SafeArea` and system insets are required. Orientation remains enabled.

## 9. Authentication, routing, and security

- HTTPS to Supabase. `supabase_flutter` is initialised only in live mode, with PKCE and `detectSessionInUri`.
- Session restore uses `onAuthStateChange`. Sign-out calls `signOut()`.
- Route access is a pure function (`redirectFor`) over `AppSession`. Hiding UI is not the guard. Client routing is not a substitute for RLS.
- Live guests land on welcome/sign-in. Incomplete onboarding cannot open the shell. Ready users skip auth screens.
- Demo (`APP_ENV=demo`) and local preview never open a Supabase session and never write to a real account.
- Password recovery and email confirmation use a 6-character email OTP. The app calls `verifyOTP` with `signup` or `recovery`. Hosted templates live in `supabase/templates/` and must include `{{ .Token }}` with no confirmation links.
- RLS on every exposed user/business table. Anon cannot select `profiles` or `businesses`.
- Passwords and access tokens are never logged. `AppLogger` redacts JWTs and secret assignments.
- `.env` is gitignored. `.env.example` contains placeholders only.

## 10. Testing seams

Pure Dart:

- `Money`
- `FinancialEngine`
- `CashOutlookEngine`
- `DashboardPeriodSelection` / `BusinessZone`
- `CashForecastEngine`
- `RecommendationRules` / `RecommendationLifecycle`
- validators and formatters

Flutter:

- design-system widgets
- responsive shell
- forms and empty/error states

Persistence:

- Drift repository tests with an in-memory or file database
- SQL policy tests against the Kgwebo Supabase project once migrations exist

## 11. Out of scope until later

- Conversational / AI transaction entry (spec Feature J, optional)
- Accrual accounting
- Multi-currency conversion of historical amounts
- Bank or card integrations
- Creating a second Supabase project
