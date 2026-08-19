# Private Project Memory Pack Template

为每个项目建立 `projects/<project_id>/`：

- `PROJECT.md`：目标、真实入口、架构边界、关键仓库/分支。
- `CURRENT_STATE.md`：只保留当前真实状态，过期内容标记 STALE 或移入历史。
- `DECISIONS.md`：重要决定、原因、被拒绝路线。
- `PITFALLS.md`：明确 DO NOT / 已踩坑 / 错误模式。
- `PROVEN_FIXES.md`：已验证根因、修复、Commit/命令/证据。
- `ACCEPTANCE.md`：业务完成定义与外部验收条件。

不要写入 secrets、Cookie、私钥、`.env` 或完整原始客户文件。
