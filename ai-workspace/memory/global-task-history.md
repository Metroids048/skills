# Global Task History

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
[project: C:\Users\win\Desktop\海小南] 2026-07-06 海小南 PM 项目资料 V1.1 分册文档
- **内容**: 基于调研报告V2、甲方确认清单、现有智能体列表、PRD V1.0 和真实页面代码参考，在 `docs/` 下新增 9 份 V1.1 PM 分册文档：索引、架构蓝图、路线图、页面/UI规范、全局产品配置、功能矩阵、PRD V1.1、待确认清单、现有智能体资源清单。
- **验证**: 脚本检查 9 个目标文件均存在且 UTF-8 可读；PRD V1.1 覆盖用户诉求、架构、UI、功能、接口、非功能、验收、风险、部署约束；Excel `agents` 表为 50 行含表头、49 条有效资源，文档资源行数为 49。
- **风险**: 用户计划中提到“50 条资源”，实际 Excel 有效数据为 49 条，已在资源清单和 PRD 中标为待确认；未修改业务代码或运行应用测试。

[project: C:\Users\win\Desktop\海小南] 2026-07-02 海小南核心智能体能力升级 PRD
- **内容**: 基于用户确认的 PM 版方案，生成 `海小南核心智能体能力升级_PRD_V1.0.md`，覆盖用户诉求、产品/UI 方案、功能清单、实现方式、接口、技术路线、实施拆解、验收标准、风险和待确认项。
- **验证**: 读取 PRD 章节目录、关键 Mermaid 流程、接口 JSON 样例、功能需求和实施拆解，确认文档可读且覆盖开发前评审所需内容。
- **风险**: 本轮为文档交付，未涉及代码实现和运行测试；BMS/BIMS 命名、首批指标/页面清单、权限规则等仍需业务方确认。

[project: C:\Users\win\Desktop\海小南] 2026-06-29 海小南 Demo 二阶段补齐
- **内容**: 在 `hai-xiaonan-demo.html` 中补齐数字人演示层，新增悬浮提示、嘴部/眨眼/执行光束/成功粒子/状态徽标；引入 `SCENARIO_ROUTE_TABLE`、`DEMO_SCRIPT_LIBRARY`、`DIGITAL_HUMAN_STATE_META`，把文本语音、直达语音、预设命令和页面内自动演示收敛到统一链路，并补上“直接回答 / 指标穿透 / 档案归档 / 合同交底 / 串行调度”几类预设场景。
- **验证**: 从 HTML 抽取最新活动脚本后执行 `node --check` 通过；文本检查确认新的路由表、脚本库、数字人叠层 DOM 和串行演示执行器均已落地。
- **风险**: 尚未在真实浏览器里逐条走完 hover / drag / 麦克风权限 / TTS 降级 / 串行脚本的完整人工演示，现场效果仍建议再做一轮手动冒烟。

[project: C:\Users\win\Desktop\Agent Platform] 2026-06-26 Web 用户端 v1.1 续跑复核
- **内容**: 接续用户端 v1.1 重构，复核“大改/冲突先用非技术语言确认”规则已写入项目与全局记忆，复核保存笔记多选/分支、个人笔记编辑、我的空间精简、智能体编辑权限和 PRD 同步内容，并更新 SESSION 当前状态。
- **验证**: `node --check` 用户端相关 JS 通过；`node prototype/scripts/web-portal-check.js` 通过；`node prototype/scripts/verify-all.js` 通过，仅 Figma Desktop MCP 未启动为可选 WARN。
- **风险**: 项目目录不是 git 仓库，无法用 git diff 做最终变更边界审计。

[project: C:\Users\win\Desktop\Agent Platform] 2026-06-26 Web 用户端 v1.1 我的空间与历史沉淀修订
- **内容**: 完成保存为笔记全选/多选历史轮次与分支轮次、个人笔记编辑、我的空间移除个人知识库和独立偏好设置、默认深度思考/默认知识库并入基础信息、我的智能体编辑权限区分、保存个人智能体 loading 尺寸一致；同步中台 Web 用户侧 PRD，并将“大改/冲突必须用非技术语言先确认”写入项目与全局规则。
- **验证**: `node --check` 相关用户端 JS、`node prototype/scripts/web-portal-check.js`、`node prototype/scripts/verify-all.js` 均通过；`scripts/sync-ai-guardrails.ps1 -Force` 后 `scripts/verify-figma-mcp.ps1` 通过但提示 Figma Desktop MCP 未启动（可选 WARN）。
- **风险**: 个人智能体编辑跳转仍为原型内运营平台详情入口，真实权限与后端同步需后续接入。

