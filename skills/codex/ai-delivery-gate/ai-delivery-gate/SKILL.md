---
name: ai-delivery-gate
description: Agent Platform delivery gate — combines verification-before-completion with verify-all regression suite. Use before claiming prototype/app delivery complete, after editing prototype/assets/*.js, or when user asks for delivery sign-off.
---

# AI Delivery Gate (Agent Platform)

Mandatory gate before **done**, **fixed**, **PASS**, or **delivery ready**.

Read `.github/agent/memory/postmortem-navigation-2026-05-28.md` when touching navigation, session state, or `proto.js` init.

## Step 0 — Read verification-before-completion

Read the full skill (global or project copy):

- `~/.claude/skills/superpowers-main/skills/verification-before-completion/SKILL.md`, or
- `skills/superpowers-main/skills/verification-before-completion/SKILL.md`

**Iron law:** No completion claims without fresh verification evidence.

## Step 1 — Identify scope

| If you changed… | Required commands |
|-----------------|-------------------|
| `prototype/assets/*.js` | `node --check` on each file + full verify-all |
| Any `prototype/**/*.html` or CSS | `node prototype/scripts/verify-all.js` |
| Packaging / zip deliverable | `node prototype/scripts/package-check.js` + verify-all |
| App/src (future) | lint, typecheck, test, build as available |

## Step 2 — Run verify-all (prototype)

From project root:

```bash
node prototype/scripts/verify-all.js
```

Expected final line: **VERIFY-ALL PASSED (smoke + e2e + regression + browser-check + navigation-journey)**

**5 steps (all required):**

1. `smoke-check.js` — static + syntax
2. `e2e-check.js` — main-path contracts
3. `regression-check.js` — Proto vm load; Skills >= 6
4. `browser-check.js` — critical DOM (jsdom)
5. **`navigation-journey-check.js`** — index↔05 re-entry, firstConfig, double wire

**grep/smoke PASS ≠ navigation OK** (see ADR-003, postmortem).

First-time jsdom:

```bash
cd prototype && npm install jsdom --no-save
```

## Step 3 — Evidence checklist

Before claiming complete, confirm:

- [ ] Fresh command output captured in this session
- [ ] Exit code 0; navigation-journey step PASS
- [ ] No TODO/FIXME/mock left in changed files
- [ ] No `window.__*Wired` or session-only Tab lock (ADR-003)
- [ ] PDCA: `task-history.md` updated (via ai-coding-ok Mode C)

## Step 4 — Completion format

**Completed** — what was delivered  
**Verified** — commands run + key output lines  
**Remaining Risks** — gaps or manual spot-check items

If any step failed or skipped → **"Task is NOT fully verified."**

## User spot-check (2 min — navigation focus)

See `prototype/DELIVERY-CHECKLIST.md`:

1. Direct open `05-agent-detail.html?id=agt_demo_001` — Skills, `+`, Tabs OK
2. Back to `index.html` → re-enter 05 — **same as step 1**
3. `10-skills-management.html` — >= 6 Skill rows

## After updating this skill or project rules

```powershell
powershell scripts/sync-ai-guardrails.ps1 -Force
```
