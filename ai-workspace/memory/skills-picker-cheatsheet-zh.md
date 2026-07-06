# Skills 选择速查（中文）

> 三端 `/` 技能列表：**标题**多为英文 slug；**副标题 description** 已中文优先（`【中文名】…触发：…`）。  
> 完整目录：[`~/.claude/global-skills-index-zh.md`](file:///C:/Users/win/.claude/global-skills-index-zh.md)

## 一、每轮几乎总会用到

| 场景 | 选这个 skill | slug |
|------|----------------|------|
| 会话开始 / 不知道用哪个 | 全局会话核心 | `global-session-core` |
| 「帮我做…」「优化一下」说不清 | 需求澄清 | `requirement-clarifier` |
| 先整理任务再执行 | 任务 intake 桥接 | `task-intake-bridge` |
| 写代码时要简洁、少 diff | Karpathy 编码准则 | `karpathy-guidelines` |
| 项目有 AGENTS.md / memory | 项目编码 PDCA | `ai-coding-ok` |

## 二、按任务类型

| 你想做什么 | 优先 skill | slug |
|------------|-------------|------|
| 新功能 / 新模块 / 从零搭建 | 0→1 架构门禁 → 方案脑暴 → 编写实施计划 | `zero-to-one-gate` → `brainstorming` → `writing-plans` |
| 写 PRD / 需求文档 | PRD 撰写 | `pm-prd-writer` |
| 中文多步规划（task_plan 文件） | 中文文件化规划 | `planning-with-files-zh` |
| Bug / 报错 / 不工作 | 系统化排错（要修）或 结构化诊断（只定位） | `systematic-debugging` / `diagnose` |
| 声称完成 / 验收 / PASS | 全局交付验收 | `global-delivery-gate` |
| 原型 verify-all | 原型交付验收 | `ai-delivery-gate` |

## 三、PPT / 演示

| 你想做什么 | 优先 skill | slug |
|------------|-------------|------|
| 从文档/Markdown 生成**可编辑 .pptx** | PPT 原生生成 | `ppt-master` `[待确认: 需 vendor 安装 + Python 依赖]` |
| 不知道用哪个 AI PPT 工具 | AI PPT 工具选型 | `awesome-ai-ppt` |
| 直接编辑 .pptx 文件 | PPTX 读写编辑 | `pptx` |
| 网页/HTML 演讲页 | HTML 演示页 | `frontend-slides` |

## 四、UI / Figma

| 场景 | skill | slug |
|------|-------|------|
| Figma 链接转前端 | Figma 转代码 | `figma2code` |
| UI 丑 / 落地页要有设计感 | 前端审美 anti-slop | `design-taste-frontend` |

## 五、研究与论文

| 场景 | skill | slug |
|------|-------|------|
| 深度调研 / 多源引用 | 深度研究 | `deep-research` |
| 写学术论文 | 学术论文写作 | `academic-paper` |
| 模拟审稿 | 学术论文审稿 | `academic-paper-reviewer` |

## 六、维护 locale

```powershell
# 改 ~/.ai-workspace/skills-locale-zh.json 后：
powershell -File "$env:USERPROFILE\.ai-workspace\scripts\apply-skills-locale.ps1"
powershell -File "$env:USERPROFILE\.ai-workspace\scripts\scan-global-skills.ps1"
```

## 七、本轮新装（2026-07-02）

| slug | 来源 | 说明 |
|------|------|------|
| `anthropic-architect` | jamesrochabrun | Anthropic 架构选型 |
| `llm-router` | jamesrochabrun | 多模型路由 |
| `engineer-expertise-extractor` | jamesrochabrun | 从 GitHub 提取工程经验 |
| `design-brief-generator` | jamesrochabrun | 设计 brief |
| `content-brief-generator` | jamesrochabrun | 内容 brief |
| `query-expert` | jamesrochabrun | SQL 专家 |
| `technical-launch-planner` | jamesrochabrun | 技术发布规划 |
| `qa-test-planner` | jamesrochabrun | 测试计划 |
| `awesome-ai-ppt` | ningzimu | AI PPT 工具推荐 |

**跳过：** SuperProgramming（与现有 superpowers 链重复）、presenton（完整应用未部署）、claude-skill-registry（仅索引）、ppt-master / awesome-copilot（网络超时 `[待确认]` 可重跑安装脚本）。
