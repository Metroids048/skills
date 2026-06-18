"""Merge Codex++ overlay TOML into ~/.codex/config.toml (plugins, marketplaces, MCP)."""
from __future__ import annotations

import json
import os
import re
import sys
import tomllib
from pathlib import Path

FIGMA_MCP_OVERLAY = """[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
startup_timeout_sec = 30

[mcp_servers.figma-desktop]
url = "http://127.0.0.1:3845/mcp"
startup_timeout_sec = 30
"""


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def strip_sections_by_predicate(text: str, should_skip) -> str:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    skipping = False
    header_re = re.compile(r"^\s*\[(.+?)\]\s*$")

    for line in lines:
        m = header_re.match(line.rstrip("\r\n"))
        if m:
            header = m.group(1).strip()
            skipping = should_skip(header)
            if skipping:
                continue
            out.append(line)
            continue
        if not skipping:
            out.append(line)

    return "".join(out).rstrip() + "\n"


def strip_plugins_and_marketplaces(text: str) -> str:
    def pred(header: str) -> bool:
        return header.startswith("marketplaces.") or header.startswith('plugins."') or (
            header.startswith("plugins.") and header != "plugins"
        )

    return strip_sections_by_predicate(text, pred)


def strip_mcp_servers(text: str, server_names: set[str]) -> str:
    if not server_names:
        return text

    def pred(header: str) -> bool:
        if not header.startswith("mcp_servers."):
            return False
        rest = header[len("mcp_servers.") :]
        if rest.endswith(".env"):
            rest = rest[: -len(".env")]
        return rest in server_names

    return strip_sections_by_predicate(text, pred)


def parse_mcp_server_names(text: str) -> set[str]:
    names: set[str] = set()
    try:
        data = tomllib.loads(text)
    except tomllib.TOMLDecodeError:
        return names
    mcp = data.get("mcp_servers")
    if isinstance(mcp, dict):
        names.update(mcp.keys())
    return names


def ensure_figma_mcp_overlay(text: str) -> str:
    names = parse_mcp_server_names(text)
    additions: list[str] = []
    if "figma" not in names:
        additions.append("""[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
startup_timeout_sec = 30
""")
    if "figma-desktop" not in names:
        additions.append("""[mcp_servers.figma-desktop]
url = "http://127.0.0.1:3845/mcp"
startup_timeout_sec = 30
""")
    if not additions:
        return text.strip()
    return "\n\n".join(part.strip() for part in [text.strip(), *additions] if part.strip())


def load_overlays(
    codex_home: Path,
    settings_path: Path,
    overlay_path: Path,
    mcp_overlay_path: Path,
) -> tuple[str, str]:
    common = ""
    context = ""

    if settings_path.is_file():
        settings = json.loads(read_text(settings_path))
        common = (settings.get("relayCommonConfigContents") or "").strip()
        context = (settings.get("relayContextConfigContents") or "").strip()

    if not common and overlay_path.is_file():
        common = read_text(overlay_path).strip()

    if not context and mcp_overlay_path.is_file():
        context = read_text(mcp_overlay_path).strip()

    context = ensure_figma_mcp_overlay(context or FIGMA_MCP_OVERLAY)

    return common, context


def merge_config(
    config_path: Path,
    common_overlay: str,
    context_overlay: str,
) -> dict[str, int]:
    if not config_path.is_file():
        raise FileNotFoundError(f"config not found: {config_path}")

    base = read_text(config_path)

    merged = strip_plugins_and_marketplaces(base)

    mcp_to_replace: set[str] = set()
    if context_overlay:
        mcp_to_replace = parse_mcp_server_names(context_overlay)
        if mcp_to_replace:
            merged = strip_mcp_servers(merged, mcp_to_replace)

    parts = [merged.rstrip()]
    if context_overlay:
        parts.append(context_overlay.strip())
    if common_overlay:
        parts.append(common_overlay.strip())

    final_text = "\n\n".join(p for p in parts if p) + "\n"

    tmp = config_path.with_suffix(".toml.merge.tmp")
    tmp.write_text(final_text, encoding="utf-8")
    tmp.replace(config_path)

    result = tomllib.loads(final_text)
    plugins = result.get("plugins") or {}
    marketplaces = result.get("marketplaces") or {}
    mcp = result.get("mcp_servers") or {}

    return {
        "plugins": len(plugins) if isinstance(plugins, dict) else 0,
        "marketplaces": len(marketplaces) if isinstance(marketplaces, dict) else 0,
        "mcp": len(mcp) if isinstance(mcp, dict) else 0,
    }


def extract_mcp_overlay(text: str) -> str:
    """Extract [mcp_servers.*] sections (incl. .env) from config text."""
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    in_mcp = False
    header_re = re.compile(r"^\s*\[(.+?)\]\s*$")

    for line in lines:
        m = header_re.match(line.rstrip("\r\n"))
        if m:
            header = m.group(1).strip()
            if header == "mcp_servers":
                in_mcp = False
                continue
            if header.startswith("mcp_servers."):
                in_mcp = True
                out.append(line)
                continue
            in_mcp = False
            continue
        if in_mcp:
            out.append(line)

    return "".join(out).strip()


def export_mcp_overlay_file(config_path: Path, mcp_overlay_path: Path) -> str:
    text = ensure_figma_mcp_overlay(extract_mcp_overlay(read_text(config_path)))
    if text:
        mcp_overlay_path.write_text(text + "\n", encoding="utf-8")
    return text


def main() -> int:
    codex_home = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))
    config_path = codex_home / "config.toml"
    settings_path = Path.home() / ".codex-session-delete" / "settings.json"
    overlay_path = codex_home / "codex-plus-overlay.toml"
    mcp_overlay_path = codex_home / "codex-plus-mcp-overlay.toml"

    if len(sys.argv) > 1:
        if sys.argv[1] == "--export-mcp":
            target = Path(sys.argv[2]) if len(sys.argv) > 2 else config_path
            out = Path(sys.argv[3]) if len(sys.argv) > 3 else mcp_overlay_path
            text = export_mcp_overlay_file(target, out)
            print("export_mcp_ok", len(parse_mcp_server_names(text)), "servers")
            return 0
        codex_home = Path(sys.argv[1])
        config_path = codex_home / "config.toml"

    common, context = load_overlays(codex_home, settings_path, overlay_path, mcp_overlay_path)

    if not common and not context:
        print("merge_skip no overlay sources")
        return 1

    counts = merge_config(config_path, common, context)
    print(
        f"merge_ok plugins={counts['plugins']} marketplaces={counts['marketplaces']} mcp={counts['mcp']}"
    )

    text = read_text(config_path)
    for key in ("figma@openai-curated", "github@openai-curated", "slack@openai-curated"):
        ok = f'plugins."{key}"' in text
        print(f"merge_check {key}={'yes' if ok else 'no'}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
