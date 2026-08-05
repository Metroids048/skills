#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""隐私与危险操作检查（Hooks / 同步前调用）。"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

SECRET_NAME_PATTERNS = [
    r"(^|/|\\)\.env(\.|$)",
    r"\.(pem|key)$",
    r"wallet\.dat$",
    r"(^|/|\\)cookies?([/\\]|$)",
    r"cookies?\.sqlite$",
    r"id_rsa$",
    r"credentials\.json$",
    r"auth\.json$",
]
SECRET_CONTENT_PATTERNS = [
    r"(?i)api[_-]?key\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}",
    r"(?i)secret\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{12,}",
    r"(?i)Bearer\s+[A-Za-z0-9\-._~+/]+=*",
]
DANGEROUS_CMD = [
    r"(?i)Remove-Item\s+-Recurse",
    r"(?i)format\s+[a-z]:",
    r"(?i)rm\s+-rf\s+/",
    r"(?i)reg\s+delete",
    r"(?i)shutdown\s+/",
    r"(?i)diskpart",
]


def is_secret_path(path: str) -> bool:
    p = path.replace("\\", "/")
    return any(re.search(pat, p, flags=re.IGNORECASE) for pat in SECRET_NAME_PATTERNS)


def scan_text(text: str) -> list[str]:
    hits = []
    for pat in SECRET_CONTENT_PATTERNS:
        if re.search(pat, text or ""):
            hits.append(pat)
    return hits


def is_dangerous_command(cmd: str) -> bool:
    return any(re.search(pat, cmd or "") for pat in DANGEROUS_CMD)


def redact(text: str) -> str:
    out = text
    for pat in SECRET_CONTENT_PATTERNS:
        out = re.sub(pat, "[REDACTED]", out)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--path")
    ap.add_argument("--command")
    ap.add_argument("--file", type=Path)
    ap.add_argument("--hook-stdin", action="store_true")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        assert is_secret_path(r"C:\proj\.env")
        assert is_secret_path("id_rsa")
        assert is_secret_path(r"C:\Users\x\Cookies\Cookies")
        assert not is_secret_path(r"C:\proj\README.md")
        assert is_dangerous_command("Remove-Item -Recurse C:\\")
        assert scan_text("api_key=YOUR_API_KEY")
        assert "[REDACTED]" in redact("api_key=YOUR_API_KEY")
        print("PASS: 隐私检查自测")
        return 0

    if args.hook_stdin:
        raw = sys.stdin.read()
        try:
            data = json.loads(raw) if raw.strip() else {}
        except json.JSONDecodeError:
            data = {"raw": raw}
        path = str(data.get("path") or data.get("file_path") or "")
        cmd = str(data.get("command") or data.get("shell") or "")
        if path and is_secret_path(path):
            print(json.dumps({"permission": "deny", "reason": "secret path"}, ensure_ascii=False))
            return 2
        if cmd and is_dangerous_command(cmd):
            print(json.dumps({"permission": "deny", "reason": "dangerous command"}, ensure_ascii=False))
            return 2
        print(json.dumps({"permission": "allow"}, ensure_ascii=False))
        return 0

    if args.path and is_secret_path(args.path):
        print("DENY secret path")
        return 2
    if args.command and is_dangerous_command(args.command):
        print("DENY dangerous command")
        return 2
    if args.file and args.file.is_file():
        hits = scan_text(args.file.read_text(encoding="utf-8", errors="ignore"))
        if hits:
            print("DENY secret content patterns", hits)
            return 2
    print("ALLOW")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
