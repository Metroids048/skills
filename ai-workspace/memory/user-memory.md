# User Memory (Global)

Last updated: 2026-06-08

> Cross-project facts, preferences, and workflow conventions. **Do not commit to git** — lives in `~/.ai-workspace/memory/`.

## Preferences

- Reply language: 简体中文 (unless user asks otherwise)
- Skills: global library at `~/.cursor/skills/`; match by description, Read full SKILL.md when applicable
- Token habits: short updates, no long log dumps; never skip verification to save tokens
- Tools: Cursor + Claude Code + Codex share hooks via `~/.ai-workspace/scripts/`
- **taste-skill** (2026-06-05): [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) 13 个 skill 已装三端；默认 `design-taste-frontend`（v2），Codex 高动效用 `gpt-taste`；重装 `scripts/hooks/install-taste-skills.ps1 -RefreshFromGitHub -Force`
- **Headroom** (2026-06-04): `headroom-ai==0.20.15` @ `%APPDATA%\Python\Python312\Scripts\headroom.exe` — MCP 已接入三端；全流量 proxy 见 `~/.ai-workspace/docs/headroom-setup-zh.md`（勿自动覆盖 `ANTHROPIC_BASE_URL=15721`）
- **requirement-clarifier** (2026-06-04): 运行时钩子读 `~/.ai-workspace/scripts/skills-sync.config.json`；`alwaysOnSkills` 须含 `requirement-clarifier`；`UserPromptSubmit` 也会注入 always-on（修复前仅 SessionStart 且配置缺项）
- **需求澄清偏好** (2026-06-05): B 类必先 Mini-Spec + §7；极模糊用 interview-protocol；风险/多文件用 clarification-guardrails。精华链路见 `skill-chain-map.md`。**硬拦** (2026-06-05): Type B → PreToolUse deny Write/Edit 直至用户说「确认/按澄清结果执行/直接做」等（`clarification-gate-keywords.json`）；状态 `~/.ai-workspace/clarifications/gate-state.json`。不批量装重复高星 skills（ADR-006）。
- **0→1 mode: strict** — 新模块/大范围「帮我做…」必须先方案+ADR+用户确认，再写代码；用户非技术，由 Agent 主动补 ADR/模块边界
- **Maximum permission:** 「最大权限」「全部解决」= 少来回确认、把**当前问题**修完 — **不等于**可删 CC Switch、清配置目录、跑卸载脚本；破坏性操作须先说明并获确认

## Global Workflow

1. SessionStart: Read `global-session-core` skill + this file before coding tasks
2. Coding tasks: ai-coding-ok PDCA — global memory first, project overlay if present
3. **0→1 chain (strict):** `zero-to-one-gate` → `brainstorming` → user approve → `writing-plans` or `planning-with-files-zh` → build → `global-delivery-gate`
4. Before claiming done: run detected verify commands (see `global-delivery-gate` skill)
5. After tasks: append `global-task-history.md` with `[project: path]` tag

## Lessons Learned (cross-project)

- Skills hooks must use `scan-global-skills.ps1`, not full catalog dump (saves tokens)
- JSON settings for RTK must be UTF-8 **without BOM**
- Re-run `rtk init -g --auto-patch` after updating Claude hooks
- Vibe coding「帮我做一个…」= 0→1 until proven otherwise — do not skip architecture for speed
- **2026-06-03:** Agent 误删 CC Switch 配置（用户未授权）— 「最大权限」仅图省事，禁止越权破坏性操作；见 ADR-G003 + `maximum-permission-scope.mdc`

## Active Projects

See `projects-registry.md` for path → alias mapping.

## Reference docs

- **三端配置与避坑总览**（2026-05-28 ~ 2026-06-08）：`~/.ai-workspace/docs/tri-end-ai-config-inventory-zh.md`
