"""Fix One-API (tangguo) provider and sync Codex config."""
from __future__ import annotations

import json
import os
import re
import sqlite3
from pathlib import Path

HOME = Path(os.environ["USERPROFILE"])
DB = HOME / ".cc-switch" / "cc-switch.db"
CONFIG = HOME / ".codex" / "config.toml"
AUTH = HOME / ".codex" / "auth.json"
SETTINGS = HOME / ".cc-switch" / "settings.json"
TANGGUO_BASE = "https://api.tangguo.xin/v1"
ONE_API_PREFIX = "one-api-"


def fix_provider_config(config_text: str) -> tuple[str, list[str]]:
    notes: list[str] = []
    out = config_text
    # Replace any hctopup base_url inside One-API provider configs
    if "ai.hctopup.com" in out:
        out = re.sub(
            r'base_url\s*=\s*"https://ai\.hctopup\.com/v1"',
            f'base_url = "{TANGGUO_BASE}"',
            out,
        )
        notes.append("replaced hctopup base_url -> tangguo")
    # Ensure provider name
    if 'name = "HCAI"' in out and "One-API" not in out:
        out = out.replace('name = "HCAI"', 'name = "One-API"')
        notes.append("renamed HCAI -> One-API")
    return out, notes


def main() -> None:
    conn = sqlite3.connect(DB)
    rows = conn.execute(
        "SELECT id, name, settings_config FROM providers WHERE app_type='codex'"
    ).fetchall()

    active_id = json.loads(SETTINGS.read_text(encoding="utf-8")).get("currentProviderCodex")
    fixed_providers: list[str] = []

    for pid, name, raw in rows:
        if not (name == "One-API" or pid.startswith(ONE_API_PREFIX)):
            continue
        data = json.loads(raw)
        notes: list[str] = []
        cfg = data.get("config", "")
        new_cfg, cfg_notes = fix_provider_config(cfg)
        notes.extend(cfg_notes)
        if new_cfg != cfg:
            data["config"] = new_cfg
        # Sync bearer token from config if present in toml
        if CONFIG.exists():
            toml = CONFIG.read_text(encoding="utf-8")
            m = re.search(r'experimental_bearer_token\s*=\s*"(sk-[^"]+)"', toml)
            if m:
                key = m.group(1)
                auth = data.setdefault("auth", {})
                if auth.get("OPENAI_API_KEY") != key:
                    auth["OPENAI_API_KEY"] = key
                    notes.append("synced OPENAI_API_KEY from config.toml")
        if notes:
            conn.execute(
                "UPDATE providers SET settings_config=? WHERE id=?",
                (json.dumps(data, ensure_ascii=False), pid),
            )
            fixed_providers.append(f"{pid}: {', '.join(notes)}")

    conn.commit()
    conn.close()

    # Fix live config.toml
    toml_notes: list[str] = []
    if CONFIG.exists():
        toml = CONFIG.read_text(encoding="utf-8")
        new_toml, toml_notes = fix_provider_config(toml)
        if 'name = "One-API"' not in new_toml and "[model_providers.custom]" in new_toml:
            new_toml = re.sub(
                r'(\[model_providers\.custom\]\s*\n)name\s*=\s*"[^"]*"',
                r'\1name = "One-API"',
                new_toml,
                count=1,
            )
            toml_notes.append("set custom provider name One-API")
        if new_toml != toml:
            CONFIG.write_text(new_toml, encoding="utf-8")

    # Ensure auth.json has sk key when using One-API
    if AUTH.exists() and CONFIG.exists():
        toml = CONFIG.read_text(encoding="utf-8")
        m = re.search(r'experimental_bearer_token\s*=\s*"(sk-[^"]+)"', toml)
        if m:
            auth = json.loads(AUTH.read_text(encoding="utf-8"))
            key = m.group(1)
            if auth.get("OPENAI_API_KEY") != key:
                auth["OPENAI_API_KEY"] = key
                auth.pop("auth_mode", None)  # API key mode, not OAuth
                AUTH.write_text(json.dumps(auth, indent=2) + "\n", encoding="utf-8")
                toml_notes.append("synced auth.json OPENAI_API_KEY")

    print("active_provider:", active_id)
    print("db_fixed:", fixed_providers or "(none needed)")
    print("toml_fixed:", toml_notes or "(none needed)")

    # Verify key against tangguo responses endpoint
    import urllib.error
    import urllib.request

    key = json.loads(AUTH.read_text(encoding="utf-8")).get("OPENAI_API_KEY", "")
    if not key:
        print("verify: SKIP no key")
        return
    req = urllib.request.Request(
        f"{TANGGUO_BASE}/models",
        headers={"Authorization": f"Bearer {key}"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"verify tangguo /models: HTTP {resp.status} OK")
    except urllib.error.HTTPError as e:
        print(f"verify tangguo /models: HTTP {e.code} {e.read().decode()[:120]}")


if __name__ == "__main__":
    main()
