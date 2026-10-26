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
