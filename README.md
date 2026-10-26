# Kgwebo

Your business. Clearer decisions. Stronger growth.

Kgwebo is a Flutter Android companion for informal traders and small retailers in Botswana. This repository currently includes authentication, business profiles, sales and expenses, inventory, cash-flow forecasts, deterministic recommendations, owner-scoped offline writes for amount-only transactions and unpaid bills, and cash-basis Reports with PDF export/share.

Ask is a dedicated copilot tab: talk or type to explain recorded cash, show charts, walk through recommendations, and draft sales or expenses. It never invents totals, never converts ZAR into pula, and never saves money until you confirm. Gemini Flash runs behind the `kgwebo-copilot` Edge Function; the Gemini key is not in the app.

## Requirements

- Flutter **3.29.2**
- Dart **3.7.2**
- Android toolchain from `flutter doctor` (minSdk **24**, compileSdk **36**)

## Configuration

1. Copy `.env.example` to `.env` (gitignored).
2. Keep `SUPABASE_URL` as the Kgwebo project URL if it is already correct.
3. Set `SUPABASE_ANON_KEY` to the **publishable / anon** client key only. Never put a service-role key in the app.
4. Set `APP_ENV` to `development`, `staging`, `production`, or `demo`.

Load local values with:

```text
flutter run --dart-define-from-file=.env
```

The Cursor / VS Code launch configuration passes the same flag.

`.env.example` is bundled as an asset so the URL and environment name can load without secrets. `.env` itself is not listed as a Flutter asset. Dart-define values override file values.

Live mode (`APP_ENV` development/staging/production with a valid publishable key) initialises the Supabase client and restores the Auth session. `APP_ENV=demo` is an explicit labelled demo and never opens a backend session. Missing development credentials start a labelled local preview. Missing production or staging credentials block startup. Neither case substitutes demo figures.

Email confirmation and password reset use a **6-digit OTP**, not a magic link. Paste `supabase/templates/confirmation.html` into **Confirm signup** and `supabase/templates/recovery.html` into **Reset password**. Keep OTP length at 6.

## Run, test, and build

```text
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=.env
```

## Layout

Navigation follows available logical width:

- **< 600** compact bottom bar: Home, Activity, Products, More
- **600–1023** navigation rail with all six destinations
- **≥ 1024** extended rail

Orientation is not locked.

## Reports PDF

1. Sign in, open **More → Reports** (compact) or **Reports** on the rail.
2. Choose This month, Last month, Last 3 months, This year, or a custom range (Africa/Gaborone).
3. Confirm the preview matches Home for the same period.
4. Tap **Export PDF**. Android’s share sheet can save or send the file. The app does not request broad storage permission.

Figures come from `FinancialEngine`. Pending sync rows are excluded. A stale-cache banner appears when the report is from on-device confirmed data.

## Release signing

Debug APKs keep the debug keystore. A release assemble **fails** unless credentials are present:

1. Copy `android/key.properties.example` to `android/key.properties` (gitignored).
2. Point `storeFile` at a local `.jks` that is not in git.
3. Fill `storePassword`, `keyAlias`, and `keyPassword`, or set `KGWEBO_STORE_FILE`, `KGWEBO_STORE_PASSWORD`, `KGWEBO_KEY_ALIAS`, and `KGWEBO_KEY_PASSWORD`.

This is upload-key configuration for a later Play Console listing. It is not Play Store review.

## Documentation

- `docs/FINANCIAL_MODEL.md` — cash, sales, expenses, forecasts
- `docs/ARCHITECTURE.md` — sync and layering
- `docs/SECURITY.md` — RLS and client secrets
- `docs/KNOWN_LIMITATIONS.md` — honest product limits
- `docs/DEMO_GUIDE.md` — stakeholder walkthrough
- `docs/TEST_PLAN.md` — what was actually tested
