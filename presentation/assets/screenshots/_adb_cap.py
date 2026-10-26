"""Emulator helpers: screenshot, tap, swipe, dump UI labels."""

from __future__ import annotations

import argparse
import re
import subprocess
import time
from pathlib import Path

ROOT = Path(r"E:\Personal Apps\Kgwebo\presentation\assets\screenshots")
DEVICE_PNG = "/sdcard/Download/kgwebo_cap.png"
DEVICE_XML = "/sdcard/Download/ui.xml"


def adb(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["adb", *args],
        check=check,
        capture_output=True,
        text=True,
    )


def capture(name: str) -> Path:
    dest = ROOT / name
    adb("shell", "screencap", "-p", DEVICE_PNG)
    adb("pull", DEVICE_PNG, str(dest))
    print(f"saved {dest} ({dest.stat().st_size} bytes)")
    return dest


def tap(x: int, y: int) -> None:
    adb("shell", "input", "tap", str(x), str(y))
    print(f"tap {x},{y}")


def swipe(x1: int, y1: int, x2: int, y2: int, ms: int = 400) -> None:
    adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))
    print(f"swipe {x1},{y1} -> {x2},{y2}")


def key(name: str) -> None:
    adb("shell", "input", "keyevent", name)
    print(f"key {name}")


def type_text(text: str) -> None:
    escaped = text.replace(" ", "%s").replace("'", "\\'")
    adb("shell", "input", "text", escaped)
    print(f"type {text!r}")


def dump_ui() -> list[tuple[str, int, int, int, int]]:
    adb("shell", "uiautomator", "dump", DEVICE_XML)
    dest = ROOT / "_ui.xml"
    adb("pull", DEVICE_XML, str(dest))
    xml = dest.read_text(encoding="utf-8")
    rows: list[tuple[str, int, int, int, int]] = []
    for m in re.finditer(
        r'content-desc="([^"]+)"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',
        xml,
    ):
        desc = m.group(1).replace("&#10;", " | ")
        if desc.strip():
            rows.append(
                (desc, int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)))
            )
            print(f"{desc:60} {m.group(2)},{m.group(3)}-{m.group(4)},{m.group(5)}")
    return rows


def center(bounds: tuple[int, int, int, int]) -> tuple[int, int]:
    x1, y1, x2, y2 = bounds
    return (x1 + x2) // 2, (y1 + y2) // 2


def find_label(rows: list[tuple[str, int, int, int, int]], needle: str) -> tuple[int, int]:
    needle_l = needle.lower()
    for desc, x1, y1, x2, y2 in rows:
        if needle_l in desc.lower():
            return center((x1, y1, x2, y2))
    raise SystemExit(f"label not found: {needle}")


def main() -> None:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("cap")
    c.add_argument("name")
    t = sub.add_parser("tap")
    t.add_argument("x", type=int)
    t.add_argument("y", type=int)
    s = sub.add_parser("swipe")
    s.add_argument("x1", type=int)
    s.add_argument("y1", type=int)
    s.add_argument("x2", type=int)
    s.add_argument("y2", type=int)
    k = sub.add_parser("key")
    k.add_argument("name")
    ty = sub.add_parser("type")
    ty.add_argument("text")
    sub.add_parser("ui")
    tl = sub.add_parser("tap-label")
    tl.add_argument("needle")
    w = sub.add_parser("wait")
    w.add_argument("seconds", type=float)
    args = p.parse_args()
    if args.cmd == "cap":
        capture(args.name)
    elif args.cmd == "tap":
        tap(args.x, args.y)
    elif args.cmd == "swipe":
        swipe(args.x1, args.y1, args.x2, args.y2)
    elif args.cmd == "key":
        key(args.name)
    elif args.cmd == "type":
        type_text(args.text)
    elif args.cmd == "ui":
        dump_ui()
    elif args.cmd == "tap-label":
        rows = dump_ui()
        x, y = find_label(rows, args.needle)
        tap(x, y)
    elif args.cmd == "wait":
        time.sleep(args.seconds)


if __name__ == "__main__":
    main()
