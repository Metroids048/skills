<!-- AGENT-CONFIG-PACK:WORKING-AGREEMENT START -->
# Global Working Agreement (agent-config-pack)

> Installed 2026-07-22. Also mirrored in `~/.claude/AGENTS.md` and `~/.ai-workspace/memory/agent-working-agreement.md`.
> After this block, continue following the Global AI Workspace section below.

# Global Working Agreement

These instructions are personal defaults for every repository. Project-level instructions and the user's current request may add more specific constraints.

## Communication

- Respond to the user in Chinese by default. Keep code, identifiers, commands, logs, and established project terminology in their original language.
- Be direct and evidence-based. Distinguish verified facts, assumptions, inferences, and unresolved uncertainty.
- Do not claim that work is complete, fixed, tested, deployed, or successful without evidence from actual tool output.

## Task interpretation

- Identify the requested outcome, constraints, non-goals, and observable completion criteria before editing.
- If the user asks only for analysis, planning, review, explanation, or research, do not modify files.
- Resolve minor ambiguity with the safest reasonable assumption and state it. Ask only when a decision materially changes the result or involves irreversible/high-risk action.
- For non-trivial work, inspect the relevant repository structure, existing implementation, tests, configuration, and recent local changes before proposing edits.

## Planning and scope

- Use the smallest process that fits the task. Do not create formal plans for trivial, local edits.
- For multi-file, architectural, risky, or poorly understood work, create a concise implementation plan with ordered milestones and verification for each milestone.
- Stay within scope. Do not perform unrelated refactors, dependency upgrades, formatting sweeps, or API changes.
- Prefer adapting existing patterns over introducing new abstractions or dependencies.

## Implementation

- Make the smallest coherent change that solves the root problem.
- Preserve backward compatibility unless the request explicitly permits breaking changes.
- For bug fixes, reproduce the failure first when feasible and add a regression test that fails before the fix and passes after it.
- Do not weaken, delete, skip, or rewrite valid tests merely to make a change pass.
- Do not add production dependencies without explaining why existing dependencies or standard-library options are insufficient.
- Never fabricate files, commands, APIs, test output, benchmark results, external responses, or platform behavior.

## Verification

- Discover and use the repository's documented validation commands. Do not invent commands when the project defines them.
- After edits, run the narrowest relevant checks first, then the required broader suite for the affected area.
- Verify behavior, not only syntax: execute the changed path, inspect outputs, and test meaningful edge cases when feasible.
- Review the final diff against the original request and acceptance criteria.
- Treat skipped or unavailable checks as unverified, not passed.

## Independent review

- For substantial changes, use a fresh context or an available reviewer subagent to inspect the final diff, original requirements, and real verification output.
- A reviewer must cite concrete evidence and must not edit implementation files while reviewing.
- Deterministic failures take precedence over model opinions.

## Safety

- Do not expose, print, commit, or transmit secrets, credentials, tokens, private keys, or `.env` contents.
- Do not run destructive commands, rewrite shared git history, delete user data, deploy to production, trade real funds, or perform irreversible migrations without explicit user authorization.
- Prefer dry runs, previews, backups, reversible migrations, and sandbox environments.
- Stop when requirements conflict, required evidence is unavailable, the environment is unsafe, or the next step needs a human business/risk decision.

## Retry and stopping rules

- Maximum automatic repair attempts for the same failing check: 3.
- If the same check fails twice without meaningful new evidence or progress, stop repeating the same approach. Reassess the root cause or escalate with evidence.
- Never loop indefinitely. Report completed work, remaining failures, attempted approaches, and the smallest next decision needed.

## Completion report

At completion, report:

1. What changed and why.
2. Files or components affected.
3. Exact verification commands run and their outcomes.
4. Known limitations, skipped checks, and remaining risks.
5. Whether the result is ready, partially complete, or blocked.

## Durable learning

- Keep global rules generic. Do not store project-specific paths, secrets, temporary task state, or speculative conclusions here.
- When a repeated mistake reveals a durable rule, propose a concise update to the nearest project instruction file rather than silently growing global instructions.
<!-- AGENT-CONFIG-PACK:WORKING-AGREEMENT END -->

# Global AI Workspace

Global rules: `C:\Users\win\.claude\AGENTS.md`
Global memory: `C:\Users\win\.ai-workspace\memory`
Skills index: `~/.claude/global-skills-index.md`

SessionStart: Read `C:\Users\win\.cursor\skills\global-session-core\SKILL.md` before other tools.
See also `~/.codex/RTK.md` if present.

## Git branches (default: main only)

Unless the user **explicitly** asks for a new branch or PR workflow:

- Stay on the current/`main` branch. Do **not** run `git checkout -b`, `git switch -c`, or create `codex/*` branches.
- Do **not** push a new remote branch (`git push -u origin HEAD`, `git push origin <new-branch>`).
- Prefer editing the existing local checkout. If using a Codex worktree, keep detached HEAD and never promote/push it as a remote branch unless asked.
- Never change a repo's GitHub default branch away from `main` unless asked.
## Windows Agent Shell (global)

