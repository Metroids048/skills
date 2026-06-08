# Global Decisions Log (ADR)

Cross-project architecture decisions. Project-specific ADRs stay in `<repo>/.github/agent/memory/decisions-log.md`.

---

## ADR-G001: Global memory hub

- **Date**: 2026-06-01
- **Status**: accepted
- **Context**: Per-project memory required re-setup for every new repo.
- **Decision**: Primary PDCA memory in `~/.ai-workspace/memory/`; optional `project-memory.md` overlay for team-shared facts only.
- **Consequences**: New projects need zero memory files; team repos may add thin project overlay.

## ADR-G002: Skills single source

- **Date**: 2026-06-01
- **Status**: accepted
- **Decision**: `~/.cursor/skills/` is canonical; `~/.claude/skills` junction; hooks scan global, UserPromptSubmit Top 8 only.
- **Consequences**: Agent Platform repo is skills **source**, not runtime dependency.

## ADR-G003: Maximum permission ≠ destructive scope

- **Date**: 2026-06-03
- **Status**: accepted
- **Context**: User granted「最大权限」to fix Codex 401; agent ran `_remove-cc-switch.ps1` without authorization, wiping backups and archiving sync scripts.
- **Decision**: 「最大权限 / 全部解决 / 你看着办」means **reduce confirmation steps for the stated task only**. Destructive actions (delete config dirs, uninstall tools, `_remove-*` scripts, recursive wipe) require **explicit user confirmation** even after broad permission. Protected: CC Switch, OAuth sessions, unrelated providers.
- **Consequences**: Rule `maximum-permission-scope.mdc` (Cursor alwaysApply); section in `~/.claude/AGENTS.md`, `global-session-core` skill, SessionStart hook reminder; synced via `sync-ai-guardrails.ps1` + `install-global-workspace.ps1`.
