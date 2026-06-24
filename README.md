# ai-global-config

Cursor、Claude Code、Codex **三端全局配置** 的可移植源仓库。从本机导出 skills、rules、hooks、AGENTS、Codex 配置与 `~/.ai-workspace` 脚本/记忆模板，另一台设备 clone 后一条命令对齐环境。

## 包含内容

| 目录 | 说明 |
|------|------|
| `skills/cursor/` | 全局 Skills 正本（`~/.cursor/skills`） |
| `cursor/rules/` | Cursor always-on / ECC rules（`*.mdc`） |
| `cursor/hooks.json.template` | Cursor 钩子模板 |
| `cursor/mcp.json.example` | MCP 配置示例（token 已脱敏） |
| `claude/` | AGENTS.md、settings.json.example、hooks 片段 |
| `codex/` | AGENTS.md、config.toml.example |
| `ai-workspace/scripts/` | scan-global-skills、澄清硬拦等共用脚本 |
| `ai-workspace/memory/` | 用户记忆与 ADR **模板**（非运行时私有状态） |
| `ai-workspace/docs/` | Headroom、三端总览等文档 |
| `projects/program1/` | AI 求职台项目级 AGENTS、agent-memory、memory-global 快照 |
| `install.ps1` | 新机器一键安装 |
| `scripts/export-from-local.ps1` | 从本机刷新仓库内容 |

## 新设备安装（Windows）

```powershell
git clone https://github.com/Metroids048/skills.git
cd skills
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装后：

1. 按 `secrets/README.md` 填写 MCP token、API 代理、HCAI key
2. 重启 Cursor、Claude Code、Codex
3. （可选）各项目运行 `codegraph init -i`；启动 headroom / agentmemory 见 `ai-workspace/docs/`

## 从本机更新仓库（维护者）

在已配置好的机器上：

```powershell
cd skills
powershell -ExecutionPolicy Bypass -File scripts/export-from-local.ps1 -Force
git add -A
git commit -m "chore: sync global config from local"
git push
```

## 三端对齐原理

```
skills/cursor  ──copy──>  ~/.cursor/skills
                              │
                    junction ├──> ~/.claude/skills
                              └──> ~/.codex/skills

ai-workspace/scripts  ──>  ~/.ai-workspace/scripts  (三端 hooks 共用)

cursor/rules  ──>  ~/.cursor/rules
claude/AGENTS.md  ──>  ~/.claude/AGENTS.md
codex/*  ──>  ~/.codex/
```

## 版本

见 `manifest.json`（skill 数量、导出日期）。
