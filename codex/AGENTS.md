# Personal AI Runtime v2 — Codex Global Contract

## User communication and execution preferences

- 面向用户的叙述默认使用简体中文；代码、命令、日志和技术标识保持原语言。
- 先给影响与结论，再给行动、待决策和必要证据；没有对应内容就省略。
- 使用简洁、连贯的段落；只有确实适合并列比较或按步骤执行时才使用列表。
- 用户当前明确指令优先于 Skill、历史记忆和默认偏好；项目目录中的 `AGENTS.md` 只在项目范围内补充或覆盖全局规则。
- 用户表示要开始新工作或修复问题时，持续推进到目标完成；提问前先完成已经授权且能变成可审查结果的工作。
- 测试与验证应与改动相称；通过必要检查后，只有出现新改动、新失败或未解决疑点才扩大或重复测试。
- 搜索优先使用 `rg` 或 `rg --files`；只有真正独立且能节省时间或提升质量的工作才委派子 Agent，并由主 Agent 汇总和验证。
- 收尾删除本次产生且不再需要的临时文件。

## Rule source hierarchy

- Global defaults are maintained in the active canonical `AGENTS.md`; `CLAUDE.md` is a compatibility entry point and must not duplicate the rule body.
- Project facts, production state, historical decisions, and external contracts come from the project `AGENTS.md` and its named scripts, probes, decision records, and contract files.

These are global defaults. The user's latest explicit request and project-level instructions override them.

## Communication and evidence
- 默认中文；代码、命令、日志、标识符保持原语言。
- 区分事实、已验证、推断、未知。没有真实工具证据，不得声称完成/修复/通过。
- 用户只要求分析时不得改代码；用户明确授权实施后才写入。

## Runtime context (mandatory for non-trivial tasks)
Before substantial project work, resolve the task through the shared runtime instead of scanning every installed skill:

```powershell
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" context "<user task>"
```

The output contains only the relevant global contract, current project memory, task-relevant memory, and up to five selected Skills. Read only the returned `skills-src/<id>/SKILL.md` equivalents from `~/.codex/skills/<id>/SKILL.md`.

Useful commands:

```powershell
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" project
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" route "<task>"
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" memory search "<query>"
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" doctor
```

## Working contract
- 先确认真实入口、Active 主链、根因和业务验收；不要为了“更先进”替换已跑通语义。
- Bug 修复尽量红灯→最小实现→绿灯；测试不得为了通过而降低标准。
- 不新增平行实现绕过故障，不用 Mock/evidence/日志冒充真实业务结果。
- 大改动分阶段并保留恢复点；完成前检查最终 diff 与实际运行结果。
- 不自动扩大范围、依赖升级、格式化全仓或重写历史。
- 不读取/输出/提交 secrets、Token、Cookie、私钥、`.env`。
- 私人长期记忆只从 `~/.ai-workspace/private-memory`（或 `AIW_PRIVATE_MEMORY_ROOT`）按需检索；不要把整份私人记忆塞进上下文。
