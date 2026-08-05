# 导入会话胶囊

- 来源文件：`C:\Users\win\.cursor\projects\c-Users-win-Desktop-Operating-Platform\agent-transcripts\d54d6414-197d-4b94-842e-96aa4f4935d2\d54d6414-197d-4b94-842e-96aa4f4935d2.jsonl`
- hash：`2d13f90792596d348d05543e33d16510bf0db7dba08254346e378fa17e6f3f1f`
- 工具：cursor
- 项目：Operating Platform
- 状态：COMPLETE
- 轮次数：19
- 隐私命中：False

## 角色区分

### User

<user_query>
 @c:\Users\win\.cursor\projects\c-Users-win-Desktop-Operating-Platform\terminals\1.txt:34-36 
</user_query>

### Assistant

正在配置全局设置，使每次任务开始前自动检查项目 `skills` 文件夹。先查看项目结构与相关技能文档。

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

正在实现：以始终生效的项目规则为主（最可靠），并配合 `sessionStart` 钩子自动生成 skills 索引。

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

索引为空，正在排查扫描脚本问题。

[REDACTED]

### Assistant

[REDACTED]

### Assistant

修复 PowerShell 脚本中 `$entries +=` 在管道内无法正确累积的问题。

[REDACTED]

### Assistant

[REDACTED]

### Assistant

[REDACTED]

### Assistant

优化扫描脚本：排除重复副本并修复输出编码。

[REDACTED]

### Assistant

[REDACTED]

### Assistant

已为项目配置「每次任务前先扫描 skills」的全局机制，包含三层保障：

## 已配置内容

### 1. 始终生效的项目规则
`.cursor/rules/project-skills-first.mdc`（`alwaysApply: true`）

每次任务开始前 Agent 会：
- 读取 `.cursor/skills-index.md`（或扫描 `skills/**/SKILL.md`）
- 用 `name` / `description` 与当前任务匹配
- 命中则 Read 对应 `SKILL.md` 并严格执行；未命中则走常规流程

### 2. 会话启动钩子（自动刷新索引）
- `.cursor/hooks.json`：在 `sessionStart` 时运行扫描脚本
- `.cursor/hooks/scan-project-skills.ps1`：遍历 `skills/`，生成索引并尝试注入上下文

当前已索引 **43 个** 可用 skill（已排除 `agency-agents-main`、各工具链副本目录等噪音路径）。

### 3. Cursor 标准位置的引导 skill
`.cursor/skills/using-project-skills/SKILL.md` — 与内置 skill 机制对齐，强化「先扫项目 skills」习惯。

## 你需要做的一步

1. **信任本工作区**（项目 hooks 仅在受信任工作区运行）
2. 保存 `hooks.json` 后若未生效，**重启 Cursor** 或打开 **Settings → Hooks** 确认已加载
3. 新对话开始时会自动更新 `.cursor/skills-index.md`

> 说明：`sessionStart` 的 `additional_context` 在部分 Cursor 版本可能未注入（已知问题）；**规则 `project-skills-first` 是主要保障**，钩子负责维护索引。

## 项目里已有的实用 skills（示例）

| 场景 | skill |
|------|--------|
| Figma / 产品分析 | `figma-product-report` |
| 前端 UI | `frontend-design` |
| React 性能 | `vercel-react-best-practices` |
| 多步骤规划 | `planning-with-files-zh` |
| PM 写 PRD / 路线图等 | `SPACE-prd-writer`、`SPACE-roadmap-planner` 等 |
| 调试 / TDD | `systematic-debugging`、`test-driven-development` |

完整列表见 `.cursor/skills-index.md`。

## 若希望「所有项目」都生效

当前配置绑定本仓库的 `skills/` 目录。若要在任意项目复用同一流程，可将 `.cursor/rules/project-skills-first.mdc` 复制到用户级规则目录，或为每个项目单独配置 hooks。

如需把某几个内置 Cursor skill（如 `create-rule`、`loop`）同步下载到 `skills/`，告诉我具体场景即可。

[REDACTED]
