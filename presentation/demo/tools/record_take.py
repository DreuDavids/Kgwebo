"""Drive the emulator and capture a Kgwebo demo take via emulator screenrecord."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ADB = Path.home() / "AppData/Local/Android/sdk/platform-tools/adb.exe"
ROOT = Path(r"E:\Personal Apps\Kgwebo\presentation\demo")
RAW = ROOT / "raw"
DEVICE_XML = "/sdcard/Download/ui.xml"
DEVICE_PNG = "/sdcard/Download/kgwebo_cap.png"
EMU_WEBM = Path(r"C:\Users\tumel\AppData\Local\Temp\kgwebo_take.webm")


def adb(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [str(ADB), *args],
        check=check,
        capture_output=True,
        text=True,
    )


def tap(x: int, y: int) -> None:
    adb("shell", "input", "tap", str(x), str(y))
    print(f"  tap {x},{y}", flush=True)


def swipe(x1: int, y1: int, x2: int, y2: int, ms: int = 500) -> None:
    adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))
    print(f"  swipe {x1},{y1}->{x2},{y2}", flush=True)


NAV = {
    "Home": (124, 2199),
    "Money": (332, 2199),
    "Stock": (540, 2199),
    "Ask": (748, 2199),
    "More": (956, 2199),
}


def dump_ui() -> str:
    adb("shell", "uiautomator", "dump", DEVICE_XML)
    pulled = RAW / "_ui.xml"
    adb("pull", DEVICE_XML, str(pulled))
    return pulled.read_text(encoding="utf-8")


def wait_for(needle: str, attempts: int = 8) -> tuple[str, tuple[int, int]]:
    last = ""
    for i in range(attempts):
        try:
            xml = dump_ui()
            last = xml
            return xml, find_center(xml, needle)
        except (RuntimeError, subprocess.CalledProcessError) as exc:
            print(f"  retry {i + 1}/{attempts} for {needle!r}: {exc}", flush=True)
            time.sleep(1.2)
    raise RuntimeError(f"UI node not found after retries: {needle}\n{last[:400]}")


def nodes(xml: str) -> list[tuple[str, int, int]]:
    found: list[tuple[str, int, int]] = []
    for m in re.finditer(
        r'content-desc="([^"]*)"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',
        xml,
    ):
        desc = m.group(1).replace("&#10;", "\n")
        x1, y1, x2, y2 = map(int, m.groups()[1:])
        found.append((desc, (x1 + x2) // 2, (y1 + y2) // 2))
    return found


def find_center(xml: str, needle: str) -> tuple[int, int]:
    needle_l = needle.lower()
    for desc, x, y in nodes(xml):
        if needle_l in desc.lower():
            print(f"  found {needle!r} in {desc.splitlines()[0]!r} @ {x},{y}", flush=True)
            return x, y
    raise RuntimeError(f"UI node not found: {needle}")


def screenshot(name: str) -> Path:
    dest = RAW / name
    adb("shell", "screencap", "-p", DEVICE_PNG)
    adb("pull", DEVICE_PNG, str(dest))
    print(f"  saved {dest} ({dest.stat().st_size} bytes)", flush=True)
    return dest


def enlarge_emulator() -> None:
    script = r"""
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinDemo {
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
"@
$p = Get-Process qemu-system-x86_64 | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { throw "emulator window not found" }
[WinDemo]::ShowWindow($p.MainWindowHandle, 9) | Out-Null
[WinDemo]::MoveWindow($p.MainWindowHandle, 40, 0, 720, 1480, $true) | Out-Null
"""
    subprocess.run(
        ["powershell", "-NoProfile", "-Command", script],
        check=True,
        capture_output=True,
        text=True,
    )
    print("  enlarged emulator window", flush=True)


def emu(command: str) -> str:
    result = adb("emu", command, check=False)
    text = ((result.stdout or "") + (result.stderr or "")).strip()
    print(f"  emu {command[:80]} -> {text}", flush=True)
    return text


def wait(seconds: float) -> None:
    print(f"  wait {seconds:.1f}s", flush=True)
    time.sleep(seconds)


def tap_label(xml: str, label: str) -> None:
    x, y = find_center(xml, f"{label}\n{label}") if "\n" not in label else find_center(xml, label)
    tap(x, y)


def nav(label: str) -> None:
    xml = dump_ui()
    x, y = find_center(xml, f"{label}\n{label}")
    tap(x, y)


def prep_emulator() -> None:
    enlarge_emulator()
    adb("shell", "settings", "put", "global", "heads_up_notifications_enabled", "0", check=False)
    adb("shell", "cmd", "statusbar", "collapse", check=False)
    adb("shell", "input", "keyevent", "KEYCODE_WAKEUP", check=False)
    adb("shell", "svc", "power", "stayon", "true", check=False)


def goto_home() -> None:
    tap(*NAV["Home"])
    wait(2.2)


def locate_targets() -> dict[str, tuple[int, int]]:
    """Discover tap targets before the camera rolls so dumps don't pause the take."""
    targets = dict(NAV)
    goto_home()
    wait_for("Home\nHome")
    screenshot("_home_before_take.png")

    tap(*targets["More"])
    wait(1.6)
    try:
        _, targets["Bills"] = wait_for("Money you still need to pay", attempts=5)
        screenshot("_more_hub.png")
    except RuntimeError:
        tap(*targets["More"])
        wait(1.4)
        _, targets["Bills"] = wait_for("Money you still need to pay", attempts=5)
        screenshot("_more_hub.png")

    tap(*targets["Ask"])
    wait(2.4)
    xml, _ = wait_for("Ask Kgwebo", attempts=6)
    screenshot("_ask_before_take.png")
    try:
        targets["cash_chip"] = find_center(xml, "How much cash do I have?")
    except RuntimeError:
        print("  cash chip missing; will type during take", flush=True)
    try:
        targets["send"] = find_center(xml, "Send")
    except RuntimeError:
        pass
    try:
        targets["composer"] = find_center(xml, "Ask Kgwebo")
    except RuntimeError:
        pass

    tap(*targets["Home"])
    wait(1.8)
    screenshot("_home_ready.png")
    print("TARGETS", targets, flush=True)
    return targets


def start_emu_record(dest: Path) -> None:
    dest.unlink(missing_ok=True)
    text = emu(f"screenrecord start --fps 30 --bit-rate 12M {dest}")
    if "OK" not in text:
        raise RuntimeError(f"screenrecord start failed: {text}")
    wait(0.8)


def stop_emu_record(dest: Path, local_name: str) -> Path:
    emu("screenrecord stop")
    wait(0.8)
    if not dest.exists() or dest.stat().st_size < 50_000:
        raise RuntimeError(f"recording missing or tiny: {dest}")
    out = RAW / local_name
    shutil.copy2(dest, out)
    print(f"  copied {out} ({out.stat().st_size} bytes)", flush=True)
    return out


def relaunch_app() -> None:
    """Clear in-memory Ask history without touching recorded business data."""
    adb("shell", "am", "force-stop", "bw.kgwebo.kgwebo")
    wait(0.8)
    adb(
        "shell",
        "am",
        "start",
        "-n",
        "bw.kgwebo.kgwebo/bw.kgwebo.kgwebo.MainActivity",
    )
    wait(8.0)


def run_take(name: str = "take1.webm") -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    prep_emulator()
    relaunch_app()
    targets = locate_targets()

    start_emu_record(EMU_WEBM)
    t0 = time.monotonic()

    def mark(label: str) -> None:
        print(f"T+{time.monotonic() - t0:5.1f}s  {label}", flush=True)

    mark("dashboard")
    wait(8.0)
    swipe(540, 1680, 540, 920, 420)
    wait(3.5)

    mark("money")
    tap(*targets["Money"])
    wait(8.5)

    mark("bills")
    tap(*targets["More"])
    wait(1.4)
    tap(*targets["Bills"])
    wait(11.0)

    mark("ask")
    tap(*targets["Ask"])
    wait(3.5)
    if "cash_chip" in targets:
        tap(*targets["cash_chip"])
        mark("cash chip tapped")
    else:
        if "composer" in targets:
            tap(*targets["composer"])
            wait(0.5)
        adb("shell", "input", "text", "How%smuch%scash%sdo%si%shave")
        wait(0.7)
        if "send" in targets:
            tap(*targets["send"])
        mark("cash question typed")
    wait(26.0)
    screenshot("_ask_after_reply.png")

    mark("home close")
    tap(*targets["Home"])
    wait(5.5)

    mark("stop")
    stop_emu_record(EMU_WEBM, name)
    screenshot("_home_after_take.png")
    print(f"take duration ~{time.monotonic() - t0:.1f}s", flush=True)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "take"
    if cmd == "home":
        RAW.mkdir(parents=True, exist_ok=True)
        prep_emulator()
        goto_home()
        screenshot("_home_prep.png")
    elif cmd == "targets":
        RAW.mkdir(parents=True, exist_ok=True)
        prep_emulator()
        locate_targets()
    else:
        run_take(sys.argv[2] if len(sys.argv) > 2 else "take1.webm")
