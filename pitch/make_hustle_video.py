"""Render Kgwebo's 20-second robots hustle pitch."""

from __future__ import annotations

import asyncio
from pathlib import Path

import edge_tts
import numpy as np
from moviepy import AudioFileClip, VideoClip, concatenate_videoclips
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
STILLS = ROOT / "stills"
FONTS = ROOT.parent / "assets" / "fonts"
VOICE_PATH = ROOT / "kgwebo-hustle-vo.mp3"
OUT_PATH = ROOT / "kgwebo-20s-hustle.mp4"

W, H, FPS = 1080, 1920, 30
LIME = (198, 255, 74, 255)
WHITE = (255, 255, 255, 255)
INK = (17, 17, 17, 255)
TARGET_SECONDS = 20.0

VOICE = "en-ZA-LeahNeural"
SPOKEN = (
    "Small shops take money all day and still can't tell profit from cash. "
    "For your stall, your spaza, your WhatsApp hustle, Kgwebo's got you. "
    "Built for traders, not office apps. Free to download, privacy encrypted. "
    "See cash, stock, and bills coming, with a live cash-flow engine. "
    "Money in the till, peace in the mind, with Kgwebo."
)

SCENES = [
    {
        "file": "01-robots.jpg",
        "headline": "Profit... or just cash?",
        "support": "Most shops cannot tell.",
        "weight": 4.0,
        "zoom": (1.0, 1.12),
    },
    {
        "file": "02-till.jpg",
        "headline": "Kgwebo got you.",
        "support": "Stall. Spaza. WhatsApp hustle.",
        "weight": 4.2,
        "zoom": (1.08, 1.0),
    },
    {
        "file": "03-phone.jpg",
        "headline": "Traders, not accountants.",
        "support": "Free download. Encrypted. Yours.",
        "weight": 4.4,
        "zoom": (1.0, 1.1),
    },
    {
        "file": "04-confidence.jpg",
        "headline": "Cash. Stock. Bills coming.",
        "support": "A live cash-flow engine.",
        "weight": 4.0,
        "zoom": (1.05, 1.0),
    },
    {
        "file": "05-brand.jpg",
        "headline": "Clearer decisions.",
        "support": "Stronger growth. With Kgwebo.",
        "weight": 3.4,
        "zoom": (1.0, 1.08),
    },
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def cover_image(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGB")
    scale = max(W / im.width, H / im.height) * 1.18
    im = im.resize((max(int(im.width * scale), W + 8), max(int(im.height * scale), H + 8)), Image.Resampling.LANCZOS)
    return im


def ken_burns(path: Path, duration: float, zoom_from: float, zoom_to: float, overlay: Image.Image) -> VideoClip:
    source = cover_image(path)
    sw, sh = source.size
    overlay_rgba = overlay.convert("RGBA")

    def make_frame(t: float) -> np.ndarray:
        p = 0.0 if duration <= 0 else min(max(t / duration, 0.0), 1.0)
        z = zoom_from + (zoom_to - zoom_from) * p
        crop_w = min(int(W / z), sw)
        crop_h = min(int(H / z), sh)
        max_x = max(sw - crop_w, 0)
        max_y = max(sh - crop_h, 0)
        x = int(max_x * (0.18 + 0.62 * p))
        y = int(max_y * (0.22 * (1.0 - p) + 0.08))
        frame = source.crop((x, y, x + crop_w, y + crop_h)).resize((W, H), Image.Resampling.BILINEAR)
        return np.array(Image.alpha_composite(frame.convert("RGBA"), overlay_rgba).convert("RGB"))

    return VideoClip(make_frame, duration=duration).with_fps(FPS)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, face: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = word if not current else f"{current} {word}"
        if draw.textlength(trial, font=face) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines or [text]


def caption_overlay(headline: str, support: str) -> Image.Image:
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shade_draw = ImageDraw.Draw(shade)
    for i in range(780):
        alpha = int(210 * (i / 779) ** 1.35)
        y = H - 780 + i
        shade_draw.line([(0, y), (W, y)], fill=(8, 8, 8, alpha))
    overlay = Image.alpha_composite(overlay, shade)

    draw = ImageDraw.Draw(overlay)
    display = font("Fraunces-SemiBold.ttf", 74)
    body = font("PlusJakartaSans-SemiBold.ttf", 36)
    mark = font("PlusJakartaSans-Bold.ttf", 28)

    draw.rounded_rectangle((48, 64, 236, 118), radius=28, fill=LIME)
    draw.text((72, 76), "KGWEBO", font=mark, fill=INK)

    max_width = W - 120
    headlines = wrap_text(draw, headline, display, max_width)
    supports = wrap_text(draw, support, body, max_width)
    line_h = 86
    support_h = 48
    block_h = len(headlines) * line_h + 18 + len(supports) * support_h
    y = H - 120 - block_h

    draw.rectangle((48, y - 18, 48 + 72, y - 10), fill=LIME)

    for line in headlines:
        # Soft shadow for street-legibility
        draw.text((52, y + 3), line, font=display, fill=(0, 0, 0, 180))
        draw.text((48, y), line, font=display, fill=WHITE)
        y += line_h
    y += 8
    for line in supports:
        draw.text((50, y + 2), line, font=body, fill=(0, 0, 0, 160))
        draw.text((48, y), line, font=body, fill=LIME)
        y += support_h
    return overlay


async def synthesize_voice() -> None:
    communicate = edge_tts.Communicate(
        SPOKEN,
        VOICE,
        rate="+32%",
        pitch="+3Hz",
    )
    await communicate.save(str(VOICE_PATH))


def fit_audio(audio: AudioFileClip) -> AudioFileClip:
    if audio.duration > TARGET_SECONDS + 0.05:
        return audio.with_speed_scaled(audio.duration / TARGET_SECONDS)
    return audio.subclipped(0, max(0.1, audio.duration - 0.05))


def build() -> None:
    if not VOICE_PATH.exists():
        asyncio.run(synthesize_voice())

    audio = fit_audio(AudioFileClip(str(VOICE_PATH)))
    runtime = min(TARGET_SECONDS, audio.duration)
    total_weight = sum(scene["weight"] for scene in SCENES)
    clips = []
    for scene in SCENES:
        duration = runtime * (scene["weight"] / total_weight)
        still = STILLS / scene["file"]
        if not still.exists():
            raise FileNotFoundError(still)
        zoom_from, zoom_to = scene["zoom"]
        overlay = caption_overlay(scene["headline"], scene["support"])
        clips.append(ken_burns(still, duration, zoom_from, zoom_to, overlay).with_duration(duration))

    video = concatenate_videoclips(clips, method="compose").with_audio(audio).with_duration(runtime)
    video.write_videofile(
        str(OUT_PATH),
        fps=FPS,
        codec="libx264",
        audio_codec="aac",
        bitrate="8000k",
        ffmpeg_params=["-pix_fmt", "yuv420p", "-movflags", "+faststart"],
        logger="bar",
    )
    video.close()
    audio.close()
    print(f"Wrote {OUT_PATH} ({TARGET_SECONDS:.1f}s)")


if __name__ == "__main__":
    build()
