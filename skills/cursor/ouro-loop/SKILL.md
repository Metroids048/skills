---
name: ouro-loop
description: Use when a task needs MAP-PLAN-BUILD-VERIFY-REMEDIATE autonomous loops with multiple verification gates.
disable-model-invocation: true
---
# ouro-loop (Agent Platform wrapper)

**Vendor source:** [`skills/ouro-loop-master/program.md`](../../skills/ouro-loop-master/program.md)

## Required workflow

1. **Read** `skills/ouro-loop-master/program.md` completely.
2. **BOUND**: Read project `CLAUDE.md` → `@AGENTS.md` and `.github/agent/memory/project-memory.md`.
3. Follow MAP → PLAN → BUILD → VERIFY → REMEDIATE loop; do not skip gates.
4. Prototype changes: end loop only after `node prototype/scripts/verify-all.js` passes — all **5 steps** including `navigation-journey-check.js` (ADR-003).

Modules: `skills/ouro-loop-master/modules/*.md`

