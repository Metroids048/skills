---
name: prompt-intake-router
description: "【中文名】Prompt 增强路由 — 与已有 intake/clarify skills 综合，每轮按需选用 1–2 个做 prompt 结构化或需求澄清（非三选一独占）。模糊实施、口语需求、优化 prompt、整理任务指令时 Read 本 skill，再 Read 选中的 1–2 个下游 skill 全文。"
disable-model-invocation: true
---

# Prompt Intake Router

## Purpose

**Not a replacement** for existing skills. When user input needs structuring before execution, pick **1–2 skills total** from the intake pool below — combined with `task-intake-bridge` / `global-session-core` (light classify only).

Do **not** load all three prompt enhancers in one turn. Do **not** skip the broader skill catalog when a better match exists.

## When to Read this skill

- Type B fuzzy implementation, vibe coding, spoken requirements
- User asks to optimize/clarify a prompt or task instruction
- **Skip**: Type A Q&A; Type C with full spec; 直接做/就改这一处 with explicit scope

## Intake pool (pick 1–2 per turn)

### A. Prompt 结构化（三选一，最多 1 个）

| Skill | When |
| --- | --- |
| `maestro-prompt-leverage` | Agent 编码/多步仓库任务、handoff 式执行 brief |
| `prompt-optimizer` | EARS 可测试需求、产品规格、可验收标准 |
| `prompt-architect` | 通用 prompt 框架（CO-STAR/RISEN 等）、写作类 prompt |

### B. 需求澄清（按需 0–1 个，常与 A 配对）

| Skill | When |
| --- | --- |
| `requirement-clarifier` | 模糊实施、Mini-Spec、§12 执行 Prompt（默认首选） |
| `pm-prd-writer` | 用户明确要 PRD/需求文档 |
| `brainstorming` | 需方案对比或创造性方向 |
| `idea-refine` | 极模糊产品想法、Not Doing / MVP 边界 |
| `zero-to-one-gate` | 新模块/新页面/无 ADR 覆盖 |

### Typical pairs (examples)

- 口语化「帮我做 X」→ `prompt-optimizer` + `requirement-clarifier`
- 「修这个 bug」→ `maestro-prompt-leverage` only（Type C 可跳过 clarifier）
- 「优化这段 prompt」→ `prompt-architect` only
- 新功能 + 方案未定 → `brainstorming` + `requirement-clarifier`

## Hard limits

- **Max 2** intake/clarify skills Read per turn (full SKILL.md each).
- **Max 1** from group A (architect / optimizer / maestro-leverage).
- Prefer **most specific** match over loading the whole chain.
- Output feeds existing gates; do not Write/Edit until Type B cleared or user confirms.

## Workflow

1. `task-intake-bridge` classifies (request_type, scope).
2. This router picks 1–2 from pool; Read those SKILL.md files only.
3. Produce brief enhanced intent → hand to `requirement-clarifier` §4.5/§12 when still Type B.
4. Reply start: `Skills: <chosen-1-or-2>, …` (router name optional if not Read).

## Integration (not a fixed pipeline)

```
User input
  → task-intake-bridge (classify)
  → [optional] 1–2 from intake pool (this router guides selection)
  → [if still fuzzy] requirement-clarifier / zero-to-one-gate / …
  → implementation + delivery gate
```

Other domain skills (debug, figma, ppt, verify, …) still win via global index when the task is not intake-heavy.
