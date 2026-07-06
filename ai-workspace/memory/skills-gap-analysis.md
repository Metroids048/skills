# Top GitHub Skills 库 — 三端全局安装评估（2026-06-03）

> 目标：查缺补漏，**不是**再装 1000+ 技能。已有 **206** 全局 skills + always-on 门禁，再全量安装会稀释路由、挤占上下文。

## 当前 always-on 栈（建议保持）

| 层 | 组件 | 作用 |
|----|------|------|
| 会话 | `global-session-core` | 路由、记忆、token 习惯 |
| 任务前 | `requirement-clarifier` | 模糊需求 → 可执行 Prompt |
| 编码行为 | `karpathy-guidelines` | 简洁、精准 diff、目标驱动 |
| 0→1 | `zero-to-one-gate` + `brainstorming` | 新模块须方案确认 |
| 交付 | `global-delivery-gate` / `ai-delivery-gate` | 验证再声称完成 |
| PDCA | `ai-coding-ok` | 项目记忆读写 |
| 补充 | ECC minimal、CodeGraph、Understand-Anything | 见 `supplement-tools-installed.md` |

---

## 你列的 Top 10 — 逐项结论

| # | 库 | 星数 | 三端全局？ | 建议 | 与现有重叠 |
|---|-----|------|-----------|------|-----------|
| 1 | [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | 16.9K+ | ⚠️ 仅精选 | **不要全装 337+**；按域 cherry-pick（PRD→已有 `pm-prd-writer`/`create-prd`） | 高 — 工程/PM 与 `pm-skills-main`、ECC 重叠 |
| 2 | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 39K+ | ❌ 不建议全局 | 体积极大；用 **关键词路由** 按需 Read，或维护 `promptKeywordBoosts` | 中 — 部分已散落在 `~/.cursor/skills` |
| 3 | [spencerpauly/awesome-cursor-skills](https://github.com/spencerpauly/awesome-cursor-skills) | 8.5K+ | ✅ Cursor 规则/技能 | 可同步 **5–10 条** 到 `~/.cursor/skills/cursor-awesome-*`（性能、并行探索） | 低 |
| 4 | [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 24K+ | ❌ 目录型 | 作 **索引** 用 `global-skills-index.md`，不批量复制 | 高若全装 |
| 5 | [github/awesome-copilot](https://github.com/github/awesome-copilot) | 官方 | ✅ Codex/Copilot | Codex 用户可 `copilot plugin` 选装；与 Cursor 格式不同 | 中 |
| 6 | ComposioHQ/awesome-claude-skills | 精选50 | ⚠️ Claude 向 | 作 **清单对照** 查漏；单条缺失再装 | 中 |
| 7 | [ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books) | 1.7K+ | ✅ rules | 以 **rules 片段** 补充 `~/.cursor/rules/books-*`（非 always-on） | 低 |
| 8 | best-of-n-solving | — | ✅ 已有能力 | 用 Cursor **`best-of-n-runner` Task** + `using-git-worktrees` | 已覆盖 |
| 9 | screenshotting-changelog | — | ⚠️ 按需 | PR/发布场景再装单 skill；非每次任务 | 无 |
| 10 | grinding-until-pass | — | ✅ 已有能力 | `ouro-loop` + `verification-before-completion` + `ai-delivery-gate` | 已覆盖 |

---

## 推荐「第二批」补缺（可选、仍保守）

1. **Karpathy** — ✅ 已装（rules + skill + AGENTS 指针）
2. **awesome-cursor-skills** — ✅ 已装 3 条（junction 三端）：`cursor-awesome-parallel-exploring`、`cursor-awesome-auditing-performance`、`cursor-awesome-building-skills-from-patterns`
3. **ciembor/agent-rules-books** — ✅ `~/.cursor/rules/books-clean-code.mdc`、`books-ddd.mdc`（nano，`alwaysApply: false`）
4. **claude-skills** — ✅ 合规域 cherry-pick：`rezvani-soc2-audit-prep`、`rezvani-gdpr-audit-prep`、`rezvani-ai-act-readiness`（非全量 337+）

**不建议全局装：** antigravity-awesome-skills 全库、VoltAgent 1000+、claude-skills 全量、ECC 再 full 一遍。

---

## Claude Code 插件（手动）

```text
/plugin marketplace add multica-ai/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills
```

（中文 README 写 `forrestchang` 为历史 marketplace 名；当前仓库插件名为 `andrej-karpathy-skills`。）

---

## 维护原则

1. **always-on ≤ 4 个 skill 正文**（session、clarifier、karpathy、delivery 按需）
2. **新增库先 `install-plan --dry-run` 或单文件 junction**
3. **每月** 跑 `skill-stocktake`（ECC 自带）或扫重名目录
4. **项目级** 放 repo `.cursor/skills/`，**全局** 只放跨项目通用

---

## 2026-07-02 用户请求库 — 安装与跳过记录

脚本：[`install-requested-skills-batch.ps1`](../scripts/install-requested-skills-batch.ps1)、[`install-james-picks.cmd`](../scripts/install-james-picks.cmd)、[`install-awesome-ai-ppt.ps1`](../scripts/install-awesome-ai-ppt.ps1)

| 源 | 结果 | 说明 |
|----|------|------|
| [jamesrochabrun/skills](https://github.com/jamesrochabrun/skills) | ✅ 8 项 junction 三端 | anthropic-architect, llm-router, engineer-expertise-extractor, design-brief-generator, content-brief-generator, query-expert, technical-launch-planner, qa-test-planner |
| [ningzimu/awesome-ai-ppt](https://github.com/ningzimu/awesome-ai-ppt) | ✅ awesome-ai-ppt | meta 工具选型 skill |
| [hugohe3/ppt-master](https://github.com/hugohe3/ppt-master) | ⏸ `[待确认]` | zip/git 超时；重跑 batch 或 `npx skills add hugohe3/ppt-master` |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | ⏸ `[待确认]` | main.zip 下载超时；重跑 `install-awesome-copilot-cherry.ps1` |
| [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry) | ⏭ 索引 stub | vendor README，无 skills 树 |
| [MingChao-king/SuperProgramming](https://github.com/MingChao-king/SuperProgramming) | ⏭ 跳过 | 与 brainstorming / writing-plans / ouro-loop / tdd-workflow 重复 |
| [presenton/presenton](https://github.com/presenton/presenton) | ⏭ 跳过 | 完整应用；未部署 Docker/MCP |

### 中文元数据层（同批）

| 文件 | 作用 |
|------|------|
| [`skills-locale-zh.json`](../skills-locale-zh.json) | P0 中文 label/summary/triggers SSOT |
| [`apply-skills-locale.ps1`](../scripts/apply-skills-locale.ps1) | 写回三端 SKILL.md description |
| [`global-skills-index-zh.md`](file:///C:/Users/win/.claude/global-skills-index-zh.md) | 中文可读目录（scan 生成） |
| [`skills-picker-cheatsheet-zh.md`](skills-picker-cheatsheet-zh.md) | 场景速查 |

**UI 限制：** 列表标题仍为 slug 格式化英文名；副标题 description 中文优先。
