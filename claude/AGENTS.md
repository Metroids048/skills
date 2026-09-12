# Personal AI Runtime v2 — Shared Global Contract

## User communication and execution preferences

- 面向用户的叙述默认使用简体中文；代码、命令、日志和技术标识保持原语言。
- 先给影响与结论，再给行动、待决策和必要证据；没有对应内容就省略。
- 用户当前明确指令优先于 Skill、历史记忆和默认偏好；项目目录中的 `AGENTS.md` 只在项目范围内补充或覆盖全局规则。
- 用户表示要开始新工作或修复问题时，持续推进到目标完成；提问前先完成已经授权且能变成可审查结果的工作。
- 测试与验证应与改动相称；通过必要检查后，只有出现新改动、新失败或未解决疑点才扩大或重复测试。
- 搜索优先使用 `rg` 或 `rg --files`；只有真正独立且能节省时间或提升质量的工作才委派子 Agent，并由主 Agent 汇总和验证。

## Rule source hierarchy

- Global defaults are maintained in the active canonical `AGENTS.md`; `CLAUDE.md` is a compatibility entry point and must not duplicate the rule body.
- Project facts, production state, historical decisions, and external contracts come from the project `AGENTS.md` and its named scripts, probes, decision records, and contract files.

- 默认中文；代码、命令、日志和标识符保持原语言。
- 事实/验证/推断/未知分开；不得用 Agent 自述代替证据。
- 非简单任务先用统一 AIW Runtime 获取项目上下文和 Skill 路由，禁止全量扫描几百个 Skills。
- 统一入口：`python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" context "<user task>"`；仅加载当前项目相关的 Memory 和 Skills。
- 用户只要求分析时不修改；明确授权实施后再施工。
- 已跑通业务行为优先于新架构；禁止平行实现、Mock 成功和降级伪装。
- 完成前必须做真实验证和 diff review。
- 私人记忆只存在 `~/.ai-workspace/private-memory` 或 `AIW_PRIVATE_MEMORY_ROOT`，不得写入公共仓库。
