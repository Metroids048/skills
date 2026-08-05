# 敖钦储量及产量规划协同项目 Agent 规则

本项目当前处于产品页面开发前准备阶段。任何 Agent 在本项目工作时，必须先读本文件，再读 `项目开发文档/`。

## 1. 必读资料

开始任何任务前依次读取：

1. `项目开发文档/00-开发前准备总览.md`
2. `项目开发文档/07-产品需求文档_PRD_V0.2.md`
3. `项目开发文档/08-待确认事项清单.md`
4. 与本次任务相关的产品架构、页面线框、UI 规范、技术路线、功能清单
5. `project-memory.md`

原始资料在 `原始需求/` 和 `立项分析-需求调研手册.md`，需要核对事实时再读取。

## 2. 最高优先级：不确定必须问

任何不确定、冲突或大幅度改动，都必须先问用户，不能自行决定。

必须提问的情况包括：

- 页面结构、导航、核心流程要大改。
- 新增或删除页面、模块、功能入口。
- 与 `项目开发文档/` 中已有内容冲突。
- 需要选择技术栈、组件库、数据流、权限方案、接口方式。
- 需要假设业务口径、字段、公式、审批流程、数据权限。
- UI 方向可能影响用户使用习惯或整体产品气质。
- 任务范围会从文档扩展到代码，或从前端扩展到后端/数据/AI。

提问必须使用通俗易懂的非技术性语言，说明：

1. 现在卡在哪里。
2. 如果这样改，会影响用户看到什么或怎么用。
3. 有哪些选择。
4. 推荐哪个选择以及为什么。

不要只说技术名词，例如“是否修改 schema”“是否重构状态管理”。要翻译成业务影响，例如“这会改变数据保存方式，旧版本数据可能需要迁移”。

## 3. 开发前门禁

没有以下内容，不得开始页面或代码开发：

- 页面职责清楚。
- 主操作清楚。
- 数据来源清楚，无法确认的已标 `[待确认]`。
- 加载、空态、错误态、权限态已定义。
- AI 参与方式和失败处理已定义。
- 验收方式清楚。

## 4. 产品与 UI 原则

- 产品方向：企业级业务工作台 + 适度智能助手。
- 不做营销页、大屏优先、纯聊天壳。
- 一页一任务，不把采集、分析、审批、AI 问答全部堆在一屏。
- 储量和产量规划页面优先保证表格、图表、版本、口径、日志可读。
- AI 输出必须可追溯来源、参数、版本或引用。
- 不得把本地兜底、模拟结果伪装成敖钦/海能真实成功。

## 5. 技术路线边界

当前推荐路线：

- 前端：Vue3 + TypeScript + Vite + Vue Router + Pinia
- UI：Ant Design Vue + VXE Table + ECharts
- 后端：Java/Spring Boot 或甲方标准 Java 框架 `[待确认]`
- AI：敖钦/海能 API 集成层
- 数据：人大金仓 + TDengine + Redis + MongoDB
- 部署：海油云容器平台
- 安全：等保 2.0 二级

如需偏离以上路线，必须先问用户确认。

## 6. 文件与编码

- 所有文档使用 UTF-8。
- 修改中文 Markdown 优先用 `apply_patch`。
- 不要用不可靠脚本整文件重写中文文档。
- 不要删除原始资料。
- 不要把 `[待确认]` 擅自改成确定结论。

## 7. 浏览器与预览

- 不得自动打开浏览器窗口。
- 如需要预览，只输出地址和说明，由用户决定是否打开。
- Codex 中不能声称已完成真实浏览器视觉验收，除非确实执行了可见截图或浏览器检查。

## 8. 完成标准

交付前必须检查：

- 是否满足用户最新要求。
- 是否读过相关项目文档。
- 是否保留并更新所有待确认项。
- 是否说明未验证或无法验证的部分。
- 如果改动规则或记忆，必须说明改到了哪里。

## 9. 全局 Prompt 增强（三端）

模糊需求进入实现前，与已有 skills **综合选用**，每轮 **1–2 个** 即可（非固定全链）：

- 判型：`task-intake-bridge`
- Prompt 结构化（三选一，最多 1 个）：`prompt-architect` / `prompt-optimizer` / `maestro-prompt-leverage`
- 需求澄清（按需）：`requirement-clarifier`、`brainstorming`、`zero-to-one-gate` 等
- 路由参考：`prompt-intake-router`（按需 Read，非每轮强制）

Skills 在 `~/.cursor/skills` 等全局目录，本项目无需重复安装。

<!-- AGENT-CONFIG-PACK:PROJECT-BRIDGE START -->
## Agent Config Pack bridge (2026-07-22)

Shared cross-tool contract for this repo (Cursor / Codex / Claude Code):

- Global Working Agreement lives in user globals (`~/.codex/AGENTS.md`, `~/.claude/AGENTS.md`, Cursor `00-agent-working-agreement.mdc`).
- This file (`AGENTS.md`) is the **project SSOT**. Claude imports it via `@AGENTS.md` in `CLAUDE.md`.
- Tool patches: `.cursor/rules/00-core-workflow.mdc`, `.cursor/rules/10-verification.mdc`, `.claude/rules/testing.md`.
- Before claiming COMPLETE: use `verify-work` skill (global or project `.agents/.cursor/.claude/skills/verify-work`).
- Analysis / planning / review-only requests: do not edit files.
- Max 3 auto-repairs per failing check; same failure twice without progress → stop and escalate with evidence.
- Never report unexecuted checks as passed. Prefer project-documented verify commands.
- Durable lessons only in `docs/AGENT_LESSONS.md` (no secrets, no temp task chatter).
- Substantial changes: independent read-only review via `.claude/agents/code-reviewer` when available.
<!-- AGENT-CONFIG-PACK:PROJECT-BRIDGE END -->

<!-- AI-KNOWLEDGE-MANAGED-START -->

## 共享用户记忆与项目知识

开始涉及本项目的非简单任务前，读取：

- `项目知识库/项目总览.md`
- `项目知识库/当前状态.md`
- `项目知识库/目标与验收标准.md`
- `项目知识库/开放事项.md`

默认收口模式；任务结束生成会话记录并调用中央同步；不得直接重写中央主知识库。

<!-- AI-KNOWLEDGE-MANAGED-END -->
