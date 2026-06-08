# Interview Protocol（极模糊需求 · 单问收敛）

> 精华来源：[addyosmani/agent-skills `interview-me`](https://github.com/addyosmani/agent-skills)（MIT）— 嵌入 `requirement-clarifier`，供「一句话建 X」类需求。

## 何时用 Interview 模式（而非一次性 §1–§12）

| 用 Interview | 用 Mini-Spec 批量 |
|--------------|-------------------|
| 「做一个 dashboard」「加个功能」几乎无细节 | 「优化看板，太平、信息乱」已有痛点描述 |
| 置信度 <70% 且说不清 success | 用户说「整理成文档 / 先出方案」 |
| 用户愿逐轮回答 | 用户时间紧，要一屏看清 |

**可混合：** 先 2–4 轮 Interview → 置信度 ≥95% → 输出 **§4.5 Mini-Spec** + §12。

## 流程（每轮一条消息）

### Step 1 — 假设 + 置信度（首条必出）

```
HYPOTHESIS: <一句话理解用户要什么>
CONFIDENCE: ~NN% — 仍缺：<who|why|success|constraint>
```

### Step 2 — 单问 + 猜测（禁止一次抛 5 问）

```
Q: <一个聚焦问题，优先选择题>
GUESS: <你的猜测 + 理由>
```

等待用户回答后再问下一题。借鉴 [obra/superpowers brainstorming](https://github.com/obra/superpowers)：**one question per message**。

### Step 3 — 戳穿「应该想要」

若用户答「要可扩展、要专业、行业标准」等空洞词，追问：

> 如果不用向任何人解释，你**实际**想要的结果是什么？

### Step 4 — 意图复述（置信度 ≥95% 时）

```
- Outcome:      
- User:         
- Why now:      
- Success:      
- Constraint:   
- Out of scope:   ← 必填
```

问：**Yes /  refine？**  
「随便你」「 sounds good」**不算**确认 → 给 A/B 具体选项再确认。

### Step 5 — 停止条件

> 能否预测用户对「接下来三个问题」的回答？

- 能 → 产出 Mini-Spec → §12  
- 不能且已问 ≥5 轮 → 说明基础信息缺失，建议用户补一句成功样子或参考链接

## 与下游 skill 分工

| 确认后的意图 | 交给 |
|--------------|------|
| 仍多方案、要发散 | `idea-refine` 或 `brainstorming` |
| 新模块/架构 | `zero-to-one-gate` |
| 范围已清、要计划 | `writing-plans` / `planning-with-files-zh` |
| 范围已清、要小改 | Mini-Spec → §12 → 执行 |

## 反模式（禁止）

- 一次列出 10 个问题（用 §7 ≤5 或 Interview 单问）
- 没有 GUESS 的空问句
- 未确认就写 spec/代码
- 跳过 Out of scope
