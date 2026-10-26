# Responsive test matrix

Widget tests render key screens at logical sizes. They do **not** prove every Android device.

## Automated sizes

Used across dashboard, settings, onboarding, cash-flow, recommendations, forms, reports, history filters, and the compact shell:

| Profile        | Size     | Orientation |
| -------------- | -------- | ----------- |
| Compact phone  | 320×568  | Portrait    |
| Standard phone | 360×800  | Portrait    |
| Standard phone | 800×360  | Landscape   |
| Tablet         | 768×1024 | Portrait    |
| Tablet         | 1024×768 | Landscape   |

Fail conditions in those tests: exceptions, `RenderFlex` overflow where asserted, missing primary actions.

## Manual

- 24 Oct 2026: emulator `emulator-5554`, compact 1080×2340, API 37. Offline-write checklist in `docs/TEST_PLAN.md` section 8b.
- Physical handset: **not executed**.
- Font scale 1.3: covered on some widget tests; not a full device pass.
