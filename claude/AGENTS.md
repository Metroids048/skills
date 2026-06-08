# ai-coding-ok: Global Engineering Rules

Applies to **all projects** when no repo-local `AGENTS.md` overrides.

---

## PDCA — Global memory (default)

**Plan（任务开始前）**

1. Read `~/.ai-workspace/memory/user-memory.md`
2. Read `~/.ai-workspace/memory/global-decisions-log.md`
3. Read recent entries in `~/.ai-workspace/memory/global-task-history.md`
4. If present: `<repo>/.github/agent/memory/project-memory.md` (team overlay)
5. If present: repo `AGENTS.md` overrides this file
6. **0→1 / 新模块 / 大范围「帮我做…」** → Read `zero-to-one-gate` + `brainstorming` before code (strict: user approve before implement)
7. **模糊 / 口语化需求** → Read `requirement-clarifier` with `global-session-core`; output §12 execution Prompt before implementation unless user said 直接执行

**Act（任务结束后）**

1. Append `~/.ai-workspace/memory/global-task-history.md` with `[project: path]` tag
2. Update project memory files if they exist
3. Architecture decisions → `global-decisions-log.md` or project `decisions-log.md`
4. If verification incomplete → **"Task is NOT fully verified."**

---

## Karpathy 行为准则（always on）

Read `~/.cursor/rules/karpathy-guidelines.mdc` / `~/.cursor/skills/karpathy-guidelines/SKILL.md` — 编码前思考、简洁优先、精准修改、目标驱动验证。与 `requirement-clarifier`、交付门禁互补。

来源：[andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)

---

## Requirement clarifier (all tools · always on)

SessionStart: Read `requirement-clarifier` with `global-session-core`. Clarify fuzzy requests before implementation unless user said 直接执行.

---

## Zero-to-one gate (all tools · strict)

| Phase | Skills |
|-------|--------|
| Detect + brainstorm | `zero-to-one-gate`, `brainstorming` |
| User approve | Plain 中文摘要 ≤15 行 |
| Plan | `writing-plans` or `planning-with-files-zh` |
| Build | Per plan; large → `ouro-loop` |
| Verify | `global-delivery-gate` |

---

## Maximum permission scope (all tools)

「最大权限」= 少确认、修当前问题 — **不是**删 CC Switch / 清配置 / `_remove-*`。破坏性操作须先说明影响并获确认。

---

## Core principles

1. Code generation ≠ task completion — verify before claiming done
2. No TODO/FIXME/mock/fake success
3. Greenfield requires approved architecture before first implementation

---

## Validation (auto-detect)

1. `node prototype/scripts/verify-all.js` if exists
2. `npm run verify` / `lint` / `typecheck` / `test` / `build` from package.json
3. See `global-delivery-gate` skill

---

## Task completion format

**Completed** / **Verified** / **Remaining Risks**

Skills index: `~/.claude/global-skills-index.md`

**ECC supplement (optional):** `~/.claude/AGENTS.ecc-supplement.md` — use after `/plugin install ecc@ecc` only; do not stack `install.ps1 --profile full`.
