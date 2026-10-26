"""Punchier recut: animated titles, Mixkit bed, natural VO, lime captions."""

from __future__ import annotations

import subprocess
from pathlib import Path

FFMPEG = Path(
    r"E:\Personal Apps\Kgwebo\presentation\.venv\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
)
ROOT = Path(r"E:\Personal Apps\Kgwebo\presentation\demo")
RAW = ROOT / "raw"
OUT = ROOT / "Kgwebo_Demo_2026.mp4"
FONT = Path(r"E:\Personal Apps\Kgwebo\assets\fonts\PlusJakartaSans-Bold.ttf")
TAKE = RAW / "take2.webm"
MUSIC = RAW / "music_driving_ambition.mp3"

# Ink letterbox, phone almost full-height, footer for lime captions.
PHONE = (
    "scale=840:1780:force_original_aspect_ratio=decrease,"
    "pad=1080:1920:(ow-iw)/2:28:0x111111,"
    "fps=30,format=yuv420p"
)
ENCODE = [
    "-c:v",
    "libx264",
    "-preset",
    "medium",
    "-crf",
    "16",
    "-pix_fmt",
    "yuv420p",
    "-an",
]


def run(args: list[str]) -> None:
    print("+", " ".join(str(a) for a in args[:10]), "...")
    subprocess.run(args, check=True)


def ff(*args: str) -> None:
    run([str(FFMPEG), "-y", *args])


def duration(path: Path) -> float:
    probe = subprocess.run(
        [str(FFMPEG), "-i", str(path), "-f", "null", "-"],
        capture_output=True,
        text=True,
    )
    last = "0"
    for line in probe.stderr.splitlines():
        if "time=" in line:
            last = line.split("time=")[1].split()[0]
    if last in {"0", "N/A"}:
        return 0.0
    h, m, s = last.split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


def animated_title(png: Path, seconds: float, dest: Path, fade_out: float = 0.28) -> None:
    vf = (
        "scale=1080:1920,"
        f"fade=t=in:st=0:d=0.22,fade=t=out:st={seconds - fade_out:.2f}:d={fade_out},"
        "fps=30,format=yuv420p"
    )
    ff(
        "-loop",
        "1",
        "-framerate",
        "30",
        "-t",
        f"{seconds:.3f}",
        "-i",
        str(png),
        "-vf",
        vf,
        "-r",
        "30",
        *ENCODE,
        str(dest),
    )


def take_clip(
    start: float,
    seconds: float,
    dest: Path,
    speed: float = 1.0,
    hold_end: float = 0.0,
) -> None:
    parts = [PHONE]
    if speed != 1.0:
        parts.append(f"setpts=PTS/{speed:.4f}")
    if hold_end > 0:
        parts.append(f"tpad=stop_mode=clone:stop_duration={hold_end:.3f}")
    ff(
        "-ss",
        f"{start:.3f}",
        "-t",
        f"{seconds:.3f}",
        "-i",
        str(TAKE),
        "-vf",
        ",".join(parts),
        "-r",
        "30",
        *ENCODE,
        str(dest),
    )


def concat(parts: list[Path], dest: Path) -> None:
    listing = RAW / "concat_win.txt"
    listing.write_text(
        "\n".join(f"file '{p.as_posix()}'" for p in parts) + "\n",
        encoding="utf-8",
    )
    ff("-f", "concat", "-safe", "0", "-i", str(listing), "-c", "copy", str(dest))


def fontfile() -> str:
    return str(FONT).replace("\\", "/").replace(":", "\\:")


def caption_filter(marks: list[tuple[float, float, str]]) -> str:
    parts = [
        "fade=t=in:st=0:d=0.12",
    ]
    for start, end, text in marks:
        escaped = text.replace("\\", "\\\\").replace("'", "\\'")
        parts.append(
            "drawtext="
            f"fontfile='{fontfile()}':"
            f"text='{escaped}':"
            "fontsize=42:fontcolor=0x111111:"
            "box=1:boxcolor=0xC6FF4A@0.96:boxborderw=20:"
            "x=(w-text_w)/2:y=h-92:"
            f"enable='between(t,{start:.2f},{end:.2f})'"
        )
    return ",".join(parts)


