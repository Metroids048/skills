# Skill Chain Map — 模糊需求 → 可执行（三端通用）

> 整合本仓库已有 skills + GitHub 高星实践，避免 Agent 跳过中间层。

## 推荐链路（按模糊程度）

```
极模糊（「做一个 X」）
  → interview-protocol（单问+猜测，至 95%）
  → §4.5 Mini-Spec
  → [可选] idea-refine / brainstorming（多方案）
  → [若新模块] zero-to-one-gate + ADR
  → writing-plans / planning-with-files-zh
  → §12 执行 Prompt
  → 实现 + global-delivery-gate

中等模糊（「优化 Y，因为 Z」）
  → vibe-coding-bridge 七维
  → §4.5 Mini-Spec + §7
  → §12 → 实现

清晰（路径+验收齐全）
  → §1 + §12 极简 → 实现
```

## 外部精华 ↔ 本地落地

| 来源 | Stars/口碑 | 取了什么 | 落在哪里 |
|------|------------|----------|----------|
| [obra/superpowers](https://github.com/obra/superpowers) brainstorming | 200k+ | HARD-GATE、单问、设计 doc、`writing-plans` 终端 | 已有 `~/.cursor/skills/brainstorming`；0→1 链调用 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) interview-me | 44k+ | 假设+置信度、Q+GUESS、Out of scope、95% 停止 | `interview-protocol.md` |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) idea-refine | 44k+ | Not Doing、MVP、假设验证清单 | Mini-Spec 字段 + §8 |
| [DmiyDing/clarify-first](https://github.com/DmiyDing/clarify-first) | 风险门禁 | 假设权重、MEDIUM/HIGH 两阶段 | `clarification-guardrails.md` |
| [foryourhealth111-pixel/Vibe-Skills](https://github.com/foryourhealth111-pixel/Vibe-Skills) | 2k+ | 规划/澄清/拆解分层 | 与 `planning-with-files-zh` 并列 |
| 本地 `grill-me` | — | 计划压力测试 | 用户说「grill 我」时，澄清**之后** |

## 三端如何生效

| 端 | 机制 |
|----|------|
| Cursor | `requirement-clarifier.mdc` + hooks 注入附录路径 |
| Claude Code | `settings.json` UserPromptSubmit + `AGENTS.md` |
| Codex | `hooks.json` + `persistent_instructions` |

## Agent 必读顺序（B 类 vibe coding）

1. `SKILL.md`
2. `vibe-coding-bridge.md`
3. 极模糊 → `interview-protocol.md`；否则 → `question-bank-zh.md`
4. `clarification-guardrails.md`（MULTI 文件或高风险）
5. `mini-spec-template.md` → 用户确认
6. `output-template.md` §12
