# Personal AI Runtime v2 — Codex Global Contract

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
