---
category: 10-intake-routing
purpose: 用户需求桥接、模糊输入澄清、0到1 判型与前置路由。
use_when:
  - 模糊口语化需求
  - 多步骤任务
  - 跨模块改造
  - 0到1新功能或架构类请求
  - 需要先把自然语言转成 agent 可执行语言
do_not_use_when:
  - 需求已经清晰且只需直接实现
  - 只做最终交付验证
priority_order:
  - task-intake-bridge
  - requirement-clarifier
  - prompt-intake-router
  - zero-to-one-gate
  - brainstorming
default_chain:
  - task-intake-bridge
  - requirement-clarifier
selection_rules:
  - 先用 task-intake-bridge 判型
  - 每轮从 intake 池选 1–2 个（prompt 三选一最多 1 个 + 可选 clarifier/planning）
  - 需要选型参考时 Read prompt-intake-router，非每轮强制
  - 输入模糊或带实施意图时 requirement-clarifier 优先于单独 prompt enhancer
  - 新模块、新页面、跨流程时加入 zero-to-one-gate
  - 需要方案对比或创造性方向时加入 brainstorming
anti_patterns:
  - 未判型就直接进入实现 skill
  - 把 0到1 请求当作普通修 bug 处理
skills:
  - name: task-intake-bridge
    when: 任何需要先判型、归类、转写的请求
  - name: prompt-intake-router
    when: 需从 intake 池选 1–2 个时作参考（按需，非 always-on）
  - name: prompt-architect
    when: 通用 prompt 框架；与 clarifier 等组合，每轮最多 1 个 prompt enhancer
  - name: prompt-optimizer
    when: EARS 可测试需求；常与 requirement-clarifier 配对
  - name: maestro-prompt-leverage
    when: Agent 编码/多步仓库任务 brief；清晰单点任务可单独使用
  - name: requirement-clarifier
    when: 模糊实施、vibe coding、需要 Mini-Spec
  - name: zero-to-one-gate
    when: 新模块、新页面、整体架构、新工作流
  - name: brainstorming
    when: 需要明确方向、比较方案、补设计意图
examples:
  - 帮我把三端 skills 整体整理一下
  - 做一个新的审核工作流
  - 我想把这个需求转成 agent 更好执行的形式
---
