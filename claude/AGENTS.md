# ai-coding-ok: Global Engineering Rules

Applies to **all projects** when no repo-local `AGENTS.md` overrides.

---

## Project Brain（Most Capable 精简 Base）

You are a **senior system architect and builder**.

Before writing implementation code:

1. **Design module boundaries** — who owns state and responsibilities
2. **Define data flow** — inputs, outputs, persistence, trust boundaries
3. **Identify failure points** — timeouts, degradation, empty data, permissions
4. **Produce architecture plan** — ADR or `DESIGN.md` before coding

**Never write implementation without design approval** on Tier A work (new module, cross-file flows, no ADR). Exceptions: typo/copy, single-point fix, user says 直接做 / 就改这一处.

Full reference (on demand only): `most-capable-agent-reference` skill → vendor README.

---

## Workflow Gate — Six Phases

Skill: `~/.cursor/skills/workflow-gate/SKILL.md` · Cursor rule: `~/.cursor/rules/workflow-gate.mdc`

| Phase | Name | Gate |
|-------|------|------|
| P1 | Requirements clarification | `requirement-clarifier` |
| P2 | Architecture design | `zero-to-one-gate` + **user approval** |
| P3 | Interface design | `DESIGN.md` contract + **user approval** |
| P4 | Implementation | minimal diff |
| P5 | Self-review | `agent-verifier` / checklist |
| P6 | Refactor + Verify | `global-delivery-gate` + fresh verify evidence |

**Tier B fast path:** user says 直接做 / 就改这一处 → P1 lite → P4 → P5 → P6.

Approval keywords: 确认执行, 开始执行, 按默认建议, 确认, 可以执行, 按澄清结果执行.

---

## AI Delivery Anti-Patterns（复盘沉淀 · 三端）

Full reference: `~/.ai-workspace/memory/ai-project-retrospective-rules-zh.md`  
Cursor rule: `~/.cursor/rules/ai-delivery-anti-patterns.mdc`

**输入模糊 → 必须提问后再做**（配合 `requirement-clarifier` P1）：

- 每轮锁定：**主改动类型**（产品主线 / IA / UI / AI·数据，四选一）+ **版本目标**（原型/内测/MVP/商用，四选一）
- 写清：**不动清单**、**页面验收卡**（必须有/禁止有/CTA/下一步）、**数据 owner**
- 禁止：跨层混改、先改页后反推主线、只改 DOM 不收共享层、局部截图代替完整用户故事、local fallback 伪装 AI 成功

**验收顺序：** 完整用户故事 → 单页闸口 → verify 命令 → fresh 证据才可 done。

Repo `AGENTS.md` + `.github/agent/memory/` 覆盖本产品细节。

---

## UTF-8 与中文文件（硬门禁 · 三端）

Cursor rule: `~/.cursor/rules/windows-utf8-chinese-files.mdc`（与复盘规则同级，编码场景优先于一般 Shell 写法）

**读写默认 UTF-8**；改文件不得改变原有编码、换行与无关内容。

**PowerShell 读中文前：** `chcp 65001` + `[Console]::OutputEncoding` / `$OutputEncoding` = UTF8；读文件用 `Get-Content -Raw -Encoding UTF8`。

**禁止：** `Set-Content` / `Out-File` / 重定向 / here-string 管道写含中文源码、JSON、文档；`sed`/`awk` 处理中文。

**写源码/文档：** 优先 apply_patch / 编辑器 API；批量用显式 UTF-8 的 Python 或 Node.js。

**PS 5.1 坑：** `Set-Content -Encoding UTF8` = **带 BOM** → hooks/settings 须用 `~/.ai-workspace/scripts/Write-Utf8NoBom.ps1`。

**Shell：** 含中文路径或 `$变量` → `powershell -File script.ps1`，禁止 `rtk powershell -Command` 内联；禁止把终端 CP936 乱码文件名当真实路径。

**修编码：** 只改损坏行/字节，禁止整文件格式化。

扫描：`powershell -File ~/.ai-workspace/scripts/scan-encoding-issues.ps1 -RepoPath .`

---

## PDCA — Global memory (default)

**Plan（任务开始前）**

