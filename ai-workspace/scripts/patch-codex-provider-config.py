# -*- coding: utf-8 -*-
"""Merge CC Switch Codex provider fields into live ~/.codex/config.toml.

Only patches TOP-LEVEL keys (before the first [section]) and [model_providers.custom].
Never touches keys inside [profiles.*] or other sections.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

TOP_KEYS = (
    "model_provider",
    "model",
    "model_reasoning_effort",
    "model_catalog_json",
    "disable_response_storage",
    "notify",
    "openai_base_url",
)
PROVIDER_SECTION = "model_providers.custom"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def split_preamble(text: str) -> tuple[str, str]:
    """Return (preamble_including_trailing_newlines, rest_from_first_section)."""
    match = re.search(r"(?m)^\[", text)
    if not match:
        return text, ""
    return text[: match.start()], text[match.start() :]


def extract_top_assignments(text: str) -> dict[str, str]:
    preamble, _ = split_preamble(text)
    out: dict[str, str] = {}
    for key in TOP_KEYS:
        match = re.search(rf"(?m)^{re.escape(key)}\s*=\s*.+$", preamble)
        if match:
            out[key] = match.group(0)
    return out


def extract_section(text: str, section: str) -> str | None:
    pattern = rf"(?ms)^\[{re.escape(section)}\]\s*\r?\n(.*?)(?=^\[[^\]]+\]|\Z)"
    match = re.search(pattern, text)
    if not match:
        return None
    return f"[{section}]\n{match.group(1).rstrip()}\n"


def replace_top_key(text: str, key: str, assignment: str) -> str:
    preamble, rest = split_preamble(text)
    pattern = rf"(?m)^{re.escape(key)}\s*=\s*.+?\r?\n"
    line = assignment.rstrip() + "\n"
    if re.search(pattern, preamble):
        preamble = re.sub(pattern, lambda _match: line, preamble, count=1)
    else:
        anchor = re.search(r"(?m)^model_provider\s*=\s*.+$", preamble)
        if anchor and key != "model_provider":
            # Insert on the next line AFTER the full model_provider assignment.
            insert_at = anchor.end()
            preamble = preamble[:insert_at] + "\n" + line + preamble[insert_at:].lstrip("\n")
            preamble = re.sub(r"\n{3,}", "\n\n", preamble)
        else:
            preamble = preamble.rstrip() + "\n" + line + ("\n" if rest else "")
    return preamble + rest


def replace_section(text: str, section: str, block: str) -> str:
    pattern = rf"(?ms)^\[{re.escape(section)}\]\s*\r?\n.*?(?=^\[[^\]]+\]|\Z)"
    normalized = block.rstrip() + "\n\n"
    if re.search(pattern, text):
        return re.sub(pattern, normalized, text, count=1)
    # Prefer inserting before [profiles.*]
    anchor = re.search(r"(?m)^\[profiles\.", text)
    if anchor:
        pos = anchor.start()
        return text[:pos] + normalized + text[pos:]
    # Else before first section after preamble features/mcp — append near end of known provider area
    return text.rstrip() + "\n\n" + normalized


def merge_provider_patch(live_text: str, provider_text: str) -> str:
    result = live_text
    for key, assignment in extract_top_assignments(provider_text).items():
        result = replace_top_key(result, key, assignment)
    section = extract_section(provider_text, PROVIDER_SECTION)
    if section:
        # Force API-key providers off ChatGPT login wall
        if "requires_openai_auth = true" in section:
            section = section.replace(
                "requires_openai_auth = true", "requires_openai_auth = false"
            )
        result = replace_section(result, PROVIDER_SECTION, section)
    return result.rstrip() + "\n"


def main() -> int:
    if len(sys.argv) < 3:
        print(
            "usage: patch-codex-provider-config.py <live-config.toml> <provider-config.toml|-",
            file=sys.stderr,
        )
        return 2

    live_path = Path(sys.argv[1])
    provider_arg = sys.argv[2]
    provider_text = sys.stdin.read() if provider_arg == "-" else read_text(Path(provider_arg))
    live_text = read_text(live_path)
    merged = merge_provider_patch(live_text, provider_text)
    live_path.write_text(merged, encoding="utf-8")
    base_match = re.search(
        rf"(?ms)^\[{re.escape(PROVIDER_SECTION)}\]\s*\r?\n.*?(?:^base_url\s*=\s*\"([^\"]+)\")",
        merged,
    )
    if not base_match:
        base_match = re.search(r'(?m)^base_url\s*=\s*"([^"]+)"', merged)
    model_match = re.search(r'(?m)^model\s*=\s*"([^"]+)"', split_preamble(merged)[0])
    provider_match = re.search(
        r'(?m)^model_provider\s*=\s*"([^"]+)"', split_preamble(merged)[0]
    )
    print(
        "patch_ok",
        f"model_provider={provider_match.group(1) if provider_match else '(missing)'}",
        f"base_url={base_match.group(1) if base_match else '(missing)'}",
        f"model={model_match.group(1) if model_match else '(missing)'}",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
