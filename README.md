# Kgwebo

Your business. Clearer decisions. Stronger growth.

Kgwebo is a Flutter Android companion for informal traders and small retailers in Botswana. This repository currently contains **Phase 2**: the application shell, design system, Supabase email/password authentication, session-aware routing, and first-business onboarding. Transaction capture and the financial engine are later phases.

## Requirements

- Flutter **3.29.2**
- Dart **3.7.2**
- Android toolchain from `flutter doctor`

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

`.env.example` is bundled as an asset so the URL and environment name can load without secrets. `.env` itself is not listed as a Flutter asset, so a missing local file cannot break CI builds. Dart-define values override file values.

Live mode (`APP_ENV` development/staging/production with a valid publishable key) initialises the Supabase client and restores the Auth session. `APP_ENV=demo` is an explicit labelled demo and never opens a backend session. Missing development credentials start a labelled local preview. Missing production or staging credentials block startup. Neither case substitutes demo figures.

Add `bw.kgwebo.kgwebo://login-callback` to Supabase Auth additional redirect URLs for email confirmation and password recovery.

## Run, test, and build

```text
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

## Layout

Navigation follows available logical width:

- **< 600** compact bottom bar: Home, Activity, Products, More
- **600–1023** navigation rail with all six destinations
- **≥ 1024** extended rail

Orientation is not locked. Dashboard sections reflow; they are not fixed-width cards.
