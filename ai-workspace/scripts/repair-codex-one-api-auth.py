# -*- coding: utf-8 -*-
"""Repair One-API provider for pure API-key Codex use (no ChatGPT login wall)."""
from __future__ import annotations

import json
import re
import sqlite3
from pathlib import Path

HOME = Path.home()
DB = HOME / ".cc-switch" / "cc-switch.db"
SETTINGS = HOME / ".cc-switch" / "settings.json"
CONFIG = HOME / ".codex" / "config.toml"
AUTH = HOME / ".codex" / "auth.json"
PLUS = HOME / ".codex-session-delete" / "settings.json"
ACTIVE = "one-api-1783589315861"


def force_no_openai_auth(config_text: str) -> tuple[str, bool]:
    changed = False
    out = config_text
    if re.search(r"(?m)^requires_openai_auth\s*=\s*true\s*$", out):
        out = re.sub(
            r"(?m)^requires_openai_auth\s*=\s*true\s*$",
            "requires_openai_auth = false",
            out,
        )
        changed = True
    elif "[model_providers.custom]" in out and not re.search(
        r"(?m)^requires_openai_auth\s*=", out
    ):
        out = re.sub(
            r"(?m)^(\[model_providers\.custom\]\s*\r?\n)",
            r"\1requires_openai_auth = false\n",
            out,
            count=1,
        )
        changed = True
    return out, changed


def main() -> None:
    notes: list[str] = []
    settings = json.loads(SETTINGS.read_text(encoding="utf-8"))
    active = settings.get("currentProviderCodex") or ACTIVE
    if active != ACTIVE:
        notes.append(f"active_is_{active}_expected_{ACTIVE}")

    con = sqlite3.connect(DB)
    row = con.execute(
        "SELECT settings_config FROM providers WHERE id=? AND app_type='codex'",
        (ACTIVE,),
    ).fetchone()
    if not row:
        raise SystemExit(f"provider missing: {ACTIVE}")
    data = json.loads(row[0])
    cfg = data.get("config") or ""
    new_cfg, cfg_changed = force_no_openai_auth(cfg)
    if cfg_changed:
        data["config"] = new_cfg
        notes.append("db_requires_openai_auth=false")
    auth = data.setdefault("auth", {})
    key = auth.get("OPENAI_API_KEY")
    if not key:
        # fallback: live config bearer
        if CONFIG.exists():
            m = re.search(
                r'experimental_bearer_token\s*=\s*"(sk-[^"]+)"',
                CONFIG.read_text(encoding="utf-8"),
            )
            if m:
                key = m.group(1)
                auth["OPENAI_API_KEY"] = key
                notes.append("db_key_from_live_bearer")
    # API key providers must not carry chatgpt auth_mode in stored provider auth
    if "auth_mode" in auth:
        auth.pop("auth_mode", None)
        notes.append("db_auth_mode_removed")
    con.execute(
        "UPDATE providers SET settings_config=?, is_current=1 WHERE id=? AND app_type='codex'",
        (json.dumps(data, ensure_ascii=False), ACTIVE),
    )
    con.execute(
        "UPDATE providers SET is_current=0 WHERE app_type='codex' AND id!=?",
        (ACTIVE,),
    )
    con.commit()
    con.close()

    # live config.toml
    if CONFIG.exists():
        toml = CONFIG.read_text(encoding="utf-8")
        new_toml, changed = force_no_openai_auth(toml)
        if changed:
            CONFIG.write_text(new_toml, encoding="utf-8")
            notes.append("live_requires_openai_auth=false")

    # live auth.json -> API key mode, keep oauth tokens for later official switch
    if not key:
        raise SystemExit("no OPENAI_API_KEY available for One-API")
    live = json.loads(AUTH.read_text(encoding="utf-8")) if AUTH.exists() else {}
    live["OPENAI_API_KEY"] = key
    if live.get("auth_mode") == "chatgpt":
        live.pop("auth_mode", None)
        notes.append("live_auth_mode_cleared")
    AUTH.write_text(json.dumps(live, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    notes.append("live_api_key_set")

    # Codex++ relay -> pureApi
    if PLUS.exists():
        plus = json.loads(PLUS.read_text(encoding="utf-8-sig"))
        relay_id = f"ccs-{ACTIVE}"
        profiles = list(plus.get("relayProfiles") or [])
        found = False
        for pr in profiles:
            if pr.get("id") == relay_id or "One-API" in str(pr.get("name", "")):
                pr["id"] = relay_id
                pr["relayMode"] = "pureApi"
                pr["officialMixApiKey"] = False
                pr["upstreamBaseUrl"] = "https://api.tangguo.xin/v1"
                pr["authContents"] = json.dumps(
                    {"OPENAI_API_KEY": key}, ensure_ascii=False, indent=2
                ) + "\n"
                found = True
                notes.append(f"plus_profile_{relay_id}_pureApi")
        if not found:
            profiles.append(
                {
                    "id": relay_id,
                    "name": "One-API（ccswitch）",
                    "upstreamBaseUrl": "https://api.tangguo.xin/v1",
                    "protocol": "responses",
                    "relayMode": "pureApi",
                    "officialMixApiKey": False,
                    "authContents": json.dumps(
                        {"OPENAI_API_KEY": key}, ensure_ascii=False, indent=2
                    )
                    + "\n",
                    "useCommonConfig": True,
                    "modelInsertMode": "patch",
                }
            )
            notes.append("plus_profile_created")
        plus["relayProfiles"] = profiles
        plus["activeRelayId"] = relay_id
        plus["relayBaseUrl"] = "https://api.tangguo.xin/v1"
        plus["relayApiKey"] = key
        plus["providerSyncLastSelectedProvider"] = "custom"
        PLUS.write_text(
            json.dumps(plus, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        notes.append("plus_active_one_api")

    print("active=", active)
    print("notes=", notes)


if __name__ == "__main__":
    main()
