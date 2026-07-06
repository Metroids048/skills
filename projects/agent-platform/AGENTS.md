# ai-coding-ok: v1.0 (Agent Platform)

> **Project override** — global defaults live in `~/.claude/AGENTS.md` and `~/.ai-workspace/memory/`. This file adds prototype/Figma/verify-all gates for this repo.

# AI Engineering Operating Rules

This project uses AI-assisted development.

ALL agents (Claude Code, Codex, Cursor, GPT, Gemini, DeepSeek, etc.) MUST follow the rules below.

Failure to follow these rules means the task is NOT complete.

---

## PDCA — 任务开始前/结束后必做

**Plan（任务开始前）**

1. Read global `~/.claude/AGENTS.md` § **Engineering Assistant Charter**
2. Read this `AGENTS.md`
3. If present: project root `SESSION.md` / `TASK.md`（轻量任务上下文）
4. Read `.github/agent/memory/project-memory.md`
5. Read `.github/agent/memory/decisions-log.md`
6. Read `.github/agent/memory/task-history.md`

**Act（任务结束后，不可跳过）**

1. Update `task-history.md` with task summary
2. Sync `SESSION.md` 顶部 Current Status（若存在，≤15 行摘要）
3. Update `TODO.md` / `REVIEW.md` if present for active task
4. If architecture changed → update `decisions-log.md`
5. If project facts changed → update `project-memory.md`
6. If verification incomplete → state **"Task is NOT fully verified."**

---

# 1. CORE PRINCIPLES

## 1.1 Never Assume Completion

Code generation DOES NOT equal task completion.

Before ending ANY task, the AI MUST:

- verify functionality
- verify requirements
- verify UX
- verify architecture consistency
- verify edge cases
- verify error handling
- verify responsiveness
- verify production readiness

## 1.2 No Fake Completion

The AI MUST NOT:

- claim something works without verification
- leave placeholder implementations
- use fake APIs
- use mock logic unless explicitly allowed
- skip unfinished features
- hide errors
- silently ignore failures

Forbidden examples: TODO, FIXME, temporary hack, mocked implementation, fake response, hardcoded success.

## 1.3 Requirement Alignment

Compare implementation against PRD.md, TASKS.md, user instructions, and prior architecture decisions. Identify missing requirements, partial implementations, inconsistent behaviors, UX mismatches, API mismatches.

## 1.4 大改与冲突必须先确认

当任务涉及大幅度改动、产品主线调整、页面结构重排、删除已有功能、改变已有流程，或新需求与当前实现/PRD/ADR 冲突时，AI MUST 先用通俗易懂的非技术性语言询问用户如何取舍。

询问必须说明：

- 现在冲突点是什么
- 有哪几种改法
- 每种改法对用户体验或业务流程有什么影响
- 推荐哪一种以及原因

在用户确认前，不得直接按自己的判断重构、删除或替换已有内容。用户明确说“继续”“直接做”时，也只代表减少无关确认；遇到上述冲突仍必须先问。

---

# 2. MANDATORY SELF-REVIEW LOOP

Before completing ANY task: Implement → Self Review → Functional Verification → UX Verification → Edge Case Review → Production Review.

Check logic errors, missing states, duplicated code, broken architecture, dead code, security risks, and invalid assumptions.

---

# 3. REQUIRED VALIDATION COMMANDS

**This repo (Agent Platform) — no root `package.json`. Do NOT run `npm run lint` at repo root.**

Prototype / shared JS (when touching `prototype/`):

```bash
node prototype/scripts/verify-all.js
```

**verify-all runs 9 steps** (all must pass when applicable):

1. `package-check.js`
2. `smoke-check.js` — static contracts + `node --check`
3. `e2e-check.js` — main-path logic keywords
4. `regression-check.js` — vm-load Proto; Skills catalog >= 6
5. `browser-check.js` — critical page DOM (jsdom)
6. `navigation-journey-check.js` — index↔05 re-entry, firstConfig, double wire
7. `ops-interaction-journey-check.js`
8. `web-portal-check.js`
9. `v11-ops-check.js`

**Node/React sub-projects** (see `~/.ai-workspace/memory/projects-registry.md` — e.g. `program1-main`, `demo1`):

```bash
npm run verify
```

Typically: `lint` + `typecheck` + `test` + `build`. Rule: `node-project-delivery.mdc`.

**Generic npm template** (only when project has `package.json`):

```bash
npm run lint
npm run typecheck
npm run test
npm run build
```

