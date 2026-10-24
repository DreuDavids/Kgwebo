import asyncio
from pathlib import Path

import edge_tts
from moviepy import AudioFileClip

OUT = Path(__file__).resolve().parent / "kgwebo-hustle-vo.mp3"
SPOKEN = (
    "Small shops take money all day and still can't tell profit from cash. "
    "For your stall, your spaza, your WhatsApp hustle, Kgwebo's got you. "
    "Built for traders, not office apps. Free to download, privacy encrypted. "
    "See cash, stock, and bills coming, with a live cash-flow engine. "
    "Money in the till, peace in the mind, with Kgwebo."
)


async def synth(rate: str) -> float:
    communicate = edge_tts.Communicate(SPOKEN, "en-ZA-LeahNeural", rate=rate, pitch="+3Hz")
    await communicate.save(str(OUT))
    audio = AudioFileClip(str(OUT))
    duration = audio.duration
    audio.close()
    print(rate, round(duration, 2))
    return duration


async def main() -> None:
    print("WORDS", len(SPOKEN.split()))
    chosen = "+28%"
    best_gap = 999.0
    for rate in ("+18%", "+26%", "+32%", "+38%"):
        duration = await synth(rate)
        gap = abs(duration - 20.0)
        if gap < best_gap:
            best_gap = gap
            chosen = rate
        if 19.5 <= duration <= 20.5:
            print("LOCKED", rate, duration)
            return
    await synth(chosen)
    print("CLOSEST", chosen)


if __name__ == "__main__":
    asyncio.run(main())
