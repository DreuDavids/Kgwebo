# Kgwebo security notes

**Backend:** Supabase project `Kgwebo` (`hhwxajxjmyjntxykptvs`).  
**Client:** Flutter uses the publishable/anon key only. Service-role keys are rejected by `AppConfig`.

## What is enforced in schema

Checked live on 25 October 2026: FORCE RLS is on `profiles`, `businesses`, `transactions`, `obligations`, `products`, `sale_items`, `stock_movements`, and `recommendations`.

- Business `owner_id` is forced to `auth.uid()` and frozen on update.
- Transaction `created_by` is forced to `auth.uid()`. `business_id`, currency and idempotency key cannot be reassigned.
- Clients cannot insert `sale_items` or `stock_movements`. Stock quantity is frozen unless a SECURITY DEFINER RPC sets `kgwebo.allow_stock_update`.
- Intended RPCs callable by `authenticated`: `create_catalog_product`, `record_product_sale`, `record_stock_movement`. Security advisors flag these as SECURITY DEFINER; that is required for atomic inventory writes, not an accidental grant.

## What automated tests prove

- Service-role material is rejected and never appears in `AppConfig.toString()`.
- Auth failure copy for unknown codes and unknown PostgREST text is generic. Tokens in messages are redacted.
- Drift caches and the sync outbox are queried by the current owner and business.
- The coordinator will not submit another owner’s queue or mark a valid op permanent solely because the session changed mid-flight.

## What live tests proved (manual, not CI)

Documented in `docs/TEST_PLAN.md`, executed 21 October and 24 October 2026 with real JWTs:

- User B cannot select or mutate user A’s businesses, transactions, obligations, products, sale items, stock movements or recommendations.
- Concurrent last-unit oversell: one 200, one 400, remaining stock 0.

Those runs are **not** replayed by `flutter test`. SQL files under `supabase/tests/` are privilege catalog checks plus a human checklist.

## What is not claimed

- The app is not “end-to-end encrypted” for business records. Data is stored in Postgres under RLS.
- Cache rows remain on disk after sign-out, keyed by owner. Isolation is query filtering, not file encryption.
- Error messages no longer pass raw unique-constraint or JSON-error text to the UI. They still show curated `AuthFailure` copy.

## Auth leaked-password protection

Checked live 26 Oct 2026 via security advisors on `hhwxajxjmyjntxykptvs`: `auth_leaked_password_protection` is still **WARN / disabled**.

The organisation **Late 2026 Projects** (`nosqaseoyrdpdxxvsdeg`) is on the **Free** plan. HaveIBeenPwned leaked-password protection is a **Pro Plan** Auth setting. It cannot be enabled with SQL.

After a Pro upgrade: Dashboard → Authentication → Attack Protection (password security) → enable **Leaked password protection**. Re-run advisors and confirm the warning is gone before claiming it is on.

## Release signing

Release APKs must not use the debug keystore. `android/app/build.gradle.kts` fails `assembleRelease` / `bundleRelease` unless `android/key.properties` or `KGWEBO_*` env vars are set. `android/key.properties`, `*.jks`, and `*.keystore` are gitignored. Debug builds are unchanged.

## Client secrets

- `.env` is gitignored. `.env.example` has the project URL and an empty anon key.
- Never put a service-role key in Flutter, dart-define, or Android resources.
- Never commit a signing keystore or `key.properties` passwords.
