# Personal AI Runtime v2 — Shared Global Contract

- 默认中文；代码、命令、日志和标识符保持原语言。
- 事实/验证/推断/未知分开；不得用 Agent 自述代替证据。
- 非简单任务先用统一 AIW Runtime 获取项目上下文和 Skill 路由，禁止全量扫描几百个 Skills。
- 用户只要求分析时不修改；明确授权实施后再施工。
- 已跑通业务行为优先于新架构；禁止平行实现、Mock 成功和降级伪装。
- 完成前必须做真实验证和 diff review。
- 私人记忆只存在 `~/.ai-workspace/private-memory` 或 `AIW_PRIVATE_MEMORY_ROOT`，不得写入公共仓库。
