# Personal AI Runtime v2

一个跨 **Codex / Claude Code / Cursor** 的个人 AI Runtime：统一用户工作契约、项目记忆、踩坑/已验证修复、Skill Registry、确定性 Skill Router 与可移植安装。

> v2 不再把“装了多少 Skills”当能力指标。默认运行时只安装 `skills-src/` 中经过 curated registry 激活的高信号 Skills；旧 `skills/{cursor,claude,codex,agents}` 只作为 legacy source pool / 回滚证据，不再默认安装。

## 核心链路

```text
用户任务
  → aiw project（识别项目）
  → L0 全局契约
  → L1 当前项目 memory pack
  → L2 当前任务相关 memory
  → [只有明确追溯历史] L3 session evidence
  → Skill Registry / Router（Top ≤ 5）
  → Codex / Claude Code / Cursor
```

## 隐私边界

本 GitHub 仓库只保存 runtime、public-safe bootstrap memory、模板和 canonical Skills。**真实用户画像、求职/财务/法律/交易、客户资料、ChatGPT 会话和三端原始 session 不允许提交到这里。**

私人长期记忆 SSOT：

```text
~/.ai-workspace/private-memory/
```

也可以设置：

```text
AIW_PRIVATE_MEMORY_ROOT=D:\AI-Knowledge
```

当前仓库历史曾包含 raw archives/knowledge-center；仅删除当前树不能撤销既往公开暴露。若历史中发现仍有效凭证，应优先轮换凭证；历史重写属于单独的破坏性治理操作。

## 目录

```text
runtime/                 # aiw CLI / router / memory retriever / context builder
registry/                # projects + active skill metadata SSOT
skills-src/              # canonical active Skills SSOT
skills/                  # legacy endpoint snapshots; no longer installed
memory/                  # public-safe bootstrap only
templates/private-memory # 私人项目记忆模板
scripts/import-chatgpt-export.py
scripts/export-from-local.ps1
codex/ claude/ cursor/   # thin adapters
```

## Windows 安装

```powershell
git clone https://github.com/Metroids048/skills.git
cd skills
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装器会：
1. 把 `runtime/ registry/ memory/` 安装到 `~/.ai-workspace/`；
2. 创建但不会覆盖 `~/.ai-workspace/private-memory/`；
3. 只把 `skills-src/` 安装到三端 Skills 目录；
4. 安装三端薄适配规则；
5. 清理 Claude 中旧的 `scan-global-skills.ps1` 全量 prompt hook（其他 hooks 保留）；
6. 运行 `aiw doctor`。

## CLI

```powershell
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" doctor
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" project
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" route "为什么之前能开单现在不开单"
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" context "定位不开单根因"
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" memory search "R2 cost gate"
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" skills audit
```

## 项目识别

推荐在业务仓库增加：

```json
{
  "project_id": "automated-trading",
  "memory_pack": ["automated-trading"],
  "skill_profiles": ["engineering", "trading", "debugging"]
}
```

路径：`.ai/project.json`。没有 manifest 时，AIW 再按 `registry/projects.json` 的 remote/basename 匹配。

## Private Memory Pack

每个项目建议：

```text
projects/<project_id>/
├─ PROJECT.md
├─ CURRENT_STATE.md
├─ DECISIONS.md
├─ PITFALLS.md
├─ PROVEN_FIXES.md
└─ ACCEPTANCE.md
```

重点不是复制全部聊天，而是保留未来真正会用到的：事实、决定、错误模式、根因、已验证修复、验收证据和开放事项。

## ChatGPT 历史回填

从 ChatGPT 导出的 `conversations.json` 必须导入仓库外部私人目录：

```powershell
python scripts/import-chatgpt-export.py C:\path\to\conversations.json
```

Importer：
- 拒绝把输出写进当前 Git repo；
- 对常见 token/key 形态做脱敏；
- 原始会话只标记 `PROPOSED_NOT_DURABLE`；
- 不会静默覆盖长期记忆。

之后再把真正稳定的事实/决定/根因/修复提炼到 project pack。

## Export

默认导出不再备份 raw session，也不会覆盖 `skills-src` 或 private memory：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-from-local.ps1 -Force
```

只有显式 `-IncludePrivateArchives` 才允许 raw evidence，而且脚本会用 `gh repo view` **fail-closed 验证 PRIVATE visibility**。无法验证为 PRIVATE 就拒绝导出。

## Skill 精炼策略

- `registry/skills.json` 决定 Active / alias / trigger / negative trigger / profiles / priority。
- `skills-src/<id>` 是 canonical skill body。
- 同一能力只有一个 `canonical_id`；例如 `verify-work` 路由到 `verification-before-completion`。
- 默认 Top‑5；没有 positive trigger 的 Skill 不自动激活。
- style-only / 泛描述 / 重复 Skills 保留在 legacy pool，不进入默认 runtime。
- `tests/fixtures/routing_cases.json` 是 routing regression benchmark；新增/调整 Skill 必须同时更新 benchmark。

## 当前验收边界

Linux CI/本地可以验证 Python Runtime、routing benchmark、memory privacy contract 与脚本静态契约。Windows PowerShell 的真实安装仍必须在独立 Windows 用户（例如 `C:\Users\aiw-test`）做最终外部验收，不能用静态测试冒充。
