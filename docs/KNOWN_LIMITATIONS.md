# Kgwebo known limitations

Grounded in the repository on 26 October 2026. A limitation listed here is not a silent bug: it is current product behaviour.

## Accounting

- Cash-basis records only. Figures are not audited profit, tax, or bank-confirmed cash.
- Opening cash is a starting position, not revenue.
- Cost of goods sold is informational on sale lines. It is not posted as an operating expense.
- Incoming cash is not forecast. Unpaid sales have no payment due date.
- Mixed-currency rows are skipped, not converted.
- Pending outbox creates are not confirmed cash, sales, expenses, or forecast inputs.

## Offline

- Queued writes: amount-only transaction creates and new unpaid commitment creates, after a retryable network failure.
- Online-only: product sales, stock movements, catalogue writes, edits, deletes, recommendation dismissals, and business profile saves.
- Product details can use a cached product after a retryable failure if the catalogue was loaded first.
- Timeout-after-commit has unit coverage and a unique `(business_id, idempotency_key)` constraint. It has **not** been executed on an emulator or physical device.

## Reports

- Reports are a cash-basis summary from `FinancialEngine`, not audited accounts, tax profit, or a bank statement.
- Period opening/closing cash is omitted when confirmed history hits the 5,000-row cap, because it cannot be reconstructed accurately.
- PDF export uses the Android share sheet. Broad filesystem access is not requested.

## Settings and account

- Settings → Privacy explains session, cache, and unsupported features. There is no notification-preference toggle, in-app account deletion, or raw personal-data export.
- Sign-out clears the session. Owner-scoped Drift cache remains on the device.

## Security operations

- Leaked-password protection is still **disabled** on `hhwxajxjmyjntxykptvs` (advisor warning, 26 Oct 2026). Enabling it requires the Supabase Pro plan and a dashboard toggle; it cannot be turned on from SQL. See `docs/TEST_PLAN.md` section 8f.
- Phase 8 throwaway Auth users and businesses were identified and **not deleted** in this session. Exact cleanup steps are in `docs/TEST_PLAN.md` section 8f. Do not delete DreuTech.
- Email OTP templates in `supabase/templates/` must be pasted into the Auth dashboard. This session did not re-verify the live templates.
- Release APKs require `android/key.properties` or `KGWEBO_*` signing env vars. Debug builds still use the debug keystore. Missing release credentials fail the release assemble instead of signing with debug keys.

## Android SDK floor

- Debug and release builds require **minSdk 24** (Android 7.0). `flutter_tts` (Ask voice) declares minSdk 24 and compileSdk 36. This is higher than Flutter 3.29’s default minSdk 21.

## Device coverage

- Automated responsive widget tests cover 320×568, 360×800, 800×360, 768×1024 and 1024×768 on several screens.
- Manual Android QA used emulator `emulator-5554` (API 37). **No physical handset pass.**
- There is no `integration_test/` suite.

## Out of product scope

- Accrual accounting.
- Bank or card integrations.
- Multi-currency conversion of historical amounts.
- Offline product sales and stock writes.
- In-app account deletion and raw personal-data export.

Ask is shipped (Phase 10). It drafts sales and expenses for confirmation only, does not invent totals, and does not convert named foreign amounts into the business currency. Cloud Ask needs a signed-in JWT and is limited to 40 calls per 10 minutes per user. Conversation memory is in-session only. The mic needs `RECORD_AUDIO`; spoken replies are short and skip recorded totals. It is not professional advice.
