# Windows / Codex Agent 失败模式目录（本机级）

Last updated: 2026-07-17  
Status: active  
ADR: ADR-G006  
Rules: `windows-failure-triage.mdc` + `windows-agent-shell.mdc`  
Stack: `AGENT-GLOBAL-STACK.md`  
Repair: `repair-windows-agent-env.ps1` · Audit: `audit-windows-agent-env.ps1`

> 目的：把「看起来像环境又坏了」的现象拆成固定三类，并规定**全局装一次** vs **项目自有依赖**，禁止每个新任务/新项目重复 pip / 重复试编码。

---

## 失败必须分三层报告（硬门禁）

| 层 | 名称 | 含义 | 可否宣称「项目功能失败」 |
|----|------|------|--------------------------|
| L1 | 工具命令失败 | Agent 自己写的 shell/JS/正则/转义错，命令未真正执行 | **否** |
| L2 | 环境能力缺口 | 本机缺 SDK、权限清理、全局栈缺包、编码未修复 | **否**（标环境；能修则跑 repair） |
| L3 | 项目功能失败 | 业务代码/测试断言/产品验收未过 | **是** |

交付话术禁止：把 L1/L2 写成「代码挂了」「验证失败」。  
正确示例：「L2：全局栈缺 pytest 工具包 — 已跑 install；L3 未跑，不判定代码失败。」

---

## 已确认的高频模式（来自 Codex / 三端任务史）

### L1 — 工具命令失败（禁止当环境坏）

| ID | 症状 | 根因 | 固定做法 |
|----|------|------|----------|
| L1-01 | `SyntaxError: invalid Unicode escape` / TOML `invalid unicode` | Windows 路径 `C:\Users\...` 写进 JS/JSON/TOML 字符串，`\U` 被当转义 | 路径用正斜杠 `C:/Users/...`，或 `Path`/`Join-Path`，**禁止**把反斜杠路径塞进需转义的字面量；Codex 规则写 `AGENTS.md` 不写进 TOML 长路径 |
| L1-02 | PowerShell「正则表达式无效」/ 枚举日志中断 | 正则以 `\` 结尾，或内联 `-match` 吃掉路径 | 用 `Get-ChildItem` + `-notlike`；正则写进 `.ps1` 文件；禁止内联路径正则 |
| L1-03 | `$null` / 变量被吃掉 / 命令变形 | Codex 外包 `-Command "..."` 吃掉 `$_`、`$var` | **禁止** inline 写 `$_`/`$env:` 复杂表达式；改 `rg` / `.py` / `.ps1 -File` |
| L1-04 | `rtk Get-Content` 反复失败 | RTK 包不住 PS cmdlet | 禁止 rtk 包 cmdlet；Read 工具或 `read-text-file.py` |
| L1-05 | `python -c` + 中文/多行炸 | 控制台/引号/编码 | 写 `.py` → `run-agent-python.ps1` |
| L1-06 | `.ps1` Unexpected token / 中文乱码 | Agent 用错误编码写 PS1 | `verify-ps1-script-encoding.ps1`；FAIL → **改写 Python**，禁止循环试编码 |

### L2 — 环境能力缺口（全局修一次，禁止每项目）

| ID | 症状 | 根因 | 固定做法 |
|----|------|------|----------|
| L2-01 | `AGENT_PYTHON` 无 pytest / 验证「卡住」 | **误用**全局栈跑**项目**测试；或全局工具包未装 | 先跑 `resolve-test-runner.py`；项目测试用 `py -3` / 项目 `.venv`；全局只保证 Agent 工具包（含 pytest）一次装齐 |
| L2-02 | 无 win32com / Office COM 失败 | 用了 Codex 自带 Python | 只用 `AGENT_PYTHON` / `install-global-agent-python.ps1` |
| L2-03 | 中文路径 gbk / cwd 乱码 | 控制台非 UTF-8 | `verify-windows-shell-encoding.ps1` → FAIL 则 `repair-...` 后**重启会话** |
| L2-04 | Playwright / 浏览器测「失败」但业务步已过 | Windows 清临时 profile `EPERM` | 报告标 **L2 清理**；主流程截图/断言过则 L3 可 PASS；禁止整任务判失败 |
| L2-05 | 系统音频桥 / 旁路编译失败 | 本机无 .NET SDK 等 | 标 L2 能力缺失；与产品主验收脱钩，除非任务明确依赖该旁路 |
| L2-06 | Codex 仍是 PS 5.1 | `shell_path` 未生效或未重启 | 见 `CODEX-WINDOWS-SHELL.md`；修 config 后全退 Codex |
| L2-07 | 每项目 `pip install` / 写 500 行依赖探测 | Agent 把全局能力当项目问题 | **禁止**；缺包优先装进 `~/.ai-workspace/venv`；仅用户明确要求才 `ensure-python-env.ps1 -UseProjectVenv` |
| L2-08 | Docker 不在 PATH → compose 校验 skipped | 本机无 Docker | 标 L2 skipped，不是 L3 fail |

### L3 — 项目功能失败（唯一可说「没做完」）

| ID | 含义 |
|----|------|
| L3-01 | 项目约定的 verify / pytest / npm test 断言失败 |
| L3-02 | 产品验收路径未走通（在 L1/L2 已排除之后） |

---

## 全局装一次 vs 项目自有

| 类别 | 装哪里 | 何时 |
|------|--------|------|
| Office/CJK/读文件/Agent 脚本常用库 | `~/.ai-workspace/venv`（`AGENT_PYTHON`） | `install-global-agent-python.ps1` **一次** |
| Agent 工具包（pytest/yaml/requests/httpx/jsonschema/chardet） | 同上 | 同上（默认带上） |
| 项目业务依赖、项目 pytest 插件 | 项目 `.venv` / `py -3 -m pip` | 仅该项目需要时；**不要**拷进每个新项目的全局探测脚本 |
| Node 依赖 | 项目 `node_modules` | 各项目自己的 `package.json`（无法全局替代） |

解析命令（开工验证前必跑）：

```powershell
& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\resolve-test-runner.py"
```

---

## Agent 行为红线（写进规则后仍违反 = 流程 bug）

1. 不得用「缺 pytest」暗示全局 Python 坏了，而不先跑 `resolve-test-runner.py`。  
2. 不得在未分 L1/L2/L3 的情况下说「任务失败 / 验证失败」。  
3. 不得为新项目再写一套 Python/编码探测 boilerplate。  
4. 不得把 EPERM 清理失败写成浏览器业务失败。  
5. 缺全局包 → `install-global-agent-python.ps1` 或 `repair-windows-agent-env.ps1`，禁止对话里反复 `pip install` 试错。

---

## 一键自检 / 修复

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\audit-windows-agent-env.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\repair-windows-agent-env.ps1"
```
