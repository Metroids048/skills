# Supplement tools (2026-06-03)

Conservative install — does **not** replace `scan-global-skills`, `global-session-core`, or `requirement-clarifier`.

Backup: `~/.ai-workspace/backups/pre-supplement-tools-2026-06-03/`

## ECC ([affaan-m/ECC](https://github.com/affaan-m/ECC))

| Tool | What was installed | Conflicts avoided |
|------|-------------------|-------------------|
| Claude Code | `minimal` → `~/.claude/skills/ecc/`, rules; marketplace in `settings.json` (run `/plugin install ecc@ecc` manually) | No ECC hooks; no `profile full` |
| Cursor | `minimal` → `~/.cursor/` skills/rules/agents; **hooks restored** to scan-global-skills only | ECC hooks.json reverted |
| Codex | `minimal` → `~/.codex/skills/`; `AGENTS.md` restored + `AGENTS.ecc-supplement.md` | Primary AGENTS = global workspace |

Vendor clone: `~/.ai-workspace/vendor/ECC`

## CodeGraph ([colbymchenry/codegraph](https://github.com/colbymchenry/codegraph))

- CLI: `@colbymchenry/codegraph` v0.9.9 global
- MCP wired: Claude, Cursor (`~/.cursor/mcp.json`), Codex (`~/.codex/config.toml`)
- Project index: `Agent Platform/.codegraph/` (`codegraph init -i`)

## Understand Anything ([Lum1104/Understand-Anything](https://github.com/Lum1104/Understand-Anything))

- Repo: `~/.understand-anything/repo`
- Codex/Cursor: junctions under `~/.agents/skills/` and `~/.cursor/skills/` (`understand`, `understand-chat`, …)
- Claude Code: marketplace `Lum1104/Understand-Anything` in `settings.json` → run `/plugin install understand-anything`

Commands (after CC plugin): `/understand`, `/understand-dashboard`, `/understand --language zh`

## Manual steps (user)

1. Restart Cursor / Claude Code / Codex sessions.
2. In Claude Code: `/plugin marketplace add Lum1104/Understand-Anything` then `/plugin install understand-anything`; optionally `/plugin install ecc@ecc` (do not also run `install.ps1 --profile full`).
3. In Cursor Plugins UI: add `https://github.com/Lum1104/Understand-Anything` if auto-discover fails.
4. Trim `~/.cursor/mcp.json` MCP servers if context feels heavy (ECC added github/context7/exa/memory/playwright/sequential-thinking).

## Uninstall pointers

- ECC: `node ~/.ai-workspace/vendor/ECC/scripts/uninstall.js --dry-run`
- CodeGraph: `codegraph uninstall --yes`
- UA: `~/.ai-workspace/vendor/Understand-Anything/install.ps1 -Uninstall codex` (+ remove Cursor junctions manually)
