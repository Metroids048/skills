# User Memory (Global)

Last updated: 2026-07-22

> Cross-project facts, preferences, and workflow conventions. **Do not commit to git** — lives in `~/.ai-workspace/memory/`.

## Retrospective rules (Read on product/UI/AI tasks)

**Full text:** `~/.ai-workspace/memory/ai-project-retrospective-rules-zh.md`  
**Cursor rule:** `~/.cursor/rules/ai-delivery-anti-patterns.mdc`

- 输入模糊（优化一下/改 UI/对标竞品/整体弄好）→ **必须提问**锁定主改动类型、版本目标、不动清单、验收方式；禁止脑补后直接改代码
- 大幅度改动、删除/替换已有内容、改变产品流程，或新需求与当前实现/PRD/ADR 冲突 → **必须用通俗非技术语言先问用户如何取舍**；说明冲突点、2-3 种改法、用户能看到的影响和推荐方案；用户说“继续/直接做”也不豁免真实冲突确认
- 每轮**只选一个**主改动类型：产品主线 / IA / UI / AI·数据 — 禁止混改
- 改页必须同步：共享样式、文案、状态、测试
- 验收：完整用户故事先于单页截图；verify 通过才可 claim done
- AI 求职台产品链路见 `program1-main/.github/agent/memory/project-memory.md`

## Preferences

- Reply language: 简体中文 (unless user asks otherwise)
- Skills: global library at `~/.cursor/skills/`; match by description, Read full SKILL.md when applicable
- Token habits: short updates, no long log dumps; never skip verification to save tokens
- Tools: Cursor + Claude Code + Codex share hooks via `~/.ai-workspace/scripts/`
- **0→1 mode: strict** — 新模块/大范围「帮我做…」必须先方案+ADR+用户确认，再写代码；用户非技术，由 Agent 主动补 ADR/模块边界
- **Maximum permission:** 「最大权限」「全部解决」= 少来回确认、把**当前问题**修完 — **不等于**可删 CC Switch、清配置目录、跑卸载脚本；破坏性操作须先说明并获确认
- **成本与稳定性（2026-07-30 / ADR-G007）：** 单目标；长命令 30–60s 轮询；日志只取错误+末尾约 200 行；429/断流最多重试 1 次；可验收阶段立即 Git 提交；中断必报恢复点。SSOT: `cost-stability-constraints.md`


<!-- AGENT-CONFIG-PACK:MEMORY START -->
## Agent Config Pack (三端统一架构) — 2026-07-22

推荐结构（不要分别维护三套完全不同的规则）：

```
全局个人规则（Working Agreement）
    ↓
项目根 AGENTS.md（共同事实来源；Claude 用 @AGENTS.md 导入）
    ↓
工具专用补丁（Cursor .cursor/rules；Claude CLAUDE.md + .claude/rules）
    ↓
verify-work Skill
    ↓
测试 / CI / Hooks / 权限（硬性约束）
```

### 安装位置速查

| 层 | 路径 |
|---|---|
| Working Agreement 规范副本 | `~/.ai-workspace/memory/agent-working-agreement.md` |
| Codex 全局 | `~/.codex/AGENTS.md`（含 managed block） |
| Claude 全局 | `~/.claude/CLAUDE.md` + `~/.claude/AGENTS.md` |
| Cursor 全局规则 | `~/.cursor/rules/00-agent-working-agreement.mdc` |
| Cursor User Rules 粘贴源 | `~/.cursor/USER_RULES.txt` 与 `~/.ai-workspace/templates/cursor/USER_RULES.txt`（Settings → Rules → User Rules） |
| verify-work | `~/.agents|/.cursor|/.claude/skills/verify-work/SKILL.md` |
| 项目模板 | `~/.ai-workspace/templates/agent-config-pack/` |

### AGENT_LESSONS / 长期记忆只记什么

只记录长期有效且已验证：真实构建测试命令、特殊架构约束、重复≥2次错误、已证实根因与修复、外部平台不明显行为。

不要记录：临时进度、一次性日志、未验证猜测、隐私密钥、整段会话上下文。

Claude auto memory：保持为索引（启动约前 200 行 / 25KB）；不是硬执行机制。

