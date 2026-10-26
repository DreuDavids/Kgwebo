"""Title and closing cards matching the live Kgwebo visual identity."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(r"E:\Personal Apps\Kgwebo")
OUT = ROOT / "presentation" / "demo" / "raw"
FONTS = ROOT / "assets" / "fonts"
W, H = 1080, 1920
INK = (17, 17, 17, 255)
LIME = (198, 255, 74, 255)
CANVAS = (244, 245, 247, 255)
MUTED = (107, 114, 128, 255)
WHITE = (255, 255, 255, 255)


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def rounded_rect(draw: ImageDraw.ImageDraw, xy, radius: int, fill) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill)


def mark(draw: ImageDraw.ImageDraw, cx: int, cy: int, size: int = 120) -> None:
    half = size // 2
    rounded_rect(
        draw,
        (cx - half, cy - half, cx + half, cy + half),
        radius=size // 4,
        fill=LIME,
    )
    k = font("PlusJakartaSans-Bold.ttf", int(size * 0.62))
    bbox = draw.textbbox((0, 0), "K", font=k)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((cx - tw / 2 - bbox[0], cy - th / 2 - bbox[1] - size * 0.04), "K", font=k, fill=INK)


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = word if not current else f"{current} {word}"
        if draw.textbbox((0, 0), trial, font=fnt)[2] <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def card(path: Path, heading: str, sub: str, footer: str | None = None) -> None:
    img = Image.new("RGBA", (W, H), INK)
    draw = ImageDraw.Draw(img)
    mark(draw, W // 2, 620, 132)
    heading_font = font("Fraunces-SemiBold.ttf", 92)
    sub_font = font("PlusJakartaSans-Regular.ttf", 36)
    footer_font = font("PlusJakartaSans-SemiBold.ttf", 28)

    y = 780
    for line in wrap(draw, heading, heading_font, 860):
        bbox = draw.textbbox((0, 0), line, font=heading_font)
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) / 2, y), line, font=heading_font, fill=WHITE)
        y += 108

    y += 28
    for line in wrap(draw, sub, sub_font, 820):
        bbox = draw.textbbox((0, 0), line, font=sub_font)
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) / 2, y), line, font=sub_font, fill=LIME)
        y += 52

    if footer:
        bbox = draw.textbbox((0, 0), footer, font=footer_font)
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) / 2, 1680), footer, font=footer_font, fill=MUTED)

    img.convert("RGB").save(path, quality=95)
    print(f"wrote {path}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    card(
        OUT / "title_open.png",
        "Kgwebo",
        "See the cash. Then decide.",
        "FNB App of the Year 2026",
    )
    card(
        OUT / "title_close.png",
        "Kgwebo",
        "Clearer records. Clearer calls.",
        "Your business. Stronger decisions.",
    )


if __name__ == "__main__":
    main()
