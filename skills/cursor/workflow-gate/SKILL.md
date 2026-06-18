---
name: workflow-gate
description: ALWAYS apply — six-phase workflow gate with approval between architecture, interface design, and implementation. Maps to requirement-clarifier, zero-to-one-gate, and global-delivery-gate.
disable-model-invocation: false
---
# Workflow Gate — Six Phases

Applies to **Cursor, Claude Code, Codex**. Unified gate for spec-driven delivery.

## Tiers

| Tier | When | Path |
|------|------|------|
| **A — Strict** | New module, cross-file flow, no ADR, 「帮我做…」 | P1→P2→P3→approval→P4→P5→P6 |
| **B — Fast** | Typo, copy, single-line fix, user says 直接做/就改这一处 | P1 lite → P4 → P5 → P6 |

## Phases

| Phase | Name | Skills / artifacts | Approval required |
|-------|------|-------------------|-------------------|
| P1 | Requirements clarification | `requirement-clarifier` | Tier A: Mini-Spec confirm; Tier B: skip if user said 直接做 |
| P2 | Architecture design | `zero-to-one-gate`, `brainstorming`, ADR in `decisions-log.md` | **Yes** before P3 |
| P3 | Interface design | `DESIGN.md` or `docs/architecture/*` with interface contracts | **Yes** before P4 |
| P4 | Implementation | Minimal diff; match repo conventions | After P3 or Tier B skip |
| P5 | Self-review | `agent-verifier` or structured self-review checklist | Before claim done |
| P6 | Refactor + Verify | `global-delivery-gate`; run detected verify commands | Fresh evidence required |

## Approval keywords (align with clarification gate)

User may advance with: 确认执行, 开始执行, 按默认建议, 确认, 可以执行, 按澄清结果执行

## Before any code (Project Brain)

1. Design module boundaries
2. Define data flow
3. Identify failure points
4. Produce architecture plan

**Never write implementation without design approval** (Tier A). Exceptions: Tier B fast path only.

## Outputs by phase

- P2: ADR entry + 2–3 options + recommendation (≤15 lines summary)
- P3: Interface contract table (inputs, outputs, errors, owners)
- P6: Completed / Verified / Remaining Risks

## Cross-references

- 0→1 detail: `zero-to-one-gate`
- Plans: `writing-plans` or `planning-with-files-zh`
- Prototype delivery: `ai-delivery-gate` instead of `global-delivery-gate`
