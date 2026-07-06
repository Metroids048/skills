# 全局 Agent 栈（换项目不变）

一次安装，所有文件夹共用。Agent **禁止**每个项目再做 venv 审计或写 500 行依赖检测脚本。

## 一键安装

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\install-global-agent-python.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\repair-codex-config.ps1"
```

## 固定路径

| 项 | 路径 |
|----|------|
| 全局 Python | `%USERPROFILE%\.ai-workspace\venv\Scripts\python.exe` |
| 环境变量 | `AGENT_PYTHON`（User 级） |
| 命令别名 | `%USERPROFILE%\.local\bin\agent-python.cmd` |
| 运行时快照 | `%USERPROFILE%\.ai-workspace\runtime\python-env.json` |

## Agent 应怎么用

```powershell
# 跑项目里的脚本（任意 cwd）
& $env:AGENT_PYTHON tools\ppt_v0_xxx.py "C:\Users\win\Desktop\敖钦储能项目\..."

# 或
agent-python tools\build_doc.py "中文路径.docx"

# 读中文文件
& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\read-text-file.py" "路径"
```

**不要：** 扫 `.venv`、`python -c`、管道喂 Python、每项目 `build_*_optimized.py` 里重复 pip 检测。

## 验证（与项目无关）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\verify-global-agent-stack.ps1"
```

## 已装模块

pywin32、python-pptx、python-docx、openpyxl、Pillow（可选：`install-global-agent-python.ps1 -WithPdf` 装 pymupdf）

## Codex 更新后

Desktop 会冲掉 `config.toml` → 再跑 `repair-codex-config.ps1`，然后**完全退出** Codex 重开。

## 项目 .venv

仅当你**显式**要跑该项目专用依赖时用 `-UseProjectVenv`：

```powershell
ensure-python-env.ps1 -UseProjectVenv -ProjectDir "C:\path\to\project"
```

默认 Agent 栈 **不**自动切到项目 `.venv`。
