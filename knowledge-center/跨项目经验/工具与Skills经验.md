# 工具与 Skills 经验

- 更新：2026-07-28T11:50:07
- 来源：`USER_KNOWLEDGE_BASE.md` §4、`用户长期记忆/工具与工作环境.md`、中央 `工具/`

## 1. 三端角色（UKB）

| 工具 | 当前角色 | 证据 |
|---|---|---|
| Cursor | 日常代码阅读、修改、项目交互 | UKB §4.1 |
| Claude Code | 长任务实施、代码审查、Subagent、项目记忆 | UKB §4.1 |
| Codex | 代码实施、并行任务、插件/Skills、复杂项目推进 | UKB §4.1 |
| ChatGPT | 研究、规划、Prompt、综合讨论 | UKB §4.1 |

## 2. 配置分层（已验证做法）

1. 全局行为规则：只记跨项目稳定偏好。
2. 项目 `AGENTS.md`：目标、非目标、目录、命令、架构边界、验收。
3. 工具专用：Claude `CLAUDE.md` + skills；Cursor `.cursor/rules`；Codex AGENTS + `.agents/skills`。
4. 按需 Skill：复杂流程按需加载，不塞满全局上下文。
5. 确定性层：tests、CI、Hooks、verify、permissions。

- 证据：UKB §4.2；项目 D 条目。

## 2b. 三端 Skills 路由与 Config Pack（2026-06～07 已验证）

- `[CONFIRMED]` curated 分类路由 + `task-intake-bridge`（ADR-018 / Agent Platform）；hooks 用 `scan-global-skills.ps1`，禁止全库 dump。
- `[CONFIRMED]` Agent Config Pack（2026-07-22）：Working Agreement → 项目 AGENTS → 工具补丁 → verify-work → Hooks/CI；安装报告在 `~/.ai-workspace/memory/agent-config-pack-*.json`。
- `[CONFIRMED]` RTK / hooks 的 JSON 设置须 UTF-8 **无 BOM**；更新 Claude hooks 后重跑 `rtk init -g --auto-patch`。
- `[CONFIRMED]` 澄清硬门禁：`repair-tri-end-hooks.ps1` 默认真实 clarification gate，非 fail-open stub。

## 3. Codex 已知故障与对策

- `[CONFIRMED]` 错误族：`Unknown parameter: namespace` / `Expected an ID that begins with 'rs'` / `stream disconnected` / `Transport error` / `error decoding response body`。来源：UKB §4.3。
- `[CONFIRMED]` 对策偏好：正常完成或 token 将尽时保存、提交并推送；用 Prompt H / `/Token耗尽前收口`。

## 4. 本机知识中心常用命令

```text
python 工具/知识中心.py 梳理 --all
python 工具/知识中心.py 同步 --all
python 工具/知识中心.py 复盘
python 工具/汇总跨项目经验.py
python 工具/知识中心.py 验收
```

- `[CONFIRMED]` 中央目录就地：`C:\Users\win\Desktop\全局配置`（见全局决策记录）。
- `[CONFIRMED]` 本机 `cursor agent` 非交互 stream-json 未暴露时，用 `--simulate` 覆盖记录链路（交付说明环境缺口）。

## 5. Skills / 视频工具视角（UKB）

- `[CONFIRMED]` 工具内容固定视角：不复述功能说明书，放进真实任务里验收（UKB §6.5）。
- `[CONFIRMED]` Agent Video Studio：Skills 唯一编辑源 `skills-src/`；同步到 `.claude/skills` 与 `.agents/skills`；Codex HyperFrames 插件非硬依赖（UKB §5.3）。
- `[OPEN]` 「装了多个视频 Skills，真正留下几个」仍是前 12 条验证内容之一（UKB §6.7 #10）。

## 6. UKB §4 原文摘录（只读同步）

```markdown
## 4.1 核心 Agent 工具

| 工具 | 当前角色 |
|---|---|
| Cursor | 日常代码阅读、修改、项目交互 |
| Claude Code | 长任务实施、代码审查、Subagent、项目记忆 |
| Codex | 代码实施、并行任务、插件/Skills、复杂项目推进 |
| ChatGPT | 研究、规划、Prompt、法律/旅行/产品等综合讨论 |

## 4.2 通用 Agent 配置体系

已形成的推荐分层：

1. 全局行为规则：只记录跨项目稳定偏好，不写具体项目事实。
2. 项目根目录 `AGENTS.md`：项目目标、非目标、目录、命令、架构边界、验收和风险。
3. 工具专用配置：
   - Claude Code：`CLAUDE.md`、`.claude/skills/`、`.claude/agents/`、Hooks；
   - Cursor：`.cursor/rules/*.mdc`；
   - Codex：项目和全局 `AGENTS.md`、`.agents/skills/`。
4. 按需 Skill：复杂流程按需加载，不把所有流程长期塞入全局上下文。
5. 确定性强制层：tests、CI、Hooks、verify scripts、permissions。

## 4.3 已知 Codex 使用问题 / 视频素材

- `[CONFIRMED]` 遇到过错误：
  - `Unknown parameter: 'input[57].namespace'.`
  - `Invalid 'input[10].id': ... Expected an ID that begins with 'rs'.`
  - `stream disconnected before completion`
  - `Transport error`
  - `error decoding response body`
- `[CONFIRMED]` 用户担心长任务在 token 耗尽前没有推送 GitHub。
- `[CONFIRMED]` 用户希望 Agent 在正常完成后，或上下文/token接近耗尽前，自动保存、提交并推送已完成成果。
- `[CONTENT_IDEA][PUBLIC_SAFE]` Codex 为什么任务做到一半突然报错？
- `[CONTENT_IDEA][PUBLIC_SAFE]` Token 快耗尽时如何保证代码不会丢？
- `[CONTENT_IDEA][PUBLIC_SAFE]` Agent 的“完成”和真正交付有什么区别？
- `[CONTENT_IDEA][PUBLIC_SAFE]` 为什么项目越改越多？
- `[CONTENT_IDEA][PUBLIC_SAFE]` Prompt 和 Loop 的真正区别。

---
```
