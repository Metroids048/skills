#!/usr/bin/env python3
"""Global agent stack self-check (no per-project audit)."""
from __future__ import annotations

import importlib.util
import json
import os
import sys
from pathlib import Path

MODULES = ("win32com", "pptx", "docx", "openpyxl", "PIL")
TOOLING = ("pytest", "yaml", "requests", "httpx", "jsonschema", "chardet")
OPTIONAL = ("fitz",)


def main() -> int:
    data = {
        "python": sys.executable,
        "agent_python_env": os.environ.get("AGENT_PYTHON"),
        "utf8_stdout": sys.stdout.encoding,
        "modules": {m: importlib.util.find_spec(m) is not None for m in MODULES},
        "tooling": {m: importlib.util.find_spec(m) is not None for m in TOOLING},
        "optional": {m: importlib.util.find_spec(m) is not None for m in OPTIONAL},
    }
    print(json.dumps(data, ensure_ascii=False, indent=2))
    missing = [m for m, ok in data["modules"].items() if not ok]
    missing_tooling = [m for m, ok in data["tooling"].items() if not ok]
    if missing:
        print(f"FAIL missing office/cjk: {', '.join(missing)}", file=sys.stderr)
        print("Run: install-global-agent-python.ps1", file=sys.stderr)
        return 1
    if missing_tooling:
        print(f"FAIL missing agent tooling: {', '.join(missing_tooling)}", file=sys.stderr)
        print("Run: install-global-agent-python.ps1  (do NOT pip per-project)", file=sys.stderr)
        return 1
    if data["utf8_stdout"] and str(data["utf8_stdout"]).lower() not in ("utf-8", "utf8"):
        print(f"WARN stdout encoding: {data['utf8_stdout']}", file=sys.stderr)
    # Chinese path probe
    desktop = Path.home() / "Desktop"
    try:
        cjk = next(
            (
                p
                for p in desktop.iterdir()
                if p.is_dir() and any("\u4e00" <= c <= "\u9fff" for c in p.name)
            ),
            None,
        )
    except OSError:
        cjk = None
    if cjk:
        data["cjk_probe"] = str(cjk)
    # Reminder for agents (stdout only — stderr NOTE breaks PowerShell native error handling)
    print(
        "NOTE: For project tests run resolve-test-runner.py — "
        "AGENT_PYTHON tooling pytest != project .venv"
    )
    print("PASS: global-agent-stack")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
