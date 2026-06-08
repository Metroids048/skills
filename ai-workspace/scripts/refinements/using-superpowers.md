# Using Skills (Cursor)

## Rule

Match the user request to skill **descriptions** in `~/.cursor/skills/`. **Read** the full `SKILL.md` when the task clearly fits **or** when `zero-to-one-gate` signals apply (see below).

Priority: **user instruction** > matched project/global skill > Cursor built-in skill > default behavior.

**Conflict:** `zero-to-one-gate` (strict) overrides「直接做 / 快点」— still require scheme summary + approval before implementation.

## When to load a skill

| Signal | Action |
|--------|--------|
| User names a skill or domain (PRD, Figma, TDD, 架构, 0→1…) | Read that skill |
| Description clearly matches the task | Read that skill |
| Vibe coding「帮我做一个…」「新模块」「从0」 | Read **zero-to-one-gate** first, then **brainstorming** |
| Multiple skills fit | Pick the most specific; 0→1 chain (gate + brainstorm + plan) may load together |
| No match | Proceed without skill files |

## When NOT to load

- Pure chit-chat, git status, or one-line factual questions
- Already loaded the same skill this session for the same task type

## Process skills (mandatory for 0→1)

- **zero-to-one-gate** — 新功能、新模块、新页面、大范围需求；Agent 主动识别，用户无需懂技术
- **brainstorming** — **required** after zero-to-one-gate; 2–3 approaches before code
- **writing-plans** / **planning-with-files-zh** — after user approves architecture
- **systematic-debugging** — before fixing bugs or test failures
- **verification-before-completion** / **global-delivery-gate** — before claiming done

**Skip brainstorming only for:** typo, copy edit, single-file bug with explicit scope, or step within an existing approved plan+ADR.

## Announce

If you used skills, one short line at reply start: `Skills: name-a, name-b`.

## Conflicts

If two skills disagree, prefer the **more specific** skill. **zero-to-one-gate (strict)** wins over fast-delivery shortcuts.
