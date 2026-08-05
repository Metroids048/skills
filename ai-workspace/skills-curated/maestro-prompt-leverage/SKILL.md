---
name: maestro-prompt-leverage
description: "【中文名】Maestro Prompt Leverage — 把口语化 Agent 任务指令增强为带 Objective/Tool Rules/Output Contract/Done Criteria 的可执行 brief。用于 coding/debug/refactor/多步仓库任务、handoff、wrap prompt before execution。源自 ReinaMacCredy/maestro prompt-leverage。"
disable-model-invocation: false
---

# Maestro Prompt Leverage

Strengthen a raw user prompt into an execution-ready instruction set for Cursor, Claude Code, Codex, or other coding agents.

## When to use

- User gives a vague **implementation** ask ("fix the login", "add export", "clean up this module")
- Task needs clearer tool rules, verification, and done criteria before agent runs tools
- Wrapping current chat request into a reusable execution prompt

## Workflow

1. **Preserve intent** — quote the user's core ask; do not expand scope.
2. **Detect task type** — coding | research | writing | review | planning | analysis (see script or keywords below).
3. **Set intensity** — Light | Standard | Deep (production/critical → Deep).
4. **Emit structured brief** using blocks below.
5. **Optional**: run `scripts/augment_prompt.py "<raw>"` for a baseline scaffold, then refine in prose.

## Output blocks (required)

```markdown
## Objective
- Complete: [specific task]
- Optimize for correct, useful result — not plausible-sounding only.

## Context
- Preserve user constraints and scope boundaries.
- Assumptions: [list or 待确认]

## Work Style
- Task type: [type]
- Effort: [Light|Standard|Deep]
- Go deep where risk/complexity is highest.

## Tool Rules
- [Task-specific: inspect files first, narrowest verify, no guessing checkable facts]

## Output Contract
- [What the agent must return: summary, diffs, validation evidence, risks]

## Verification
- Correctness, completeness, edge cases before claiming done.

## Done Criteria
- Task satisfied, format matched, verification passed.
```

## Task detection (if not obvious)

| Type | Signals |
| --- | --- |
| coding | code, bug, repo, refactor, test, implement, fix, api |
| research | research, compare, sources, analyze |
| review | review, audit, critique |
| planning | plan, roadmap, strategy, outline |

## Script

`scripts/augment_prompt.py` — CLI baseline upgrade. Prefer skill reasoning for final brief.

## Upstream

Based on [ReinaMacCredy/maestro](https://github.com/ReinaMacCredy/maestro) `prompt-leverage` (vendored for tri-end without requiring `maestro` CLI).
