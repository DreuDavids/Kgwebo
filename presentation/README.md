# Kgwebo presentation — FNB App of the Year 2026

Deliverables:

- [`Kgwebo_FNB_App_of_the_Year_2026.pptx`](Kgwebo_FNB_App_of_the_Year_2026.pptx)
- [`Kgwebo_FNB_App_of_the_Year_2026.pdf`](Kgwebo_FNB_App_of_the_Year_2026.pdf)
- [`PRESENTER_GUIDE.md`](PRESENTER_GUIDE.md)
- [`assets/screenshots/`](assets/screenshots/) — real emulator captures from the running Android app

The deck is 12 widescreen (16:9) slides. Visual identity matches the live app: ink `#111111`, lime `#C6FF4A`, canvas `#F4F5F7`, Plus Jakarta Sans, Fraunces for the mark.

Slides 5–6 are the DreuTech Monday story (restock vs rent). Slides 9–10 are the architecture stack and the record/Ask pipelines. There is no roadmap slide and no standalone security slide; isolation is stated as part of the architecture.

## Judge demo account

Printed on slides 1 and 12, and in the footer:

- Email: `dreu.davids1@gmail.com`
- Password: `password`
- Stall: DreuTech (illustrative / synthetic ZAR records)

Do not put Supabase service-role keys, `.env` values, or LiteLLM secrets in the deck.

## Regenerate

From this folder, using an isolated venv (not the Flutter app):

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe .\build_deck.py
```

Export PDF with PowerPoint (this machine):

```powershell
$pptx = "$PWD\Kgwebo_FNB_App_of_the_Year_2026.pptx"
$pdf  = "$PWD\Kgwebo_FNB_App_of_the_Year_2026.pdf"
$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = 1
$pres = $ppt.Presentations.Open($pptx)
$pres.SaveAs($pdf, 32)
$pres.Close()
$ppt.Quit()
```

Install Plus Jakarta Sans and Fraunces from `../assets/fonts/` if PowerPoint substitutes fonts.

## Recapture screenshots

Requires a running emulator with the current debug build, signed in as the judge account.

```powershell
python .\assets\screenshots\_adb_cap.py cap 01-dashboard.png
```

Replace files `00-welcome.png` through `09-reports.png`, then run `build_deck.py` again.

Do not use `APP_ENV=demo`. That mode is an empty labelled shell.