**Codex on Windows may still use PowerShell 5.1 for `command_execution`** until `shell_path` + full restart. See `~/.ai-workspace/scripts/CODEX-WINDOWS-SHELL.md`.

Before Python / Chinese paths / Office files:

1. One-time stack: `install-global-agent-python.ps1` — see `~/.ai-workspace/AGENT-GLOBAL-STACK.md` (Office + agent tooling once; never reinstall per task/project)
2. Verify (any folder): `verify-global-agent-stack.ps1` or full `audit-windows-agent-env.ps1`
3. Agent/Office Python: `$env:AGENT_PYTHON script.py` or `agent-python script.py` — NOT Codex bundled python, NOT inline `python -c`
4. **Project tests:** `& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\resolve-test-runner.py"` first — do not claim global stack broken when project plugins are missing on AGENT_PYTHON
5. Read file: Cursor Read OR `read-text-file.py path`
6. Paths in JS/JSON/TOML: forward slashes `C:/Users/...` only — `\U` escapes are L1 tool bugs
7. **Failure triage:** L1 tool / L2 env / L3 project — `windows-failure-triage.mdc` + `windows-agent-failure-catalog-zh.md`. EPERM after Playwright success = L2 cleanup, not L3 fail
8. Never `rtk Get-Content`; prefer PS7 or `.ps1 -File`; never inline `$_`

Full rules: `~/.cursor/rules/windows-agent-shell.mdc` + `windows-failure-triage.mdc`
Upgrade/repair: `~/.ai-workspace/scripts/repair-windows-agent-env.ps1`

## 成本与稳定性约束（全局 · 所有项目）

SSOT: `~/.ai-workspace/memory/cost-stability-constraints.md` · Cursor: `~/.cursor/rules/cost-stability-constraints.mdc`

1. 本轮只完成已定义的唯一目标；不做非阻塞扩展与全面重构。
2. 长时测试/编译/安装：每 30–60 秒检查一次，禁止高频轮询。
3. 命令输出只读关键错误与末尾约 200 行；禁止把完整超长日志反复灌入上下文。
4. 429 / 断流 / 网关错误 / 无响应：最多自动重试 1 次；再失败立即停止并记录恢复点。
5. 每完成一个可独立验收的阶段，立即 Git 提交（授权阶段提交；用户当次说「不要提交」则跳过）。禁止提交密钥/`.env`/Cookie。
6. 不重复扫描已确认且未变化的文件。
7. 高推理仅用于根因与关键决策；方案确定后的实现降低推理强度。
8. 任务中断前必须输出：已完成内容、当前状态、未完成步骤、下一步命令、最新提交。

<!-- AIOS MANAGED BLOCK START -->
## AI Coding OS

For product design, page design, UI design, redesign, dashboard, landing page, AI product workflow, PRD-to-UI, or product/UI review tasks:

- Read `C:\Users\win\.ai-workspace\ai-coding-os\AGENTS.md`.
- Load only the specific AIOS workflow files needed for the task.
- Keep existing global and repo rules higher priority than AIOS.
- Do not jump from vague product/UI requests directly into code.
<!-- AIOS MANAGED BLOCK END -->

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

## Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`
<!-- codebase-memory-mcp:end -->

<!-- AGENT-CONFIG-PACK:CODEX-NOTE START -->
## Codex install note (2026-07-22)

- Codex loads **global** `~/.codex/AGENTS.md` first, then walks from project root toward cwd for project `AGENTS.md` (closer wins).
- `verify-work` skill: `~/.agents/skills/verify-work` and `~/.codex/skills/verify-work` (also project `.agents/skills/verify-work` when present).
- Do **not** maintain a separate Codex-only rulebook; project facts belong in each repo's `AGENTS.md`.
- For any repo missing filled placeholders in `AGENTS.md`, replace `<...>` with real install/test/build commands before relying on them.
<!-- AGENT-CONFIG-PACK:CODEX-NOTE END -->

<!-- AI-KNOWLEDGE-CENTER-START -->
## 本机 AI 全局知识管理中心

中央目录：`C:/Users/win/Desktop/全局配置`

开始非简单跨项目任务前，按需读取：

- `C:/Users/win/Desktop/全局配置/MEMORY_AGENTS.md`
- `C:/Users/win/Desktop/全局配置/USER_KNOWLEDGE_BASE.md`
- `C:/Users/win/Desktop/全局配置/当前全局状态.md`
- 相关项目：`C:/Users/win/Desktop/全局配置/项目镜像/<项目名>/`

任务结束：生成会话胶囊 → 更新项目 `项目知识库/` → `python 工具/知识中心.py 同步 --项目 <名>`。
不得静默覆盖中央主知识库；冲突只写待确认补丁。
禁止读取密钥/Cookie/钱包；禁止自动部署/真实交易/付款。

CLI：`python C:/Users/win/Desktop/全局配置/工具/知识中心.py --help`
<!-- AI-KNOWLEDGE-CENTER-END -->
