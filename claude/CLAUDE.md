@AGENTS.md
@RTK.md

<!-- AGENT-CONFIG-PACK:CLAUDE-ADDITIONS START -->
# Claude Code global additions (agent-config-pack)

> Installed 2026-07-22. Working Agreement lives in `@AGENTS.md` (managed block).

- Use project Skills for repeatable multi-step procedures instead of expanding this file.
- For substantial changes, delegate final review to a read-only `code-reviewer` subagent / fresh context when available.
- Treat CLAUDE.md and auto memory as guidance, not enforcement. Mandatory checks must be implemented through tests, CI, permissions, or Hooks.
- Auto memory may store stable discoveries (real commands, architecture decisions, recurring failure patterns, proven debugging). It must not store secrets, temporary task details, unverified guesses, or user-sensitive information.
- Prefer `verify-work` skill before claiming COMPLETE.
- Keep this file concise; durable cross-tool rules belong in `AGENTS.md` / `~/.ai-workspace/memory/`.
- Cost & stability: follow `~/.ai-workspace/memory/cost-stability-constraints.md` (also in `@AGENTS.md`).
<!-- AGENT-CONFIG-PACK:CLAUDE-ADDITIONS END -->

# Global AI Workspace

**SessionStart:** Read `C:\Users\win\.cursor\skills\global-session-core\SKILL.md` and global memory at `C:\Users\win\.ai-workspace\memory\user-memory.md`.

**全局工作规则：** 有任何不确定和拿不准主意的都必须要先问用户，不可自行假设后直接执行。整个任务的进度、流程、思考过程、操作说明和提问都必须用中文详细展示。

**交付自查规则（Mandatory）：** 任何任务声明完成前，必须用 Read 工具重新读取所有被修改的关键代码段，逐一确认预期逻辑已落地（不能只凭记忆），再告知用户完成。若发现预期逻辑未落地，必须继续修复直到读取验证通过才能声明完成。禁止在未读取验证的情况下说"已修复"或"已完成"。

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