[project: C:\Users\win\Desktop\program1-main-latest] 2026-06-26 大改冲突必须用非技术语言确认规则
- **内容**: 按用户要求，将“大幅度改动或与已有内容冲突时，必须用通俗易懂的非技术语言询问确认”的规则写入项目 `AGENTS.md`、`.github/agent/memory/RULES.md`、项目记忆、全局 `global-agent-master.md`、Claude/Codex 全局入口。
- **验证**: 文本检查确认规则已写入本地规则文件。
- **风险**: 这是流程规则更新，不涉及运行时代码；后续任务需要主动遵守，多问多确认。

[project: C:\Users\win\Desktop\program1-main-latest] 2026-06-26 AI 求职台 Prompt G 补完与产品 UI 收口
- **内容**: 修复 `/api/mock/session/:id/answer` 因 FTS5 查询非法字符触发的 500，补齐 Fastify app 测试关闭以避免 Windows EPERM；新增 `InterviewRecord.questionResults` 可选兼容字段与派生写入；更新 CI；按 Prompt G 完成首页、主导航、模拟配置、`/resume` 简历证据预览与记录页筛选空态收口。
- **验证**: `npm run test:server` 27 tests passed；`npm run test:app` 5 test files / 32 tests passed；`npm run verify` 通过，14 test files / 81 tests passed，build 通过。
- **风险**: Codex 无渲染层验收；仍保留既有 `react-refresh/only-export-components` lint warnings 和 Vite chunk size warning，建议 Cursor 或人工浏览器补 1280/390 视觉冒烟。

[project: C:\Users\win\Desktop\program1-main] 2026-06-24 AI 求职台灾难迭代整顿与 mock 主链路修复
- **内容**: 恢复公开 MVP 的七主导航和多页面 IA，岗位抽屉改回“摘要 + 进入完整页面”，mock setup 不再写死题数/时长，配置后进入房间不再二次弹配置；同时修复 SQLite FTS5 检索查询污染导致的 `/api/mock/session/:id/answer` 500。
- **验证**: `npm run lint`、`npm run typecheck:server`、`npm test`、`npm run build`、`npm run verify` 全部通过；后端两条 mock 关键回归单测已单独复跑通过。
- **风险**: Codex 无渲染层验收；当前结论基于代码审查、Vitest 和接口链路，UI 最终观感仍建议在 Cursor 或人工浏览器补一轮冒烟。

[project: C:\Users\win\Desktop\program1-main] 2026-06-24 真实启动异常页根因修复
- **内容**: 复现并修复浏览器真实启动即落入异常页的问题。根因是旧版 `localStorage` 缓存中的岗位对象缺少新结构字段，而 `normalizePosition()` 未补齐 `job/matchReport/answers/mockTurns/report/selectedQuestionId`，后续 `repairAppState()` 启动期直接抛错。
- **验证**: 旧缓存最小复现脚本从抛错变为通过；新增 `App` 回归测试覆盖“旧缓存启动不崩”；`npm run verify` 通过。
- **风险**: 仍建议用户本机刷新页面确认现有标签页已拿到新 bundle；Codex 无浏览器渲染层验收。

[project: C:\Users\win\Desktop\Agent Platform] 2026-06-22 Tri-end curated skills routing + task-intake bridge
- **内容**: 将 Codex / Cursor / Claude Code 的 skills 路由升级为 `task-intake-bridge -> curated category _routing.md -> shortlisted skills`，新增 repo 内唯一真源 `skills/curated/`、桥接 skill、治理清单、归档索引，并让 sync / hooks / repair / verify 脚本接入分类优先路由。
- **验证**: curated governance build、curated sync、routing smoke、clarification hard gate、tri-end config verify、`sync-ai-guardrails.ps1 -Force`、`node prototype/scripts/verify-all.js` 均已通过。
- **风险**: 当前已运行的 Cursor / Claude Code / Codex 会话可能仍继承旧环境变量或旧 hook，需要重启三端会话后完全生效。

