"""Cut take 2, add titles, captions, and narration into the submission MP4."""

from __future__ import annotations

import subprocess
from pathlib import Path

FFMPEG = Path(
    r"E:\Personal Apps\Kgwebo\presentation\.venv\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
)
ROOT = Path(r"E:\Personal Apps\Kgwebo\presentation\demo")
RAW = ROOT / "raw"
OUT = ROOT / "Kgwebo_Demo_2026.mp4"
SHOTS = ROOT / "Kgwebo_Demo_Screenshots"
FONT = Path(r"E:\Personal Apps\Kgwebo\assets\fonts\PlusJakartaSans-SemiBold.ttf")
TAKE = RAW / "take2.webm"

PHONE = (
    "scale=804:1760:force_original_aspect_ratio=decrease,"
    "pad=1080:1920:(ow-iw)/2:36:0xF4F5F7,"
    "fps=30,format=yuv420p"
)
ENCODE = ["-c:v", "libx264", "-preset", "medium", "-crf", "16", "-pix_fmt", "yuv420p", "-an"]


def run(args: list[str]) -> None:
    print("+", " ".join(str(a) for a in args[:8]), "...")
    subprocess.run(args, check=True)


def ff(*args: str) -> None:
    run([str(FFMPEG), "-y", *args])


def duration(path: Path) -> float:
    probe = subprocess.run(
        [
            str(FFMPEG),
            "-i",
            str(path),
            "-f",
            "null",
            "-",
        ],
        capture_output=True,
        text=True,
    )
    text = probe.stderr
    # last time= in the encode/null output
    last = "0"
    for line in text.splitlines():
        if "time=" in line:
            part = line.split("time=")[1].split()[0]
            last = part
    h, m, s = last.split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


def title_clip(png: Path, seconds: float, dest: Path) -> None:
    ff(
        "-loop",
        "1",
        "-t",
        f"{seconds:.3f}",
        "-i",
        str(png),
        "-vf",
        f"scale=1080:1920,fps=30,format=yuv420p",
        *ENCODE,
        str(dest),
    )


def take_clip(start: float, seconds: float, dest: Path, speed: float = 1.0) -> None:
    vf = PHONE if speed == 1.0 else f"{PHONE},setpts=PTS/{speed:.4f}"
    ff(
        "-ss",
        f"{start:.3f}",
        "-t",
        f"{seconds:.3f}",
        "-i",
        str(TAKE),
        "-vf",
        vf,
        "-r",
        "30",
        *ENCODE,
        str(dest),
    )


def concat(parts: list[Path], dest: Path) -> None:
    listing = RAW / "concat.txt"
    listing.write_text(
        "\n".join(f"file '{p.as_posix()}'" for p in parts) + "\n",
        encoding="utf-8",
    )
    ff("-f", "concat", "-safe", "0", "-i", str(listing), "-c", "copy", str(dest))


def fontfile() -> str:
    return str(FONT).replace("\\", "/").replace(":", "\\:")


def caption_filter(marks: list[tuple[float, float, str]]) -> str:
    parts = []
    for start, end, text in marks:
        escaped = text.replace("\\", "\\\\").replace("'", "\\'")
        parts.append(
            "drawtext="
            f"fontfile='{fontfile()}':"
            f"text='{escaped}':"
            "fontsize=34:fontcolor=0x111111:"
            "borderw=0:"
            "box=1:boxcolor=white@0.94:boxborderw=16:"
            "x=(w-text_w)/2:y=h-96:"
            f"enable='between(t,{start:.2f},{end:.2f})'"
        )
    return ",".join(parts)


