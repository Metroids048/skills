<!-- AGENT-CONFIG-PACK:WORKING-AGREEMENT START -->
# Global Working Agreement (agent-config-pack)

> Installed 2026-07-22. Canonical copy: `~/.ai-workspace/memory/agent-working-agreement.md`.
> Project `AGENTS.md` and current user request override when more specific.

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

Global master: `C:\Users\win\.ai-workspace\memory\global-agent-master.md`
Global memory: `C:\Users\win\.ai-workspace\memory`
Skills index: `~/.claude/global-skills-index.md`

SessionStart: Read `C:\Users\win\.cursor\skills\global-session-core\SKILL.md` before other tools.
See also `~/.codex/RTK.md` if present.

## Plain-language confirmation rule

For any large change or conflict with existing behavior, stop and ask the user in plain non-technical language before implementing. Explain what will change on screen, what existing workflow or data may be affected, and give clear options with tradeoffs.
## Windows Agent Shell (global)

Before Python / Chinese paths / Office files / Shell cmdlets:

1. Verify when needed: `powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\audit-windows-agent-env.ps1"`
2. Read files with the Read tool when available, or `& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\read-text-file.py" "path"`
3. Run Python with the global agent Python: `$env:AGENT_PYTHON script.py` or `agent-python script.py`; do not use inline `python -c` for multi-line, Chinese paths, or Office work.
4. Office/PPT/Word uses the global venv from `python-env.json`; do not use Codex bundled Python under `.cache\codex-runtimes`.
5. PowerShell 7 is installed at `C:\Program Files\PowerShell\7\pwsh.exe`; Codex may still need `~/.codex/config.toml` `[windows].shell_path` plus a full restart before default shell probes show PS7.
6. Never use `rtk` for PowerShell cmdlets such as `Get-Content`, `Select-Object`, or `Get-ChildItem`; use PS7 directly or a `.ps1 -File`.
7. **Failure triage (mandatory):** classify L1 tool / L2 env / L3 project — see `~/.cursor/rules/windows-failure-triage.mdc` and `~/.ai-workspace/memory/windows-agent-failure-catalog-zh.md`. Never report path `\U` escapes, EPERM cleanup, or missing project pytest-on-AGENT_PYTHON as "project failed".
8. **Project tests:** run `& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\resolve-test-runner.py"` first. Global stack installs Office + agent tooling once; do not reinstall per project.
9. **Paths in JS/JSON/TOML:** use forward slashes `C:/Users/...` — never raw `C:\Users\...` in string literals.

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
