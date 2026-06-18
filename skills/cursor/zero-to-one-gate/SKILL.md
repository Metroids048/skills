---
name: zero-to-one-gate
description: Use when work is greenfield, a new module/page/workflow, or 帮我做… without ADR coverage — before Write/Edit on implementation files.
disable-model-invocation: false
---
# Zero-to-One Gate（0→1 架构门禁）

适用于 **Cursor、Claude Code、Codex**。用户不必懂技术；**由 Agent 判断**是否属于 0→1，并主动暂停编码、先出架构。

## 0. Strict 模式（默认）

- 命中 §1 信号 → **必须先** 2–3 套方案 + ADR 摘要 + 用户确认，再写实现代码
- 即使用户说「直接做 / 快点 / 不用设计」→ 仍须先给 **≤15 行方案摘要 + scope 确认**；不得跳过 ADR/模块边界
- 例外仅见 §1 最后一行（typo、单点 bug、已有 ADR+plan 的逐步实现）

## 1. 何时必须触发（HARD-GATE）

满足 **任一** 即触发，**禁止直接写实现代码**：

| 信号 | 示例 |
|------|------|
| 新能力 / 新模块 | 「做一个 XX 管理」「加一套 YY 流程」 |
| 新页面 / 新子系统 | 新 HTML 页、新服务、新包 |
| 架构 / 整体设计 | 「怎么拆模块」「从 0 设计」 |
| 模糊但范围大 | 「帮我把运营平台做出来」 |
| 跨多文件新链路 | 新状态流、新 API 层、新数据模型 |
| 项目 memory 无 ADR 覆盖该域 | decisions-log 查不到相关决策 |

**不触发**（可直接小改）： typo、改文案、单文件 bug、明确「只改这一行」、已有 ADR+plan 的逐步实现。

## 2. 触发后的强制流程

```
Detect → Brainstorm → Architect → User Approve → Plan → Build → Verify
```

### Step A — 读上下文（与 ai-coding-ok Mode B 叠加）

1. 全局：`user-memory.md`、最近 `global-task-history.md`
2. 项目：`AGENTS.md`、`project-memory.md`、`decisions-log.md`、`task-history.md`
3. 若有 PRD / 需求 md：读全文，标出 **未落地的模块与状态**

### Step B — `brainstorming` skill（必读）

- 一次只问一个澄清问题（用户可能是非技术）
- 给出 **2–3 套架构/模块方案** + trade-off + 推荐
- **HARD-GATE**：用户口头或文字确认方案前，不写代码、不 scaffold

### Step C — 架构产出（本 skill 负责结构）

产出写入 **至少一处**（按项目选最合适的）：

| 产物 | 路径 | 内容 |
|------|------|------|
| 架构摘要 | `.github/agent/memory/decisions-log.md` 新 ADR | 模块边界、状态归属、扩展点、禁止事项 |
| 设计说明 | `docs/architecture/YYYY-MM-DD-<topic>.md` | 模块图（mermaid）、数据流、文件职责表 |
| 实现计划 | `docs/plans/YYYY-MM-DD-<topic>.md` 或 superpowers plans | 分步任务、验收标准 |

**架构摘要必须包含：**

1. **模块边界** — 每个模块职责一句话；什么不属于它
2. **状态与数据** — 谁拥有 state（session/local/API）；禁止双写
3. **入口与导航** — 页面/路由/Deep link；与现有 proto 导航一致
4. **复用 vs 新建** — 必须复用的现有函数/组件；禁止重复实现
5. **验证策略** — 本仓库的 verify 命令（如 verify-all）
6. **非目标** — 本轮不做什么（防 scope creep）

### Step D — 用户确认

用 **plain 中文** 给非技术用户一段摘要（≤15 行），问：「按方案 A 继续吗？」  
确认后才进入 Step E。

### Step E — `writing-plans` 或 `planning-with-files-zh`

- 中文任务优先 `planning-with-files-zh`（`task_plan.md` / `findings.md` / `progress.md`）
- 或 `writing-plans` → `docs/plans/...`
- 复杂多轮用 `ouro-loop`（MAP→PLAN→BUILD→VERIFY）

### Step F — 实现与收尾

- 按 plan 分步提交；每步可独立验证
- 架构变更 → 更新 `decisions-log.md`
- 结束：`ai-coding-ok` Mode C + `global-delivery-gate`

## 3. Agent 主动识别的项目薄弱点

在 Step A 后 **自行检查**（用户不问也要做）：

| 薄弱点 | 检测 | 动作 |
|--------|------|------|
| 无 ADR | decisions-log 无相关条目 | 本任务写 ADR-xxx |
| 模块职责重叠 | 多文件改同一 state | 方案里明确单一 owner |
| 只有 PRD 无技术映射 | PRD 有功能无文件/模块 | 产出 PRD→模块对照表 |
| 验证偏 grep | 只有 smoke 无 journey | plan 里加运行时/导航验证 |
| 导航/session 风险 | 动 proto.js / 05 页 | 引用 ADR-003；plan 含 index↔05 复测 |
| Skill 链断裂 | 直接开写 | 回到 Step B |

## 4. 与其他 skill 的分工

| Skill | 何时 |
|-------|------|
| `pm-prd-writer` | 产品需求文档，不是纯技术架构 |
| `brainstorming` | 所有 0→1 创意与方案（本 gate 强制前置） |
| `writing-plans` / `planning-with-files-zh` | 确认方案后的实现计划 |
| `ouro-loop` | 大任务、多文件、需多轮 VERIFY |
| `figma-workflow` / `pm-image2proto` | 有设计稿时的 UI 实现（仍须模块边界 ADR） |
| `ai-delivery-gate` | 交付前验证 |

## 5. 对非技术用户的沟通原则

1. 先 **结论后细节**；架构用表格/列表，少堆术语
2. 每个决策给 **默认推荐**（「建议选 A，因为…」）
3. 不要问「要用 Redis 吗？」—— 改成「数据需要跨页面保存，我建议继续用 sessionStorage，和现有原型一致」
4. 发现 scope 过大 → 主动拆 **MVP / Phase 2**

## 6. 回复格式

触发本 skill 时，回复开头：

`Skills: zero-to-one-gate, brainstorming, …`

阶段更新用：`Phase: Detect | Brainstorm | Architect | Approve | Plan | Build | Verify`

