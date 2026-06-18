---
name: workflow-gate
description: ALWAYS apply 鈥?six-phase workflow gate with approval between architecture, interface design, and implementation. Maps to requirement-clarifier, zero-to-one-gate, and global-delivery-gate.
disable-model-invocation: false
---
# Workflow Gate 鈥?Six Phases

Applies to **Cursor, Claude Code, Codex**. Unified gate for spec-driven delivery.

## Tiers

| Tier | When | Path |
|------|------|------|
| **A 鈥?Strict** | New module, cross-file flow, no ADR, 甯垜鍋氣€?| P1鈫扨2鈫扨3鈫抋pproval鈫扨4鈫扨5鈫扨6 |
| **B 鈥?Fast** | Typo, copy, single-line fix, user says 鐩存帴鍋?灏辨敼杩欎竴澶?| P1 lite 鈫?P4 鈫?P5 鈫?P6 |

## Phases

| Phase | Name | Skills / artifacts | Approval required |
|-------|------|-------------------|-------------------|
| P1 | Requirements clarification | `requirement-clarifier` | Tier A: Mini-Spec confirm; Tier B: skip if user said 鐩存帴鍋?|
| P2 | Architecture design | `zero-to-one-gate`, `brainstorming`, ADR in `decisions-log.md` | **Yes** before P3 |
| P3 | Interface design | `DESIGN.md` or `docs/architecture/*` with interface contracts | **Yes** before P4 |
| P4 | Implementation | Minimal diff; match repo conventions | After P3 or Tier B skip |
| P5 | Self-review | `agent-verifier` or structured self-review checklist | Before claim done |
| P6 | Refactor + Verify | `global-delivery-gate`; run detected verify commands | Fresh evidence required |

## Approval keywords (align with clarification gate)

User may advance with: 纭鎵ц, 寮€濮嬫墽琛? 鎸夐粯璁ゅ缓璁? 纭, 鍙互鎵ц, 鎸夋緞娓呯粨鏋滄墽琛?

## Before any code (Project Brain)

1. Design module boundaries
2. Define data flow
3. Identify failure points
4. Produce architecture plan

**Never write implementation without design approval** (Tier A). Exceptions: Tier B fast path only.

## Outputs by phase

- P2: ADR entry + 2鈥? options + recommendation (鈮?5 lines summary)
- P3: Interface contract table (inputs, outputs, errors, owners)
- P6: Completed / Verified / Remaining Risks

## Cross-references

- 0鈫? detail: `zero-to-one-gate`
- Plans: `writing-plans` or `planning-with-files-zh`
- Prototype delivery: `ai-delivery-gate` instead of `global-delivery-gate`