def main() -> None:
    RAW.mkdir(parents=True, exist_ok=True)

    title = RAW / "w_title.mp4"
    dash = RAW / "w_dash.mp4"
    money = RAW / "w_money.mp4"
    bills = RAW / "w_bills.mp4"
    ask_in = RAW / "w_ask_in.mp4"
    think = RAW / "w_think.mp4"
    reply = RAW / "w_reply.mp4"
    home = RAW / "w_home.mp4"
    close = RAW / "w_close.mp4"

    animated_title(RAW / "title_open.png", 3.2, title)
    take_clip(0.35, 11.20, dash)
    take_clip(12.30, 7.40, money)
    take_clip(23.60, 9.40, bills)
    take_clip(33.30, 3.70, ask_in)
    take_clip(37.20, 16.80, think, speed=1.38)
    take_clip(54.00, 9.30, reply, hold_end=2.40)
    take_clip(64.10, 4.80, home)
    animated_title(RAW / "title_close.png", 5.20, close, fade_out=0.45)

    parts = [title, dash, money, bills, ask_in, think, reply, home, close]
    silent = RAW / "w_concat.mp4"
    concat(parts, silent)

    starts: list[float] = []
    t = 0.0
    for part in parts:
        d = duration(part)
        starts.append(t)
        print(f"  {part.name:16} {d:6.2f}s  start {t:6.2f}")
        t += d
    total = t
    print(f"concat duration {total:.2f}s")
    if total >= 90:
        raise SystemExit(f"cut is too long: {total:.2f}s")

    cap = [
        (starts[1] + 0.25, starts[2] - 0.12, "CASH ON HAND"),
        (starts[2] + 0.20, starts[3] - 0.12, "THE LEDGER"),
        (starts[3] + 0.35, starts[4] - 0.12, "WHAT CASH WILL BE LEFT"),
        (starts[4] + 0.20, starts[6] - 0.05, "JUST ASK"),
        (starts[6] + 0.15, starts[7] - 0.10, "FROM THE BOOKS  —  NOT THE MODEL"),
        (starts[7] + 0.15, starts[8] - 0.15, "CLEARER CALLS"),
    ]
    captioned = RAW / "w_captioned.mp4"
    ff(
        "-i",
        str(silent),
        "-vf",
        caption_filter(cap),
        *ENCODE,
        str(captioned),
    )

    vo = [
        (RAW / "v2_n1.mp3", 0.12),
        (RAW / "v2_n2.mp3", starts[1] + 0.18),
        (RAW / "v2_n3.mp3", starts[2] + 0.18),
        (RAW / "v2_n4.mp3", starts[3] + 0.35),
        (RAW / "v2_n5.mp3", starts[4] + 0.15),
        (RAW / "v2_n6.mp3", starts[6] + 0.20),
        (RAW / "v2_n7.mp3", starts[8] + 0.18),
    ]
    inputs = ["-i", str(captioned), "-i", str(MUSIC)]
    delay_filters = []
    mix_labels = []
    for i, (path, start) in enumerate(vo, start=2):
        inputs.extend(["-i", str(path)])
        ms = int(start * 1000)
        delay_filters.append(
            f"[{i}:a]adelay={ms}|{ms},aresample=44100,aformat=channel_layouts=stereo,volume=2.1[v{i}]"
        )
        mix_labels.append(f"[v{i}]")
    n_vo = len(vo)
    filt = (
        f"[1:a]atrim=0:{total:.3f},asetpts=PTS-STARTPTS,aresample=44100,"
        "aformat=channel_layouts=stereo,volume=0.22[music];"
        + ";".join(delay_filters)
        + ";"
        + "".join(mix_labels)
        + f"amix=inputs={n_vo}:normalize=0:dropout_transition=2,alimiter=limit=0.92,asplit=2[voicea][voiceb];"
        "[music][voicea]sidechaincompress=threshold=0.032:ratio=8:attack=12:release=280:makeup=2[bed];"
        "[bed][voiceb]amix=inputs=2:duration=first:dropout_transition=0,alimiter=limit=0.96[aout]"
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
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes) duration {total:.2f}s")


if __name__ == "__main__":
    main()
