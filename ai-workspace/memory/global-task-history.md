
[project: global ~/.ai-workspace] 2026-07-30 成本与稳定性约束三端落地（ADR-G007）
- **内容**: 新增 SSOT cost-stability-constraints.md；Cursor alwaysApply cost-stability-constraints.mdc；写入 Claude/Codex AGENTS、CLAUDE.md、global-agent-master、user-memory、global-session-core（skill+mdc）。
- **验证**: 11 个入口文件均命中 cost-stability / ADR-G007。
- **风险**: 规则靠 alwaysApply/AGENTS 提示，已开会话需新开后完全生效；阶段提交与个别项目「未要求不提交」冲突时以本约束为准（用户说不要提交可跳过）。

[project: global ~/.ai-workspace] 2026-07-17 Windows/Codex failure triage + global install once (ADR-G006)
- **内容**: 梳理 L1/L2/L3 失败目录；新增 windows-failure-triage.mdc；全局 venv 一次装齐 Office+agent tooling；resolve-test-runner.py；更新三端 AGENTS/CODEX-WINDOWS-SHELL/AGENT-GLOBAL-STACK/audit/repair；补 Claude settings 门禁字段。
- **验证**: install-global-agent-python.ps1 PASS；verify-global-agent-stack PASS（pytest 等 tooling true）；audit-windows-agent-env PASS。
- **风险**: 规则靠 alwaysApply 提示，新会话模型仍可能偶发违反；需靠 audit + 用户纠正强化。
# Global Task History
[project: C:\Users\win\Desktop\AI--main] 2026-07-22 Strategy liveness funnel and A-E shadow baseline
- **内容**: 接续部署耦合事故修复；补决策逐层漏斗、两笔手动交易只读尸检、A-E 影子候选消融；将小时自动化 24 重定向到当前任务。未改生产策略、风控、杠杆、仓位、止损止盈、成本或 net-edge。
- **验证**: Ruff 全绿；Mypy 151 文件全绿；新增回归 11 passed；Core 590 passed/3 skipped；全量仍仅 8 个 pandas-ta 可选依赖失败，591 passed/4 skipped。
- **结论/风险**: 排除资金/套利非方向决策后，7 日方向候选召回主要受 ensemble 影响（C 328 vs A 91），LLM 影响很小（B 95）；D/E 因历史 4h/下游证据缺口保留 unknown。尚无收益/回撤证据，禁止据此调整生产。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-17 V1.5.1 模板选择与多维表格补齐
- **内容**: 新增默认“演示全权限账户”，保留现有业务角色；原型模板目录改为 9 份原始工作簿的真实 Sheet 名/用途/主流程状态；储量和产量工作表支持模板与 Sheet 选择、维度筛选、VXE 多列排序及本地个人表头编辑；系统管理页补充完整权限矩阵。
- **验证**: `frontend-demo` `npm run verify` 通过（7 测试文件 / 27 用例、vue-tsc、Vite build）；`git diff --check -- frontend-demo` 通过；本地 Vite `http://127.0.0.1:1112/` 返回 HTTP 200。
- **风险**: 原型不解析/回写真实 Excel，模板字段为多维字段组与关键原表字段的结构化映射；完整 307/292 列字典、正式公式、共享表头发布和正式权限仍待业务确认。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-14 原始需求深覆盖原型续建
- **内容**: 将 A4、B3–B5、C2–C3 从静态展示升级为可交互本地 Mock 闭环：分级复核、规划任务状态流、剖面/排期联动、结构化问数与规律挖掘；规划任务嵌入既有工作表，未改左侧导航与路由。
- **验证**: `frontend-demo` `npm run verify` 通过（Vitest 4 文件 / 17 用例、vue-tsc、Vite build）；本地服务 `/login` 返回 HTTP 200；编辑器诊断无新增问题。
- **风险**: Playwright MCP Bridge 连接超时，未完成自动化浏览器视觉走查；真实数据、算法、权限、审批、NL2SQL 与敖钦/海能 API 均未接入，相关口径继续待确认。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-14 智能助手右侧面板与入口文案改版
- **内容**: 全站 AI 入口统一为「智能助手」；右侧抽屉按 p3 骨架重做工具/Agent/模式切换；去掉「解释无解原因」等怪名；左侧导航未改。
- **验证**: `frontend-demo` `npm run build`（vue-tsc + vite）通过。
- **风险**: 未做真实浏览器截图验收；请硬刷新后打开顶栏「智能助手」核对布局。

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-13 方案B：成果中心并入版本对比
- **内容**: 移除产量「成果中心」菜单；B7 结果输出并入版本对比页；旧 `/planning/output` 重定向；同步讲解稿与 project-memory；此前已修侧栏叠层与智能辅助分模式样例回复。
- **验证**: `frontend-demo` `npm run build` 通过。
- **风险**: 未做浏览器截图验收；请硬刷新后确认侧栏不再叠字、版本对比页下半区有结果输出。

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-13 原型七项整改 V0.8
- **内容**: 全站命名收口为储量/规划工作表；数据接入补上传/拉取/筛选/日志；修复工作表 Sheet/检查器/聚焦栅格；版本对比按钮接侧栏与异常定位；敖钦侧栏按路由 Profile 差异化；洞察/成果/版本 BI 组合图与双轴。
- **验证**: `frontend-demo` 下 `npm run build`（vue-tsc + vite）两次通过。
- **风险**: 未做真实浏览器手测截图；Demo 仍不解析真实 Excel、不接正式接口/敖钦 API。

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
[project: C:\Users\win\Desktop\AI--main] 2026-07-10 TASK-041 adversarial-audit remediation
- **内容**: 基于全局对抗性审查修复本地空库启动、交易网关权限/幂等/最小名义金额、CCXT 外部日志、前端 API 不可达状态与运维页刷新契约；补齐 SQLite schema、网关、前端组件/API 客户端回归。
- **验证**: 隔离 SQLite 迁移 + FastAPI `/health` 返回 200；`py -3 -m pytest -q` 为 205 passed/1 skipped；Ruff、admin Vitest（17 tests）、Vite build、diff check 通过；浏览器正常态与 API 断开态复验完成。
- **风险**: Docker 不在 PATH；全仓 Mypy 仍有 68 个错误（23 文件），未宣称类型门禁通过；操作方仍需轮换前序 Testnet API Key。

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
[project: C:\Users\win\Desktop\AI--main] 2026-07-07 TASK-030 security closure and third-party frontend data wiring
- **内容**: 修复 TASK-029 遗留的 Python audit、Docker 双调度器、WS 重连状态不可见问题；升级 Vite/Vitest 前端审计链；把验证/复盘/研究/运维四个占位页改成真实 API 数据页；为 news/macro API 增加 `refresh=true` 第三方 read-through；产出 `docs/security/task-030-security-scan.{md,html}`。
- **验证**: `py -3 -m pytest -q` 149 passed / 1 skipped；Ruff lint、mypy、changed-file format check、admin Vitest、admin Vite 8 build、npm audit、project pip-audit 全部通过；compose validation 因 Docker 不在 PATH 按设计 skipped。
- **风险**: whole-machine pip-audit 仍报告非项目全局包 `litellm/nltk/torch`，未擅自升级或卸载；全仓格式检查仍有历史 drift，未做无关大面积格式化。

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

