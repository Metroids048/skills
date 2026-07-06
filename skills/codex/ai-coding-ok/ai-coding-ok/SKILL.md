---
name: ai-coding-ok
description: USE FIRST on any coding task. Global-first PDCA — read ~/.ai-workspace/memory/ before work, append global-task-history after. Project overlay at .github/agent/memory/ when present. Also install/upgrade ai-coding-ok guardrails.
---

# ai-coding-ok (Global-first wrapper)

**Vendor source:** [`skills/vendor/ai-coding-ok/SKILL.md`](../../skills/vendor/ai-coding-ok/SKILL.md)

Global memory root: `%USERPROFILE%\.ai-workspace\memory\`

## Mode B — Plan (before any coding task)

Read in order:

1. `~/.ai-workspace/memory/user-memory.md` — cross-project preferences and lessons
2. `~/.ai-workspace/memory/global-decisions-log.md` — global ADRs
3. `~/.ai-workspace/memory/global-task-history.md` — recent tasks (last ~10 entries)
4. **If exists:** `<repo>/.github/agent/memory/project-memory.md` — team/project facts
5. **If exists:** `<repo>/.github/agent/memory/decisions-log.md` and `task-history.md`
6. **Rules:** `<repo>/AGENTS.md` if present, else `~/.claude/AGENTS.md`
7. Read vendor SKILL.md above for full guardrails
8. **0→1 self-check** (strict): if `zero-to-one-gate` §1 signals → Read `zero-to-one-gate` + `brainstorming`, ADR + user approve before any implementation

Then proceed — if 0→1 triggered, the task is the gate flow until approved; otherwise continue with the user's task.

## Mode C — Act (after finishing a coding task)

1. **Always** append `~/.ai-workspace/memory/global-task-history.md`:
   - Format: `## [TASK-xxx] title` with `[project: path or alias]`, date, summary, verified
   - Update `projects-registry.md` last-active date if row exists
2. **If** `<repo>/.github/agent/memory/` exists → also update project `task-history.md`
3. Architecture changes → global or project `decisions-log.md` as appropriate
4. Project fact changes → project `project-memory.md` (team) or `user-memory.md` (personal cross-project)

## Install / upgrade

See vendor SKILL.md Mode A. For global workspace bootstrap:

```powershell
powershell -File "$env:USERPROFILE\.ai-workspace\scripts\install-global-workspace.ps1"
```
