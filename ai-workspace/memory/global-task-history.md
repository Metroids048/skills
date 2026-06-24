# Global Task History

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---
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