[project: C:\Users\win\Desktop\AI--main] 2026-07-10 Fixed Top20 Binance simulation-first auto-trading optimization
- **内容**: 固定自动交易候选池为 operator Top20，补 Binance `exchangeInfo` 状态/精度/最小名义金额映射，`PEPE` 映射 `1000PEPEUSDT`；全 20 币种维护自动 cycle 所需周期；默认自动策略改为成熟模板车道，`4h_direction_15m_entry` 降级为禁用研究策略；新增中等风险默认参数、typed auto-settings API、order-sync API、Binance Testnet/Demo 成功后才写本地订单/持仓/保护单的 simulation-first 同步；交易台新增自动开单设置、Top20 自动监控、消息源和订单同步面板。
- **验证**: 后端非集成测试 196 passed / 1 deselected / 1 warning；Ruff、mypy、admin Vitest 12 passed、admin build、git diff --check 通过；Playwright 打开 `http://127.0.0.1:5173/trading` 确认新增面板渲染且无 JS runtime crash。仅启动 Vite 时 API 代理 502 属预期。
- **风险**: Live/mainnet trading 仍关闭；未在本轮提交真实 Binance Testnet 订单；用户上传/提到的 `02_量化策略与LLM+RAG开平单逻辑详细报告.md` 保持未跟踪未修改。

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

[project: C:\Users\win\Desktop\AI--main] 2026-07-07 交易核心调度与实时行情接线
- **内容**: 新增 in-process Paper runtime scheduler、Binance WS `LiveFeedBus`、共享 `/ohlcv/stream` 广播、交易台自动引擎状态/限价单/止损止盈线、Risk/Strategy 平台入口、Postgres batch upsert、CI/dependabot 和 Binance-only 文档收口。
- **验证**: `py -3 -m pytest -q` 146 passed / 1 skipped；Ruff、mypy、admin Vitest、admin build 通过；compose validation 因本机无 Docker 按脚本 skipped。
- **风险**: 前端 npm audit 仍有既有 5 个漏洞，未强制升级；真实 Binance WS 长连需在有网络的运行态继续观察重连和 feed stale 指标。

[project: C:\Users\win\Desktop\program1-main-latest] 2026-07-07 AI/语音链路融合 V1
- **内容**: 接入 VAD 资源与 `@ricky0123/vad-react`，新增讯飞 RTASR WebSocket 骨架，前端语音适配层优先服务端 ASR、失败回退 Web Speech/文字输入；LLM provider 链调整为 OpenRouter free pool -> GitHub Models -> DeepSeek -> local fallback，并更新 env/docs。
- **验证**: `npm run verify` 通过；provider/server/app 窄测 79 passed；`npm run test:full-flow` 与 `npm run test:ai-success-smoke` 通过；真实 token 扫描无命中。
- **风险**: `npm run test:browser-flow` 业务步骤完成后在 Windows 临时目录清理阶段报 `EPERM`，已用接口链路和 AI smoke 兜底；用户在聊天中暴露过 OpenRouter/GitHub token，建议轮换。

[project: C:\Users\win\Desktop\program1-main-latest] 2026-07-07 JWT 空密钥与账户额度展示修复
- **内容**: 将 `JWT_SECRET=` / 空白值视为本地未配置并回退开发密钥，生产环境空密钥直接拒绝认证服务初始化；账户页额度顶部改为展示真实分项功能额度，不再显示旧“兼容总额度”。
- **验证**: `npm run test:server` 45 passed；账户页组件测试 1 passed；`npm run verify` 通过（19 files / 130 tests）；`npm run test:full-flow` 与 `npm run test:ai-success-smoke` 通过。
- **风险**: `npm run test:browser-flow` 仍在 Windows 临时浏览器 profile 清理阶段报 `EPERM`；截图工件已恢复，未接真实邮件/监控/真流式。

