#!/usr/bin/env python3
"""List/read files under a directory — safe for Chinese paths (no shell pipe)."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def main() -> int:
    p = argparse.ArgumentParser(description="Agent-safe file list/read (UTF-8 paths)")
    p.add_argument("path", help="file or directory")
    p.add_argument("--glob", default="*", help="glob when path is directory")
    p.add_argument("--read", action="store_true", help="print file contents (files only)")
    p.add_argument("--json", action="store_true", help="JSON output for directory listing")
    args = p.parse_args()

    root = Path(args.path)
    if not root.exists():
        print(f"not found: {root}", file=sys.stderr)
        return 1

    if root.is_file() or args.read:
        if not root.is_file():
            print("not a file", file=sys.stderr)
            return 1
        text = root.read_text(encoding="utf-8-sig")
        sys.stdout.write(text)
        if not text.endswith("\n"):
            sys.stdout.write("\n")
        return 0

    items = sorted(root.glob(args.glob))
    if args.json:
        print(json.dumps([str(x.relative_to(root)) if x.is_relative_to(root) else str(x) for x in items], ensure_ascii=False, indent=2))
    else:
        for x in items:
            print(x)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
