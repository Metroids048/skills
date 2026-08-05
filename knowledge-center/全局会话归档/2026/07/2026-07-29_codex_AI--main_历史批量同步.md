---
id: SESSION-20260729-CODEX-AI-MAIN
created_at: 2026-07-29T17:40:00+08:00
source_tool: codex
project: AI--main
status: PARTIAL
sensitivity: SENSITIVE
public_content_eligible: review_required
---

# Session Capsule

## 1. User goal

从 Codex 历史中回填自动量化交易项目的决策、根因、已验证修复和开放事项。

## 2. Inputs and context

- rollout：37 个；根会话 28；2026-07-03～2026-07-29。
- 重点会话：`019f69d7-c21b-7803-9161-f438aeca23c0`、`019f877d-69cf-72d2-a208-8993ea998544`、`019f9324-7748-7260-a548-7ce94c6635bc`。
- 交叉证据：项目 memory、`global-task-history.md`。

## 3. Actions performed

只提取最终回执；区分事故修复、调度活性与真实自然交易闭环。

## 4. Files changed

中央胶囊与项目 `项目知识库/` 条目；未改交易业务源码。

## 5. Commands and external actions

| Command / action | Exit status | Meaningful output |
|---|---:|---|
| `盘点Codex历史.py --extract-final <session ids>` | 0 | 读取脱敏最终回执 |

## 6. Verification evidence

- 拒单链路回归：后端 429 passed、前端 34 passed、构建通过。
- 部署耦合事故修复：Ruff、Mypy 通过；pytest 581 passed、8 个既有可选依赖失败；未冒充全量绿。
- 真实自然 Binance entry/exit：未完成；外部仓位/账户模式导致 fail-closed。

## 7. User feedback and corrections

不得把 Agent acceptance 往返单当成策略自然成交；不得调整风险阈值来换取开单。

## 8. Decisions made

| Decision | Reason | Rejected alternative | Impact |
|---|---|---|---|
| 验收流量必须显式授权并带 provenance | 防止验收单与策略单混淆 | 默认允许验收下单 | 可审计 |
| 外部仓位不认领、不平仓、不计入策略收益 | 避免越权与污染证据 | 系统自动清理 | 保持 fail-closed |

## 9. Errors and root causes

| Error | Evidence | Root cause | Status |
|---|---|---|---|
| 秒级开平被误认为策略高频 | 会话 019f877d | Agent acceptance traffic 与生产时间线混写 | CONFIRMED |
| 配置刷新后仍 universe reject | 会话 019f9324 | RuntimeScheduler 使用的 active ConfigSnapshot 未同步 | PROVEN_FIX |
| “不开单”缺少可解释性 | 会话 019f69d7 | 多阶段拒绝未形成统一漏斗 | PROVEN_FIX |

## 10. Proven fixes

显式 acceptance authorization、单写入者租约/唯一时槽、订单 provenance、重复订单幂等、决策漏斗。

## 11. Unresolved items

真实自然 entry 与自然 reduceOnly exit 的完整交易所回执和 SQLite/API 对账仍缺；状态保持 `PARTIAL/OPEN`。

## 12. Reusable lessons

“事故修复通过”“调度器健康”“自然交易闭环完成”是三种不同验收结论。

## 13. Candidate video content

验收单为什么会被误认成策略交易；没有开单究竟有多少类 blocker。

## 14. Proposed durable-memory updates

仅写项目知识与跨项目经验，不修改用户主知识库。

## 15. Conflicts / stale records

事故修复已验证，但后续真实闭环仍受外部条件阻断；不得将前者覆盖后者。

## 16. Sensitive items withheld

账户、订单号、API/认证信息、真实仓位细节、收益数据。

## 17. Next smallest action

使用干净 Testnet 条件完成只读自然 entry/exit 对账；未满足前保持 fail-closed。

