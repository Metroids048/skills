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

## ADR-G004: AI delivery anti-patterns (round boundary + clarify-first)

- **Date**: 2026-06-18
- **Status**: accepted
- **Context**: program1-main 多轮任务因未锁改动层级（产品/IA/UI/AI）、模糊输入直接执行、局部验收，导致返工与「越改越差」。
- **Decision**:
  1. 全局规则 `ai-delivery-anti-patterns.mdc` + 长期记忆 `ai-project-retrospective-rules-zh.md`
  2. 模糊输入必须先提问（主改动类型、版本目标、不动清单、验收方式、页面验收卡）— 配合 `requirement-clarifier` / `workflow-gate` P1
  3. 每轮只允许一个主改动类型；验收顺序：用户故事 → 单页闸口 → verify
  4. 产品级细节写入 repo `project-memory.md`，不堆进全局 always-on 正文
- **Consequences**: Cursor/Claude/Codex 共享 `~/.claude/AGENTS.md` 摘要；Codex 经 `~/.codex/AGENTS.md` 指针生效。

## ADR-G005: Global agent master SSOT

- **Date**: 2026-06-22
- **Status**: accepted
- **Context**: Cursor, Codex, and Claude Code each had strong but partially duplicated guardrails. The top-level behavior needed one shared source for question gating, R2T, skill/tool triggering, and rework classification.
- **Decision**: Create ~/.ai-workspace/memory/global-agent-master.md as the SSOT. Reduce ~/.claude/AGENTS.md, ~/.codex/AGENTS.md, and key Cursor always-on rules to thin shims that reference the master.
- **Consequences**: Cross-tool behavior is now governed by one document; repo-local AGENTS still win on project details; existing safety rules remain in the shims.

