---
name: global-session-core
description: ALWAYS apply at session start. Core agent workflow — skill routing, lean token habits, verification-before-completion, global memory paths. Read this SKILL.md at the start of every conversation before other tools.
disable-model-invocation: false
---

# Global Session Core (always on)

This skill applies to **every** conversation in Cursor, Claude Code, and Codex.

## 0. Global memory (every coding task)

Before coding, Read (paths injected at SessionStart):

- `~/.ai-workspace/memory/user-memory.md`
- Recent entries in `global-task-history.md`
- Project overlay `project-memory.md` if hook lists one

After tasks: append `global-task-history.md` per `ai-coding-ok` Mode C.

## 1. Skill routing (using-superpowers)

1. Match the user request to skill **names/descriptions** in `~/.cursor/skills/` (index: `~/.claude/global-skills-index.md`).
2. For each clearly applicable skill, **Read** the full `SKILL.md` at its absolute path before using other tools.
3. Pick the most specific match; avoid loading more than 2–3 domain skills per turn — **except** the 0→1 chain (`zero-to-one-gate` + `brainstorming` + plan skill) counts as one group and is always allowed together.
4. At reply start, one short line: `Skills: name-a, name-b` (include `global-session-core` when this skill guided the session).
5. Priority: **user instruction** > matched skill > built-in > default.

**Do NOT load skills for:** pure chit-chat, one-line factual questions, or when user rules already cover the same workflow without needing the skill body.

## 1.5 Zero-to-one detection (strict)

After memory load, **before any Write/Edit on implementation files**, self-check against `zero-to-one-gate` §1 signals (新模块、新页面、「帮我做…」、无 ADR 覆盖等).

If triggered:

1. **Read** `~/.cursor/skills/zero-to-one-gate/SKILL.md` and `brainstorming/SKILL.md`
2. Present 2–3 approaches; get user approval; write ADR or `docs/architecture/` summary
3. **Do not** scaffold or implement until approved — even if user says「直接做」
4. Then `writing-plans` or `planning-with-files-zh` → build → `global-delivery-gate`

## 2. Lean token habits (savethetokens Lean Mode)

1. Keep progress updates short and phase-based; do not narrate every file write.
2. Do not paste long command output unless asked — summarize key signals only.
3. One chat session per task; start fresh for unrelated work.
4. Compact around 50% context usage instead of waiting for hard limits.
5. **Never** reduce code thoroughness to save tokens — tests, verification, safety checks, and error handling are non-negotiable.

## 3. Verification before completion

Before claiming **done**, **fixed**, or **PASS**:

1. Re-read the user request and acceptance criteria.
2. Follow **`global-delivery-gate`** skill — auto-detect verify command for this repo.
3. Capture **fresh command output** as evidence — no assumed PASS.
4. If verification was skipped → state **"Task is NOT fully verified."**

## 4. Maximum permission scope (never overstep)

When the user says **「最大权限」「全部解决」「你看着办」**:

- **Means:** fewer back-and-forth steps to fix **the stated problem** — not permission to expand scope or run destructive cleanup.
- **Ask first** before: deleting/uninstalling tools or config dirs (CC Switch, backups, sync scripts), `Remove-Item -Recurse`, removal scripts (`_remove-*`), disabling unrelated auto-sync, or wiping registry env beyond the one key tied to the bug.
- **Default:** minimal diff only (e.g. fix one CC Switch provider for Codex 401 — do **not** remove CC Switch).
- **Protected unless explicit delete/uninstall:** `~/.cc-switch`, cc-sync/cc-watch, OAuth sessions, unrelated providers.

Cursor: `~/.cursor/rules/maximum-permission-scope.mdc`. Global: `~/.claude/AGENTS.md` § Maximum permission scope.

## 5. Project-specific gates (when detected)

- **`prototype/scripts/verify-all.js`** present → use `ai-delivery-gate` skill (5 steps incl. navigation-journey).
- **Project `AGENTS.md`** → overrides global `~/.claude/AGENTS.md` for that repo.
