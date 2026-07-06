# Execution Rules — {{PROJECT_NAME}}

> 控制 Agent 执行行为。与全局 `workflow-gate` 叠加；冲突时 repo `AGENTS.md` 优先。

## 硬约束

- **禁止直接实现功能**（Tier A：未过 P2/P3 approval 不得 Write/Edit 实现文件）
- **必须先拆 module** — 在 `DESIGN.md` 或 ADR 中列出模块与职责
- **必须 output interface contract** — 表格式：名称、输入、输出、错误、调用方
- **必须 self-review** — P5：对照需求与 diff，再进入 P6 验证

## 允许快路径（Tier B）

-  typo、文案、明确单文件单点修改
- 用户说：直接做 / 就改这一处 / 不用澄清

## 验证

- 交付前运行 repo 规定的 verify 命令（见 `AGENTS.md`）
- 未跑 fresh verify → 不得 claim done / PASS

## 禁止

- TODO/FIXME/mock 伪装完成
- 无 approval 进入下一阶段（Tier A）
- 破坏 UTF-8 中文（Windows 下禁止 `Set-Content` 写源码）
