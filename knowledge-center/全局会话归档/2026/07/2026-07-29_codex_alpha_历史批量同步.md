---
id: SESSION-20260729-CODEX-ALPHA
created_at: 2026-07-29T17:40:00+08:00
source_tool: codex
project: alpha
status: BLOCKED
sensitivity: SENSITIVE
public_content_eligible: review_required
---

# Session Capsule

## 1. User goal

回填 Consultant Alpha Factory vNext、独立审计、Shadow Run 与平台恢复的真实状态。

## 2. Inputs and context

- rollout：16 个；根会话 9；2026-07-20～2026-07-24。
- 重点会话：`019f7e0f-e859-7ed1-9401-150789d7eb76`、`019f7e94-a896-7682-9192-b7fdbbcebb62`。

## 3. Actions performed

抽取 canonical/lineage/cluster、门禁新鲜度、dry-run 与真实平台调用边界。

## 4. Files changed

中央胶囊与项目知识文件；未改 Alpha 业务源码。

## 5. Commands and external actions

| Command / action | Exit status | Meaningful output |
|---|---:|---|
| `盘点Codex历史.py --extract-final <session ids>` | 0 | 读取脱敏最终回执 |

## 6. Verification evidence

- 审计：467 passed + 5 subtests；Ruff、Mypy、compileall 通过。
- dry-run：`endpoint_calls=0`。
- Shadow Run：新鲜 Gate=0，缺 SELF/PRODUCTION correlation；候选=0，未伪造成功。

## 7. User feedback and corrections

不允许用合成数据、补描述或扩大预算绕过 Base/Correlation/Gate 阻断。

## 8. Decisions made

| Decision | Reason | Rejected alternative | Impact |
|---|---|---|---|
| stale gate 直接阻断 Shadow Run | 缺少可验证平台证据 | 降低门槛继续生成 | fail-closed |
| dry-run 必须保持真实 endpoint 0 调用 | 防止误提交 | 试探性提交 | 可安全复现 |

## 9. Errors and root causes

| Error | Evidence | Root cause | Status |
|---|---|---|---|
| 大量表达式实质重复 | canonical/cluster 统计 | 表达式身份与 lineage 未统一 | PROVEN_FIX |
| Shadow Run 无候选 | fresh gate=0 | Gate 过期且缺相关性证据 | BLOCKED |
| 指定 CLI 参数被拒绝 | 会话 019f7e94 | CLI 合同未实现完整 Shadow Run | OPEN |

## 10. Proven fixes

动态 Gate Registry、canonical/lineage/cluster、fail-closed Submission Guard、幂等模拟、429/401 边界与敏感信息隔离。

## 11. Unresolved items

新鲜合法会话、Gate 实时同步、daily returns、SELF/PRODUCTION correlation 与完整 Shadow Run CLI。

## 12. Reusable lessons

零候选、零 endpoint 调用可以是正确工程结果；阻断证据比“跑出结果”更重要。

## 13. Candidate video content

为什么失败的 Shadow Run 反而证明系统安全；一万个 Alpha 为什么只有几千种思路。

## 14. Proposed durable-memory updates

仅写项目与跨项目经验。

## 15. Conflicts / stale records

代码审计通过不等于平台业务链路已恢复。

## 16. Sensitive items withheld

账号、Cookie、认证、私有接口、Alpha 公式、平台回执原文。

## 17. Next smallest action

在合法新鲜认证条件下运行只读 Connectivity Probe，再决定是否进入最小 Pilot。

