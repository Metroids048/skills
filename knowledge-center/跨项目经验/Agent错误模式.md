# Agent 错误模式

- 更新：2026-07-28T11:50:07
- 来源：`USER_KNOWLEDGE_BASE.md`、各 `项目镜像/*/错误与根因.md`、全局收口规则
- 规则：无独立测试证据不得标 VERIFIED；用户自述完成标 `USER_REPORTED`

## 1. 跨工具通用失败模式

- `[CONFIRMED]` 来源：UKB §1–§2 — Agent 声称完成但无独立测试证据 → 只能标 `USER_REPORTED`，不得写成 VERIFIED/COMPLETE。
- `[CONFIRMED]` 来源：UKB §2 收口模式 — 无限分析、范围膨胀、为「更优雅」而重构、模糊说「应该可以」。
- `[CONFIRMED]` 来源：UKB §2 — 用 TODO/mock/假成功掩盖未完成；未跑检查却写成通过。
- `[CONFIRMED]` 来源：全局 Windows 失败分层 — 把 L1 路径/编码/RTK 命令错误误报成「环境坏了」或 L3 项目失败。
- `[CONFIRMED]` 来源：最大权限规则 — 「最大权限」被误读成可删配置、清目录、跑破坏性清理。
- `[CONFIRMED]` 来源：知识中心复盘 — 系统脚手架 COMPLETE ≠ 内容层已填充；验收只查文件存在会导致占位漏检。
- `[CONFIRMED]` 来源：UKB §4.3 — Codex 长任务中途报错（namespace/rs id/stream disconnect/Transport）且 token 耗尽前未推送。
- `[CONFIRMED]` 来源：Agent Platform postmortem 2026-05-28 — smoke/e2e 全绿仍可能导航全红；根因含 `window.__*Wired` 早退与缺 navigation-journey。
- `[CONFIRMED]` 来源：ADR-G004 / program1-main — 未锁「本轮改哪一层」就改页面 → 返工循环。
- `[CONFIRMED]` 来源：ADR-G003 — 「最大权限」下擅自跑 `_remove-*` / 删 CC Switch。
- `[CONTENT_IDEA][PUBLIC_SAFE]` 为什么测试全绿页面还是坏？（导航旅程 / `__*Wired`）
- `[CONTENT_IDEA][PUBLIC_SAFE]` 「最大权限」差点删掉工具配置。
- `[CONTENT_IDEA][PUBLIC_SAFE]` Windows 上 Agent 总说环境坏了（L1/L2/L3）。

## 2. 按项目沉淀的确认问题

### Agent Platform

- 证据文件：`项目镜像/Agent Platform/错误与根因.md`
- - `[CONFIRMED]` 2026-05-28 导航链路失败：须 `verify-all` 含 navigation-journey；禁止 `__*Wired` 跳过绑定。
- - `[USER_REPORTED]` 已形成全局 User Rules、项目 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*.mdc`、`verify-work` Skill、独立只读 Reviewer、Hooks/CI/tests/permissions 体系。

### AI--main

- 证据文件：`项目镜像/AI--main/错误与根因.md`
- - `[CONFIRMED]` 长期不自动开单。
- - `[CONFIRMED]` 本地 paper 出现幽灵单。
- - `[CONFIRMED]` 前端多处占位符没有与后端和交易所实时数据打通。
- - `[CONFIRMED]` AI API 使用量曾为 0，说明 AI 分析链没有真正执行。
- - `[CONFIRMED]` 自动开仓曾在 `gateway.submit_order()` 前因缺少 `market_rules_snapshot` fail-closed。
- - `[CONFIRMED]` 自动平仓曾通过 `run_id + symbol` 错误继承历史 protection，出现 ETH 误平仓风险。
- - `[CONFIRMED]` “没有交易”曾无法区分无信号、市场状态不匹配、MetaLabel 拒绝、风险拒绝、AI 拒绝、数据过期或执行失败。
- - `[CONFIRMED]` 回放和实时执行存在价格、时间和成交语义偏差。
- - `[CONFIRMED]` 现有候选策略高度共享趋势、ADX 等信息，策略多样性不足。
- - `[CONFIRMED]` 固定 2R 退出忽视不同策略收益分布。
- - `[CONFIRMED]` 缺少市场结构、成交量、订单流和衍生品数据。

### 产能评价

- 证据文件：`项目镜像/产能评价/错误与根因.md`
- - `[CONFIRMED][SENSITIVE]` 工作/客户项目。
- - `[CONFIRMED]` 已进行前端原型 Demo 迭代。
- - `[CONFIRMED]` 客户曾反馈与原始需求、实际流程和内容仍有较大差距。
- - `[CONFIRMED]` 后续按 0724 需求与立项报告迭代。
- - `[USER_REPORTED]` 用户已完成一轮优化，下一步是测试审查验证。

### 合同审查

- 证据文件：`项目镜像/合同审查/错误与根因.md`
- - `[CONFIRMED][SENSITIVE]` 前期方案和报价沟通项目，已有 V0.3/V0.4。

### 敖钦储能项目

- 证据文件：`项目镜像/敖钦储能项目/错误与根因.md`
- - `[CONFIRMED][SENSITIVE]` 工作/客户项目。
- - `[CONFIRMED]` 已进行前端原型 Demo 迭代。
- - `[CONFIRMED]` 客户曾反馈与原始需求、实际流程和内容仍有较大差距。
- - `[CONFIRMED]` 后续按 0724 需求与立项报告迭代。
- - `[USER_REPORTED]` 用户已完成一轮优化，下一步是测试审查验证。

## 3. 防再犯检查清单

- 交付前：真实命令输出 + 验收映射；未跑项标「未验证」。
- 声称 COMPLETE 前：内容文件不得仍是整行空壳占位。
- Windows：先分 L1/L2/L3；路径用正斜杠；中文用 UTF-8；禁止 rtk 包 PS cmdlet。
- 资金/生产：fail-closed；禁止 Synthetic Fill 冒充真实成交。
- 敏感：密钥/Cookie/钱包/未脱敏客户资料永不入库原文。
