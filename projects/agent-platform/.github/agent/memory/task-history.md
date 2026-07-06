# Task History — Agent Platform

> Newest entries at bottom of active section. See ADR entries in `decisions-log.md`.

## [TASK-023] 用户端 AI 工作台闭环升级

- **Date**: 2026-06-05
- **Type**: feature / frontend / architecture
- **Summary**: 按用户端下一版方案升级 `09-user-chat.html`：新增智能体中心搜索/收藏/最近、智能体详情、会话前配置、生成过程透明化、可恢复失败、我的资产、反馈单追踪、专家复核、消息中心和轻量权限申请；新增 `assets/user-chat-portal.js` 作为独立用户端状态 owner，使用 `proto_user_portal_state`，不写入运营/开发侧 `proto.js` 业务状态。
- **Files changed**: `prototype/09-user-chat.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/style.css`, `prototype/scripts/smoke-check.js`, `prototype/scripts/browser-check.js`, `docs/architecture/2026-06-05-user-portal-closed-loop.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED；补充 `node --check prototype/assets/user-chat-portal.js` 与 jsdom 初始化检查通过。
- **Notes**: 用户端只展示可理解的能力、状态、进度和服务入口，不暴露后台审核队列、任务派发表、开发者权限表。

## [TASK-025] P0-3 个人智能体提交审核 → 同步运营平台

- **Date**: 2026-06-17
- **Type**: feature / prototype
- **Summary**: 在用户端「我的空间」会话沉淀草稿卡片上增加「提交审核」按钮；点击后自动复制个人智能体数据到 `proto_ops_v11_agents` + `proto_ops_v11_agents_v4`，草稿状态升级为 `submitted`；UI 上显示「已同步到运营平台」状态标签 + 跳转 `05-agent-detail.html` 的入口；被删除时仅从用户端移除，不影响已同步到运营平台的记录。
- **Files changed**: `prototype/assets/user-personal-space.js`（新增 `submitPersonalAgentToOps`、重构 `renderSessionAgentDrafts`、绑定提交事件）
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED；`node --check` 语法通过
- **Notes**: P0-3 已完成；同步后智能体在运营侧为 `dev` 草稿状态，用户需在运营平台完成配置后发布。

- **Date**: 2026-06-05
- **Type**: fix / frontend / product
- **Summary**: 按用户反馈将 `09-user-chat.html` 从后台化 AI 工作台回正为截图式极简聊天页：左侧智能体列表、顶部模型选择、中心欢迎态、底部输入框、会话 Skills、能力来源浮层、回答引用/原文、文件卡和反馈弹窗；移除资产中心、专家复核、消息中心、权限申请等偏后台入口。
- **Files changed**: `prototype/09-user-chat.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/style.css`, `prototype/scripts/smoke-check.js`, `prototype/scripts/browser-check.js`, `docs/architecture/2026-06-05-user-chat-lite-portal.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node --check prototype/assets/user-chat-portal.js` PASS；用户端 jsdom 初始化/发送后 DOM 检查 PASS；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED。
- **Notes**: 用户明确指出知识库和 Skills 只是举例，实际取舍应基于截图产品形态；后续用户端功能必须服务聊天主体验，不能再按管理后台思路扩写。

## [TASK-026] 敖钦 AI 用户端 Web 门户 PRD v1.0

- **Date**: 2026-06-17
- **Type**: document / product
- **Summary**: 按用户要求「多图多表少文本，覆盖每个功能点和设计细节」，编写完整的敖钦 AI 用户端 Web 门户产品需求文档 v1.0。
- **Documents**: `docs/prd/敖钦AI用户端Web门户_PRD_v1.0.md`
- **Review**: `docs/prd/敖钦AI用户端Web门户_PRD_v1.0_评审报告.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-076 [2026-06-17] PRD 去技术化重构 + 全局规则修复
[project: c:\Users\win\Desktop\Agent Platform]

**Root Cause**: PRD 写作技能 (`create-prd`, `pm-prd-writer`) 和全局写作规则 (`global-document-writing-style.mdc`) 缺乏明确的 PRD 受众导向约束，导致 Agent 在生成 PRD 时混入代码实现细节和内部工程概念。

**Global fixes**:
- `~/.cursor/rules/global-document-writing-style.mdc`: 新增 PRD 受众约束（4 条：禁止实现细节、架构用业务语言、交互不写函数调用、布局引用设计稿）
- `~/.cursor/skills/create-prd/SKILL.md`: Step 4 增加禁止项、架构图/交互/布局三规则
- `skills/pm-prd-writer/SKILL.md` (project-local): 新增「PRD 受众边界」章节
- `skills/pm-prd-writer/references/prd-template.md`: 简化模板（去掉 DFD/STD 硬要求、去掉控件类型列、增加受众边界说明）
- ADR-017 写入 `decisions-log.md` + `project-memory.md`

**PRD rewrite** (`docs/prd/敖钦AI用户端Web门户_PRD_v1.0.md`):
- Chapter 2: 系统架构引用 `架构.png` 替代技术 Mermaid；功能树保留业务语言；移除用户-运营集成架构图（含 `UserAgentResolver`、`proto_ops_v11_agents` 等内部名）
- Chapter 4: 移除所有 ASCII 页面布局图；移除文件路径；移除函数名；移除 CSS 类名、sessionStorage Key 键名；移除控件类型；移除内部 ID；简化表格删除"来源"等代码列
- Chapter 5: 智能体数据模型改为中文列名；模型映射表移除内部 ID 列；权限模型移除英文 key 名
- Chapter 6: 移除所有 Mermaid 流程图/序列图，替换为分步骤文字描述
- Chapter 7: 移除所有 `proto_*` 内部 key 名和模块名；移除 JS 模块依赖图
- Chapter 8: 移除函数名引用
- Chapter 9: 删除 sessionStorage Key 表（28 项）和 JS 模块 API 表（13 模块）；简化页面路由表
- 全局英文术语中文化（`debounce` → 防抖；`sessionStorage` → 浏览器本地存储）

**Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

- **Date**: 2026-06-05
- **Type**: fix / frontend / UX
- **Summary**: 续 Codex 019e96ab 未完成项：移除用户可见 DeepSeek/Qwen 等品牌露出（模型改为标准/增强/专业/旗舰）；智能体/模型切换静默；重构 `.aioq-*` 布局（stage-scroll 滚动链、composer 回主区文档流、侧栏收起、模型下拉锚定）；「敖」字换海能 SVG 图标；输入区图标语义对齐（Skills 叠层、能力 info、发送纸飞机）；回答区按钮用瞬时态替代 toast。
- **Design Read**: 国央企 B2B 对话页，trust-first 企业蓝灰语言（design-taste-frontend VARIANCE 3–4 / MOTION 2–3）。
- **Files changed**: `prototype/09-user-chat.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/style.css`, `prototype/scripts/smoke-check.js`, `.github/agent/memory/task-history.md`
- **Verified**: `node --check prototype/assets/user-chat-portal.js` PASS；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 navigation-journey + ops-interaction-journey）。
- **Notes**: 未改动运营/Figma 误续模块；`LEGACY_MODEL_PATTERN` 仅用于 sessionStorage 迁移，不对用户展示。

## [TASK-001] Install AI global engineering guardrails

