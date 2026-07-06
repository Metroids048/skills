#!/usr/bin/env python3
"""Validate ~/.codex/config.toml parses (catches \\U in Windows paths)."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore[no-redef]


def main() -> int:
    path = Path.home() / ".codex" / "config.toml"
    raw = path.read_text(encoding="utf-8-sig")
    tomllib.loads(raw)
    print(f"PASS: {path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
