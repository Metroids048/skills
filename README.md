# ai-global-config

Cursor、Claude Code、Codex **三端全局配置** 的可移植源仓库。从本机导出 skills、rules、hooks、AGENTS、Codex 配置与 `~/.ai-workspace` 脚本/记忆模板，另一台设备 clone 后一条命令对齐环境。

## 包含内容

| 目录 | 说明 |
|------|------|
| `skills/cursor/` | Cursor 全局 skills 快照（`~/.cursor/skills`） |
| `skills/claude/` | Claude Code 全局 skills 快照（`~/.claude/skills`） |
| `skills/codex/` | Codex 全局 skills 快照（`~/.codex/skills`） |
| `skills/agents/` | `.agents/skills` 子集入口 |
| `cursor/rules/` | Cursor always-on / ECC rules（`*.mdc`） |
| `cursor/commands/` | Cursor slash commands |
| `cursor/hooks/` | Cursor hook 脚本 |
| `cursor/mcp-configs/` | Cursor MCP server 配置 |
| `cursor/hooks.json.template` | Cursor 钩子模板 |
| `cursor/mcp.json.example` | MCP 配置示例（token 已脱敏） |
| `claude/` | AGENTS/CLAUDE、settings.example、commands、rules、MCP、global skills index |
| `codex/` | AGENTS、RTK、config/overlay examples、hooks、scripts、MCP |
| `ai-workspace/scripts/` | scan-global-skills、澄清硬拦、Windows agent shell、修复/验证脚本 |
| `ai-workspace/memory/` | 用户记忆、全局任务历史、项目注册表、ADR/复盘记录 |
| `ai-workspace/ai-coding-os/` | AIOS 产品/UI 工作流唯一源 |
| `ai-workspace/templates/` | 全局模板 |
| `ai-workspace/skills-curated/` | 轻量 curated skill 源材料 |
| `projects/*/` | 项目级 AGENTS、CLAUDE、`.github/agent` memory/rules 快照 |
| `knowledge-center/` | Desktop「全局配置」**完整**快照（含原始记录/会话归档；仓库须为 Private） |
| `archives/` | Codex/Claude/Cursor 会话与历史沉淀（sessions、file-history、transcripts） |
| `docs/reports/` | skills 去重/迁移审计报告 |
| `install.ps1` | 新机器一键安装 |
| `scripts/export-from-local.ps1` | 从本机刷新仓库内容 |

## 不包含内容

仓库有意排除真实 secrets、auth/session 凭证、sqlite runtime、浏览器/插件缓存、venv/vendor、`node_modules`、CC Switch 与 AppData 编辑器缓存。  
**本仓库应为 Private**：`archives/` 与 `knowledge-center/` 含个人/项目对话沉淀。

## 新设备安装（Windows）

```powershell
git clone https://github.com/Metroids048/skills.git
cd skills
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装后：

1. 按 `secrets/README.md` 填写 MCP token、API 代理、HCAI key
2. 重启 Cursor、Claude Code、Codex
3. 运行 `powershell -NoProfile -File "$env:USERPROFILE\.ai-workspace\scripts\audit-windows-agent-env.ps1"`
4. （可选）把 `projects/*` 中的项目 memory 快照复制到对应项目根；启动 headroom / agentmemory 见 `ai-workspace/docs/`

默认安装会保持三端 skills 差异。若希望进一步精简成 Cursor skills 为正本，Claude/Codex 使用 junction：

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -UseJunctionSkills
```

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
skills/claude  ──copy──>  ~/.claude/skills
skills/codex   ──copy──>  ~/.codex/skills

可选：
skills/cursor  ──junction──>  ~/.claude/skills + ~/.codex/skills

ai-workspace/scripts  ──>  ~/.ai-workspace/scripts  (三端 hooks 共用)

cursor/rules  ──>  ~/.cursor/rules
claude/AGENTS.md  ──>  ~/.claude/AGENTS.md
codex/*  ──>  ~/.codex/
```

## 版本

见 `manifest.json`（skill 数量、导出日期）。

## 当前去重结论

最新报告见 `docs/reports/agent-workspace-stocktake.md`：

- 三端加 `.agents` 共扫描 880 个 skill。
- 发现 280 组内容完全一致，主要来自三端复制。
- 建议下一阶段将重复 skill 收敛为“单一源 + 端侧 shim/junction”，并优先处理薄封装/泛描述 skill。
- 实际删除或归档仍需要逐项确认，当前仓库先保存完整快照。
