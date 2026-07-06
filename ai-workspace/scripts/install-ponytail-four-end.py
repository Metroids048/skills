#!/usr/bin/env python3
"""Install/sync DietrichGebert/ponytail across Cursor, Claude Code, Codex, Reasonix."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

VERSION = "4.8.4"
REPO = "https://github.com/DietrichGebert/ponytail.git"
USER_HOME = Path.home()
VENDOR = USER_HOME / ".ai-workspace" / "vendor" / "ponytail"
CURSOR_RULE = USER_HOME / ".cursor" / "rules" / "ponytail.mdc"
CLAUDE_CACHE = (
    USER_HOME
    / ".claude"
    / "plugins"
    / "cache"
    / "ponytail"
    / "ponytail"
    / VERSION
)
CODEX_CACHE = (
    USER_HOME / ".codex" / "plugins" / "cache" / "ponytail" / "ponytail" / VERSION
)
CODEX_CONFIG = USER_HOME / ".codex" / "config.toml"
PONYTAIL_CONFIG_DIR = Path(
    os.environ.get("APPDATA", str(USER_HOME / "AppData" / "Roaming"))
) / "ponytail"
PONYTAIL_CONFIG = PONYTAIL_CONFIG_DIR / "config.json"
REASONIX_MEMORY = (
    USER_HOME / "AppData" / "Roaming" / "reasonix" / "memory" / "global"
)
REASONIX_GLOBAL_WS_MEMORY = (
    USER_HOME / "AppData" / "Roaming" / "reasonix" / "global-workspace" / "memory"
)
AI_MEMORY = USER_HOME / ".ai-workspace" / "memory" / "ponytail.md"
REASONIX_MEMORY_FILE = REASONIX_MEMORY / "ponytail.md"
REASONIX_INDEX = REASONIX_MEMORY / "MEMORY.md"


def log(msg: str) -> None:
    print(msg, flush=True)


def ensure_vendor() -> Path:
    if VENDOR.is_dir() and (VENDOR / ".git").is_dir():
        log(f"vendor_ok pull {VENDOR}")
        subprocess.run(
            ["git", "-C", str(VENDOR), "pull", "--ff-only"],
            check=False,
            capture_output=True,
            text=True,
        )
    elif CLAUDE_CACHE.is_dir():
        log(f"vendor_seed copy {CLAUDE_CACHE} -> {VENDOR}")
        if VENDOR.exists():
            shutil.rmtree(VENDOR)
        shutil.copytree(CLAUDE_CACHE, VENDOR)
    else:
        log(f"vendor_clone {REPO} -> {VENDOR}")
        VENDOR.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["git", "clone", "--depth", "1", REPO, str(VENDOR)],
            check=True,
        )
    return VENDOR


def copy_text(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    log(f"copied {src.name} -> {dst}")


def sync_cursor(vendor: Path) -> None:
    src = vendor / ".cursor" / "rules" / "ponytail.mdc"
    if not src.is_file():
        raise FileNotFoundError(src)
    copy_text(src, CURSOR_RULE)


def sync_reasonix(vendor: Path) -> None:
    agents = vendor / "AGENTS.md"
    if not agents.is_file():
        raise FileNotFoundError(agents)
    body = agents.read_text(encoding="utf-8")
    header = (
        "# Ponytail — lazy senior dev mode\n\n"
        "> SSOT: `~/.ai-workspace/vendor/ponytail/AGENTS.md` · "
        "Synced by `install-ponytail-four-end.py`\n\n"
    )
    content = header + body
    for target in (AI_MEMORY, REASONIX_MEMORY_FILE):
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        log(f"written {target}")

    ws_target = REASONIX_GLOBAL_WS_MEMORY / "ponytail.md"
    if REASONIX_GLOBAL_WS_MEMORY.parent.is_dir():
        ws_target.parent.mkdir(parents=True, exist_ok=True)
        ws_target.write_text(content, encoding="utf-8")
        log(f"written {ws_target}")

    link_line = (
        "- [Ponytail lazy senior dev mode](ponytail.md) — "
        "YAGNI / stdlib-first / minimum diff; synced globally"
    )
    if REASONIX_INDEX.is_file():
        text = REASONIX_INDEX.read_text(encoding="utf-8")
        if "ponytail.md" not in text:
            REASONIX_INDEX.write_text(text.rstrip() + "\n" + link_line + "\n", encoding="utf-8")
            log(f"updated {REASONIX_INDEX}")
    else:
        REASONIX_INDEX.write_text("# Memory\n\n" + link_line + "\n", encoding="utf-8")
        log(f"created {REASONIX_INDEX}")


def sync_ponytail_config() -> None:
    PONYTAIL_CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    data = {"defaultMode": "full"}
    if PONYTAIL_CONFIG.is_file():
        try:
            existing = json.loads(PONYTAIL_CONFIG.read_text(encoding="utf-8"))
            if isinstance(existing, dict):
                existing.setdefault("defaultMode", "full")
                data = existing
        except json.JSONDecodeError:
            pass
    PONYTAIL_CONFIG.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    log(f"written {PONYTAIL_CONFIG}")


def sync_codex_cache(vendor: Path) -> None:
    CODEX_CACHE.parent.mkdir(parents=True, exist_ok=True)
    if CODEX_CACHE.is_dir():
        shutil.rmtree(CODEX_CACHE)
    shutil.copytree(vendor, CODEX_CACHE)
    log(f"codex_cache {CODEX_CACHE}")


def sync_codex_config() -> None:
    if not CODEX_CONFIG.is_file():
        raise FileNotFoundError(CODEX_CONFIG)

    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    vendor_posix = VENDOR.as_posix()
    block = (
        f"\n# ponytail — synced by install-ponytail-four-end.py\n"
        f"[marketplaces.ponytail]\n"
        f'last_updated = "{stamp}"\n'
        f'source_type = "local"\n'
        f"source = '{vendor_posix}'\n\n"
        f'[plugins."ponytail@ponytail"]\n'
        f"enabled = true\n"
    )

    text = CODEX_CONFIG.read_text(encoding="utf-8")
    if "[marketplaces.ponytail]" in text:
        text = re.sub(
            r"\n# ponytail — synced by install-ponytail-four-end\.py\n"
            r"\[marketplaces\.ponytail\][\s\S]*?"
            r'\[plugins\."ponytail@ponytail"\]\nenabled = true\n',
            block,
            text,
            count=1,
        )
    else:
        backup = CODEX_CONFIG.with_suffix(f".toml.bak-ponytail-{datetime.now():%Y%m%d-%H%M%S}")
        shutil.copy2(CODEX_CONFIG, backup)
        log(f"backup {backup}")
        text = text.rstrip() + block

    CODEX_CONFIG.write_text(text, encoding="utf-8")
    log(f"updated {CODEX_CONFIG}")


def verify_claude() -> None:
    settings = USER_HOME / ".claude" / "settings.json"
    installed = USER_HOME / ".claude" / "plugins" / "installed_plugins.json"
    ok = False
    if settings.is_file():
        data = json.loads(settings.read_text(encoding="utf-8"))
        ok = data.get("enabledPlugins", {}).get("ponytail@ponytail") is True
    if installed.is_file():
        data = json.loads(installed.read_text(encoding="utf-8"))
        ok = ok or "ponytail@ponytail" in data.get("plugins", {})
    log(f"claude_plugin {'OK' if ok else 'MISSING — run: claude plugin install ponytail@ponytail'}")


def main() -> int:
    vendor = ensure_vendor()
    sync_cursor(vendor)
    sync_reasonix(vendor)
    sync_ponytail_config()
    sync_codex_cache(vendor)
    sync_codex_config()
    verify_claude()
    log("done — restart Codex Desktop / new Claude session / Cursor window for hooks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