[project: C:\Users\win\Desktop\program1-main] 2026-06-18 AI ????? MVP ???????
- **??**: ????????????? MVP ?????????????????????? AGENTS?README?????????????????????????????????
- **??**: `npm run verify` ??????????? 13 ? react-refresh warning???? error?
- **??**: ???
[project: C:\Users\win\Desktop\Agent Platform] 2026-06-17 P0-3 个人智能体提交审核 → 同步运营平台
- **内容**: 在「我的空间」会话沉淀草稿增加「提交审核」按钮；点击后同步到 proto_ops_v11_agents，状态变为 submitted；UI 展示「已同步到运营平台」标签 + 跳转 05-agent-detail.html
- **文件**: user-personal-space.js（submitPersonalAgentToOps、renderSessionAgentDrafts 重构、事件绑定）
- **验证**: verify-all.js → VERIFY-ALL PASSED；node --check 通过
- **状态**: ✅ 完成

[project: C:\Users\win\Desktop\Agent Platform] 2026-06-17 敖钦 AI 用户端 Web 门户产品分析
- **内容**: 遍历 prototype/web端/ 全部 6 主页面 + 4 子页面 + 20+ 共享 JS 模块，产出完整产品分析报告
- **产出**: 计划文件记录优劣势分析、流程闭环审计、用户端/运营端打通情况评估
- **关键决策**: 当前为概念验证原型；反馈闭环仅关键节点通知；个人智能体先同步到运营平台创建
- **状态**: ✅ 完成（纯分析，无需代码变更）

## [TASK-G001] Global AI workspace bootstrap

- **Date**: 2026-06-01
- **Project**: Agent Platform
- **Type**: infra
- **Summary**: Established `~/.ai-workspace/memory/` for cross-project PDCA; hooks inject global memory paths; ai-coding-ok reads global first, project overlay optional.
- **Verified**: install-global-workspace.ps1 + SessionStart smoke


## [2026-06-17] Agent Platform - CC Switch model sync + PRD task-history cleanup
[project: Agent Platform]
- CC Switch: ANTHROPIC_MODEL updated to deepseek-v4-pro
- task-history.md: cleaned 541 junk lines from compression, fixed TASK-078 metadata

## [2026-06-18] program1-main — AI 项目复盘规则三端沉淀
[project: program1-main]
- 精炼 `参考资料/AI项目复盘 (1)(2).md` → `~/.ai-workspace/memory/ai-project-retrospective-rules-zh.md`
- Cursor always-on: `ai-delivery-anti-patterns.mdc`（模糊输入必问、四选一主改动类型、禁止跨层混改）
- 全局：`~/.claude/AGENTS.md` § Anti-Patterns、`user-memory.md`、`global-decisions-log.md` ADR-G004
- 项目：`.github/agent/memory/{project-memory,RULES,decisions-log}.md` + 根 `AGENTS.md` 澄清门禁
- Verified: `verify-tri-end-config.ps1` PASS

[project: cross-project] 2026-06-22 Global agent master SSOT + tri-end shim refactor
- **内容**: Added global-agent-master.md as the shared behavior SSOT for question gating, R2T,按需 skills/tools, and rework classification.
- **变更**: Simplified ~/.claude/AGENTS.md, ~/.codex/AGENTS.md, and Cursor always-on rules to thin references that point to the master.
- **验证**: Local file review only; no code/runtime verification required.

[project: C:\Users\win\Desktop\海小南] 2026-06-29 海小南 Demo 交互能力增强
- **内容**: 修复 `hai-xiaonan-demo.html` 配置区脚本损坏与重复定义，重建 12 个智能体注册/语音意图映射，补齐语音与快捷语句共用的意图执行链，加入实体提取与工具自动开关，并保留透明数字人桌宠与任务工作台演示。
- **验证**: `node --check __demo-check.js` 语法通过；`http://localhost:8000/hai-xiaonan-demo.html` 返回 200。
- **风险**: 尚未在真实浏览器里人工逐条走完麦克风权限允许/拒绝/不支持三条路径；Web Speech API 现场表现仍受浏览器与环境噪音影响。

