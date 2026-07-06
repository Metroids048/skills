"""Verify .ps1 is parseable on Windows PS 5.1. Exit 0=OK, 1=fail."""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


def read_text(path: Path) -> tuple[str, bool]:
    raw = path.read_bytes()
    has_bom = raw[:3] == b"\xef\xbb\xbf"
    payload = raw[3:] if has_bom else raw
    return payload.decode("utf-8"), has_bom


def parse_errors(path: Path) -> list[str]:
    ps1 = path.resolve()
    ps = rf"""
$path = '{ps1}'
$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
if ($errors) {{ $errors | ForEach-Object {{ $_.ToString() }} }}
"""
    proc = subprocess.run(
        ["powershell", "-NoProfile", "-Command", ps],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    lines = [ln.strip() for ln in (proc.stdout or "").splitlines() if ln.strip()]
    return lines


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: verify-ps1-script-encoding.py <path.ps1>", file=sys.stderr)
        return 1
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"FAIL: not found: {path}")
        return 1

    text, has_bom = read_text(path)
    if re.search(r"[\u4e00-\u9fff]", text) and not has_bom:
        print("FAIL: CJK content without UTF-8 BOM (PS 5.1 -File will misparse)")
        print("Fix: Write-Utf8BomFile, or rewrite in Python")
        return 1

    errors = parse_errors(path)
    if errors:
        print("FAIL: PowerShell parser errors (likely CJK mojibake or broken strings)")
        for err in errors[:5]:
            print(f"  - {err}")
        if len(errors) > 5:
            print(f"  - ... and {len(errors) - 5} more")
        print("Fix: rewrite script in Python; do not retry chcp/escape loops")
        return 1

    print("PASS: verify-ps1-script-encoding")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
