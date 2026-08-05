# -*- coding: utf-8 -*-
"""Keep Codex++ relay profile aligned with current CC Switch Codex provider."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def extract_base_url(config_text: str) -> str:
    match = re.search(r'(?m)^base_url\s*=\s*"([^"]+)"', config_text)
    return match.group(1) if match else ""


def relay_id_for_provider(provider_id: str) -> str:
    return f"ccs-{provider_id}"


def find_profile(profiles: list[dict], provider_id: str, provider_name: str) -> dict | None:
    exact = relay_id_for_provider(provider_id)
    for profile in profiles:
        if profile.get("id") == exact:
            return profile
    prefix = provider_id.split("-", 1)[0] if "-" in provider_id else provider_id
    candidates = [
        p for p in profiles
        if isinstance(p.get("id"), str)
        and p["id"].startswith(f"ccs-{prefix}-")
        and provider_name.split("（", 1)[0] in str(p.get("name", ""))
    ]
    if len(candidates) == 1:
        return candidates[0]
    for profile in profiles:
        if provider_name and provider_name in str(profile.get("name", "")):
            return profile
    return None


def upsert_profile(
    settings: dict,
    provider_id: str,
    provider_name: str,
    config_text: str,
    auth_obj: dict,
    website_url: str,
) -> str:
    profiles: list[dict] = list(settings.get("relayProfiles") or [])
    profile = find_profile(profiles, provider_id, provider_name)
    relay_id = relay_id_for_provider(provider_id)
    base_url = extract_base_url(config_text) or website_url.rstrip("/")
    auth_text = json.dumps(auth_obj, ensure_ascii=False, indent=2) + "\n"

    if profile is None:
        profile = {
            "id": relay_id,
            "name": f"{provider_name}（ccswitch）",
            "upstreamBaseUrl": base_url,
            "protocol": "responses",
            "relayMode": "pureApi",
            "officialMixApiKey": False,
            "testModel": "",
            "configContents": config_text,
            "authContents": auth_text,
            "useCommonConfig": True,
            "contextSelection": {"mcpServers": [], "skills": [], "plugins": []},
            "contextSelectionInitialized": True,
            "contextWindow": "",
            "autoCompactLimit": "",
            "modelInsertMode": "patch",
            "modelList": "",
            "modelWindows": "{}",
            "vlmModel": "",
            "vlmBaseUrl": "",
        }
        profiles.append(profile)
    else:
        profile["id"] = relay_id
        profile["name"] = f"{provider_name}（ccswitch）"
        profile["upstreamBaseUrl"] = base_url
        profile["protocol"] = profile.get("protocol") or "responses"
        # Always force pureApi for third-party providers; "official" causes ChatGPT login wall.
        profile["relayMode"] = "pureApi"
        profile["officialMixApiKey"] = False
        profile["configContents"] = config_text
        profile["authContents"] = auth_text
        profile.setdefault("useCommonConfig", True)
        profile.setdefault("modelInsertMode", "patch")

    settings["relayProfiles"] = profiles
    settings["activeRelayId"] = relay_id
    settings["relayBaseUrl"] = base_url
    api_key = auth_obj.get("OPENAI_API_KEY")
    if api_key:
        settings["relayApiKey"] = api_key
    settings["providerSyncLastSelectedProvider"] = "custom"
    return relay_id


def main() -> int:
    if len(sys.argv) < 2:
        print(
            "usage: sync-codex-plus-relay-from-cc.py <provider.json> [settings.json]",
            file=sys.stderr,
        )
        return 2

    provider = read_json(Path(sys.argv[1]))
    settings_path = Path(sys.argv[2]) if len(sys.argv) > 2 else Path.home() / ".codex-session-delete" / "settings.json"
    if not settings_path.is_file():
        print("codexplus_skip settings.json missing")
        return 0

    settings = read_json(settings_path)
    settings_config = provider.get("settings_config") or {}
    config_text = settings_config.get("config") or ""
    auth_obj = settings_config.get("auth") or {}
    relay_id = upsert_profile(
        settings,
        provider_id=str(provider.get("id", "")),
        provider_name=str(provider.get("name", "")),
        config_text=config_text,
        auth_obj=auth_obj,
        website_url=str(provider.get("website_url") or ""),
    )
    write_json(settings_path, settings)
    print("codexplus_ok", relay_id, extract_base_url(config_text))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