[project: C:/Users/win/Desktop/海小南] 2026-06-29 海小南 Demo 交互收口与话术维护
- **内容**: 统一了 V2 场景源，派生问答库、脚本库和 6 条重点快捷入口；简单问答改为数字人先播报并气泡流式出字；复杂任务继续直达档案归档、合同交底和指标页；清理用户侧的状态提示，并新增演示话术维护文档。
- **验证**: 最后一个内联脚本已通过语法解析；现行 V2 片段已清理目标文案；维护文档中的 6 条重点场景提示词齐全。
- **风险**: 尚未在真实浏览器里完整跑通麦克风授权、TTS、双击持续收听和全部 modal 操作步骤，现场仍建议再做一轮手动冒烟。

## 2026-07-03 敖钦项目 PPT V0.3 救火重做
- 基于原始需求、项目开发文档和参考模板，生成 `敖钦项目启动汇报-第2-5部分-V0.3.pptx`、大纲和自检报告。
- 采用图片、表格、流程图、矩阵图、架构图为主的 16 页蓝白企业汇报风格。
- 已做结构校验、关键口径检索、非敖钦词混入检查，并通过 PowerPoint 后台导出 16 张 PNG 预览。

## 2026-07-03 敖钦项目 PPT V0.4 高密度重做
- 根据用户反馈，V0.3 过空、排版弱、信息量不足；新增 `敖钦项目启动汇报-第2-5部分-V0.4.pptx`。
- V0.4 对齐参考模板的高信息密度：蓝色表头、密集表格、红色重点、真实截图、流程矩阵。
- 已导出 16 页 PNG 预览并生成 `tools/ppt_v04_preview/contact_sheet.jpg`；关键口径和非业务词检查通过。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-03 敖钦项目 PPT V0.5 扩页优化
- **内容**: 基于 V0.4 新增 V0.5 PPT，扩展为 22 页，补充储量/产量流程、页面 IA、验收边界、总体架构、数据流、AI 调用链路、实施路线和风险待确认矩阵；字体统一为 微软雅黑，业务文字最小 9pt。
- **产出**: tools/ppt_v05_build.py、V0.5 PPT、大纲、自检报告、tools/ppt_v05_preview/contact_sheet.jpg 和 22 张 PNG 预览。
- **验证**: 脚本 py_compile 通过；PPT 结构校验 22 页 / 8 个媒体；字体抽取仅 微软雅黑，无宋体/Times New Roman；关键口径无缺失；PowerPoint 后台导出 PNG 预览成功。
- **风险**: 最终投屏观感仍建议用户用 PowerPoint 人工快扫；项目周期和功能拆分冲突继续按 [待确认] 表达。
[project: C:\Users\win\Desktop\AI--main] 2026-07-03 Phase 1a/1b/1d/1e grounding implementation
- **内容**: Restored `services/data`, fixed ignore/runtime artifact handling, moved LLM deps to optional extra, replaced carry hardcoded metrics with real net metrics/cost breakdown, added SignalEnsemble/MetaLabel service/API, and added MACD + Dow technical signal modules. WorldQuant alpha semantics intentionally deferred per user instruction.
- **验证**: `py -3 -m pip install -e ".[dev]"` passed; import smoke passed; targeted Phase 1 tests `14 passed`; full `py -3 -m pytest -q` `31 passed`.
- **风险**: Docker compose config not verified because Docker is not on PATH; no commits possible because the folder is not a Git repository.

[project: C:\Users\win\Desktop\AI--main] 2026-07-03 Paper trading console + market APIs
- **内容**: Added market snapshot/OHLCV APIs, console overview aggregation, Paper status/RiskEvent acknowledgement controls, and rebuilt `frontend/admin` as a Paper-first trading console with Kline chart, carry metrics, orders, positions, risk feed, and manual controls.
- **验证**: `py -3 -m pytest -q` -> 35 passed; `npm --workspace frontend/admin run build` passed; Playwright desktop/mobile smoke passed after fixing chart resize overflow.
- **风险**: Browser smoke used frontend-only dev server, so API failure state was expected; real Binance WebSocket ingestion/account sync/live order execution remain future work.