**Important:** smoke/e2e grep PASS does **not** guarantee navigation works. See ADR-003 and `.github/agent/memory/postmortem-navigation-2026-05-28.md`.

If ANY command fails: DO NOT FINISH. FIX FIRST.

**Shared JS gate** — after editing `prototype/assets/*.js`:

- `node --check` on changed files
- Full `**verify-all.js`** (includes navigation-journey — not regression alone)

**Forbidden (ADR-003):** Reintroduce `window.__*Wired` skip flags; session-only Tab lock without `?new=1`.

**User spot-check after proto changes:** index → 05 → back → re-enter 05 (see `prototype/DELIVERY-CHECKLIST.md`).

**After updating project rules/skills:** `powershell scripts/sync-ai-guardrails.ps1 -Force`

---

# 4–12. UI, ARCHITECTURE, DEBUGGING, COMPLETION FORMAT

See `.github/copilot-instructions.md` and `.cursor/rules/` for UI/UX, architecture, debugging, PRD enforcement, and Definition of Done details.

## Task Completion Format

Before ending a task, provide:

**Completed** — feature list  
**Verified** — tests/commands run with evidence  
**Remaining Risks** — known limitations

If verification is incomplete: **"Task is NOT fully verified."**

---

## Zero-to-one gate (strict · this repo)

Before **new HTML pages**, **new proto modules**, **new session state keys**, or **cross-page flows**:

1. Read `zero-to-one-gate` + `brainstorming` skills (global: `~/.cursor/skills/`)
2. Write ADR in `.github/agent/memory/decisions-log.md` and/or `docs/architecture/YYYY-MM-DD-<topic>.md`
3. User approves scheme (plain 中文 ≤15 行) — even if user says「直接做」
4. Then `writing-plans` or `planning-with-files-zh` → implement → `verify-all`

**Navigation/session:** any change to `proto.js` or 05 re-entry → cite ADR-003; plan must include index↔05 spot-check.

**PRD → code:** map each PRD module to owner file (`proto.js` vs `ops-`* vs `editor-shell.js`) before coding.

---

# Ops v1.1 UX Contract (mandatory for prototype root ops pages)

1. **Reuse v1.0 shell** — `ops-platform-shell.js` topbar + sidebar; do **not** invent a second nav system.
2. **Entry** — default page = card list (`index.html`); sidebar **智能体运营** expands to **运营概览** + **审核工作台** only.
3. **No duplicate audit entry** — no audit shortcuts on dashboard or card homepage.
4. **Card interaction** — click card = view detail (`agent-detail.html`); v1.1 `⋯` menu per lifecycle doc; audit lives in `audit-workbench.html`.
5. **file:// navigation** — ops pages at prototype root use relative hrefs (`dashboard.html`, `audit-workbench.html`).
6. **Verify** — `node prototype/scripts/v11-ops-check.js` after any v1.1 change (also step 9 of verify-all).

Postmortem: `.github/agent/memory/postmortem-ops-v11-2026-06-09.md`

---

# Web 用户端 UX Contract (mandatory for `prototype/web端/`)

1. **Screenshot fidelity** — 改 UI 前对照用户截图或 Figma 376；plan 中「可选」项须用户确认后才可写入 HTML/契约。
2. **+ 菜单** — 仅「上传文件 + 引用笔记」；禁止擅自添加语音输入替换上传能力。
3. **模型下拉** — 顶栏与选项显示 4 个 DeepSeek 全名；禁止 Flash/标准/深度/专家 tier 化名。
4. **笔记 summary** — 卡片/chip/popover/选笔记预览仅标题 + 短总结（≤120 字）；轮次与全文仅在 `#historySummaryModal`。
5. **Verify** — `node prototype/scripts/verify-all.js` after any `user-*.js` or `web端/*.html` change.

Postmortem: `.github/agent/memory/postmortem-user-portal-2026-06-10.md` · ADR-015 v5

---

# Project Quick Reference


| Area             | Path                                                                 |
| ---------------- | -------------------------------------------------------------------- |
| HTML prototype   | `prototype/`                                                         |
| Shared state/Nav | `prototype/assets/proto.js`                                          |
| Delivery gate    | `prototype/scripts/verify-all.js` (5 steps incl. navigation-journey) |
| Postmortem       | `.github/agent/memory/postmortem-navigation-2026-05-28.md`           |
| Memory           | `.github/agent/memory/`                                              |
| Cursor rules     | `.cursor/rules/`                                                     |
| Skills vendor    | `skills/vendor/`                                                     |
|                  |                                                                      |

