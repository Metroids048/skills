---
name: idea-refine
description: Refines vague ideas into actionable one-pagers with MVP scope and Not Doing list. Use after requirement-clarifier Mini-Spec when user needs divergent options or stress-test before commit. Triggers on ideate, refine idea, stress-test plan. Upstream addyosmani/agent-skills (MIT).
disable-model-invocation: false
---
# Idea Refine（本地化精简版）

> 完整上游：[addyosmani/agent-skills idea-refine](https://github.com/addyosmani/agent-skills/tree/main/skills/idea-refine)

**前置：** 已走 `requirement-clarifier`；若意图仍模糊，先 `interview-protocol.md`。

## 三阶段

1. **发散** — How Might We + 3–5  sharpening 问题 + 5–8 变体（ inversion / 简化 / 10x ）
2. **收敛** — 2–3 方向；用户价值 / 可行性 / 差异化；**显式假设与可杀死点**
3. **产出 one-pager** — Problem / Direction / Assumptions to validate / MVP / **Not Doing**

## 输出路径

`docs/ideas/YYYY-MM-DD-<topic>.md` — **仅用户确认后写入**。

## 红线

- 不做 yes-machine；弱想法要直说
- 必须有 Not Doing
- 不跳过假设清单就进入实现

## 下游

确认方向 → `writing-plans` 或回到 `requirement-clarifier` §12。