- **Date**: 2026-05-28
- **Type**: chore
- **Summary**: Installed AGENTS.md, PDCA memory, Cursor rules (project + global), vendor skills wrappers, sync-ai-guardrails.ps1, and ai-delivery-gate skill. Integrated prototype verify-all as mandatory gate after shared JS changes.
- **Files changed**: AGENTS.md, CLAUDE.md, .github/**, .cursor/rules/**, .cursor/skills/**, scripts/sync-ai-guardrails.ps1, skills/vendor/**
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED (2026-05-28); `scripts/sync-ai-guardrails.ps1` synced to ~/.cursor and ~/.codex
- **Notes**: See ADR-001, ADR-002 in decisions-log.md

## [TASK-002] Prototype navigation journey systemic fix

- **Date**: 2026-05-28
- **Type**: fix
- **Summary**: Fixed index↔05 re-entry regressions: removed `__protoSkillBindWired`, added `Proto.initAgentDetailPage` bootstrap, `resolveFirstConfigMode` / ADR-003 firstConfig rules, fixed `agentName`/`agentType` params bug, added `navigation-journey-check.js` + `journey-audit-matrix.json`, updated DELIVERY-CHECKLIST spot-check to navigation-focused 3 steps.
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 navigation-journey）
- **Notes**: See ADR-003 in decisions-log.md

## [TASK-003] Global guardrails hardening + prototype standalone deliverable

- **Date**: 2026-05-28
- **Type**: chore + docs
- **Summary**: Recorded navigation failure postmortem globally; aligned AGENTS/rules/skills/copilot with verify-all 5+1 steps and ADR-003; ran `sync-ai-guardrails.ps1 -Force`; added prototype README/start scripts/PAGES.md/package-check.js.
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED
- **Notes**: See postmortem-navigation-2026-05-28.md

## [TASK-004] Dev editor P2 layout + combined publish modal

- **Date**: 2026-05-29
- **Type**: fix + feature
- **Summary**: Reverted `06-dev-editor.html` to P2 layout; combined publish modal on dev editor and ops detail via `Proto.runAgentPublish`.
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-005] Third-party register: upstream API Key + simplified credential step

- **Date**: 2026-05-29
- **Type**: feature
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-006] Restore create/third-party as list overlay modals

- **Date**: 2026-05-29
- **Type**: fix
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-007] Skills dedupe, RTK/ui-ux inclusion, three-tool global hooks

- **Date**: 2026-06-01
- **Type**: chore + infra
- **Verified**: sync + RTK smoke

## [TASK-008] Sync Skills PRD with latest prototype

- **Date**: 2026-06-01
- **Type**: docs
- **Notes**: No prototype code changed

## [TASK-009] Global AI workspace (零迁移、跨项目沉淀)

- **Date**: 2026-06-01
- **Type**: infra
- **Notes**: See ADR-004

## [TASK-010] 运营列表 BI 看板 + 行内操作

- **Date**: 2026-06-01
- **Type**: feature
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-011] 运营看板对齐业务 + 移除无关模块

- **Date**: 2026-06-01
- **Type**: fix / feature
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-012] 看板融合 + 审核路径衔接

- **Date**: 2026-06-01
- **Type**: feature
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-013] 看板 UI 回归 P1 双面板

- **Date**: 2026-06-01
- **Type**: fix / ui
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-014] 运行数据 Skills 命中率 + 移除新建 Skill 输出要求

- **Date**: 2026-06-02
- **Type**: feature / ui
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## [TASK-015] Figma 运营平台 Page 完整转换

- **Date**: 2026-06-04
- **Type**: feature
- **Summary**: 按 ADR-005 将 Figma「运营平台」Page 38 帧转为 12 个新 HTML 页 + 6 个 `ops-*.js` 模块；补 `design/interaction-spec.json`、`extract-frame.js`、`figma.config.json` 运营映射；实现用户反馈、专家工作台、权限管理、消息 drawer、任务分派 modal、专家任务审核及侧栏导航串联。
- **Files changed**: `prototype/11-*.html`, `prototype/12-*.html`, `prototype/13-*.html`, `prototype/08-audit-expert.html`, `prototype/assets/ops-*.js`, `prototype/assets/style.css`, `prototype/index.html`, `prototype/08-audit-queue.html`, `design/interaction-spec.json`, `design/scripts/extract-frame.js`, `design/figma.config.json`, `docs/architecture/2026-06-04-figma-ops-platform-conversion.md`, `.github/agent/memory/decisions-log.md`, `prototype/scripts/*`
- **Verified**: `node design/scripts/extract-frame.js "243:955"` OK; `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED
- **Notes**: See ADR-005; Figma PAT 不入库

## [TASK-020] 用户反馈详情页 Figma 1:1（243:6859）

- **Date**: 2026-06-04
- **Type**: ui
- **Summary**: 按 Figma `243:6859` 重写 `11-user-feedback-detail.html`：Hero 标题/徽章/处理反馈、四格 Bento 属性、反馈原文对话区+诊断条、相关附件卡片、处理记录时间线；`fb_001` 使用 Figma 样例文案；扩展 `ops-user-feedback.js` 的 `FIGMA_DETAIL`/`buildDetailView`/`renderDetailDom`；新增 `.ops-fb-detail-*` 样式；更新 smoke/journey DOM 契约。
- **Files changed**: `prototype/11-user-feedback-detail.html`, `prototype/assets/ops-user-feedback.js`, `prototype/assets/style.css`, `prototype/scripts/smoke-check.js`, `prototype/scripts/ops-interaction-journey-check.js`, `design/ops-audit-matrix.json`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 ops-interaction-journey）
- **Notes**: 徽章/时间线部分子节点在 figma-extract 中序列化丢失，用 Figma 可提取文案+结构推断；分派按钮保留在次级操作区（设计稿 Hero 仅「处理反馈」）

## [TASK-016] 运营平台全局查缺补漏与优化

- **Date**: 2026-06-04
- **Type**: fix + feature + ui
- **Summary**: 统一 12 个运营页壳层（`OpsShell.renderLayout`）；补筛选/搜索、右键菜单、处理反馈角色变体、专家进行中子 Tab、社区筛选、消息 drawer 三角色深链、权限 Tab+Peak Indicator、审核页详情与操作菜单；扩充 DEMO 数据；新增 `design/ops-audit-matrix.json`、`ops-context-menu.js`、`ops-audit-expert.js`、`ops-interaction-journey-check.js`（verify-all 第 6 步）。
- **Files changed**: `prototype/assets/ops-*.js`, `prototype/11~13*.html`, `prototype/08-audit-expert.html`, `prototype/index.html`, `prototype/assets/style.css`, `design/ops-audit-matrix.json`, `design/interaction-spec.json`, `prototype/scripts/verify-all.js`, `prototype/scripts/smoke-check.js`, `prototype/scripts/ops-interaction-journey-check.js`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 ops-interaction-journey）；interaction-spec 14 flows verified=true
- **Notes**: 视觉仍为结构级 fidelity；PM-01~03 / TD-01~02 journey 待补断言

## [TASK-020] GitHub 高星澄清精华并入三端

- **Date**: 2026-06-05
- **Type**: docs / infra
- **Summary**: 本地化 superpowers、addyosmani interview-me/idea-refine、clarify-first 精华 → interview-protocol、clarification-guardrails、skill-chain-map；新增 skills/idea-refine；钩子注入全附录路径。
- **Verified**: UserPromptSubmit「帮我做一个运营看板」含 SkillChain + interview-protocol + guardrails 提示

## [TASK-019] Vibe coding 需求转换中间层（Mini-Spec）

- **Date**: 2026-06-05
- **Type**: feature / docs / infra
- **Summary**: 强化 requirement-clarifier：新增 vibe-coding-bridge、mini-spec-template、question-bank-zh；§4.5 Mini-Spec 为澄清核心交付物；intent `vibe_coding`；钩子 B 类自动注入 bridge 路径。
- **Verified**: UserPromptSubmit「帮我把 index 看板优化」→ HARD GATE + Vibe coding bridge 路径 + vibe_coding intent

## [TASK-018] 条件式 ai-coding-ok + 意图识别技能路由

- **Date**: 2026-06-05
- **Type**: infra
- **Summary**: `conditionalAlwaysOnSkills` 在有 AGENTS.md / `.github/agent/memory/` 时自动加入 `ai-coding-ok`；新增 `intent-profiles.json` + `Detect-UserIntents`（信号/正则/描述触发短语/部分词重叠），替代纯固定关键词匹配；SessionStart 增加 Headroom/compact 提示。
- **Verified**: SessionStart 含 ai-coding-ok；口语化/排错类 prompt 命中 intent 并推荐对应 skills

## [TASK-022] taste-skill 三端全局安装

- **Date**: 2026-06-05
- **Type**: infra
- **Summary**: 从 [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) 安装 13 个 skills 至 `~/.cursor/skills`、`~/.claude/skills`、`~/.codex/skills`；vendor 源 `skills/vendor/taste-skill/`；新增 `install-taste-skills.ps1`；`skills-sync.config.json` 增加 hook 关键词与中文 descriptionOverrides。
- **Verified**: 13 skills x 3 targets；global-skills-index 含 `design-taste-frontend`、`gpt-taste`
- **Notes**: 默认 skill `design-taste-frontend`（v2 experimental）；升级 `-RefreshFromGitHub -Force`

## [TASK-021] 需求澄清完整链路 + PreToolUse 硬拦

- **Date**: 2026-06-05
- **Type**: infra
- **Summary**: 按用户选择「完整链路」而非批量装高星 skills：新增 `clarification-gate-core.ps1`、`clarification-hard-gate.ps1`、`clarification-gate-keywords.json`；`UserPromptSubmit` 更新 gate-state + intent draft；三端注册 PreToolUse/preToolUse；`test-clarification-gate.ps1` 冒烟 ALL PASS。见 ADR-006。
- **Files changed**: `scripts/hooks/*`, `skills-sync.config.json`, `~/.cursor/hooks.json`, `~/.claude/settings.json`, `~/.codex/hooks.json`
- **Verified**: `powershell scripts/hooks/test-clarification-gate.ps1` → ALL PASS（pending/block/allow/clear/deny JSON）
- **Notes**: 重启三端会话后生效；确认词见 `clarification-gate-keywords.json`

## [TASK-017] requirement-clarifier 三端钩子修复

- **Date**: 2026-06-04
- **Type**: infra / fix
- **Summary**: 根因：`~/.ai-workspace/scripts/skills-sync.config.json` 的 `alwaysOnSkills` 仅含 `global-session-core`，三端钩子优先读此文件导致 `requirement-clarifier` 未注入；`UserPromptSubmit` 也不重复注入 always-on。修复：统一 config、增强 `scan-global-skills.ps1`、恢复完整 SKILL.md、Codex `persistent_instructions`。
- **Verified**: SessionStart/UserPromptSubmit 钩子输出含 `requirement-clarifier` ALWAYS ON

## [TASK-025] 处理反馈弹窗 6 变体 Figma 1:1（7114–7299）

- **Date**: 2026-06-05
- **Type**: ui / feature
- **Summary**: 续 Codex Figma 运营平台 1:1 任务：按 6 个处理反馈弹窗帧实现角色/状态动态变体——个人 519px、团队/运营 647px、成员/团队选择 647 compact、专家任务创建 928px；文案与选项对齐 Figma textSamples（请说明理由、成员/团队 picker、创建专家任务表单）。
- **Files changed**: `prototype/11-user-feedback-detail.html`, `prototype/assets/ops-user-feedback.js`, `prototype/assets/style.css`, `prototype/scripts/smoke-check.js`, `prototype/scripts/ops-interaction-journey-check.js`, `design/ops-audit-matrix.json`, `design/figma-extract/frames/243-7114.json` 等 6 帧
- **Verified**: `node --check prototype/assets/ops-user-feedback.js` PASS；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 ops-interaction-journey）
- **Notes**: Codex thread `019e96ab` 无法直接读取，上下文来自 Cursor transcript `64c9b5a6`；下一批建议专家工作台 `243:272` 或分派弹窗 `243:1770/1892`

## [TASK-026] Skills 质量全量审计与调用修复

- **Date**: 2026-06-05
- **Type**: chore / architecture / tooling
- **Summary**: 按计划实现 306 skills 质量审计流水线、DAILY/LIBRARY 分级、intent 路由补洞（figma_design/skill_engineering/research_general）、CSO description 批量改写、figma2code UTF-8 修复、Tier1 触发 TDD（100% 命中）、ADR-007。
- **Files changed**: `scripts/hooks/audit-skills-quality.ps1`, `merge-audit-to-stocktake.ps1`, `agent-sort-agent-platform.ps1`, `apply-tier1-cso-descriptions.ps1`, `sync-hooks-config.ps1`, `trigger-tdd-tier1.ps1`, `scripts/hooks/intent-profiles.json`, `scripts/hooks/skills-sync.config.json`, `~/.cursor/skills/figma2code/SKILL.md`, `.cursor/skills/figma-workflow/SKILL.md`, `docs/skills-audit/*`, `.github/agent/memory/decisions-log.md` (ADR-007), 5× BROKEN skill frontmatter fixes
- **Verified**: `audit-skills-quality.ps1` → 306 skills JSON; `trigger-tdd-tier1.ps1` → 100% (16/16); `scan-global-skills.ps1` Figma prompt → figma-workflow + figma2code in Top 8; stocktake `results.json` merged
- **Notes**: 230+ skills 仍为 ROUTING_GAP（LIBRARY 预期行为）；Cursor 原生 `available_skills` 与 hook Top 8 为双轨；见 ADR-007

## [TASK-027] 三端 AI 配置梳理文档导出

- **Date**: 2026-06-08
- **Type**: docs
- **Summary**: 将 2026-05-28~06-08 三端配置/Skills/记忆/避坑梳理导出为 `~/.ai-workspace/docs/tri-end-ai-config-inventory-zh.md`；`project-memory.md` 增加总览链接。
- **Files changed**: `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`（本条目）；全局侧见 TASK-G013
- **Verified**: 对照 global-skills-index（306）、always-on rules（16）、hooks 路径一致。

## [TASK-028] AI 平台需求梳理落地（全景/海能/RBAC/看板/闭环）

- **Date**: 2026-06-08
- **Type**: docs / architecture / feature
- **Summary**: 落实计划：撰写 L0–L4 运营全景、海能集成规范 v0.1、RBAC 与人力规划；ADR-008 固化海能基座分层与五环节 API；新增 `platform-api.js` mock、`ops-feedback-loop.js` 反馈→专家→回流工单、`ops-dashboards.js` + 4 个 14-* 看板页；串联分派/完成任务与消息待办。
- **Files changed**: `docs/architecture/2026-06-08-*.md`×3, `decisions-log.md` (ADR-008), `prototype/assets/platform-api.js`, `ops-feedback-loop.js`, `ops-dashboards.js`, `14-*.html`×4, `01-architecture.html`, `index.html`, `06-dev-editor.html`, `09-user-chat.html`, `ops-dispatch.js`, `ops-expert-workbench.js`, `ops-modal-create.js`, `ops-platform-shell.js`, `ops-message-center.js`, `proto.js`, `user-chat-portal.js`, `package-check.js`, `smoke-check.js`, `design/ops-audit-matrix.json`, `project-memory.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（34 页 + 7 步含 ops-interaction-journey）
- **Notes**: 海能 API 仍为 mock，工作坊对齐见 `haineng-integration-spec.md` §10。

## [TASK-029] docs 中文汇总与查缺补漏（纯文档）

- **Date**: 2026-06-08
- **Type**: docs
- **Summary**: 按用户纠偏「只要文档、不写前端」：完成 `docs/需求梳理/05-页面元素清单与查缺补漏.md`（四条需求×讲稿×原型×Figma 四方对照）；补 `平台项目资料/平台项目情况汇总.md` 一页总览；新增 `演示页面路由表.md`；同步 `prototype/docs/PAGES.md` 为 34 页清单。
- **Files changed**: `docs/需求梳理/05-*.md`, `平台项目资料/平台项目情况汇总.md`, `平台项目资料/演示页面路由表.md`, `prototype/docs/PAGES.md`, `docs/文档索引.md`, `.github/agent/memory/task-history.md`
- **Verified**: 文档交叉引用路径检查；未改 `prototype/assets/*.js`（无 verify-all 要求）。
- **Notes**: 下一迭代建议补 `06/07/08` 模型服务/知识中心/系统管理规划稿；海能工作坊对齐 `03` §待确认。

## [TASK-030] Codex local core MCP/plugin install
- **Date**: 2026-06-08
- **Type**: infra / MCP / plugins
- **Summary**: Installed the approved lightweight Codex user-level MCP/plugin set in `C:\Users\win\.codex\config.toml`: GitHub, Figma, Superpowers, OpenAI Developers, documents/spreadsheets/presentations, and core MCP servers for GitHub, Context7, OpenAI Docs, memory, sequential thinking, Playwright, Exa, FAL, workspace-limited filesystem, and Chrome DevTools. No secrets were written; credential-backed tools inherit future Windows environment variables.
- **Files changed**: `C:\Users\win\.codex\config.toml`, `C:\Users\win\.ai-workspace\memory\global-task-history.md`, `.github/agent/memory/task-history.md`
- **Verified**: Timestamped config backup created; Python `tomllib` parsed config successfully; Node/npm/npx available; `npm view` resolved all npm-backed MCP packages. No prototype code changed, so `prototype/scripts/verify-all.js` was not required.
- **Notes**: OpenAI Codex manual helper returned HTTP 403 on `developers.openai.com/codex/codex-manual.md`; OpenAI Docs MCP URL came from the local `openai-docs` system skill and OpenAI Developers plugin metadata.

## [TASK-031] Codex Desktop plugin marketplace fix
- **Date**: 2026-06-08
- **Type**: infra / Codex plugins / MCP
- **Summary**: Fixed the missing Codex Desktop plugin UI layer after MCP config install. Registered local marketplaces in `C:\Users\win\.codex\config.toml` (`openai-bundled`, `openai-curated`, `openai-primary-runtime`, `codex-local-core`) and replaced `C:\Users\win\.codex\.agents\plugins\marketplace.json` with a core local marketplace containing GitHub, Figma, Fal, Canva, Superpowers, OpenAI Developers, Browser, Chrome, Documents, Spreadsheets, and Presentations.
- **Files changed**: `C:\Users\win\.codex\config.toml`, `C:\Users\win\.codex\.agents\plugins\marketplace.json`, `C:\Users\win\.ai-workspace\memory\global-task-history.md`, `.github/agent/memory/task-history.md`
- **Verified**: Python parsed `config.toml`; marketplace JSON parsed; `codex-local-core` contains 11 plugins; every marketplace plugin source has `.codex-plugin/plugin.json`; no prototype code changed.
- **Notes**: This addresses UI plugin discovery/installation, not only MCP startup. Codex Desktop may still require a full app restart to reload marketplace indexes.

## [TASK-032] Codex++ global plugin/MCP repair hardening
- **Date**: 2026-06-08
- **Type**: infra / Codex plugins / MCP
- **Summary**: Hardened the Codex Desktop plugin repair path after the UI only showed bundled plugins. Fixed the installer to write BOM-free TOML/JSON, regenerated `C:\Users\win\.codex\config.toml` with 178 enabled plugin blocks and 10 MCP servers, registered the full OpenAI curated local marketplace, and preinstalled all 172 curated plugins into the local Codex plugin cache. Added a global recovery script at `C:\Users\win\.ai-workspace\scripts\repair-codex-plus-plugins-mcp.ps1` so plugin/MCP config can be restored after Desktop/provider rewrites.
- **Files changed**: `scripts/install-codex-core-plugins.ps1`, `C:\Users\win\.codex\config.toml`, `C:\Users\win\.codex\.agents\plugins\marketplace.json`, `C:\Users\win\.ai-workspace\scripts\repair-codex-plus-plugins-mcp.ps1`
- **Verified**: Project and global repair scripts both passed; Python `tomllib` parsed config with `config_bom False`; config contains 178 plugin blocks, including 172 enabled `openai-curated` plugins; marketplace JSON contains 172 plugins; local cache preinstall has 172/172 plugin manifests with 0 missing cache/config entries; 10 MCP servers remain configured.
- **Notes**: Codex Desktop may require a full app restart to reload plugin marketplace UI. Credential-backed plugins still require OAuth or environment variables.

## [TASK-033] AI 应用开发平台总结性需求报告与写作风格全局约束
- **Date**: 2026-06-08
- **Type**: docs / report / global rules
- **Summary**: 基于 `docs/需求梳理/01-05`、`平台项目资料/` 演示稿、智能体运营 PRD、原型索引与 ADR-008，新增总结性需求报告 `docs/需求梳理/06-AI应用开发平台总结性需求报告.md`，并生成可渲染 SVG 配图 `docs/需求梳理/assets/ai-platform-ops-panorama.svg`；同步更新 `docs/文档索引.md` 与 `平台项目资料/平台项目情况汇总.md` 入口。
- **Global config**: 新增 Cursor 全局 rule `~/.cursor/rules/global-document-writing-style.mdc`；更新 `~/.claude/AGENTS.md` 与 `~/.codex/AGENTS.md`，要求报告/Markdown 简体中文、少 AI 味、少空行、无乱码、基于事实并标注待确认/mock/原型。
- **Verified**: 本轮执行 Markdown/SVG/链接检查；未改 `prototype/assets/*.js`，无需 `verify-all`。

## [TASK-034] AI 应用开发平台总结报告返工（海能资料全覆盖 + 图表重做）
- **Date**: 2026-06-08
- **Type**: docs / report / diagram
- **Summary**: 按用户反馈重写 `docs/需求梳理/06-AI应用开发平台总结性需求报告.md`，系统纳入 `平台项目资料/` 中海能智算、海能智能体平台、海能通用能力/新门户/7 个通用应用、推理部署、模型导入训练、微调训练、算力调度、智能体开发平台、AI 中台功能清单、星火开发指南等材料；报告改为单文件完整汇总，并内嵌 4 段 Mermaid 图代码供飞书渲染和手工修改。
- **Diagram**: 重做 `docs/需求梳理/assets/ai-platform-ops-panorama.svg`，删除内部口语表达，改为正式对外口径，并调整布局避免文字遮挡。
- **Verified**: Markdown/SVG 无 `U+FFFD`、无三连空行；报告 SVG 链接存在；Mermaid 代码块数量 4；未改原型 JS。

## [TASK-035] AI 应用开发平台总结报告二次返工（成品报告口径）
- **Date**: 2026-06-08
- **Type**: docs / report / diagram
- **Summary**: 按用户二次纠偏，将 `docs/需求梳理/06-AI应用开发平台总结性需求报告.md` 改为可直接给领导、业务方、海能协同方和后续产品研发团队阅读的正式报告；正文围绕运营全景、角色人力与能力、平台关系与数据权限串联、海能平台关系与算力使用四条原始需求组织，不再写内部执行记录。
- **Files changed**: `docs/需求梳理/06-AI应用开发平台总结性需求报告.md`, `docs/需求梳理/assets/ai-platform-ops-panorama.svg`, `docs/需求梳理/assets/*.mmd`, `docs/需求梳理/图表源码附录.md`, `docs/文档索引.md`, `平台项目资料/平台项目情况汇总.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`
- **Verified**: 主报告无 `U+FFFD`、无三连空行、无正文 Mermaid 代码块、无禁用口径 `本项目/海能侧/mock/原型/当前材料/我们消费`；SVG XML 解析通过；4 个 `.mmd` 图表源码存在且无乱码；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED。

## [TASK-036] Codex++ 重启后插件被覆盖 — relayCommonConfig 持久化
- **Date**: 2026-06-08
- **Type**: infra / Codex plugins
- **Summary**: 用户反馈 repair 后重启插件又消失、Codex++ 管理工具「插件: 0」。根因：Codex++ provider 同步用空的 `relayCommonConfigContents` 重写 `~/.codex/config.toml`，抹掉 `[marketplaces.*]` / `[plugins.*]`。扩展 `repair-codex-plus-plugins-mcp.ps1`：写入 178 插件 overlay 到 `~/.codex-session-delete/settings.json` 的 `relayCommonConfigContents` + `contextSelection.plugins`；repair 前停止 codex-plus-plus 避免内存覆盖。
- **Files changed**: `C:\Users\win\.ai-workspace\scripts\repair-codex-plus-plugins-mcp.ps1`
- **Verified**: `repair-c.ps1` → `config_ok 178 plugins`; `codexplus_overlay_ok 9952 chars 178 registry_plugins`; `sample_plugin {'id': 'browser@openai-bundled', 'enabled': True}`.
- **Notes**: 用户需在 Codex++ 管理工具点「重启 Codex++」后确认插件 Tab 数量；OAuth 类插件仍需 Desktop 内 Connect。

## [TASK-037] Codex 插件/MCP 重启持久化 — merge + watchdog
- **Date**: 2026-06-09
- **Type**: infra / Codex plugins
- **Summary**: 根因：Codex++ `apply_pure_api_injection` 重写 config.toml 但不合并 `relayCommonConfigContents`。新增 `merge-codex-config.py/ps1` 合并 overlay；repair 写入 `codex-plus-overlay.toml` + `codex-plus-mcp-overlay.toml` + `relayContextConfigContents`；`codex-config-watchdog.js` 登录/轮询/文件变更后自动 merge；更新 `CodexLaunchGuard.vbs`。
- **Files changed**: `~/.ai-workspace/scripts/merge-codex-config.{py,ps1}`, `repair-codex-plus-plugins-mcp.ps1`, `~/AppData/Local/CodexFix/codex-config-watchdog.js`, `~/Startup/CodexLaunchGuard.vbs`, `~/.codex/codex-plus-overlay.toml`, `~/.codex/codex-plus-mcp-overlay.toml`
- **Verified**: repair → `config_ok 178`; simulate pure_api (0 plugins) → merge → 178; watchdog wipe → 8s → `watchdog_restore 178`; figma/github/slack merge_check=yes.
- **Notes**: 开机后 watchdog 自动运行；若仍清零查 `CodexFix/config-watchdog.log`。OAuth 插件需 Desktop Connect 一次。
## [TASK-037] AI 应用开发平台总结报告复查记录
- **Date**: 2026-06-09
- **Type**: docs / review
- **Summary**: 按计划新增 `docs/需求梳理/07-AI应用开发平台总结报告复查与查缺补漏.md`，不改 `06` 主报告和粘贴版。复查记录补齐四条原始需求覆盖判断、资料来源矩阵、线上系统菜单证据、数据流与权限证据表、海能待确认项、粘贴版用途差异和 P0/P1/P2 优先级建议。
- **Files changed**: `docs/需求梳理/07-AI应用开发平台总结报告复查与查缺补漏.md`, `.github/agent/memory/task-history.md`, `C:\Users\win\.ai-workspace\memory\global-task-history.md`
- **Verified**: 新增 Markdown 无 `U+FFFD`、无三连空行；文内本地相对链接均存在；未修改 `prototype/assets/*.js`，无需 `node prototype/scripts/verify-all.js`。
- **Notes**: 海能 API、SSO、计量、模型档位映射仍按 `待确认` 处理；线上系统仅做只读巡检证据引用。

## [TASK-038] AI 应用开发平台总结报告修订完善版
- **Date**: 2026-06-09
- **Type**: docs / report
- **Summary**: 按用户要求基于 `docs/需求梳理/assets/06-AI应用开发平台总结性需求报告-粘贴版.md` 新建完整修订稿 `docs/需求梳理/08-AI应用开发平台总结性需求报告-修订完善版.md`，整合 `07` 复查结论，补齐原始四条需求对照、线上系统菜单映射、资料来源矩阵、核心能力扩展、数据权限证据、海能待确认清单、mock/原型边界和 P0/P1/P2 优先级建议；未覆盖原 `06` 主报告和粘贴版。
- **Files changed**: `docs/需求梳理/08-AI应用开发平台总结性需求报告-修订完善版.md`, `.github/agent/memory/task-history.md`
- **Verified**: 新增 Markdown 无 `U+FFFD`、无三连空行、无相对 Markdown 链接；关键标记 `已覆盖`、`需优化`、`待确认`、`mock`、`原型` 均存在；未修改 `prototype/assets/*.js`，无需 `node prototype/scripts/verify-all.js`。
- **Notes**: 海能 API、SSO、计量、模型档位映射、资源队列策略仍需海能工作坊确认。

## [TASK-039] AI 应用开发平台 08 报告二次优化（底座口径与数据图）
- **Date**: 2026-06-09
- **Type**: docs / report / diagram
- **Summary**: 按用户手动修改后的 `08` 为准继续返修：将用户入口统一改为独立用户端，海能平台改为底层支撑能力；重写运营全景与双向协作模式；合并未来运营组织、人力规划和阶段规划；细化主数据、配置数据、运行数据、反馈数据、计量数据、审计数据的流向、接口、协议、字段和治理规范；新增 5 段可在 Markdown/飞书中渲染的 Mermaid 草图，覆盖全景架构、数据流转、权限控制、功能协同和运营闭环。
- **Files changed**: `docs/需求梳理/08-AI应用开发平台总结性需求报告-修订完善版.md`, `.github/agent/memory/task-history.md`
- **Verified**: Markdown 无 `U+FFFD`、无三连空行；Mermaid 代码块 5 个且围栏闭合；关键标记 `待确认`、`mock`、`原型` 均存在；未修改 `prototype/assets/*.js`，无需 `node prototype/scripts/verify-all.js`。
- **Notes**: 海能 API、SSO、Meter字段、模型档位映射、资源队列策略仍按 `待确认` 处理；Mermaid 图为可编辑草图，后续可再导出 SVG/PNG 美化。

## [TASK-040] AI 应用开发平台 08 报告图片化返修
- **Date**: 2026-06-09
- **Type**: docs / report / diagram
- **Summary**: 按用户反馈将 `08` 中的 Mermaid 草图替换为正式 SVG 图片引用：直接重做 `assets/ai-platform-ops-panorama.svg`，将海能平台调整为底部能力底座，用户入口改为独立用户端；新增 `assets/ai-platform-data-flow.svg` 和 `assets/ai-platform-governance-summary.svg`，分别用于说明数据流转与接口规范、功能/权限/运营汇总。`08` 正文改为引用 3 张 SVG 图片，删除 Mermaid 代码块。
- **Files changed**: `docs/需求梳理/08-AI应用开发平台总结性需求报告-修订完善版.md`, `docs/需求梳理/assets/ai-platform-ops-panorama.svg`, `docs/需求梳理/assets/ai-platform-data-flow.svg`, `docs/需求梳理/assets/ai-platform-governance-summary.svg`, `.github/agent/memory/task-history.md`
- **Verified**: 3 张 SVG 均 XML 解析通过；`08` 无 `U+FFFD`、无三连空行、无 Mermaid 代码块残留，包含 3 个图片引用；未修改 `prototype/assets/*.js`，无需 `node prototype/scripts/verify-all.js`。
- **Notes**: 图片为可直接在 Markdown 中引用的 SVG 版本，后续可在确认布局和文案后继续导出 PNG 或进一步视觉精修。

## [TASK-041] AI 应用开发平台三张报告图打回重做
- **Date**: 2026-06-09
- **Type**: docs / report / diagram / visual QA
- **Summary**: 按用户反馈重新修正三张 SVG：全景图恢复接近第一版的用户端、运营平台、平台能力群串联结构，仅保留海能平台作为底部能力底座；数据流转图改为清晰泳道流程，不再把技术关联键、接口协议和待确认字段塞进图片；功能/权限/运营图改为“运营闭环与权限治理图”，避免与全景图重复。同步保留 `08` 中的 3 个图片引用。
- **Files changed**: `docs/需求梳理/assets/ai-platform-ops-panorama.svg`, `docs/需求梳理/assets/ai-platform-data-flow.svg`, `docs/需求梳理/assets/ai-platform-governance-summary.svg`, `.github/agent/memory/task-history.md`
- **Verified**: 三张 SVG 均 XML 解析通过；用 Chrome 打开并截图肉眼检查全景图、数据图、运营闭环与权限治理图，确认可渲染、主结构可读、未见明显文字重叠；`08` 无乱码、无三连空行、仍为 3 个图片引用且无 Mermaid 残留；清理临时 `_check_*.png` 截图。
- **Notes**: 全景图保留海能底座分层：上层AI能力支撑、下层基础资源支撑、治理支撑；数据图的具体字段和接口仍在正文表格维护。
## [TASK-042] 智能体运营 v1.1 原型与发布/上架拆分
- **Date**: 2026-06-09
- **Type**: prototype / frontend / global rules
- **Summary**: 新增 `prototype/智能体运营v1.1/` 独立新版界面，包含智能体管理卡片页、运营仪表盘、审核工作台和详情页；将流程拆成“发布候选版本 → 平台审核 → 待上架 → 运营上架 → 用户可见”，并保留到原开发页和用户对话页的跳转。新增 `v11-ops-check.js` 验证筛选、搜索、发布、审核通过、上架和驳回原因。同步补充全局规则：需求/流程/页面关系不清时及时提问，报告/PRD 多图表但文本精炼。
- **Files changed**: `prototype/智能体运营v1.1/*`, `prototype/scripts/v11-ops-check.js`, `.cursor/rules/global-document-writing-style.mdc`, `.cursor/rules/requirement-clarifier.mdc`, `scripts/sync-ai-guardrails.ps1`, `scripts/global-workspace/templates/AGENTS.global.md`, `~/.claude/AGENTS.md`, `~/.codex/AGENTS.md`, `.github/agent/memory/*`
- **Verified**: `node --check prototype/智能体运营v1.1/app.js`; `node prototype/scripts/v11-ops-check.js` → PASS; `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED; `powershell scripts/sync-ai-guardrails.ps1 -Force` completed.
- **Notes**: Chrome 插件仍返回 `Browser is not available: extension`，Playwright 本地依赖不存在；本轮视觉验收以 jsdom/专项交互检查替代，未声称完成 Chrome 截图验收。

## [TASK-043] Ops v1.1 导航 404 与卡片菜单纠偏 + 三端记忆

- **Date**: 2026-06-09
- **Type**: fix / prototype / postmortem / memory
- **Summary**: 修复 Windows `file://` 下侧栏子链双重目录导致仪表盘/工作台 404；卡片菜单收敛为 v1.0 词表（发布/停用/上架/下架/删除），移除查看/去审核/撤回；审核中卡片隐藏 `⋯`；写入 ADR-010、postmortem、`AGENTS.md` § Ops v1.1 UX Contract、三端 user-memory。
- **Files changed**: `prototype/assets/ops-platform-shell.js`, `prototype/智能体运营v1.1/app.js`, `prototype/scripts/v11-ops-check.js`, `AGENTS.md`, `.github/agent/memory/decisions-log.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/postmortem-ops-v11-2026-06-09.md`, `~/.ai-workspace/memory/user-memory.md`, `~/.ai-workspace/memory/global-task-history.md`
- **Verified**: `node prototype/scripts/v11-ops-check.js` → V11 OPS CHECK PASSED（相对路径、菜单词表、仪表盘/工作台可渲染）
- **Notes**: 用户反馈核心：迭代须保留上一版壳与交互；产品整体思考优先于堆功能。

## [TASK-044] 智能体权限入口与审核链路重构

- **Date**: 2026-06-10
- **Type**: prototype / frontend / architecture
- **Summary**: 新增统一组织/用户选择器 `prototype/assets/org-access-picker.js`，创建弹窗、旧详情页发布弹窗和 v1.1 卡片/详情权限入口复用同一选择器；权限字段统一为 `shareMode` + `permissionTargets`。v1.1 内部智能体卡片菜单新增“权限”，第三方智能体不显示；审核链路收敛为“发布候选版本 → 平台审核 → 已上架”，移除“上级审批”和“审核通过待上架”。同步旧创建/发布控件“单位共享”改“部门共享”，并写入 ADR-011。
- **Files changed**: `prototype/assets/org-access-picker.js`, `prototype/assets/style.css`, `prototype/assets/proto.js`, `prototype/assets/platform-api.js`, `prototype/assets/ops-modal-create.js`, `prototype/index.html`, `prototype/04-create-modal.html`, `prototype/05-agent-detail.html`, `prototype/06-dev-editor.html`, `prototype/08-audit-review.html`, `prototype/08-audit-status.html`, `prototype/智能体运营v1.1/*`, `prototype/scripts/v11-ops-check.js`, `prototype/scripts/smoke-check.js`, `.github/agent/memory/decisions-log.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node --check prototype/assets/org-access-picker.js`; `node --check prototype/assets/ops-modal-create.js`; `node --check prototype/assets/proto.js`; `node --check prototype/assets/platform-api.js`; `node --check prototype/智能体运营v1.1/app.js`; `node prototype/scripts/v11-ops-check.js` → V11 OPS CHECK PASSED；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED。
- **Notes**: 仓库无 `package.json`，无 `npm run lint/typecheck/test/build` 可执行；本轮验证以原型专项脚本和 verify-all 为准。

## [TASK-045] Web 用户端与后台打通（Codex 019eaf7c）

- **Date**: 2026-06-10
- **Type**: feature / frontend / architecture
- **Summary**: 承接 Codex 019eaf7c：迁移 `09-user-chat.html` 为 `prototype/web端/index.html` 独立用户端；侧栏智能体中心拆为个人/组织/企业三组（默认收起）；新增 `user-portal-context.js`、`user-agent-resolver.js`、`user-portal-bridge.js` 打通 v1.1 listed 智能体、会话 Skills、历史记录、附件/引用原文状态、反馈→专家任务闭环与运营指标 mock；专家工作台 4 页迁移至 `web端/专家工作台/`；`09-user-chat.html` 保留极简旧入口并跳转 web端。
- **Files changed**: `prototype/web端/index.html`, `prototype/web端/专家工作台/*.html`, `prototype/09-user-chat.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/user-portal-*.js`, `prototype/assets/style.css`, `prototype/assets/ops-user-feedback.js`, `prototype/assets/ops-platform-shell.js`, `prototype/智能体运营v1.1/app.js`, `prototype/scripts/web-portal-check.js`, `prototype/scripts/verify-all.js`, `prototype/scripts/package-check.js`, `prototype/docs/PAGES.md`, `.github/agent/memory/decisions-log.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 web-portal-check）；`node prototype/scripts/v11-ops-check.js` → V11 OPS CHECK PASSED
- **Notes**: 后台打通逻辑仅在 web 桥接层；`09-user-chat.html` smoke 契约不变。

## [TASK-046] 用户端 Figma 对齐与交互修复

- **Date**: 2026-06-10
- **Type**: fix / feature / figma-align
- **Summary**: 按 Figma 用户端 page `376:250`：搜索框上移至新对话与智能体中心之间；修复展开 CSS（`aioq-agent-groups`）；默认展开智能体中心+企业组；`UserAgentResolver` 始终合并 10 条 `DEFAULT_AGENTS`；侧栏「消息中心」三 Tab（`user-message-center.js`）；专家工作台换 `user-portal-shell.js` aioq 侧栏；更新 `figma.config.json` / `interaction-spec` / `figma-workflow` skill。
- **Files changed**: `prototype/web端/index.html`, `prototype/web端/专家工作台/*.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/user-agent-resolver.js`, `prototype/assets/user-portal-bridge.js`, `prototype/assets/user-message-center.js`, `prototype/assets/user-portal-shell.js`, `prototype/assets/ops-platform-shell.js`, `prototype/assets/style.css`, `prototype/scripts/web-portal-check.js`, `design/figma.config.json`, `design/interaction-spec.json`, `.cursor/skills/figma-workflow/SKILL.md`, `.github/agent/memory/*`
- **Verified**: `web-portal-check.js` + `verify-all.js` + `v11-ops-check.js` → PASS
- **Notes**: Figma PAT 不入仓；配置见 `docs/figma-setup.md`。

## [TASK-047] Web 用户端 UI 对齐修复（p2–p7）

- **Date**: 2026-06-10
- **Type**: fix / frontend / figma-align
- **Summary**: 模型下拉 p2 样式；删除智能体 i 图标/详情 drawer/能力与来源按钮；专家工作台 web 端主内容区按 Figma 243:552/2109/2345 重做（筛选+表格+分页、做任务双栏、上下文会话流）；输入区回形针+Skills 星形图标；建议区改为「你可以试着问」chip；更新 smoke/browser/web-portal 契约。
- **Files changed**: `prototype/web端/index.html`, `prototype/web端/专家工作台/workbench.html`, `task-detail.html`, `context.html`, `prototype/assets/user-chat-portal.js`, `prototype/assets/user-agent-resolver.js`, `prototype/assets/ops-expert-workbench.js`, `prototype/assets/style.css`, `prototype/09-user-chat.html`, `prototype/scripts/smoke-check.js`, `prototype/scripts/browser-check.js`, `prototype/scripts/web-portal-check.js`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（8 步含 web-portal-check）
- **Notes**: 专家工作台保留 aioq 侧栏；运营 `12-expert-*` 未同步 Figma 主内容；Figma MCP 限额，对照本地 extract + 用户截图。

## [TASK-048] Web 用户端交互深化与三端记忆沉淀

- **Date**: 2026-06-10
- **Type**: fix / ux / memory
- **Summary**: 消息中心改为居中 modal；专家工作台行菜单改为查看/做任务/取消领取；`UserAgentResolver` 补 `SUGGESTION_CATALOG` 避免切换智能体推荐问雷同；Skills 按钮换拼图 20px + `--skill` 样式；新增 `postmortem-user-portal-2026-06-10.md` 并同步三端长期记忆。
- **Files changed**: `prototype/assets/user-message-center.js`, `prototype/assets/ops-expert-workbench.js`, `prototype/assets/user-agent-resolver.js`, `prototype/assets/style.css`, `prototype/web端/index.html`, `prototype/09-user-chat.html`, `prototype/scripts/web-portal-check.js`, `.github/agent/memory/postmortem-user-portal-2026-06-10.md`, `.github/agent/memory/project-memory.md`, `~/.ai-workspace/memory/*`, `ai-global-config/ai-workspace/memory/*`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED
- **Notes**: 回答区思考/引用卡、运营 12-expert 主内容同步仍待用户确认。

## [TASK-049] v1.1 七态状态流与主页示例卡片

- **Date**: 2026-06-11
- **Type**: feature / ux / prototype
- **Summary**: 对齐用户定义的 7 态（草稿/待发布/审核中/已上架/已停用/已下架/已驳回）与卡片菜单规则；v1.1 主页增加状态对照表；8 条种子数据覆盖全部状态示例；审核中卡片开放「删除」。
- **Files changed**: `prototype/智能体运营v1.1/app.js`, `styles.css`, `prototype/scripts/v11-ops-check.js`
- **Verified**: `node --check prototype/智能体运营v1.1/app.js`；`node prototype/scripts/v11-ops-check.js` → V11 OPS CHECK PASSED
- **Notes**: 已驳回按终态保留，卡片提供「重新提交」；第三方智能体仍不显示权限。

## [TASK-050] Web 用户端智能体广场重构第一阶段

- **Date**: 2026-06-11
- **Type**: prototype / frontend / architecture
- **Summary**: 按已确认方案保留 `prototype/web端/index.html` 为默认聊天入口，新增 `prototype/web端/agent-square.html` 作为“智能体广场”二级页；聊天页侧栏“智能体中心”增加“进入智能体广场”入口。新增 `user-agent-square.js`，实现推荐/全部/我的 Tab、轮播、分类筛选、搜索、收藏、最近使用和“立即使用”跳回 `index.html?id=<agent_id>`。同步收紧 `UserAgentResolver`：只展示已上架且当前用户有权限的智能体，审核中、下架、无权限不进入用户端广场。
- **Files changed**: `prototype/web端/agent-square.html`, `prototype/assets/user-agent-square.js`, `prototype/web端/index.html`, `prototype/assets/user-agent-resolver.js`, `prototype/assets/style.css`, `prototype/scripts/web-portal-check.js`, `prototype/scripts/package-check.js`, `prototype/docs/PAGES.md`, `.github/agent/memory/*`
- **Verified**: `node --check prototype/assets/user-agent-square.js`; `node --check prototype/assets/user-agent-resolver.js`; `node prototype/scripts/web-portal-check.js` → PASS; `node prototype/scripts/package-check.js` → PASS; `node prototype/scripts/v11-ops-check.js` → V11 OPS CHECK PASSED; `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（Figma Desktop MCP 未运行，仅可选 warning）
- **Notes**: 第一阶段推荐/轮播/分类为原型 mock；未实现移动端、完整个人空间、运营端推荐配置后台和真实登录/IAM。

## [TASK-051] Prototype 前端单路径整合（v1.1 默认入口）

- **Date**: 2026-06-11
- **Type**: refactor / prototype / architecture
- **Summary**: 将 v1.1 运营五页扁平化至 `prototype/` 根目录，`index.html` 为默认卡片列表；删除 v1.0 冲突页 `08-audit-queue/review/status` 与 `智能体运营v1.1/` 子目录；逻辑迁入 `assets/ops-v11-app.js`、`assets/ops-v11.css`；保留 `05-agent-detail.html` 配置核心；`verify-all` 纳入 v11-ops-check；流程文档迁入 `prototype/docs/agent-ops-flow.html`。
- **Files changed**: `prototype/index.html`, `dashboard.html`, `audit-*.html`, `agent-detail.html`, `assets/ops-v11-*`, `assets/ops-platform-shell.js`, `assets/proto.js`, `05-agent-detail.html`, `prototype/scripts/*`, `prototype/docs/*`, `AGENTS.md`, `.github/agent/memory/*`, `docs/architecture/agent-lifecycle-states.md`
- **Verified**: `node --check prototype/assets/ops-v11-app.js`; `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（9 步含 v11-ops + navigation-journey）
- **Notes**: ADR-014；`agent-detail.html`（运营查看）与 `05-agent-detail.html`（配置）并存，命名需在 README 区分。

## [TASK-052] 旧页面归档 + 完整新建/第三方接入 + 首次发布免版本号

- **Date**: 2026-06-11
- **Type**: fix / prototype / UX
- **Summary**: 用户反馈整合后找不到旧流程。新建 `prototype/旧页面/` 归档 v1.0 主页、审核三页、创建/第三方独立页；根目录 `08-audit-*.html` 改为跳转归档；v1.1 `index.html` 重新挂载 `ops-list-modals` + 完整新建/第三方弹窗；侧栏增加「旧版页面归档」。发布规则：首次发布（无 `releaseVersion`/`lastPublishedAt`）隐藏版本号自动 v1，再次发布必填版本号（`Proto.isFirstPublish` / `05` / `06` / `ops-v11-app`）。
- **Files changed**: `prototype/旧页面/*`, `prototype/index.html`, `prototype/08-audit-*.html`, `prototype/assets/ops-v11-app.js`, `prototype/assets/proto.js`, `prototype/05-agent-detail.html`, `prototype/06-dev-editor.html`, `prototype/assets/ops-platform-shell.js`, `prototype/scripts/*`, `prototype/docs/PAGES.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（9 步全绿）
- **Notes**: 旧书签 `08-audit-queue.html` 等不再 404；完整第三方弹窗含 upstream 密钥与多步创建链。

## [TASK-053] Web 用户端 v2 门户化重构与 Figma MCP 全局修复

- **Date**: 2026-06-11
- **Type**: prototype / frontend / infra / architecture
- **Summary**: 按用户纠偏将任务从“智能体广场单页”升级为“用户端门户 v2”：`web端/index.html` 保持默认对话工作台，增强图片附件、深度思考、知识库、引用笔记等输入区原型能力；`web端/agent-square.html` 重做为前台化智能体广场，承接推荐 / 全部 / 我的、分类、搜索、收藏和立即使用；新增 `web端/my-space.html` 承接基础信息、个人笔记、个人智能体、收藏和最近使用。用户端只消费运营端已上架且当前用户有权限的智能体，反馈继续回流运营闭环，不暴露审核、派单、开发配置等后台概念。
- **Figma MCP**: 补齐 `~/.codex/config.toml` 与 `~/.codex/codex-plus-mcp-overlay.toml` 的 `figma` / `figma-desktop` MCP；更新全局 `merge-codex-config.py` 保留 Figma MCP；扩展 `scripts/verify-figma-mcp.ps1` 同时检查 Cursor、Codex、overlay、Desktop 3845 端口和 `design/figma.config.json`；重写 `docs/figma-setup.md`。
- **Files changed**: `prototype/web端/index.html`, `prototype/web端/agent-square.html`, `prototype/web端/my-space.html`, `prototype/assets/user-personal-space.js`, `prototype/assets/user-chat-portal.js`, `prototype/assets/user-agent-square.js`, `prototype/assets/user-portal-bridge.js`, `prototype/assets/user-portal-context.js`, `prototype/assets/style.css`, `prototype/scripts/web-portal-check.js`, `prototype/scripts/package-check.js`, `prototype/docs/PAGES.md`, `scripts/verify-figma-mcp.ps1`, `docs/figma-setup.md`, `.github/agent/memory/decisions-log.md`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`, `C:\Users\win\.codex\config.toml`, `C:\Users\win\.codex\codex-plus-mcp-overlay.toml`, `C:\Users\win\.ai-workspace\scripts\merge-codex-config.py`
- **Verified**: `node --check` on changed user JS passed; `node prototype/scripts/web-portal-check.js` passed; `node prototype/scripts/package-check.js` passed; `node prototype/scripts/verify-all.js` passed; `powershell -ExecutionPolicy Bypass -File scripts/verify-figma-mcp.ps1` passed config checks with Desktop MCP port warning.
- **Notes**: Figma Desktop 进程存在但 `127.0.0.1:3845` 未监听时，Codex 侧配置已修复，仍需在 Figma Desktop 内开启 Dev Mode MCP 后 `-StrictDesktop` 才能通过；真实 IAM/SSO、移动端页面、运营端推荐配置后台仍为后续阶段。

## [TASK-054] Figma 三端 Starter 免费打通（Cursor/Codex/Claude Code）

- **Date**: 2026-06-11
- **Type**: infra / docs / architecture
- **Summary**: 按 ADR-016 实现 Starter 免费 Figma 双向策略：PAT REST 读 + Remote MCP 写；新建 `sync-figma-mcp.ps1` 与 `figma-mcp-canonical.json` 管理员模板；补齐 `~/.claude.json` figma MCP；扩展 `verify-figma-mcp.ps1` 覆盖三端 + PAT；更新 `figma.config.json` 路由、`figma-setup.md`、`figma2code`/`figma-workflow` skill、`figma-design.mdc`；`sync-ai-guardrails.ps1 -Force` 自动跑 Figma 同步。
- **Files changed**: `scripts/sync-figma-mcp.ps1`, `scripts/global-workspace/templates/mcp/figma-mcp-canonical.json`, `scripts/verify-figma-mcp.ps1`, `scripts/sync-ai-guardrails.ps1`, `design/figma.config.json`, `docs/figma-setup.md`, `skills/figma2code/SKILL.md`, `.cursor/skills/figma-workflow/SKILL.md`, `.cursor/rules/figma-design.mdc`, `.github/agent/memory/decisions-log.md` (ADR-016), `.github/agent/memory/project-memory.md`, `C:\Users\win\.claude.json`, `C:\Users\win\.ai-workspace\templates\mcp\figma-mcp-canonical.json`
- **Verified**: `sync-figma-mcp.ps1` PASS（Claude 已合并）；`verify-figma-mcp.ps1` PASS with 2 WARN（`FIGMA_API_KEY` 未设、3845 未监听，Starter 预期）
- **Notes**: 用户须手动设 `FIGMA_API_KEY` 并完成三端 OAuth 各一次；读/写冒烟需 OAuth 后实测。

## [TASK-054b] 用户 PAT 写入本机环境变量

- **Date**: 2026-06-11
- **Type**: infra
- **Summary**: 用户提供 Figma PAT；已写入 Windows 用户级 `FIGMA_API_KEY`（不入仓）；PAT REST 对 `gDc0xlVkOeJdgrQOZMy3wh` 验证通过；`verify-figma-mcp.ps1` 仅剩 Desktop 3845 WARN。
- **Verified**: PAT REST OK；verify PASS (1 WARN)；三端 MCP 配置 PASS；Claude `figma` 状态仍为 Needs authentication（OAuth 须客户端内点击）
- **Notes**: Token 曾在聊天中暴露，建议任务完成后在 Figma 轮换 PAT。

## [TASK-055] Web端重构 Phase 1 — 广场重设计 + 个人空间四面板 + Composer知识库

- **Date**: 2026-06-11
- **Type**: feature / frontend
- **Summary**: 按 ADR-015 + 用户确认方向（企业蓝·严谨专业，对话工作台保持首页，广场为一级导航）完成三项必做功能：(1) 智能体广场重设计：Banner 三张自动轮播（setInterval 4s）+ 轮播点指示器 + 推荐Tab编辑化布局（精选推荐横滚 + 各分类横滚区 + 查看全部链接）+ 我的Tab分区（最近使用/收藏/我创建的/授权）；(2) 个人空间四面板：profile hero展示 + 笔记CRUD（新建/删除）+ 智能体状态徽章 + 技术信息面板（组织/角色/用量mock）+ 偏好设置；(3) Composer知识库选择器视觉升级：native select 外包自定义pill（CSS appearance:none），选中时同步更新 #kbLabel 显示。
- **Files changed**: `prototype/web端/agent-square.html`, `prototype/web端/my-space.html`, `prototype/web端/index.html`, `prototype/assets/user-agent-square.js`, `prototype/assets/user-personal-space.js`, `prototype/assets/user-chat-portal.js`, `prototype/assets/style.css`
- **Verified**: `node prototype/scripts/verify-all.js` PASS (9/9 steps, 1 warning Figma Desktop MCP optional)
- **Notes**: Write工具在Windows上会引入Unicode smart quotes (U+201C/201D)导致ID检查失败，需对含ID属性的HTML整体重写（Write tool）而非Edit；my-space.html写入时需保留"原型 mock"字样以通过web-portal-check.js标记原型边界检查。

## [TASK-056] 三端工程助手宪章整合（ADR-G004）

- **Date**: 2026-06-12
- **Type**: infra / docs / global-config
- **Summary**: 诊断 Cursor/Codex 效果差与烧钱根因（16 always-on 规则冲突、Codex 缺 persistent_instructions + high reasoning）。建立 Engineering Assistant Charter SSOT（`~/.claude/AGENTS.md` + `~/.ai-workspace/templates/engineering-charter.md`）；新增 `engineering-assistant-charter.mdc`；9 条 ECC common-* 改按需；Codex config medium + 插件/MCP 精简；项目 `SESSION.md` + `docs/agent-templates/` 记忆模板。
- **Files changed**: `~/.claude/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.codex/config.toml`, `~/.cursor/rules/engineering-assistant-charter.mdc`, `~/.cursor/rules/common-*.mdc` (9), `~/.cursor/rules/requirement-clarifier.mdc`, `~/.ai-workspace/templates/*`, `~/.ai-workspace/memory/global-decisions-log.md` (ADR-G004), `~/.ai-workspace/docs/tri-end-ai-config-inventory-zh.md`, `AGENTS.md`, `SESSION.md`, `scripts/sync-ai-guardrails.ps1`, `docs/agent-templates/*`
- **Verified**: sync-ai-guardrails.ps1 -Force；always-on 规则计数 9；Codex persistent_instructions + medium 存在
- **Notes**: Codex config 备份于 `~/.codex/backups_state/config-pre-charter-20260612100219.toml`；重启三端会话生效。

## [TASK-057] v1.1 主页 + 原详情/数据链路回正

- **Date**: 2026-06-12
- **Type**: fix / routing / ops
- **Summary**: 用户确认主页保持 v1.1 卡片列表，但详情/新建/运行数据/审核进度须走原页面。卡片点击与 v11 简易新建 fallback 改路由至 `05-agent-detail.html`（syncProtoState 后跳转）；审核进度链改回 `08-audit-status.html`；`agent-detail.html` 改为重定向 shim。
- **Files changed**: `prototype/assets/ops-v11-app.js`, `prototype/assets/proto.js`, `prototype/05-agent-detail.html`, `prototype/agent-detail.html`, `prototype/08-audit-status.html`, `prototype/scripts/e2e-check.js`, `prototype/scripts/smoke-check.js`, `prototype/scripts/v11-ops-check.js`, `prototype/scripts/navigation-journey-check.js`, `.github/agent/memory/project-memory.md`, `.github/agent/memory/task-history.md`
- **Verified**: `node --check` ops-v11-app.js + proto.js；package-check / navigation-journey / v11-ops-check / smoke / e2e PASS
- **Notes**: index 仍用 `ops-modal-create.js` 完整新建弹窗；创建成功默认进开发平台，列表查看走 05。

## [TASK-058] 审核状态流 + 可见范围弹窗 + 审核进度实页

- **Date**: 2026-06-12
- **Type**: fix / state-flow / ops UX
- **Summary**: 补齐「提交审核→状态/Toast/再进入可看进度」链路：`Proto.setState` 同步 v1.1 卡片 `proto_ops_v11_agents_v4`；`08-audit-status.html` 恢复为根目录实页（非跳转归档）；05 发布弹窗区分「发布」与「修改可见范围」（后者隐藏版本号/发版描述）；提交审核后保留详情页横幅+状态标签，取消强制跳转；修复 confirmPublish 先校验范围再写状态。
- **Files changed**: `prototype/assets/proto.js`, `prototype/05-agent-detail.html`, `prototype/08-audit-status.html`, `prototype/assets/ops-platform-shell.js`, `prototype/scripts/*`, `.github/agent/memory/task-history.md`
- **Verified**: `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（9 步原型门禁）
- **Notes**: 消息中心待办未自动写入审核通知（仍 mock）；v1.1 卡片菜单「发布」与 05 右上角「发布」为两套入口但状态已打通。

## TASK-059 [2026-06-12] Web 用户端 9 问题收口（Codex 019ebaa2 遗留）
[project: c:\Users\win\Desktop\Agent Platform]

**目标**：完成 Codex 任务 019ebaa2「重构 Web 用户端 UI」遗留的 4 个核心问题。

**根本原因**：Codex session 后段（line 800–1062）全在调试 browser-check.js 合约与 data-note-pick 属性名，核心 UI 改动未落地。

**完成项**：
1. Fix 1: 删除 index.html 中 `aioq-agent-sidebar-block` section（智能体列表内联块），更新 hero 提示文案 → 智能体广场单一入口
2. Fix 2: user-portal-bridge.js `renderSidebarHistory` 重构为 div+button+actions 结构，添加悬停 总结笔记/删除 操作菜单
3. Fix 3: user-chat-portal.js 增加 RESPONSE_OPENERS + pickOpener + shouldShowFileCard，buildAnswer 根据关键词返回多样化回答，file-card 按需显示
4. Fix 4a: 历史对话折叠状态 sessionStorage 持久化
5. CSS: .aioq-history-item-body/.aioq-history-item-actions/.aioq-history-action-btn hover 显示样式
6. web-portal-check.js 更新：agentListAll → sidebarHistoryList，新增智能体广场单一入口断言

**验证**：`node prototype/scripts/verify-all.js` PASSED（Figma MCP 失败为预存在的 .codex/config.toml 配置问题，非本任务导致）

**已完成** / **已验证** / **剩余风险**：my-space 布局重构和 agent-square banner 轮播未在本次范围内。

## TASK-060 [2026-06-12] Web 用户端 v3 UI/UX 改版（清言/智谱对标）
[project: c:\Users\win\Desktop\Agent Platform]

**目标**：按用户反馈与改版计划，重构侧栏、对话输入区、智能体广场与我的空间导航。

**完成项**：
1. 侧栏三段式（brand + 可滚动区 + 固定底栏）；对话页恢复智能体快捷列表（最近 3–5 + 更多智能体）
2. 最近对话 hover：保存笔记 / 重命名 / 删除（确认弹窗）；三页侧栏统一
3. 删除「AI 工作入口」banner；智谱式单盒 composer；`+` 菜单合并上传文件/引用笔记/语音
4. 智能体广场：页头精简、描述 2 行截断、推荐 grid、我的 Tab 紧凑卡片、Tab segmented 风格
5. 我的空间：「返回对话」右上角；ADR-015 修正案写入 decisions-log

**文件**：`prototype/web端/index.html`、`agent-square.html`、`my-space.html`；`user-portal-bridge.js`、`user-chat-portal.js`、`user-agent-square.js`、`style.css`；`web-portal-check.js`

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（Figma MCP 预存 WARN）

## TASK-061 [2026-06-12] Web 用户端侧栏交互 v3.2 修复
[project: c:\Users\win\Desktop\Agent Platform]

**目标**：对齐清言 p4——⋯ 功能按钮、保存笔记简化、广场/我的空间补智能体侧栏。

**完成项**：
1. 最近对话（侧栏+历史弹窗）：hover 单个 ⋯ → 下拉（保存笔记/重命名/删除）
2. 智能体侧栏：⋯ 菜单（置顶/移除）；数据源 = 最近使用 + 收藏；去掉默认填充
3. 保存笔记：去掉轮次勾选与 Markdown 预览，改为 `#historySummaryTranscript` 只读展示 + 后台全量保存
4. `agent-square.html` / `my-space.html` 补 `#sidebarAgentList`；广场使用/收藏后 refresh 侧栏
5. `web-portal-check.js` + `browser-check.js` 断言同步

**验证**：`web-portal-check.js` PASSED；`verify-all.js` PASSED

## TASK-062 [2026-06-15] Web 用户端 UI/UX 六类修复
[project: c:\Users\win\Desktop\Agent Platform]

**目标**：修复我的空间侧栏重复、滚动/删笔记确认、历史恢复 toast、意见箱已提交态、KB/Skills 图标、广场「我的」布局、专家工作台侧栏、笔记 summary 与引用展示。

**完成项**：
1. 我的空间：删侧栏「我的空间」重复项；「技术信息」→「基础信息」；主区可滚动；笔记删除确认 modal
2. 历史恢复：移除 `Proto.toast('已恢复历史会话…')` 两处
3. 意见箱：补「已提交」mock + status badge；对话反馈提交后打开意见箱 Tab
4. KB/Skills：`icons/kb-book.svg`、`icons/skill-scroll.svg` 替换 composer 图标
5. 广场：「我的」Tab 纵向布局（`aioq-square-grid--mine`）；去掉 intro 裸数字；轮播视觉增强 + mine 隐藏 banner + dot 后恢复 autoplay
6. 专家工作台 4 页：补 `user-portal-bridge.js` + 历史 modal + `mountSidebar()`
7. 笔记：`buildRefinedSummary` 写入 summary；引用 chip 显示标题+总结

**验证**：`node prototype/scripts/web-portal-check.js` PASSED；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-063 [2026-06-15] Web 用户端 v4 敖钦对标补全

**目标**：企业邮箱 mock 登录、对话页能力接线（点赞/点踩/重生成/图表/模型/引用/文件）、笔记 chip UX、广场轮播增强、我的空间改密。

**完成项**：
1. 新增 `web端/login.html`、`forgot-password.html`、`user-auth.js`；全站 session 门禁
2. 我的空间：「认证状态」→「修改账号密码」+ `#changePasswordModal` + 退出登录
3. 对话页：修复 `buildAnswer` 弯引号；顶栏四档模型；复制/重生成/点赞/点踩/文件下载/引用原文；SVG 图表 mock；笔记 chip 仅名 + popover 摘要
4. 广场轮播：左右箭头、hover 暂停、点击联动分类 Tab
5. 契约：`web-portal-check.js`、`smoke-check.js`、`browser-check.js`、`package-check.js`、ADR-015 修正案

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 web-portal-check + navigation-journey）

**演示账号**：`zhangsan@cnooc.com.cn` / `Aq123456`；忘记密码验证码 mock：`123456`

## TASK-064 [2026-06-15] Web 用户端 v5 对标纠偏

**目标**：删除 + 菜单语音、模型下拉改 DeepSeek 全名、笔记 summary 短句化、全局门禁。

**完成项**：
1. + 菜单仅「上传文件 + 引用笔记」
2. 顶栏/下拉显示 DeepSeek 四档全名
3. `buildShortNoteSummary` + `displayNoteSummary`；轮次/全文仅在保存 modal
4. ADR-015 v5、AGENTS.md § Web 用户端 UX Contract、postmortem P9–P11、web-portal-check 更新

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-065 [2026-06-15] 登录演示壳 + 关闭 Superpowers sessionStart

**目标**：登录改为演示壳（任意输入即进、打开 login 清缓存不跳走）；忘记密码页可演示跳转；关闭 Superpowers 插件 session-start 注入。

**完成项**：
1. `user-auth.js`：移除演示账号校验；`prepareLoginPage()` 打开 login 时清 session/localStorage；`login()` 任意邮箱一键进入
2. `login.html` / `forgot-password.html`：去掉演示账号与 mock 验证码文案；忘记密码流程放宽为演示可点通
3. `.cursor/settings.json`：`superpowers.enabled = false`（禁用 session-start 大段 additional_context 注入）

**验证**：`node --check prototype/assets/user-auth.js` + `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

**备注**：Superpowers 技能仍可从全局 skills 目录加载；需重启 Cursor 新会话后 session-start 弹窗才消失。全局 `~/.cursor/hooks.json` 的 `scan-global-skills.ps1` 仍会注入精简 skill 索引（与 Superpowers 无关）。

## TASK-066 [2026-06-15] 专家工作台壳统一 + session-start 弹窗根治

**目标**：专家工作台与对话页同一 v2 壳；行操作仅「做任务」；根治 Windows session-start 选应用弹窗；全局防「声称已改未改」。

**根因**：
1. 专家页仍用 `UserPortalShell.render()` 旧侧栏（品牌/结构/底栏与 index 不一致）→ 点击像换了两套页面
2. TASK-065 仅 `superpowers.enabled=false`，未修插件缓存 `hooks-cursor.json` 的 `./hooks/session-start`（Windows 无扩展名 → 系统选应用弹窗）
3. `session-start` 文件头被污染 `shen'nei'rong`；Agent 改错路径（项目 settings vs 插件 cache）且无自动校验

**完成项**：
1. 专家工作台 workbench/task-detail/context：静态 `aioq-user-sidebar` + 顶栏，与 index/agent-square 一致；`ops-platform-shell` 有 v2 侧栏时跳过 `UserPortalShell.render`
2. `ops-expert-workbench.js`：行菜单去掉「查看」；用户端 `task-view` 重定向 `task-detail`
3. `~/.ai-workspace/scripts/repair-cursor-plugin-hooks.ps1` + 挂入 `scan-global-skills.ps1` SessionStart；修复缓存 `hooks-cursor.json` 与 `session-start` 污染
4. `web-portal-check.js` 增加壳统一与行菜单契约

**验证**：`repair-cursor-plugin-hooks.ps1` + `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-067 [2026-06-15] 历史对话 → 保存个人智能体（前端闭环）

**目标**：历史 `⋯` 新增「保存个人智能体」；内容不足拦截；充足时提炼 prompt 等字段；我的空间查看/立即使用/删除；Resolver 合并使对话页可选用。

**完成项**：
1. `user-portal-bridge.js`：菜单项、`isHistoryAgentReady`、`buildPersonalAgentDraft`、`#historyAgentModal` 保存流程
2. `user-personal-space.js`：`savePersonalAgent` / `deletePersonalAgent`、会话沉淀分区渲染、删除确认
3. `user-agent-resolver.js`：`loadSessionDraftAgents` 合并 `pagt_*` 至 personal 组
4. `index.html` / `agent-square.html` / `my-space.html`：agent modal + 删除确认
5. `style.css`：agent modal 与草稿卡片样式
6. `web-portal-check.js`：契约翻转 + vm 草稿合并测试
7. ADR-015 amendment：会话沉淀数据契约

**验证**：`node --check`（bridge/personal-space/resolver）+ `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（含 web-portal-check 草稿合并断言）

## TASK-068 [2026-06-15] 笔记精炼总结 + 我的空间布局 + 联系运维帮助

**目标**：修复保存笔记仍显示大段回答套话；我的空间顶栏仅保留「返回对话」，退出登录移入偏好设置；侧栏「帮助」改为联系运维弹窗（p3）。

**完成项**：
1. `user-personal-space.js`：`buildNoteSummaryFromRounds` / `extractAnswerEssence`；`displayNoteSummary` 对旧数据去套话；偏好区新增「联系运维」「退出登录」
2. `user-portal-bridge.js`：保存笔记走精炼总结；`ensureHelpModal` / `openHelp` 全站注入联系运维
3. `index.html` / `my-space.html`：帮助弹窗改为联系运维；顶栏移除退出登录
4. `style.css`：联系运维卡片与偏好区操作样式
5. `web-portal-check.js` + `package-check.js`（tel: 白名单）：契约与 vm 精炼测试

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-069 [2026-06-16] Composer 附件底栏 + 全局 Skills 去重安装与路由修复

**目标**：附件/笔记名称移入输入框底栏；切换智能体/对话清空 composer 上下文；去重 vendor 外部 skills 至三端；修复 Cursor `beforeSubmitPrompt` hook。

**完成项**：
1. `web端/index.html` + `style.css`：`#attachChip` 移入 `.aioq-composer-toolbar-left`（inline chips）
2. `user-chat-portal.js`：`resetComposerContext()`；`selectAgent` / `restoreSession` / `#btnNewChat` 调用；移除 `defaultNoteIds` 持久化
3. `web-portal-check.js`：底栏 chip + resetComposerContext 契约断言
4. `scripts/hooks/install-external-skills.ps1`：tactus + awesome-design-skills（index.json 去重）+ anthropics/skills（bestskills 镜像）+ 2 个 reference skills；manifest 79 项
5. `skills-sync.config.json`：`tactus-design-style` description + keywordBoost
6. `install-global-skills-hooks.ps1`：补全 Cursor `beforeSubmitPrompt`；`global-skills-index` 413 条

**验证**：`node --check user-chat-portal.js` + `verify-all.js` PASS；路由 spot-check「设计风格 tactus」→ Top1 `tactus-design-style`（score 58）

**Remaining**：`trigger-tdd-tier1.ps1` 全量 16 用例因 400+ skills 扫描较慢，未在本任务跑完；DAILY 桶历史 TDD 仍参考 2026-06-05 100% 基线。

## TASK-070 [2026-06-16] Skills 路由重构（Phase A/B）三端同步

**目标**：撤出 `awesome-*` 全局竞争、互斥组、CSO NOT-when、优化 trigger TDD；三端 hooks/config 同步。

**完成项**：
1. `skills-sync.config.json`：`excludeNamePrefixes`/`routingExclude*`、`exclusiveGroups`、`topMatches:10`、设计/figma/交付类 CSO NOT-when
2. `scan-global-skills.ps1`：`Invoke-GlobalSkillRouting`（路由过滤 + CSO overlay + 互斥组）；`-SkipIndexWrite`；可 dot-source
3. `sync-cursor-global-skills.ps1`：`excludeNamePrefixes` 阻止 awesome 再同步到全局
4. `prune-global-skills-routing.ps1`：三端清理 library-only skills
5. `trigger-tdd-tier1.ps1`：单次 catalog 加载（不再每用例 spawn 子进程）
6. 三端同步：`install-global-skills-hooks.ps1 -SkipSync` + config/scan 复制至 `~/.ai-workspace`、`.cursor/hooks`、`.claude/scripts`
7. `apply-tier1-cso-descriptions.ps1`：24 个全局 SKILL.md 更新

**验证**：`trigger-tdd-tier1.ps1` → **94.1% (16/17)** ≥ 90% 目标；报告 `docs/skills-audit/2026-06-16-trigger-tdd.md`

**Remaining**：catalog 仍含 vendor `awesome-*`（LIBRARY 可检索，不参与 TopN 评分）；全量 index 仍 413；figma2code 单条 ambiguous prompt 被 figma-workflow 互斥胜出（可接受）。

## TASK-071 [2026-06-16] Web 用户端：我的空间/意见箱/保存智能体

**目标**：我的空间删企业邮箱与改密、加个人知识库；意见箱从消息中心拆到侧栏左下角；保存个人智能体去掉开场建议。

**完成项**：
1. `user-personal-space.js`：基础信息去邮箱/改密；新增 `renderPersonalKb` 面板
2. `my-space.html`：个人知识库面板；删 `changePasswordModal`；保存智能体弹窗去开场建议
3. `user-message-center.js`：消息中心仅公告/待办；独立 `userFeedbackDrawer` + `openFeedbackDrawer`
4. 侧栏 6 页加 `btnFeedbackBox`（index/agent-square/my-space/专家工作台×3）
5. `user-portal-bridge.js`：保存个人智能体不再写 suggestions
6. `agent-square.html`：去开场建议字段
7. `style.css`：个人知识库列表样式；`web-portal-check.js` 断言更新

**验证**：`node --check` 三 JS + `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

**Remaining**：个人知识库为原型 mock；`~/.cursor/hooks.json` 保持删除状态（避免 preToolUse 锁死 Agent）

## TASK-072 [2026-06-17] 三端全局避坑配置（Windows + 第三方 API 缓存）

**目标**：根治 RTK/PowerShell/Python 重复失败与 Claude Code + DeepSeek 缓存命中归零；写入全局配置供 Cursor/Codex/Claude Code 持久生效。

**完成项**：
1. 新增 `windows-agent-shell.mdc`、`headroom-token-save.mdc`（纳入 `sync-ai-guardrails.ps1`）
2. 完整 `rtk-hook-cursor.ps1` SSOT + `repair-tri-end-hooks.ps1`（gate bypass + RTK Shell）
3. `apply-tri-end-env.ps1`：`CLAUDE_CODE_ATTRIBUTION_HEADER=0` 等三端 env
4. `cc-sync-all.ps1` env preserve 白名单
5. `ensure-python-env.ps1` + SessionStart 挂接；`verify-tri-end-config.ps1`
6. `open-cursor-permissions.ps1` 破坏性警告；`install-global-skills-hooks.ps1` PreToolUse 数组修复

**验证**：`verify-tri-end-config.ps1` → PASS；`rtk init -g --auto-patch` → settings.json hook added

**Remaining**：需完全重启三端会话后生效；DeepSeek 缓存命中率需 1–2 天账单侧观察

## TASK-073 [2026-06-16] 统一反馈弹窗：文本框 + 图片上传

**目标**：意见箱「提建议」与对话点踩「反馈」弹窗统一为文本框 + 支持上传图片，去掉 checkbox 类型网格。

**完成项**：
1. 新增 `user-feedback-form.js`（markup / wire / collect / reset / 预览 chip）
2. `index.html` + `user-portal-bridge.js`：对话反馈挂载 `#chatFeedbackFormMount`；校验「文字或图片至少一项」
3. `user-message-center.js`：提建议弹窗复用同一表单；详情展示附件名
4. `ops-user-feedback.js`：`createFromChat` 支持 `images`/`attachments`
5. `style.css`：`.aioq-feedback-form` / 图片 chip 样式
6. 各 Web 页引入 `user-feedback-form.js`；`09-user-chat.html` 同步；`web-portal-check.js` 断言更新

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

**Remaining**：图片仅为原型（object URL + 文件名存储，无真实上传 API）

## TASK-074 [2026-06-17] 交付门禁与 DeepSeek 缓存二期

**目标**：① Node/React 项目全局交付契约 + 解除 program1-main lint 阻塞；② 保持 CC Switch 15721 入口，上游增强 DeepSeek 缓存代理链。

**完成项**：
1. 新增 `node-project-delivery.mdc`；`AGENTS.md` §3 区分原型 `verify-all` vs Node `npm run verify`
2. `sync-ai-guardrails.ps1` 纳入 node rule；`projects-registry.md` 登记三项目
3. `verify-tri-end-config.ps1` 增加 node rule + registry 探测；`eslint.react-baseline.config.js`、`init-project-git.ps1`
4. `deepseek-cc-proxy.mjs`：剥 attribution、tools 字典序排序、去 cache_control、写 cache log
5. `install-deepseek-cache-proxy.ps1`、`verify-deepseek-cache.ps1`、`tri-end-deepseek-cache-playbook-zh.md`
6. `apply-tri-end-env.ps1` / `cc-sync-all.ps1`：DeepSeek 上游 `http://127.0.0.1:18789/anthropic`，客户端仍 15721

**验证**：
- `program1-main`: `npm run verify` → PASS（0 errors，11 warnings）
- `verify-tri-end-config.ps1` → PASS
- `verify-deepseek-cache.ps1` → PASS（log 尚无 cache hit 行，需实际会话）
- `cc-sync-all.ps1` → BASE_URL 18789 已写入 DeepSeek provider

**Remaining**：缓存命中率需 Claude Code + DeepSeek 多轮后观察 `prompt_cache_hit_tokens`；Agent Platform 仍无 git（可选 `init-project-git.ps1`）

## TASK-077 [2026-06-17] PRD v1.2 格式修复：补充 Mermaid 图 + 精简布局描述 + 修正 Markdown 结构
[project: c:\Users\win\Desktop\Agent Platform]

**目标**：修复 v1.1 去技术化过程中被误删的架构图/流程图（重绘 Mermaid）、缩短页面布局文字改引用 Figma、修复 Markdown 格式问题（缺失三章节、标题格式、表格样式）。

**完成项**：
1. 重绘 2.1 系统分层架构 Mermaid 图（三层：用户端 → 平台能力层 → 管理后台，纯业务视角，无技术内部名词）
2. 保持功能树 Mermaid 图（2.2）
3. 补充缺失的三章节（产品功能总览 + 模块优先级表格）
4. 4.3–4.6 页面描述精简，布局均改为引用 Figma 设计稿，保留表单字段 + 交互规则 + 状态表格
5. 重绘 6.1–6.4 四个流程 Mermaid 图（登录认证、对话全流程、反馈→专家→工单、智能体发现与收藏）
6. 整体 Markdown 格式修正：`#` 标题层级、表格管道对齐、列表空白行
7. 更新变更日志 v1.2

**文件**：`docs/prd/敖钦AI用户端Web门户_PRD_v1.0.md`

**验证**：`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED（9/9 steps，仅 Figma MCP 预存 WARN）


## TASK-078 [2026-06-17] PRD v1.3 查缺补漏 + PRD writing skills 迭代
[project: Agent Platform]

**目标**：根据用户手动修正的 PRD v1.2 版本，学习用户编辑方向，补充缺失功能（Skills/深度思考/消息中心等），迭代 PRD writing skills 编码用户偏好。

**用户编辑方向（已写入 pm-prd-writer + create-prd skills）：**
1. 不放 Mermaid 图，标注"暂时无法在飞书文档外展示此内容"，用户自己在飞书画
2. 不使用  Markdown 标题，用纯文本"一、二、三"编号
3. 使用  占位截图，用户自行粘贴 Figma 截图
4. 短表格 + 要点列表，避免长段落
5. 禁止非功能需求/附录章节
6. 必须覆盖：Skills 选择器、深度思考、上传限制、下载按钮、来源引用、消息中心
7. 业务约束前置标注（"和敖钦一期一致"、"视实际情况而定"）
8. 数据来源标注（"和组织结构统一"、"和运营中心数据打通"）

**PRD 补充内容：**
1. 修复编号重复：智能体广场4.2、我的空间4.2 -> 4.3，专家工作台4.4
2. 新增 4.5 消息中心（公告/待办/意见箱）
3. Skills 选择器详情（搜索/过滤/多选/上限5个）
4. 深度思考开关说明
5. 动作条新增下载按钮
**修改文件：** `docs/prd/敖钦AI用户端Web门户_PRD_v1.0.md`、`skills/pm-prd-writer/SKILL.md`、`skills/pm-prd-writer/references/prd-template.md`、`~/.cursor/skills/create-prd/SKILL.md`、`.github/agent/memory/project-memory.md`

**验证：** `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

## TASK-079 [2026-06-22] Tri-end curated skills routing + task-intake bridge
[project: Agent Platform]

**目标**：把 Codex / Cursor / Claude Code 的 skills 路由从“库存平铺 + 触发不稳定”升级为“curated category-first routing + task-intake bridge + active clarification hard gate”。

**完成项**：
1. 新增 `skills/curated/` 十个分类 `_routing.md`，固定 category/purpose/use_when/default_chain/skills 元数据
2. 新增 `skills/task-intake-bridge/SKILL.md`，作为 tri-end always-on 需求桥接层
3. `scan-global-skills.ps1` 增加 curated category routing、intent→category 强映射、category-first shortlist、并发索引写 fail-open
4. `skills-sync.config.json` / `intent-profiles.json` 加入 `task-intake-bridge` 与 curated catalog 配置
5. 新增 `sync-curated-routing.ps1`、`build-curated-skills-governance.ps1`、`verify-curated-routing.ps1`
6. 生成 `skills/curated/_governance/skills-manifest.md`、`skills-inventory.md`、`skills/archive/ARCHIVE-INDEX.md`
7. `sync-ai-guardrails.ps1`、`sync-hooks-config.ps1`、`install-global-skills-hooks.ps1`、`repair-tri-end-hooks.ps1` 全部接入 curated catalog 与真实 clarification hard gate
8. `verify-tri-end-config.ps1` 从“gate bypass”切到“hard gate active”校验口径；已同步三端全局配置

**验证**：
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/hooks/build-curated-skills-governance.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/hooks/sync-curated-routing.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/hooks/verify-curated-routing.ps1` → ALL PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/hooks/test-clarification-gate.ps1` → ALL PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/global-workspace/verify-tri-end-config.ps1` → PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-ai-guardrails.ps1 -Force`
- `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED

**备注**：tri-end 当前 shell 会话若仍继承旧环境变量，需要重启 Cursor / Claude Code / Codex 会话后才能完全切到新的 hard gate 行为。

## TASK-080 [2026-06-26] Web 用户端 v1.1 我的空间与历史沉淀修订
[project: Agent Platform]

**目标**：继续完成用户端 v1.1 重构，落实保存为笔记多选/全选历史轮次、个人笔记编辑、我的空间精简、智能体编辑权限、保存个人智能体 loading 尺寸一致，并同步中台 Web 用户侧 PRD。

**完成项**：
1. 历史对话保存笔记支持全选/清空/多选轮次，历史分支轮次进入可选择范围，并按已选轮次保存。
2. 我的空间个人笔记新增编辑弹窗，卡片仍仅展示标题和短摘要。
3. 我的空间移除个人知识库和独立偏好设置；默认开启深度思考、默认知识库并入基础信息。
4. 我的智能体权限重构：我创建的可跳转运营平台编辑，组织授权只允许使用、不显示编辑入口。
5. 保存个人智能体 loading 改为与最终配置弹窗同尺寸。
6. 更新 `web-portal-check.js`、`中台web端用户侧PRD_v1.0.md`、ADR-015 amendment 与项目记忆。
7. 按用户要求将“大幅改动/已有内容冲突必须先用非技术语言确认”的协作规则写入项目 `AGENTS.md`、全局 master、全局用户记忆与项目记忆。

**验证**：`node --check`（user-chat-portal / user-portal-bridge / user-personal-space / user-agent-resolver）通过；`node prototype/scripts/web-portal-check.js` 通过；`node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED。同步 guardrails 后复跑 `scripts/verify-figma-mcp.ps1`：Codex figma remote/desktop 配置已恢复，仅剩 Figma Desktop MCP 未启动 WARN（可选，不阻断）。

**风险**：个人智能体编辑跳转仍为原型内运营平台详情入口，真实权限与后端同步需后续接入。

## TASK-081 [2026-06-26] Web 用户端 v1.1 续跑复核与协作规则确认
[project: Agent Platform]

**目标**：接续上一轮用户端 v1.1 重构任务，确认新增需求、PRD 同步和“大改/冲突先用非技术语言确认”规则已落地，并复跑交付门禁。

**完成项**：
1. 复核 `AGENTS.md`、全局 master、全局用户记忆、项目记忆中均已有“大幅改动/冲突必须先确认”的规则。
2. 复核用户端页面和脚本中的保存笔记全选/多选、分支轮次、个人笔记编辑、我的空间精简、智能体编辑权限和 loading 同尺寸契约。
3. 复核 `docs/prd/中台web端用户侧PRD_v1.0.md` 已描述本轮改动后的业务规则。
4. 更新 `SESSION.md` 当前状态，记录 verify-all 已通过。

**验证**：
- `node --check prototype/assets/user-chat-portal.js` 通过
- `node --check prototype/assets/user-portal-bridge.js` 通过
- `node --check prototype/assets/user-personal-space.js` 通过
- `node --check prototype/assets/user-agent-resolver.js` 通过
- `node --check prototype/assets/user-message-center.js` 通过
- `node prototype/scripts/web-portal-check.js` → WEB-PORTAL-CHECK PASSED
- `node prototype/scripts/verify-all.js` → VERIFY-ALL PASSED；仅 Figma Desktop MCP 未启动为可选 WARN

**风险**：项目目录不是 git 仓库，无法用 git diff 做最终变更边界审计；本轮以文件内容检索和自动化契约检查为准。

## TASK-082 [2026-07-06] 敖钦 AI 中台总体建设方案优化版
[project: Agent Platform]

**目标**：基于现有 `敖钦AI中台总体建设方案.docx`、线上平台真实模块和用户确认方案，生成不覆盖原文件的优化版 Word，突出全平台闭环而非单一智能体运营平台。

**完成项**：
1. 新增 `docs/敖钦AI中台总体建设方案_优化版.docx`，全篇轻重构为“用户端 - 智能体开发 - 运营治理 - 知识/模型/资源/系统底座”的平台闭环叙事。
2. 新增高清图 `docs/assets/aoqin_ai_midplatform_overview.png`，将原运营局部图升级为“敖钦 AI 中台总体能力全景图”。
3. 新增高清图 `docs/assets/aoqin_ai_midplatform_flow.png`，将原开发平台数据流图升级为“全平台业务闭环与数据治理流转图”。
4. 正文补齐平台真实模块：运营管理、智能体开发、模型协同、知识库、智能编码助手、用户反馈、专家工作台、看板、权限组织、系统监控、Token 统计、MCP、Skills 等。
5. 文末“总体建设目标---当前建设进度---后续规划”整理为正式章节，覆盖目标、已具备能力、后续重点和面向甲方价值总结。

**验证**：
- 生成脚本自检通过：优化版 Word 存在，2 张图均为高清 PNG，文档覆盖关键模块，未包含账号密码和线上测试智能体名称。
- Word COM 只读打开成功，并导出 `docs/敖钦AI中台总体建设方案_优化版.pdf`：7 页、7 张表、2 张嵌入图。
- 未修改 prototype 运行时代码，因此未运行 `node prototype/scripts/verify-all.js`。

**风险**：Word 版式已通过自动打开和 PDF 导出验证，但最终投屏/打印效果仍建议人工快扫一遍。

