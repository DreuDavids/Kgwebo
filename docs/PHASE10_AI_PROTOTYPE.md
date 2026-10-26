# Phase 10 note — on-device model withdrawn

The LFM2.5-230M / `llama_flutter_android` prototype was removed on 25 October 2026.

It could not reliably emit JSON, match the user’s language, or handle amounts such as `50zar each`. Kgwebo Ask now uses LiteLLM (OpenAI-compatible) behind the `kgwebo-copilot` Edge Function, with FinancialEngine grounding on the device. See `lib/features/copilot/` and `supabase/functions/kgwebo-copilot/`.

## Secret (not in the APK)

Set these on the Kgwebo Supabase project (`hhwxajxjmyjntxykptvs`) as Edge Function secrets:

- `LITELLM_API_KEY` (required)
- `LITELLM_BASE_URL` (optional, default `https://api.litellm.ai/v1`)
- `LITELLM_MODEL` (optional, default `gpt-4o-mini`)

Without `LITELLM_API_KEY`, Ask still answers from recorded Kgwebo totals and the on-phone extractor; cloud suggestions stay offline.

Do not put this key in `.env`, dart-defines, the chat, or the Android APK.

## Cloud gate

`kgwebo-copilot` requires a signed-in JWT (`verify_jwt` plus `/auth/v1/user`). It rate-limits at 40 calls per 10 minutes per user via `public.kgwebo_touch_copilot_rate` (service-role only) writing `private.copilot_rate_windows`. Draft intents omit the cash snapshot so the model cannot restate or invent balances while extracting a sale or expense.

## On the phone

Ask uses the signed-in business currency, not a hardcoded pula. Session follow-ups stay in memory (`CopilotSession`). Bills, stock, recent transactions, and owner withdrawals are answered from recorded Kgwebo data. The mic uses on-device speech-to-text (`RECORD_AUDIO`). TTS speaks only short non-totals replies. First-run chips cover cash, recording an expense, and what to watch. After one confirmed save, Help me / Open the page is skipped.