def main() -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    SHOTS.mkdir(parents=True, exist_ok=True)

    title = RAW / "v_title.mp4"
    dash = RAW / "v_dash.mp4"
    money = RAW / "v_money.mp4"
    bills = RAW / "v_bills.mp4"
    ask_in = RAW / "v_ask_in.mp4"
    think = RAW / "v_think.mp4"
    reply = RAW / "v_reply.mp4"
    home = RAW / "v_home.mp4"
    close = RAW / "v_close.mp4"

    title_clip(RAW / "title_open.png", 5.2, title)
    take_clip(0.40, 11.50, dash)
    take_clip(12.25, 8.20, money)
    take_clip(20.80, 12.20, bills)
    take_clip(33.20, 4.00, ask_in)
    take_clip(37.20, 16.80, think, speed=1.45)
    take_clip(54.00, 9.40, reply)
    take_clip(63.50, 5.50, home)
    title_clip(RAW / "title_close.png", 7.80, close)

    parts = [title, dash, money, bills, ask_in, think, reply, home, close]
    silent = RAW / "v_concat.mp4"
    concat(parts, silent)

    starts = []
    t = 0.0
    durs = []
    for part in parts:
        d = duration(part)
        durs.append(d)
        starts.append(t)
        print(f"  {part.name:16} {d:6.2f}s  start {t:6.2f}")
        t += d
    total = t
    print(f"concat duration {total:.2f}s")

    # Caption windows follow assembled timeline.
    cap = [
        (starts[1] + 0.4, starts[2] - 0.2, "Recorded cash and October sales"),
        (starts[2] + 0.3, starts[3] - 0.2, "Everyday sales and expenses"),
        (starts[3] + 2.0, starts[4] - 0.2, "Cash after unpaid bills"),
        (starts[6] + 0.2, starts[7] - 0.15, "From recorded Kgwebo data"),
        (starts[7] + 0.2, starts[8] - 0.2, "Records and answers, together"),
    ]
    captioned = RAW / "v_captioned.mp4"
    ff(
        "-i",
        str(silent),
        "-vf",
        caption_filter(cap),
        "-c:v",
        "libx264",
        "-preset",
        "medium",
        "-crf",
        "16",
        "-pix_fmt",
        "yuv420p",
        "-an",
        str(captioned),
    )

    # Narration starts
    voice_at = {
        "n1_open.mp3": 0.15,
        "n2_home.mp3": starts[1] + 0.25,
        "n3_money.mp3": starts[2] + 0.25,
        "n4_bills.mp3": starts[3] + 1.6,
        "n5_ask.mp3": starts[6] + 0.15,
        "n6_close.mp3": starts[7] + 0.2,
    }
    inputs = ["-i", str(captioned)]
    delays = []
    mix = []
    for i, (name, start) in enumerate(voice_at.items(), start=1):
        inputs.extend(["-i", str(RAW / name)])
        ms = int(start * 1000)
        delays.append(
            f"[{i}:a]adelay={ms}|{ms},aresample=44100,aformat=channel_layouts=stereo,volume=1.6[a{i}]"
        )
        mix.append(f"[a{i}]")
    filt = ";".join(delays)
    filt += (
        ";"
        + "".join(mix)
        + f"amix=inputs={len(mix)}:normalize=0:dropout_transition=2,alimiter=limit=0.95[aout]"
    )
    ff(
        *inputs,
        "-filter_complex",
        filt,
        "-map",
        "0:v",
        "-map",
        "[aout]",
        "-c:v",
        "copy",
        "-c:a",
        "aac",
        "-b:a",
        "192k",
        "-t",
        f"{total:.3f}",
        "-movflags",
        "+faststart",
        str(OUT),
    )
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")

    # Key stills for the screenshots folder
    stills = {
        "01-dashboard.png": 10.0,
        "02-money.png": 16.0,
        "03-bills.png": 28.0,
        "04-ask-question.png": 40.0,
        "05-ask-reply.png": 62.0,
        "06-home.png": 67.0,
    }
    for name, ss in stills.items():
        ff(
            "-ss",
            f"{ss:.2f}",
            "-i",
            str(TAKE),
            "-frames:v",
            "1",
            str(SHOTS / name),
        )
    for name in ("title_open.png", "title_close.png"):
        (SHOTS / name).write_bytes((RAW / name).read_bytes())


if __name__ == "__main__":
    main()
