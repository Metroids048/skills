# 三端配置同步记录（2026-09-12）

本次同步从本机 Codex、Claude Code、Cursor 及共享 AIW Runtime 采集可公开复用的配置与 Skill。

## 已纳入

- `skills/claude/`：当前 Claude Code 全量技能快照（含 `.system` 公开技能素材）。
- `claude/`、`codex/`、`cursor/`：三端的 rules、commands、hooks、MCP 配置和可移植示例配置。
- `runtime/`、`registry/`：AIW Runtime 与项目/技能注册表。
- `memory/`：仅 public-safe bootstrap memory 与全局工作契约。

Cursor 与 Codex 当前通过 junction 指向共享 `skills-src`；仓库中的 `skills-src/` 仍是 canonical curated source，三端差异保留在各自 endpoint 快照目录。

## 明确排除

认证 token、Cookie、私钥、`.env`、数据库、缓存、日志、原始 session/transcript、浏览器状态、真实私人长期记忆（`~/.ai-workspace/private-memory`）及项目源码均未纳入提交。示例配置中的机器绝对路径已改为 `%USERPROFILE%`，凭证改为占位符。