### 使用原则（摘要）

- 单文件小改：直接改 + 针对性测试
- Bug：先复现再回归测试
- 多文件/架构：里程碑 + 验收
- 分析任务：禁止擅自实施
- 重要功能：独立上下文评审
- 真金/生产/破坏性 DB：必须人工确认
- 同一失败连续两次无进展：停止重复方案
- 所有「完成」必须附真实命令与结果
- 提示词只能影响行为；硬规则靠 Hooks / 权限 / 测试 / CI
<!-- AGENT-CONFIG-PACK:MEMORY END -->

## Global Workflow

1. SessionStart: Read `global-session-core` skill + this file before coding tasks
2. Coding tasks: ai-coding-ok PDCA — global memory first, project overlay if present
3. **0→1 chain (strict):** `zero-to-one-gate` → `brainstorming` → user approve → `writing-plans` or `planning-with-files-zh` → build → `global-delivery-gate`
4. Before claiming done: run detected verify commands (see `global-delivery-gate` skill)
5. After tasks: append `global-task-history.md` with `[project: path]` tag

## Lessons Learned (cross-project)

- Skills hooks must use `scan-global-skills.ps1`, not full catalog dump (saves tokens)
- JSON settings for RTK must be UTF-8 **without BOM**
- Re-run `rtk init -g --auto-patch` after updating Claude hooks
- Vibe coding「帮我做一个…」= 0→1 until proven otherwise — do not skip architecture for speed
- **2026-06-03:** Agent 误删 CC Switch 配置（用户未授权）— 「最大权限」仅图省事，禁止越权破坏性操作；见 ADR-G003 + `maximum-permission-scope.mdc`
- **2026-06-17 三端避坑（TASK-072）：** `windows-agent-shell.mdc` + `repair-tri-end-hooks.ps1` + `CLAUDE_CODE_ATTRIBUTION_HEADER=0`
- **2026-06-17 交付门禁（TASK-073）：** `node-project-delivery.mdc` — Agent Platform 用 `verify-all`；`program1-main`/`demo1` 用 `npm run verify`；勿在平台根跑 `npm run lint`
- **2026-06-17 DeepSeek 缓存二期：** 客户端 `15721` → CC Switch → `18789` `deepseek-cc-proxy`（tool 排序 + 剥 header）；playbook：`Agent Platform/docs/tri-end-deepseek-cache-playbook-zh.md`
- **2026-06-18 AI 项目复盘（program1-main）：** 未锁「本轮改哪一层」就改页面 → 返工恶性循环；已沉淀为 `ai-project-retrospective-rules-zh.md` + `ai-delivery-anti-patterns.mdc` + ADR-G004；模糊输入必须提问，禁止跨层混改
- **2026-07-17 Windows/Codex 失败三层 + 全局装一次（ADR-G006）：** 路径 `\U`、PS 正则、AGENT_PYTHON≠项目 pytest、EPERM 清理等反复出现，是 L1/L2 被误报成「环境又坏了」+ 每项目重装。目录 `windows-agent-failure-catalog-zh.md`；规则 `windows-failure-triage.mdc`；测试前 `resolve-test-runner.py`；依赖只进 `~/.ai-workspace/venv` 一次

## Active Projects

See `projects-registry.md` for path → alias mapping.

<!-- AGENT-CONFIG-PACK:MULTI-PROJECT START -->
### 多项目说明（2026-07-22）

- **Codex 全局已就绪**：`~/.codex/AGENTS.md`（Working Agreement + workspace 规则）+ `~/.agents/skills/verify-work` + `~/.codex/skills/verify-work`。
- **项目层对所有已发现仓库安装**（不仅 alpha）：每个仓库的 `AGENTS.md` bridge、`CLAUDE.md`、`.cursor/rules/00|10`、`.claude/rules/testing`、`code-reviewer`、`verify-work`、docs 模板。
- 已有项目的 `AGENTS.md` **正文不覆盖**，只 upsert bridge；无 `AGENTS.md` 的仓库用 pack 模板创建（含 `<...>` 占位符，需按项目填实）。
- 项目清单见 `projects-registry.md`。
<!-- AGENT-CONFIG-PACK:MULTI-PROJECT END -->
