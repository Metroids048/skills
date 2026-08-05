---
id: SESSION-20260729-CODEX-PROGRAM1
created_at: 2026-07-29T17:40:00+08:00
source_tool: codex
project: program1-main-latest
status: PARTIAL
sensitivity: PRIVATE
public_content_eligible: review_required
---

# Session Capsule

## 1. User goal

回填 AI 求职台全流程修复和音频工具拆分前的项目状态。

## 2. Inputs and context

- rollout：8 个；根会话 8；2026-06-25～2026-07-10。
- 重点会话：`019f45cc-0a05-77b3-84e3-bb1cd38ff790`。

## 3. Actions performed

提取启动、账号隔离、会议监听、RAG/AI 与浏览器验收的最终结果。

## 4. Files changed

中央胶囊与项目知识文件；未改业务源码。

## 5. Commands and external actions

| Command / action | Exit status | Meaningful output |
|---|---:|---|
| `npm run test:acceptance` | 0 | app 50、server 52、全流程与 AI smoke 通过 |
| `npm run verify` | 0 | 19 files / 145 tests + build |
| `npm run test:browser-flow` | 0 | 桌面/移动浏览器路径通过 |

## 6. Verification evidence

启动脚本实际验证前后端 200；开发环境仍使用默认 JWT secret，正式部署前必须配置独立值。

## 7. User feedback and corrections

系统音频必须由用户主动连接 Windows 音频桥并授权。

## 8. Decisions made

| Decision | Reason | Rejected alternative | Impact |
|---|---|---|---|
| guest 与登录账号状态隔离 | 避免身份数据串用 | 自动 merge guest | 数据边界明确 |

## 9. Errors and root causes

账号状态曾自动合并；音频桥未配置时容易被 UI 误解为成功。

## 10. Proven fixes

移除自动 guest merge；ASR 未配置明确返回；启动脚本健康检查与日志定位。

## 11. Unresolved items

正式部署前配置 JWT secret；`program1-main` 历史是否并入 latest 待确认。

## 12. Reusable lessons

浏览器入口、账号隔离、AI 成功回执和进程健康必须在同一验收链中验证。

## 13. Candidate video content

旧本地状态如何把新前端拖进异常页；AI 页面“能打开”为什么不等于 AI 调用成功。

## 14. Proposed durable-memory updates

仅项目知识。

## 15. Conflicts / stale records

旧 `program1-main` 未登记，未静默并入。

## 16. Sensitive items withheld

简历、JD、会话、Token、环境变量值。

## 17. Next smallest action

确认旧项目归属，并在正式部署配置独立 JWT secret。

