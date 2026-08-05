---
id: SESSION-20260729-CODEX-YINPINJIANTING
created_at: 2026-07-29T17:40:00+08:00
source_tool: codex
project: yinpinjianting
status: PARTIAL
sensitivity: PRIVATE
public_content_eligible: review_required
---

# Session Capsule

## 1. User goal

回填监听提词工具的桥接诊断、AI/RAG 性能与真实会议边界。

## 2. Inputs and context

- rollout：3 个；2026-07-10～2026-07-17。
- 重点会话：`019f49bd-f95d-7001-bfa6-abb92bdea7c8`、`019f4afa-f8e1-7402-aa6f-d17db03eb434`。

## 3. Actions performed

区分 debug ASR 浏览器闭环、真实桌面桥、真实会议与真实 provider 降级链。

## 4. Files changed

中央胶囊与项目知识文件；未改业务源码。

## 5. Commands and external actions

| Command / action | Exit status | Meaningful output |
|---|---:|---|
| `npm run verify` | 0 | 129/133 个阶段性测试与 build 通过 |
| `npm run test:browser-flow` | 0 | debug bridge flow verified |

## 6. Verification evidence

AI/RAG 提词卡与简历优化性能达标；真实 .NET audio bridge、真实会议和真实 RTASR 未验证。

## 7. User feedback and corrections

不复用聊天中泄露的旧令牌；没有外部条件时不得伪造 provider 切换成功。

## 8. Decisions made

| Decision | Reason | Rejected alternative | Impact |
|---|---|---|---|
| debug ASR 只证明链路，不代表真实会议 | 外部 SDK/会议/音频设备未接入 | 用模拟结果宣称完成 | 状态保持 PARTIAL |

## 9. Errors and root causes

桌面桥默认端口与后端不一致；本机缺 .NET SDK；外部 provider 凭据/下载条件不足。

## 10. Proven fixes

统一端口、桥状态事件、RMS/peak 诊断、SSE 重连、页面三段状态、debug ASR 浏览器回归。

## 11. Unresolved items

真实会议音频、真实桌面桥编译运行、真实 RTASR 和 provider failover。

## 12. Reusable lessons

模拟桥、真实桥、真实会议、真实模型是四层不同证据。

## 13. Candidate video content

模拟音频桥测试通过，为什么仍不能说真实会议可用。

## 14. Proposed durable-memory updates

仅项目知识与公开安全经验。

## 15. Conflicts / stale records

无；历史“通过”统一限定为 debug/browser 链路。

## 16. Sensitive items withheld

简历、会议内容、转写文本、provider token。

## 17. Next smallest action

安装可用 .NET SDK 后，用真实会议音频跑一次端到端验收。

