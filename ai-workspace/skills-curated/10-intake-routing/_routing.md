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
  - zero-to-one-gate
  - brainstorming
default_chain:
  - task-intake-bridge
  - requirement-clarifier
selection_rules:
  - 先用 task-intake-bridge 判型与改写
  - 输入模糊或带实施意图时加入 requirement-clarifier
  - 新模块、新页面、跨流程时加入 zero-to-one-gate
  - 需要方案对比或创造性方向时加入 brainstorming
anti_patterns:
  - 未判型就直接进入实现 skill
  - 把 0到1 请求当作普通修 bug 处理
skills:
  - name: task-intake-bridge
    when: 任何需要先判型、归类、转写的请求
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