[project: C:\Users\win\Desktop\AI--main] 2026-07-07 TASK-030 安全收口与第三方数据接线
- **内容**: 完成 pytest/Vite/Vitest 等安全依赖升级，保留 pip-audit/npm audit 硬失败；Docker paper/live 显式切到 Celery scheduler 并加入 compose 校验；Binance WS 重连异常写入 LiveFeedBus；Validation/Review/Research/Ops 前端入口从占位页改为读取真实 API，新闻/宏观接口支持第三方 read-through refresh。
- **验证**: `py -3 -m pytest -q` 149 passed / 1 skipped；Ruff check、mypy、admin Vitest、admin build、项目级 `pip_audit .`、`npm audit --audit-level=high`、changed-file Ruff format 与 `git diff --check` 均通过；安全报告写入 `docs/security/task-030-security-scan.{md,html}`。
- **风险**: Docker 不在 PATH，`scripts/compose_validate.py` 本地按预期 skipped；全仓 `ruff format --check .` 仍有 29 个历史格式漂移文件，本轮未做无关批量格式化；整机 pip-audit 的 litellm/nltk/torch 属非项目全局包，未越权处理。
[project: C:\Users\win\Desktop\AI--main] 2026-07-08 Protective exits + free LLM fallback + Binance Testnet mirror
- **内容**: 按用户粘贴方案落地 PaperRuntimeService 止损/止盈自动平仓、`trail_after_r` 移动止损、显式 `mirror_to_gateway` Testnet 镜像开关、OpenRouter/GitHub Models 免费模型 fallback 链，以及前端 Testnet 镜像控制。
- **验证**: `py -3 -m pytest -q` 162 passed / 1 skipped；Ruff、changed-file Ruff format、mypy、admin Vitest、admin build、npm audit、pip-audit、`git diff --check` 通过；compose validation 因 Docker 不在 PATH 按预期 skipped。
- **风险**: 私有 Binance Testnet 真实界面订单验证需要用户本地 `.env` 凭据和运行态开启 `mirror_to_gateway=true`；本轮未回显或写入任何密钥到 tracked 文件。
[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-09 前端原型表格任务闭环重构
- **内容**: 按已确认计划重构 frontend-demo 静态原型：新增表格任务/工作簿/Sheet/单元格规则/公式/版本包/成果包 mock；首页改为任务与表格驾驶舱；产量规划、储量分析、智能助手、系统管理围绕工作簿、版本、成果和 AI 留痕闭环优化。
- **验证**: `npm run build` 通过两轮；`git diff --check` 无输出；本轮触及前端源文件尾随空白检查通过；Vite dev 服务 `http://127.0.0.1:1111/` HTTP 200。
- **风险**: 项目当前大量文件未跟踪，`git diff --check` 不覆盖未跟踪文件；本轮未接真实后端、敖钦/海能 API、真实公式、权限和审批，相关规则继续保留 `[待确认]`。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-09 前端原型剩余模块收口与缺陷修复
- **内容**: 继续按表格任务主线收口 frontend-demo：历史生产分析补充进入采集工作簿的闭环入口；补强全局工作台响应式规则；修复产量/储量工作簿 VXE `show-overflow` 运行时错误和储量表格重复字段告警。
- **验证**: `npm run build` 通过；Playwright 登录后截图巡检首页、历史分析、产量工作簿、储量体检、智能助手、系统管理，并覆盖 1440/1024/768 关键视口；服务 `http://127.0.0.1:1111/` HTTP 200；触及文件尾随空白检查通过。
- **风险**: 当前仓库大量文件仍未跟踪，`git diff --check` 对未跟踪文件覆盖有限；原型仍为本地 Mock，不接真实后端、敖钦/海能、公式引擎、审批和权限矩阵，相关内容继续标 `[待确认]`。

[project: C:\Users\win\Desktop\海小南] 2026-07-09 海小南能力升级静态原型
- **内容**: 新建 `海小南能力升级原型` Vite React + TypeScript + Tailwind v4 静态原型，包含能力总览工作台、资源注册中心、智能路由演示、OA 内嵌数字人和方案说明/设计文档面板；复用本地数字人、业务域图标等素材，实现请假制度、预算问数、档案归档、合同交底、页面直达、OA 用车草稿、无权限阻断等演示链路。
- **验证**: `npm run typecheck` 通过；`npm run build` 通过；Vite dev 服务 `http://127.0.0.1:3000/` HTTP 200；Playwright 验收 1440/1024/768/390 视口，预算 94.3%/指标口径、档案归档取消与确认、OA 内嵌、无权限阻断、资源注册与设计文档面板均通过，控制台无新增 error。
- **风险**: 原型仅为静态前端，不接真实海能/OA/BMS/ASR/TTS/权限审计接口；`npm install` 报 2 个依赖审计问题，未使用 `npm audit fix --force` 做破坏性升级；真实接口协议、权限码、资源负责人和上线状态仍待产品/技术确认。
[project: cross-project] 2026-07-09 Codex Windows shell/Python minimal repair
- **内容**: Restored Codex Windows shell_path to PS7 while preserving sandbox=elevated; updated RTK guidance to native-exe-only; cleaned Claude Windows shell rules; fixed Claude settings env/hooks drift; updated 
epair-codex-config.ps1 to preserve sandbox on future repairs.
- **验证**: erify-global-agent-stack.ps1 PASS; udit-windows-agent-env.ps1 PASS; erify-codex-config-toml.py PASS; PS7 7.6.3, gent-python, 
g, 
ode, 
pm, and 
tk verified.
- **风险**: Current Codex session may still use the old shell until Codex Desktop is fully quit and restarted; post-restart $PSVersionTable.PSVersion should show 7.x.
[project: C:\Users\win\Desktop\AI--main] 2026-07-09 Technical strategy hardening + Strategy Library RAG
- **内容**: 继续量化策略完整化收口：技术通道移除无信号K线fallback，加入4h方向+15m入场、RSI/EMA/ADX/VWAP/Bollinger/假突破等规则信号；Binance auto execute 改为交易所先成交、失败本地拒绝；RAG优先读取 `策略库/*.md`，ABU按GPL-3.0研究蒸馏处理。
- **验证**: 后端非集成测试 184 passed / 1 deselected / 1 warning；changed-file Ruff、mypy、admin Vitest 12 passed、admin build、git diff --check 通过。
- **风险**: 未在本轮提交真实 Binance Testnet 订单；全仓 Ruff 仍有33个既有无关风格问题；不声明盈利性，仍需回测/OOS/模拟盘验证。
[project: C:\Users\win\Desktop\AI--main] 2026-07-09 Real Binance Testnet open/close smoke + quality baseline closure
- **内容**: 执行真实 Binance Futures Testnet BTCUSDT 开平仓验证：BUY `20356862614` 开 `0.001` BTC，SELL reduce-only `20356874963` 平 `0.001` BTC，并用 SELL reduce-only `20356888777` 清理既有 `0.0001` BTC 残留；最终 Testnet 持仓为 0。修复网关私有接口时间校准和 close-only 反向下单逻辑。
- **验证**: Binance recent orders 可见三笔 FILLED 订单；最终账户探测 `open_position_count=0`；后端非集成测试 185 passed / 1 deselected / 1 warning；Ruff 全仓、mypy、admin Vitest、admin build、npm audit、项目 pip-audit、git diff --check 均通过。
- **风险**: Docker compose smoke 因本机 docker 不在 PATH 仍只能 skipped；本轮验证交易连通与安全开平，不证明策略盈利性。
[project: C:\Users\win\Desktop\yinpinjianting] 2026-07-10 AI 面试监听提词工具拆分落地
- **内容**: 从 `program1-main-latest` 复制拆出新工具目录 `yinpinjianting`，保留后端 AI/RAG/ASR/audio-bridge 能力，前端收口为监听提词台与资料库两页；新增简化工作区体验、浏览器音频入口、系统音频桥配对入口、提词卡改写和轻量简历优化。补齐 VAD/ONNX 运行时模块资源，默认 cue-card 实时预算 7.5 秒，慢模型明确 fallback。
- **验证**: `npm run verify` 通过（21 files / 128 tests + build）；`npm run test:browser-flow` 通过并产出桌面/移动截图；`npm run test:server` 54 passed；`npm run test:full-flow` 通过；`npm run test:ai-success-smoke` 在线模型三链路 success；`npm run test:perf` 通过，cue-card P95 7520ms、resume-ai P95 4661ms。
- **风险**: 系统音频桥只完成配对 UI/API 自动化烟测，真实腾讯会议/飞书桌面音频桥接未接入本机桥程序验证；新目录无 Git 仓库，运行时生成 `.data` 本地库。
[project: C:\Users\win\Desktop\yinpinjianting] 2026-07-10 系统音频桥闭环诊断版
- **内容**: 修复 Windows 音频桥默认后端端口为 `8897`，新增 `--server` / `--reset` 和环境变量覆盖；桥程序每秒上报系统音频 rms/peak/bytes；后端新增 `ASR_PROVIDER=debug` 诊断转写模式、桥连接/ASR ready/音频流诊断事件和 SSE 自动重连；监听台显示“桥连接、ASR、系统音频”三段状态与诊断文案。
- **验证**: `npm run verify` 通过（21 files / 129 tests + build）；`npm run test:server` 55 passed；`npm run test:browser-flow` 通过，覆盖模拟桥 WebSocket + debug ASR final 文本进入页面；默认服务 `http://127.0.0.1:5273/` 与后端健康检查 200。
- **风险**: 本机无 .NET SDK，未能编译/启动真实 `audio-bridge` 程序；真实腾讯会议/飞书会议音频 + 真实讯飞 RTASR 转写仍未实机验证，不能声明主流程 C 完全完成。

[project: C:\Users\win\Desktop\yinpinjianting] 2026-07-17 关键链路缺口收口并同步 main
- **内容**: 修复会话过期、中文 JD 公司解析、简历 fallback 重复标点与 fallback 误导；补账号/找回入口、语音兼容提示、模型提供商诊断与浏览器验收；工具入口隐藏无关协议链接。
- **验证**: `npm run verify`（136 tests）、`npm run test:browser-flow`、`npm run test:ai-success-smoke`、`npm run test:perf`、`npm run test:full-flow` 均通过；已推送 GitHub `main` 提交 `2103d391608c8e84b2527e822463d33c1364256a`。
- **风险**: 真实会议桌面音频桥接仍需实机验证；本机遗留 Git 网络子进程与索引锁导致本地 HEAD 尚未刷新，但源码和远端 main 已一致。
[project: cross-project] 2026-07-10 Codex GPT-5.6 Terra model picker收尾
- **内容**: 检查 Codex Store 版 `26.707.3748.0` 与既有补丁副本；确认 `model-list-filter-C2SM1X_9.js` 已从旧白名单过滤改为显示 `hidden=false` 公开模型；将 `~/.codex/config.toml` 从 `gpt-5.5/medium` 改为 `model_provider="custom"`、`model="gpt-5.6-terra"`、`model_reasoning_effort="max"`、`disable_response_storage=true`，保留 config 备份；更新桌面 `Codex 5.6.lnk` 指向补丁副本并带专属 user-data-dir，避免原版单例接管。
- **验证**: 补丁旧逻辑计数 0、新逻辑计数 1，`node --check` 通过；bundle 中存在 `gpt-5.6-sol` / `gpt-5.6-terra`；快捷方式目标为 patched-copies；临时 9222 调试端口和补丁残留 node/ChatGPT 进程已清理。
- **风险**: CDP `/json/list` 在本机临时调试实例上未返回 targets，未完成菜单 DOM 自动验收；原版 Codex 仍在运行时无参数启动会被单例接管，需使用桌面 `Codex 5.6` 入口或先退出原版。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-10 表格工作台与会议纪要增补
- **内容**: 保留既有菜单，升级储量采集、规划采集和规划方案编制为模板工作簿体验；新增本地 `.xlsx` 模板识别式 Mock 导入、Sheet 切换、编辑/公式只读、校验定位、草稿/提交复核/退回修正/归档、检查器收起和聚焦模式。补齐会议纪要的线上记录、受控 AI 查询与版本引用、唯一标识候选和 10 月试运行待确认项，并同步主线文档与项目记忆。
- **验证**: `frontend-demo` 的 `npm run build` 通过；无界面浏览器验证原始产量 `.xlsx` 识别和导入批次、产量校验/提交/退回修正、1024 储量错误定位、1280 主表内部滚动和无页面横向溢出；浏览器控制台无错误/警告。
- **风险**: 原型不读取或上传业务 Excel 内容，不接真实公式、权限、审批、接口或敖钦/海能；正式模板、唯一标识、复核责任链、AI 数据范围和 10 月试运行范围仍为 `[待确认]`。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-10 原型页面收口与演示讲解稿重写
- **内容**: 按用户确认方案完成 P1-P8 收口：储量历史清洗与采集拆分；储量/规划分析、版本和成果页面改为主内容优先的筛选、图表、明细结构；规划采集与工作流编制职责拆分；Agent 工作台和系统管理配置工作台重写；页面内重复演示标识清理，仅登录与账户菜单说明本地样例数据。
- **文档**: 重写 `10-原型演示讲解稿_需求响应矩阵.md` 为角色、页面目的、演示动作、应看到的结果、下一步跳转路线；同步页面线框、详细方案与项目记忆。
- **验证**: `frontend-demo` 的 `npm run build` 通过；无界面浏览器覆盖登录、P1 两个不同入口、储量图表多选和类型切换、规划采集、Agent 发起任务、系统管理标签；1440/1280/1024 无整体横向溢出，控制台无错误/警告。
- **风险**: 静态原型仍未接入真实业务数据、正式公式、权限、审批、数据接口或敖钦/海能；构建仍提示 Ant Design Vue 与 ECharts 的既有大体积 chunk 警告。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-10 一键演示启动与讲解稿扩写
- **内容**: 新增根目录双击入口 `启动原型演示.cmd`，并增强 `frontend-demo/scripts/start-demo.ps1`：自动检查依赖、选取空闲端口、等待 HTTP 就绪后打开浏览器；存在 `backend/` 时只在识别到 Node 启动脚本后尝试启动。当前仓库没有后端工程，脚本明确只启动前端本地样例服务。
- **文档**: 讲解稿扩写为产品宏观定位、业务痛点、设计思路、角色赋能、启动说明和 18 个逐页功能演示说明。
- **验证**: PowerShell 7 语法解析通过；脚本实际启动进程 `50424`，`http://127.0.0.1:1111/` 返回 HTTP 200；`npm run build` 通过。
- **风险**: 真实后端路径、Java/其他服务启动命令和接口配置尚不存在，需项目组提供后才能纳入一键全服务启动。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-12 原型 IA 收口与工作台细节改造
- **内容**: 全站头部改为白色轻量形式并移除全局面包屑；导航收口为储量 4 项和产量 5 项，旧分级/图件/历史/排期路由兼容跳转；储量洞察合并指标、分级和图件并新增结论行动卡；产量基础数据、调整与排期、成果中心完成职责合并；两类工作簿新增 Sheet 导航独立收起；Agent 拆为知识、数据、规划工具、规律分析四种不同工作面；样例身份统一为张三、李四、王五、赵六。
- **文档**: 重写 `10-原型演示讲解稿_需求响应矩阵.md`，按新导航说明产品定位、演示路线、逐页动作、设计原因及需求响应；同步页面线框、UI 规范、功能映射与项目记忆。
- **验证**: `npm run build` 通过；无界面浏览器验证样例身份、白色顶部栏、4+5 导航、储量旧图件路由跳转、洞察结论区、工作簿默认收起两侧辅助区、Agent 数据模式；1024/1280 无页面横向溢出，控制台无错误或警告。
- **风险**: 仍为本地样例前端，不接真实数据、权限、审批、公式或 AI 服务；构建保留 Ant Design Vue 与 ECharts 大体积 chunk 警告。

[project: C:\Users\win\Desktop\敖钦储能项目] 2026-07-16 原型 V1.5 与主线文档 V0.4 校准
- **内容**: 建立 Git 基线；新增 9 份储量/产量正式模板的结构化目录、六类身份的菜单/动作/字段/数据范围 Mock、数据湖/业务源系统/Excel 补录的批次与质量管理、储量多维指标组、四类规划模板族、2025–2030 年规划列、`mock-monthly-v0.1` 年转月草案和共享表头配置入口。基础数据页移除重复的问数/规律工作区，主线文档 `README` 与 `00–10` 更新到 V0.4/V1.5。
- **验证**: `npm run verify` 通过（7 个测试文件、25 项测试、生产构建）；无界面 Chrome 检查 1440/1280/1024 宽度无整体横向溢出，油田负责人仅见本油田，未授权系统管理路由跳转 403，月度草案可见模型版本，控制台无异常。
- **风险**: 仍未连接真实数据湖/业务系统、Excel 解析、正式业务公式、OA/统一认证、审批、RAG 或敖钦/海能 API；正式模板字段、年转月模型、角色审批链和表头发布规则保持 `[待确认]`。

[project: C:\Users\win\Desktop\产能评价] 2026-07-16 功能清单合并整理
- **内容**: 将 `Project_Discovery/06_功能清单.md` 的总表和细化表合并为一张 33 项功能清单；合并重复或过细条目，仅保留编号、模块、功能项、优先级、状态、来源和备注。缺少公式、图版、接口、模板、权限矩阵或验收样本支撑的状态留空，并在备注中标明材料缺口。
- **验证**: 目标文件仅保留一个一级标题和一张 Markdown 表格；33 条功能行均为 7 列，结构检查通过。项目目录不是 Git 仓库，未执行 Git 差异检查。
- **风险**: 功能清单仍为 Draft；空白状态及备注中的材料缺口需在后续资料补齐或业务确认后更新。
[project: C:/Users/win/Desktop/alpha] 2026-07-20 Consultant-Grade Alpha Factory vNext
- **内容**: 在不接入 `run_pipeline_loop.py` 默认循环的前提下，新增独立领域层、动态 Gate Registry、流式 Legacy Knowledge Lake、两级相关性、受限 Consultant Generator、OFAT Settings Optimizer、Bandit、fail-closed Submission Guard/Queue 和分组 CLI；旧单体反向复用新表达式身份逻辑，PENDING Self Correlation 不再标记为提交候选。
- **数据验收**: 本地保存的 API payload 同步 129,841 observations / 30 snapshots；18,659 条逻辑历史记录导入为 13,325 canonical、18,630 lineage、8,739 clusters；RECHECK 477 / REPAIR 439 / SEED_ONLY 12,121 / ARCHIVE 288；submit dry-run 477 全部安全阻断且 endpoint_calls=0。
- **验证**: 全量 `445 passed, 5 subtests passed`；compileall 与包内无旧单体依赖静态检查通过；样例 SQLite 仅在临时副本上迁移，原文件 hash 未变。
- **风险**: 本地最新 Gate observation 为 2026-07-03，按 24h TTL 已过期；候选无足够 daily returns；明文 Cookie 因缺少 DPAPI state/验证参数未迁移，已加入忽略并需人工旋转；目录无 `.git`，未创建或声称 commits。
[project: C:/Users/win/Desktop/alpha] 2026-07-20 Consultant Alpha Factory vNext 独立审计与修复
- **内容**: 独立复核动态门槛、submission/queue、correlation、Legacy、Settings Optimizer、依赖、安全与 API；修复 fail-open checks、snapshot 执行期复核、动态质量复算、absolute/sign-flip correlation、SQLite triage 锁、simulation 持久化幂等、429/401/polling 边界、真实 API 测试隔离及 notebook 明文凭据。旧写入口被隔离，`alpha_mining` 不再依赖旧单体。
- **数据验收**: 68,951,109-byte CSV 流式导入得到 scanned=18,659、canonical=13,325、lineage=18,630、clusters=8,739；严格新鲜度下 ARCHIVE=288、SEED_ONLY=13,037、RECHECK=0；dry-run endpoint_calls=0、candidates=0。
- **验证**: 最终全量 `467 passed, 5 subtests passed`；Ruff、Mypy（alpha_mining）及 compileall 全部通过；审计报告为 `CONSULTANT_ALPHA_VNEXT_REVIEW.md`。
- **风险**: fresh gate snapshots(24h)=0，缺 SELF/PRODUCTION correlation gate evidence，故未达到 shadow-run；目录无 `.git`，不能证明历史 commit 从未含敏感信息。

[project: C:/Users/win/Desktop/alpha] 2026-07-20 Consultant Alpha Factory 第一次 Shadow Run（fail-closed）
- **内容**: 按用户顺序执行 Gate sync/show、Legacy import/triage/report、correlation refresh、Consultant shadow-run 和 submit dry-run；指定 Shadow Run 参数被现有 CLI 拒绝，未冒充成功。生成 `shadow_run_summary.json`、5 份 Shadow Run CSV 与 `CONSULTANT_ALPHA_SHADOW_RUN.md`，记录零候选和完整运行级 blocker。
- **数据验收**: snapshots=30、fresh(24h)=0；历史 Alpha=18,630、唯一表达式=13,325、clusters=8,739；RECHECK=0 / REPAIR=0 / SEED_ONLY=13,037 / ARCHIVE=288；return series=0、simulations=0、final candidates=0、endpoint_calls=0。
- **验证**: 7 个要求产物均存在；candidates=0、blocked run reasons=4、family rows=41、settings rows=1、cluster rows=8,739；summary JSON 可解析，报告逐项覆盖要求，敏感凭据模式扫描无命中；`generate_shadow_run_failure_report.py` py_compile 通过。
- **风险**: `gates sync` 仅从本地 `总alpha.csv` 更新，不是 live platform refresh；最新 snapshot 为 2026-07-03，且缺 SELF/PROD correlation gate；Shadow Run 五个强制 CLI 参数尚未实现，因此本次在 seed 选择前受控阻断，不建议扩大预算。

[project: C:/Users/win/Desktop/alpha] 2026-07-22 平台接入恢复与最小 Pilot 门禁
- **内容**: 新增跨进程 `worldquant_api.lock`、持久化全局 429 Circuit Breaker、脱敏 `platform_request_events`、认证年龄/401/403/429 状态、三读取 Connectivity Probe、Ledger 报告与分层最小 Pilot 预算函数；旧明文 Cookie 缓存已删除，提交硬停保持开启。
- **证据**: 本机未发现匹配 supervisor/loop/cycle 进程，Docker 未安装，systemd/cron 不适用；历史日志约 7,691 条 429，确认旧重试路径存在请求放大。设备 process/user/machine 环境和工作区均无真实 WQ 凭据，仅有 `.env.example`，因此 Probe 在认证前停止，平台网络事件 0、Ledger 0、Pilot/PATCH/Submit 调用 0。
- **验证**: `531 passed, 5 subtests passed`；compileall、SQLite integrity_check、迁移 v1-v7、git diff --check、敏感信息扫描通过；业务状态保持 BLOCKED。
- **风险**: 用户提供的密码文本呈省略/脱敏形式，未用于认证；多机器共享账号活动无法由当前主机排除。需用户通过本地环境设置完整凭据或建立新鲜合法会话后，才能继续唯一读取探针与最小日期分片。
# [AI Quant Research Platform] 2026-07-22 deployment-coupled trading incident

- Determined that dense July 21 BTC/ETH Simulation round trips were Agent-triggered Testnet acceptance traffic, while most non-order periods still contained live decisions blocked by strategy/ensemble/LLM filters.
- Implemented explicit acceptance authorization, DB scheduler leadership and unique slots, no-immediate-start Paper scheduling, candle-intent order uniqueness, and full order provenance without changing any trading-risk threshold.
- Restarted the local Paper engine with mainnet disabled. Accelerated 24-hour two-instance verification passed 96/96 slots with zero duplicate winners; a separate hourly read-only wall-clock observation is active as Codex automation 24.

## [2026-07-22] agent-config-pack install — [project: C:/Users/win/Desktop/alpha]

- Installed Global Working Agreement into Codex/Claude AGENTS + Cursor alwaysApply rule
- Installed verify-work skill to ~/.agents, ~/.cursor, ~/.claude (+ alpha project copies)
- Expanded alpha AGENTS.md / CLAUDE.md / .cursor/rules / .claude agents+rules / docs templates
- Updated user-memory.md with 三端统一架构与长期记忆约定
- Cursor Settings → User Rules: paste from `~/.cursor/USER_RULES.txt` (UI cannot be written by Agent)

## [2026-07-22] agent-config-pack multi-project + Codex skill paths

- Clarified: Codex global was already installed; added `~/.codex/skills/verify-work` and multi-project note
- Installed project-layer pack into 7 Desktop/registry projects (AGENTS bridge only; no wholesale overwrite)
- Updated projects-registry.md

[project: C:\Users\win\Desktop\产能评价] 2026-07-29 四方向原型续作与桌面端收口
- **内容**: 恢复中断任务，将更新后的 `06_功能清单_4方向精简版.md` 设为唯一范围基线；新增 SRC-021、REQ-040～045、FUNC-034～038、PAGE-011、AC-019；原型新增 `/dynamics`、动态分析角色、7 个生产动态/报表展示页签、筛选与来源口径反馈及恢复状态。
- **用户纠正**: 项目仅面向 PC 桌面端，验收 1440/1280/1024；禁止主动做移动端。规则已写入项目 `AGENTS.md` 和项目知识库。
- **验证**: `npm run verify` PASS；4 单测、44 条追踪、6 Mermaid、12 E2E；工作台和生产动态 1440/1280/1024 无整体横向溢出；高风险秘密模式扫描无命中。
- **状态/风险**: 静态 Demo PASS，产品 Gate CONDITIONAL PASS；真实数据湖/动态宝、算法、权限、RAG、模板/调度/推送、采收率方法和生产发布仍未实现。中央同步 copied=7、unchanged=3、conflict=1，用户偏好摘要冲突已写待确认补丁。

[project: C:\Users\win\Desktop\全局配置] 2026-07-29 Codex 历史知识批量同步
- **内容**: 只读盘点 191 个 Codex rollout（116,063 行，2026-05-22～2026-07-29）；生成 8 份项目中央胶囊、8 份项目知识索引、全局胶囊、源盘点、待确认补丁、ADR-G007、跨项目经验和 10 条 PUBLIC_SAFE 选题。未导入 raw transcript，未改业务源码。
- **验证**: `知识中心.py 同步 --all` 退出 0；第二次 `--dry-run` copied=0；8 个项目胶囊源/镜像 SHA-256 一致；知识校验、冲突检查、隐私自测、19 文件逐项隐私扫描、跨项目经验 check-only、diff check 全部通过。
- **边界**: 合同审查无 Codex rollout；`program/program1-main/demo/demo1/alpha-codex-v50.4-pipeline-recovery/平台项目资料` 未登记或归属不明，只写待确认；每项目 1 个用户偏好摘要冲突未覆盖。

[project: C:\Users\win\Desktop\AI--main] 2026-07-30 BTC/ETH 策略内核重构 Gate 0/1
- **内容**: 完成当前树审计和 Golden Baseline 冻结器；独立复核后以 TDD 修正 `source_tree_hash` 漏扫 `docs/**` 及冻结后记忆漂移问题，运行行为未改。
- **结论**: `DATA_COVERAGE_INSUFFICIENT`。BTC/ETH 5m 为 0 bars，无法形成五周期共同 4h 截止点、42 个月覆盖或 180 天 Holdout；Task 2+ 按计划暂停。
- **验证**: Task 0/1 组合回归 95 passed；目标 Ruff/format/mypy 通过；独立 reviewer 无 Critical/Important/Minor；中央同步 copied=2、unchanged=10、conflict=1，冲突未覆盖。
[project: C:\Users\win\Desktop\AI--main] 2026-07-30 Automatic Trading V2 natural Testnet closure
- **内容**: 自然 Scheduler 完成 Binance Testnet Entry/Fill/Position/Protection/保护触发 Reduce-only Exit/本地 CLOSED/HEALTHY 对账；修复延迟 fill、algoId→actualOrderId、隔离投影精确闭合、incident resolution 与 LLM Runtime truth。
- **验证**: Binance/local positions `0/0`、open orders `0`、reconciliation `HEALTHY`；Ruff PASS；mypy 206 files PASS；pytest 1181 passed/16 skipped；frontend 65 passed；build PASS；浏览器 0 errors、Runtime 稳定约 10 秒轮询。
- **风险**: 历史 `PROTECTION_RECOVERY_FAILED` 仍有 1 条 OPEN；仅 Testnet，不证明盈利，不授权 Mainnet；下一阶段先做 strategy readiness。
[project: C:\Users\win\Desktop\产能评价] 2026-07-30 产品业务理解与系统审计第一阶段
- **内容**: 恢复中断线程的 Office/PDF 提取结果，交叉核对 7 份需求/伴随资料、14 份产品基线与 `prototype` 当前实现；新增 `docs/product-understanding-and-audit/00-分析进度与证据索引.md`、`01-产品全景与业务理解.md`，明确客户事实、合理推断、缺失资产和纯前端 Mock 边界。未修改原型代码。
- **验证**: 新增 4 个 Mermaid 图在本地 Chrome 解析通过；资料/代码数量与必备章节断言 PASS；`rtk npm run verify` 退出 0（lint、typecheck、4 单测、build、44 条追踪、6 个既有 Mermaid、12 个 E2E）。
- **风险**: 第一阶段完成不代表项目生产就绪；Excel/图片模板、《2025 指南》、公式/图版/函数工具、数据湖/动态宝接口、权限矩阵、报告模板、RAG 授权语料和金标准仍缺失，产品 Gate 继续为 CONDITIONAL PASS。

[project: C:\Users\win\Desktop\AI--main] 2026-07-30 Strategy readiness 与运行态最终收口
- **内容**: 冻结并复验 `baseline-20260729-0000Z-r4`；BTC/ETH 五周期 2023-01-01 至 2026-07-29 连续覆盖，1126 条 JSONL 全部有效，Final Holdout 未访问。恢复 API、RuntimeScheduler、前端与只读 watcher；自然 reconciliation 投影最新 ETH 保护成交。
- **验证**: r4 的 HEAD/source hash 1000/1000 匹配；portfolio Sharpe -0.109602、PF 0.988208、MaxDD 77.14%、net expectancy -0.000202，active strategy REJECTED；Ruff PASS、mypy 214 files PASS、pytest 1231 passed/16 skipped。Binance TP reduce-only order `15015635115` / trade `309278262` 后 position CLOSED、protection PROTECTION_FILLED；exchange/local/orders `0/0/0`、reconciliation HEALTHY，watcher 在线。
- **风险**: Strategy readiness 仅 PARTIAL，尚缺 next-bar parity、point-in-time costs、逐窗口 walk-forward 与 dependent bootstrap；独立复核发现生成器长 replay 源树竞态与 `generated_at` 语义两个非当前产物阻断的 provenance 风险；不证明盈利或 Mainnet 就绪。

[project: C:\Users\win\Desktop\AI--main] 2026-07-31 Strategy Phase 1 next-bar parity
- **内容**: Technical replay 改为 closed-bar signal 后使用 next-bar open/timestamp 成交；无后续 bar 不虚构成交；`end_at` 约束同时覆盖下一根成交和窗口内 end-of-window 强制收盘，防止 walk-forward/OOS 跨窗口泄漏。
- **验证**: RED 先复现两类边界失败；修复后 focused replay `14 passed`、相关 validation `21 passed`、全量 pytest `1238 passed, 16 skipped, 7 warnings`、Ruff PASS、mypy `215 source files` PASS、CURRENT_STATE 真实刷新为 `1238 passed, 0 failed`。
- **边界**: 未生成新 baseline，未读取 Final Holdout；`r4` 保留为 pre-parity 历史基线。Funding/spread/latency/partial-fill、input-hash parity、walk-forward ledger、dependent bootstrap 仍未完成；没有修改风险或晋级门槛。