[project: C:\Users\win\Desktop\AI--main] 2026-07-03 Binance Data Layer first-tranche ingestion
- **内容**: Implemented Binance public market-data ingestion for the Paper console: idempotent `ohlcv_bars` / `market_extras` writes, CCXT OHLCV/funding backfill services, Binance WS closed-Kline/funding payload handlers, ingestion task execution for `binance_ohlcv_backfill` and `binance_funding_backfill`, live collector seam, Vite `/api` proxy, and status/memory docs.
- **验证**: `py -3 -m pip install -e ".[dev]"` passed; targeted Data Layer tests `11 passed`; changed-file Ruff check passed; full `py -3 -m pytest -q` `41 passed`; `npm --workspace frontend/admin run build` passed.
- **风险**: No live Binance network smoke was run in this pass; scope intentionally excludes live trading, account sync, notifications, order book persistence, LLM veto, and frontend push.

[project: C:\Users\win\Desktop\AI--main] 2026-07-03 AI Quant remediation plan first pass
- **内容**: Repaired engineering baseline; added carry walk-forward/OOS/stress validation reports; added `/api/v1` system dependency health, exchange capabilities, and notification outbox APIs; made Makefile operational targets real or explicitly failing; made unknown Agent executors fail instead of falsely completing; synchronized stale status docs.
- **验证**: `py -3 -m pytest -q` 45 passed / 1 skipped; Ruff check passed; Ruff format check passed; mypy passed; `npm --workspace frontend/admin run build` passed.
- **风险**: Docker compose config not verified because Docker is not on PATH; GitHub publish depends on network/auth because local folder is not a Git repo.

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-03 PPT 生成工作流 Skill 沉淀
- **内容**: 基于 3 个历史 Codex PPT 生成/返工会话，沉淀全局 skill ppt-generate（显示标题 ppt生成），覆盖模板识别、版本保护、字号/标题/表格/流程图/架构图、PNG 逐页视觉验收和交付物规范。
- **安装**: 已同步到 ~/.codex/skills/ppt-generate/、~/.cursor/skills/ppt-generate/、~/.claude/skills/ppt-generate/。
- **验证**: 三端 quick_validate.py 均通过；已运行 scan-global-skills.ps1，global-skills-index.md 可检索 ppt-generate。
[project: C:\Users\win\Desktop\AI--main] 2026-07-03 Open-source strategy library intake + Paper order stepping
- **内容**: Added E-level open-source strategy research intake for Freqtrade/Jesse/Hummingbot/Lean/vn.py/ABU/Superalgos/TradingAgents/Qbot/Vibe-Trading/daily_stock_analysis plus candidates; added `StrategySourceManifest`, research-source APIs, Agent tasks, deterministic StrategyIdea/Draft extraction, and PaperRun step order generation through gatekeeper.
- **验证**: `py -3 -m pytest -q` 52 passed / 1 skipped; `py -3 -m ruff check .` passed; `py -3 -m mypy` passed; `npm --workspace frontend/admin run build` passed.
- **风险**: External project runtime code is intentionally not imported; GPL/AGPL sources are research references only; live framework integration, remote cloning, vector DB RAG, and live grid/market-making are future scoped tasks.

[project: C:\Users\win\Desktop\Agent Platform] 2026-07-06 敖钦 AI 中台总体建设方案优化版
- **内容**: 生成 `docs/敖钦AI中台总体建设方案_优化版.docx`，保留原文件；新增两张高清全局图 `aoqin_ai_midplatform_overview.png`、`aoqin_ai_midplatform_flow.png`，将文档主线调整为用户端、智能体开发、运营治理、知识/模型/资源/系统底座的全平台闭环。
- **验证**: 生成脚本自检通过；Word COM 只读打开并导出 PDF 成功，优化版为 7 页、7 张表、2 张嵌入图；检查未包含账号密码和线上测试智能体名称。
- **风险**: 自动验证确认文件可打开和图文完整；最终投屏/打印效果仍建议人工快扫。

