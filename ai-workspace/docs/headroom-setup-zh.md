# Headroom 三端配置说明（Windows）

> 安装版本：`headroom-ai==0.20.15`（Windows 上最后一个免编译 wheel；最新 0.22.x 需 Rust 编译，暂未装）

## 已配置

| 工具 | MCP 工具 | 配置位置 |
|------|----------|----------|
| **Claude Code** | `headroom_compress` / `headroom_retrieve` / `headroom_stats` | `~/.claude.json`（`claude mcp add`）+ `~/.claude/settings.json` |
| **Cursor** | 同上 | `~/.cursor/mcp.json` |
| **Codex** | 同上 | `~/.codex/config.toml` |

可执行文件路径（未加入 PATH，配置里写绝对路径）：

`C:\Users\win\AppData\Roaming\Python\Python312\Scripts\headroom.exe`

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

## 验证

```powershell
$hr = "$env:APPDATA\Python\Python312\Scripts\headroom.exe"
& $hr --version
& $hr mcp status
claude mcp list   # 应显示 headroom Connected
```

## 重装 / 升级

```powershell
python -m pip install --user --only-binary=:all: -i https://pypi.tuna.tsinghua.edu.cn/simple "headroom-ai[mcp,proxy]==0.20.15"
```

升级到 0.22.x 需安装 Rust + MSVC 或等待官方 Windows wheel。

## 参考

- 仓库：https://github.com/chopratejas/headroom
- 文档：https://headroom-docs.vercel.app/docs/mcp
