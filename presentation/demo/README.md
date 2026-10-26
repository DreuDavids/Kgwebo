# Kgwebo 2026 demo video

Submission cut:

- [`Kgwebo_Demo_2026.mp4`](Kgwebo_Demo_2026.mp4) — H.264, AAC, 1080×1920, 30 fps, **68.83 s**
- [`Kgwebo_Demo_Script.md`](Kgwebo_Demo_Script.md)
- [`Kgwebo_Demo_Screenshots/`](Kgwebo_Demo_Screenshots/)

Visual identity matches the live app: ink `#111111`, lime `#C6FF4A`, canvas `#F4F5F7`, Fraunces + Plus Jakarta Sans.

## What was recorded

Real Android emulator footage of the signed-in **DreuTech** stall (illustrative ZAR records). No production database seed, no scripted chat overlay.

Journey: **Home** → **Money** → **More → Bills** → **Ask** (“How much cash do I have?”) → **Home**.

Ask is the in-app copilot. The reply on screen is generated live and labelled **From recorded Kgwebo data**. Totals match Home (cash ZAR 31,840.00, October sales ZAR 30,900.00, expenses ZAR 1,310.00). The video does not claim an on-device LLM, a bank balance, or that Ask posts to the ledger.

A new sale was **not** recorded, so live DreuTech data was not changed. Money history stands in for the everyday recording workflow.

## Recording

Emulator: Pixel 10 Pro Fold, cover display **1080×2364**, portrait, `adb` serial `emulator-5554`. App package `bw.kgwebo.kgwebo`, debug banner already off.

Android `screenrecord` on this AVD writes a broken one-frame MP4. Recording used the emulator console instead:

```text
adb emu screenrecord start --fps 30 --bit-rate 12M C:\Users\tumel\AppData\Local\Temp\kgwebo_take.webm
adb emu screenrecord stop
```

The QEMU window must be enlarged (about 720×1480) or the capture stays ~562×1230. `tools/record_take.py` resizes the window, drives taps from the UI dump, then copies the WebM into `raw/`.

Selected take: `raw/take2.webm` (70.0 s, 1080×2364, VP9, ~10 Mbps). `raw/take1.webm` missed the Bills row.

## Edit

`tools/edit_win.py` plus bundled FFmpeg from `presentation/.venv` (`imageio-ffmpeg`).

- Punchier titles from `tools/make_titles.py` (“See the cash. Then decide.”)
- Tighter cuts; Ask “Thinking” is time-compressed **1.38×**
- Ink letterbox and lime caption bars
- Voice: Microsoft neural `en-US-AndrewMultilingualNeural` (conversational, slightly low pitch)
- Music: Mixkit [Driving Ambition](https://mixkit.co/free-stock-music/driving-ambition/) by Ahjay Stelino, Mixkit License (royalty-free for online video; attribution appreciated, not required). Ducked under the voice.

Rebuild:

```powershell
Set-Location "E:\Personal Apps\Kgwebo\presentation"
.\.venv\Scripts\python.exe .\demo\tools\make_titles.py
.\.venv\Scripts\python.exe .\demo\tools\edit_win.py
```

Re-record a take (emulator must already be running and signed in):

```powershell
.\.venv\Scripts\python.exe .\demo\tools\record_take.py take take3.webm
```

## Validation (this cut)

| Check    | Result                                           |
| -------- | ------------------------------------------------ |
| Path     | `presentation/demo/Kgwebo_Demo_2026.mp4`         |
| Duration | 68.83 s (under 90; tighter trailer cut)          |
| Codec    | H.264 High + AAC LC, `+faststart`                |
| Size     | 1080×1920 @ 30 fps                               |
| Decode   | `ffmpeg -v error -i … -f null -` exit 0          |
| Audio    | mean −21.8 dB, peak −3.2 dB                      |
| Footage  | Live emulator, not a mock                        |
| Ask      | Live grounded reply, readable at ~0:53–1:02      |
| Secrets  | No passwords, tokens, or personal data on screen |

Play the MP4 locally to confirm narration. Frames in `raw/check/` were inspected after export.

## Honest limits

- Emulator only (no physical-handset pass).
- DreuTech figures are illustrative, not a bank feed.
- Ask cloud round-trip is slow; thinking is slightly sped up in the cut.
- The question is entered with the real Ask chip, not the software keyboard.
- Vertical 1080p so the phone UI stays readable. A 16:9 crop would shrink the screen too far.
