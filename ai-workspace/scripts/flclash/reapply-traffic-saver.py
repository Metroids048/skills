# -*- coding: utf-8 -*-
"""Re-inject rules without YAML comments; ensure MATCH,DIRECT + AI keep rules."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(r"C:\Users\win\AppData\Roaming\com.follow\clash")
PREFS = ROOT / "shared_preferences.json"
PROFILE = ROOT / "profiles" / "338564600934961152.yaml"
CONFIG = ROOT / "config.yaml"

OLD_MARKERS = [
    "# === flclash-traffic-saver begin ===",
    "# === flclash-traffic-saver end ===",
]

PREPEND = [
    "DOMAIN-SUFFIX,windows.com,DIRECT",
    "DOMAIN-SUFFIX,windows.net,DIRECT",
    "DOMAIN-SUFFIX,windowsupdate.com,DIRECT",
    "DOMAIN-SUFFIX,delivery.mp.microsoft.com,DIRECT",
    "DOMAIN-SUFFIX,update.microsoft.com,DIRECT",
    "DOMAIN-SUFFIX,openai.com,FlyBit",
    "DOMAIN-SUFFIX,chatgpt.com,FlyBit",
    "DOMAIN-SUFFIX,oaistatic.com,FlyBit",
    "DOMAIN-SUFFIX,oaiusercontent.com,FlyBit",
    "DOMAIN-SUFFIX,anthropic.com,FlyBit",
    "DOMAIN-SUFFIX,claude.ai,FlyBit",
    "DOMAIN-SUFFIX,cursor.com,FlyBit",
    "DOMAIN-SUFFIX,cursor.sh,FlyBit",
    "DOMAIN-SUFFIX,cursorapi.com,FlyBit",
]


def clean(text: str) -> str:
    for m in OLD_MARKERS:
        text = text.replace(m + "\n", "").replace(m, "")
    # remove previously injected identical rules (idempotent)
    for rule in PREPEND:
        text = re.sub(rf"^[ \t]*- [ '\"]*{re.escape(rule)}['\"]?[ \t]*\n", "", text, flags=re.M)
    text = text.replace("MATCH,FlyBit", "MATCH,DIRECT")
    text = text.replace("DOMAIN-SUFFIX,windows.com,FlyBit", "DOMAIN-SUFFIX,windows.com,DIRECT")
    text = text.replace("DOMAIN-SUFFIX,windows.net,FlyBit", "DOMAIN-SUFFIX,windows.net,DIRECT")
    return text


def inject(path: Path, indent: str, quote: str) -> None:
    text = clean(path.read_text(encoding="utf-8"))
    block = "".join(f"{indent}- {quote}{rule}{quote}\n" for rule in PREPEND)

    def repl(m: re.Match) -> str:
        return m.group(0) + block

    new, n = re.subn(r"^rules:\s*\n", repl, text, count=1, flags=re.M)
    if n != 1:
        raise RuntimeError(f"inject failed for {path}")
    path.write_text(new, encoding="utf-8")
    print(f"[ok] {path.name}")


def prefs() -> None:
    data = json.loads(PREFS.read_text(encoding="utf-8"))
    cfg = json.loads(data["flutter.config"])
    cfg["appSettingProps"]["onlyStatisticsProxy"] = True
    cfg["appSettingProps"]["autoRun"] = True
    cfg["networkProps"]["systemProxy"] = True
    data["flutter.config"] = json.dumps(cfg, ensure_ascii=False, separators=(",", ":"))
    PREFS.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    print("[ok] prefs")


def main() -> None:
    prefs()
    inject(PROFILE, "    ", "'")
    inject(CONFIG, "  ", '"')
    c = CONFIG.read_text(encoding="utf-8")
    assert "MATCH,DIRECT" in c
    assert "# === flclash" not in c
    assert c.split("rules:")[1].lstrip().startswith("- \"DOMAIN-SUFFIX,windows.com,DIRECT\"")
    print("DONE")


if __name__ == "__main__":
    main()
