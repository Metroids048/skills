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

## ADR-G006: Windows/Codex failure triage + global install once

- **Date**: 2026-07-17
- **Status**: accepted
- **Context**: Codex/Cursor tasks repeatedly surfaced the same Windows issues (path `\U` escapes, PowerShell regex, AGENT_PYTHON vs project pytest, Playwright EPERM cleanup, missing SDKs). Users had already repaired global Python/encoding multiple times; agents re-reported L1/L2 as "environment broken" and re-pip'd per project, wasting time and disk.
- **Decision**:
  1. Catalog SSOT: `~/.ai-workspace/memory/windows-agent-failure-catalog-zh.md`
  2. Always-on rule: `windows-failure-triage.mdc` — every verify failure must be labeled L1 tool / L2 env / L3 project
  3. Global venv (`install-global-agent-python.ps1`) installs Office + agent tooling (pytest/yaml/requests/httpx/jsonschema/chardet) **once**; `resolve-test-runner.py` selects project vs global interpreter
  4. `repair-windows-agent-env.ps1` / `audit-windows-agent-env.ps1` enforce catalog + rule presence + tooling modules
  5. Codex/Claude `AGENTS.md` + `CODEX-WINDOWS-SHELL.md` + `AGENT-GLOBAL-STACK.md` updated to match
- **Consequences**: Agents must not reinstall global deps per project; must not call L1/L2 a project failure; EPERM cleanup after successful browser flow is L2 only.

## ADR-G007: 成本与稳定性约束（全局 always-on）

- **Date**: 2026-07-30
- **Status**: accepted
- **Context**: 长任务中高频轮询、灌入完整日志、无限重试与范围漂移抬高成本并降低稳定性；需要跨 Cursor / Claude Code / Codex 统一约束。
- **Decision**:
  1. SSOT: `~/.ai-workspace/memory/cost-stability-constraints.md`
  2. Cursor alwaysApply: `~/.cursor/rules/cost-stability-constraints.mdc`
  3. Claude / Codex shim: `~/.claude/AGENTS.md` 与 `~/.codex/AGENTS.md` 同名章节
  4. 八条硬约束：单目标、30–60s 轮询、日志末尾约 200 行、API/网关最多重试 1 次、阶段 Git 提交、不重复扫描、推理分级、中断恢复点
  5. 阶段提交覆盖 Working Agreement「未要求不提交」的默认习惯；用户当次说「不要提交」仍可跳过
- **Consequences**: 多阶段任务默认阶段提交；429/断流类失败不得死循环；实现阶段应降低发散推理。

