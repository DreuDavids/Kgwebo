# Kgwebo demonstration guide

Use a debug APK built with `--dart-define-from-file=.env` against the live Kgwebo Supabase project. Do not claim physical-device testing unless a handset pass is recorded.

## Suggested 8-minute path

1. Welcome → skip education → create account (or sign in). Confirm email with the 6-digit code if prompted.
2. Business setup: name, type, Botswana, BWP or the business currency, opening cash. State that opening cash is not a sale.
3. Home **Cash**: recorded cash first. Record a paid sale and a paid expense. Totals should move.
4. Record an unpaid bill due in 10 days. Switch the 14-day vs 7-day horizon. The 14-day estimate subtracts it; 7 days should not.
5. Products: add a product with cost and stock. Sell it while online. Stock decreases once. Say product sales are not queued offline.
6. Home **What to do next**: open a recommendation, follow the action, dismiss if appropriate.
7. Airplane mode: record an amount-only sale. Cash must not include it. Settings → Pending changes shows the queue. Restore network and confirm it syncs once.
8. More → Reports: pick This month, confirm sales/expenses match Home, export PDF and share it. Say it is cash-basis records, not audited accounts.
9. Sign out. Sign in as a second account if available and show empty or different figures. Sign back in to the first account.

## What not to demo as finished

- Offline product or stock writes.
- Bank feeds, AI transaction entry, data export, account deletion.
- Play Store / wider-release signing until `android/key.properties` is configured on the build machine.

## Demo data

Use a dedicated stall, not production trader data. Opening cash plus a few paid sales and one unpaid bill is enough for the forecast story. The spec cash example is BWP 2,000 + 500 − 100 + 200 − 50 = 2,550 recorded cash.
