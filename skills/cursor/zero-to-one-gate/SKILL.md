---
name: zero-to-one-gate
description: Use when work is greenfield, a new module/page/workflow, or 帮我做… without ADR coverage — before Write/Edit on implementation files.
disable-model-invocation: false
---

# Zero-to-One Gate

Use this skill to stop premature implementation on new capabilities or broad architecture changes.

## Trigger signals

Trigger when any of these are true:

- a new feature introduces a new workflow or subsystem
- a new page, module, service, or API surface is being created
- the request implies greenfield design or "build me X"
- the work crosses multiple files with new data flow or state flow
- the architecture is unclear, undocumented, or missing an ADR-level decision

## Required flow

Follow this sequence before implementation:

1. Restate the problem and success criteria
2. Present 2-3 realistic approaches with tradeoffs
3. Recommend one approach
4. Capture the decision in a short architecture summary or ADR-style note
5. Wait for user approval
6. Only then move to planning and implementation

## Do not trigger for

- typo fixes
- copy changes
- narrow, explicit bug fixes
- small edits inside an already-approved architecture

## Guardrails

- Do not "just scaffold something quickly" to figure it out later.
- Do not hide architecture decisions inside implementation.
- If a request starts broad but becomes clearly scoped after clarification, continue with a normal plan and execution flow.