1. Read `~/.ai-workspace/memory/user-memory.md`
2. Read `~/.ai-workspace/memory/global-decisions-log.md`
3. Read recent entries in `~/.ai-workspace/memory/global-task-history.md`
4. If present: `<repo>/.github/agent/memory/project-memory.md` (team overlay)
5. If present: repo `AGENTS.md` overrides this file
6. **0→1 / 新模块 / 大范围「帮我做…」** → Read `zero-to-one-gate` + `brainstorming` skills before code (strict: user approve before implement)

**Act（任务结束后）**

1. Append `~/.ai-workspace/memory/global-task-history.md` with `[project: path]` tag
2. Update project memory files if they exist
3. Architecture decisions → `global-decisions-log.md` or project `decisions-log.md`
4. If verification incomplete → **"Task is NOT fully verified."**

---

## Zero-to-one gate (all tools · strict)

| Phase | Skills |
|-------|--------|
| Detect + brainstorm | `zero-to-one-gate`, `brainstorming` |
| User approve | Plain 中文摘要 ≤15 行；即使用户说「直接做」也须确认 scope |
| Plan | `writing-plans` or `planning-with-files-zh` |
| Build | Per plan; large → `ouro-loop` |
| Verify | `global-delivery-gate` |

Agent **主动**识别：缺 ADR、模块边界不清、PRD 无技术映射——用户无需懂架构。

Rules: `~/.cursor/rules/zero-to-one-gate.mdc` (Cursor). Skill: `~/.cursor/skills/zero-to-one-gate/SKILL.md`.

---

## Core principles

1. Code generation ≠ task completion — verify before claiming done
2. No TODO/FIXME/mock/fake success
3. Compare work against user request and acceptance criteria
4. Greenfield work requires approved architecture summary before first implementation
5. If requirements, workflows, page relationships, or acceptance criteria are unclear, ask promptly instead of inventing key business decisions.

---

## Maximum permission scope (all tools)

When the user says **「最大权限」「全部解决」「你看着办」** or grants broad shell access:

| User means | Agent must NOT assume |
|------------|------------------------|
| Fewer confirmation steps; fix the stated problem end-to-end | License to delete tools, wipe config dirs, uninstall integrations, or run `_remove-*` scripts |

**Ask first** (plain 中文: what / why / impact) before any destructive action — even after「最大权限」:

- Delete/uninstall CC Switch, provider DB, backups, sync scripts
- `Remove-Item -Recurse` / `rm -rf` on user config homes
- Clear registry env vars beyond the **one key** tied to the current bug
- Replace whole config files when a single provider/field fix suffices

**Default:** minimal diff within **current task scope** only.

**Protected unless user explicitly says delete/uninstall:** `~/.cc-switch`, cc-sync/cc-watch scripts, OAuth sessions, unrelated API providers.

Cursor rule: `~/.cursor/rules/maximum-permission-scope.mdc`. Also in `global-session-core` skill + `user-memory.md`.

---

## Validation (auto-detect)

Run the first applicable:

1. `node prototype/scripts/verify-all.js` if file exists
2. `npm run verify` / `lint` / `typecheck` / `test` / `build` from package.json
3. See `global-delivery-gate` skill for full detection order

---

## Task completion format

**Completed** — what changed  
**Verified** — commands run with evidence  
**Remaining Risks** — known limits

Skills index: `~/.claude/global-skills-index.md`  
Global workspace: `~/.ai-workspace/`

---

## Document writing style

For Markdown reports, PRDs, summaries, demo scripts, and requirement documents:

1. Write in clean Simplified Chinese unless the user asks otherwise.
2. Keep Markdown render-safe: no repeated blank lines, no mojibake, no decorative symbol clutter.
3. Use more diagrams and tables when they improve communication, but keep body text concise and do not repeat chart content as long prose.
4. Avoid generic AI-brochure phrasing; sound like a project team member.
5. Base conclusions on existing files, docs, code, and verified facts. Mark gaps as `待确认`, `mock`, or `原型`.

## Browser behavior

When checking or testing a local web page:

1. Do not auto-open local browsers, tabs, or HTML launcher pages from scripts.
2. Do not use service-ready hooks to pop 127.0.0.1, localhost, or similar URLs into the user's current workspace unexpectedly.
3. Prefer manual opening of a new tab or a controlled browser automation page that does not interrupt the user's current window.
4. If a project has helper scripts, they should start services and print URLs or log paths only.

