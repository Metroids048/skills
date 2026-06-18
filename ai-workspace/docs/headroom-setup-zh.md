# Headroom 三端配置说明（Windows）

> 安装版本：`headroom-ai==0.20.15`（Windows 免编译 wheel；全量升级需关 IDE 后重装或等官方 Windows wheel）

## 一键重装

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\install-headroom-global.ps1"
```

## 已配置（2026-06-11）

| 工具 | MCP 工具 | Shell 压缩 | 配置位置 |
|------|----------|------------|----------|
| **Claude Code** | `headroom_compress` / `retrieve` / `stats` | `rtk hook claude`（PreToolUse Bash） | `~/.claude.json` + `settings.json` |
| **Cursor** | 同上 | `rtk hook cursor`（`~/.cursor/hooks.json` Shell） | `~/.cursor/mcp.json` + 全局 rule `headroom-token-save.mdc` |
| **Codex** | 同上（`--direct`） | `~/.codex/RTK.md` + `AGENTS.md` | `~/.codex/config.toml` |

可执行文件（已加入用户 PATH）：

`C:\Users\win\AppData\Roaming\Python\Python312\Scripts\headroom.exe`

用户环境变量：`HEADROOM_REQUIRE_RUST_CORE=false`（Windows 0.20.x 无 Rust 扩展时 proxy 可启动）

## 两种用法

### 1. 仅 MCP（已启用，不改现有代理）

Agent 在需要时主动调用压缩/取回工具，**不**改你现在的 API 代理。

- Claude 重启后会加载 `headroom` MCP
- Cursor：设置 → MCP → 刷新 / 重启 Cursor
- Codex：重启 Codex 桌面端

### 2. 全流量压缩（可选，需单独开 proxy）

```powershell
powershell -File "$env:USERPROFILE\.ai-workspace\scripts\start-headroom-proxy.ps1"
```

然后按需改环境变量（**会覆盖**当前 Claude 的 `ANTHROPIC_BASE_URL`）：

- Claude Code：`ANTHROPIC_BASE_URL=http://127.0.0.1:8787`
- Codex / OpenAI 兼容：`OPENAI_BASE_URL=http://127.0.0.1:8787/v1`

你当前 Claude 指向 `http://127.0.0.1:15721`（CC Switch 等），**未自动改**，避免破坏现有登录/路由。

一键包装启动（另开终端）：

```powershell
& "$env:APPDATA\Python\Python312\Scripts\headroom.exe" wrap claude
& "$env:APPDATA\Python\Python312\Scripts\headroom.exe" wrap codex
& "$env:APPDATA\Python\Python312\Scripts\headroom.exe" wrap cursor
```

## Cursor hooks 注意

`~/.cursor/hooks.json` 里 **`preToolUse` 必须是数组**。若只有单个对象，`rtk init -g --agent cursor` 会报 `preToolUse value is not an array`。

当前结构：一条 `Write|Edit`（澄清门禁）+ 一条 `Shell`（`rtk hook cursor`）。安装脚本会自动转换。

## 验证

```powershell
$hr = "$env:APPDATA\Python\Python312\Scripts\headroom.exe"
& $hr --version
& $hr mcp status
rtk init -g --agent cursor   # 应显示 RTK preToolUse entry already present
claude mcp list                # 应显示 headroom Connected
```

在任意 git 仓库里试 Shell：`rtk git status`（输出应比裸 `git status` 更短）。

## 重装 / 升级

```powershell
python -m pip install --user --only-binary=:all: -i https://pypi.tuna.tsinghua.edu.cn/simple "headroom-ai[mcp,proxy]==0.20.15"
```

升级到 0.22.x 需安装 Rust + MSVC 或等待官方 Windows wheel。

## 参考

- 仓库：https://github.com/chopratejas/headroom
- 文档：https://headroom-docs.vercel.app/docs/mcp
