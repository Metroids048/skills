# Global AI Workspace

Global rules: `~/.claude/AGENTS.md`  
Global memory: `~/.ai-workspace/memory`  
Skills index: `~/.claude/global-skills-index.md`

SessionStart: Read `~/.cursor/skills/global-session-core/SKILL.md` before other tools.

---

## UTF-8 与中文文件（Codex 硬门禁）

Codex **不加载** Cursor `.mdc` 规则；本节为 Codex 独立执行副本，与 `~/.claude/AGENTS.md` § UTF-8 同级。

1. 所有文件读写默认 **UTF-8**；修改时不得改变原有编码、换行与无关内容。
2. **读中文文件 / 列含中文路径目录前**（PowerShell）：
   ```powershell
   chcp 65001 | Out-Null
   [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
   $OutputEncoding = [System.Text.Encoding]::UTF8
   Get-Content -LiteralPath $path -Raw -Encoding UTF8
   ```
3. **禁止**用 PowerShell `Set-Content`、`Out-File`、重定向、here-string 管道写含中文源码、JSON、文档。
4. **禁止** `sed`/`awk` 处理含中文文件；用 Python/Node.js 并显式 `encoding='utf-8'` / `'utf8'`。
5. 写 `.ts/.tsx/.js/.md/.json` 等：优先编辑器 patch；批量改写只用 UTF-8 脚本。
6. PS 5.1：`Set-Content -Encoding UTF8` 带 **BOM** — JSON/hooks 须 UTF-8 **无 BOM**（见 `Write-Utf8NoBom.ps1`）。
7. 含 `$变量` 或中文路径：**禁止**一行 `powershell -Command` → 用 `.ps1` + `-File`。
8. **禁止** `$Home = ...`；用 `$UserHome = $env:USERPROFILE`。
9. **禁止**把 `git status`/dir 在 CP936 下的乱码文件名当作真实路径。
10. 修编码只改损坏部分，禁止整文件重写或全文件格式化。
11. 代码注释可用中文，须 UTF-8。

工具：`~/.ai-workspace/scripts/ensure-utf8-console.ps1`、`Write-Utf8NoBom.ps1`、`scan-encoding-issues.ps1`

Shell/RTK 契约：全局 AGENTS § UTF-8 + Windows Agent Shell 交叉条款。
