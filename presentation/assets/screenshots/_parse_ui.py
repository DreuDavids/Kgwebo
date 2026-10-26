import re
from pathlib import Path

t = Path(r"E:\Personal Apps\Kgwebo\presentation\assets\screenshots\_ui.xml").read_text(
    encoding="utf-8"
)
for m in re.finditer(
    r'content-desc="([^"]+)"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',
    t,
):
    desc = m.group(1).replace("&#10;", " | ")
    if desc.strip():
        print(f"{desc:60} {m.group(2)},{m.group(3)}-{m.group(4)},{m.group(5)}")