[project: C:\Users\win\Desktop\AI--main] 2026-07-06 7x24 Paper decision pipeline automation
- **内容**: Implemented Binance-only/Paper-only 7x24 automation: Celery Beat schedules, idempotent Paper runtime cycles, DecisionPipeline connecting technical/price-action signals + SignalEnsemble + MetaLabel + Decision Veto Agent, ATR/strategy-rule stops, news/macro/social ingestion seams, data heartbeat RiskEvents, frontend Decision Pipeline debug panel, and Vitest component coverage.
- **验证**: `py -3 -m pytest -q` 120 passed / 1 skipped; Ruff passed; mypy passed; admin Vitest passed; admin build passed; compose validation skipped because Docker is not on PATH.
- **风险**: `npm install --workspace frontend/admin` reported 5 frontend dependency audit vulnerabilities; no forced audit fix was run. Real RSS/Twitter/LLM runtime depends on operator credentials/network.

[project: C:\Users\win\.ai-workspace\ai-coding-os] 2026-07-06 AI Coding OS 三端产品/UI 工作流底座
- **内容**: 在 `C:\Users\win\.ai-workspace\ai-coding-os` 建立 AIOS 唯一源，新增 12 步产品/UI/架构/Review 工作流、产品与 UI 规范、Review System、三端入口 shim、`ai-product-ui-workflow` skill，以及 `install-aios.ps1` / `sync-aios.ps1` / `verify-aios.ps1`。
- **安装**: 已将 AIOS 管理块追加到 `~/.codex/AGENTS.md`、`~/.claude/AGENTS.md`，新增 `~/.cursor/rules/ai-coding-os.mdc`，并以 junction 同步到 `~/.cursor/skills/ai-product-ui-workflow`、`~/.claude/skills/ai-product-ui-workflow`、`~/.codex/skills/ai-product-ui-workflow`。
- **验证**: `installer/verify-aios.ps1` PASS；`scan-global-skills.ps1` 扫描 406 skills，`global-skills-index.md` / `global-skills-index-zh.md` 已包含 `ai-product-ui-workflow` 与中文触发词；`verify-tri-end-config.ps1` PASS。
- **风险**: 第一版只覆盖 Codex/Cursor/Claude Code，不做 Gemini/OpenCode；内容为核心闭环版，后续真实项目中可继续沉淀 examples、design tokens 和更细模板。

[project: C:\Users\win\Desktop\skills] 2026-07-06 三端 Agent Workspace 全局同步与 skill 盘点
- **内容**: 盘点 Codex / Claude Code / Cursor / `.agents` skills，共 880 个入口；发现 280 组完全重复内容，输出 `docs/reports/agent-workspace-stocktake.{md,json}` 与 `skills-inventory.csv`。升级 `scripts/export-from-local.ps1` 和 `install.ps1`，同步三端 skills、commands、rules、hooks、MCP、AIOS、全局 memory/scripts/templates、项目级 `.github/agent` memory 快照。
- **同步**: 提交并推送到 `git@github.com:Metroids048/skills.git`，commit `0496207 chore: sync tri-end agent workspace`；本地 `origin` 已切到 SSH，`origin/main` 验证到同一 commit。
- **验证**: skills 计数为 Cursor 280 / Claude 280 / Codex 312 / `.agents` 8；PowerShell 脚本语法检查通过；`git diff --check` 通过；高熵 token/API key/Bearer 扫描无真实命中；远端 HEAD 为 `0496207f25eedeb8ed9cbced09b03dc877a6700d`。
- **风险**: 当前只做完整快照与去重报告，没有实际删除/归档重复 skill；后续精简应按报告逐项确认后再改成单源 + shim/junction。

[project: C:\Users\win\Desktop\AI--main] 2026-07-06 Open-source RAG assetization
- **内容**: 将开源策略库摄取从登记摘要升级为真实本地 RAG 资产：新增 `ResearchSourceAsset`、GitHub allowlist fetch、清洗 Markdown 资产、`asset_manifest.json`、资产 API、Agent 资产计数字段，并让 `StrategyIdea` 提取依赖 `asset_refs`。
- **资产**: 已生成 Freqtrade/Jesse/Hummingbot/ABU/NautilusTrader/Qlib/vectorbt/OpenBB 的本地资产与 manifest；未知 license / metadata-only 源只进入 `research_note_only`。
- **验证**: `py -3 -m pytest -q` 124 passed / 1 skipped；Ruff、mypy、`npm --workspace frontend/admin run build` 全部通过。
- **风险**: 仍未做向量库/LlamaIndex 检索层、深度 LLM 研究报告、完整 repo 镜像、Docker runtime smoke、凭据化 24h 外部 API 验收。
