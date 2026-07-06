---
category: 00-core-session
purpose: 会话启动、全局记忆、基础技能路由与项目级 PDCA 护栏。
use_when:
  - 新会话开始
  - 进入编码任务前需要读全局与项目记忆
  - 需要建立本轮技能加载顺序
do_not_use_when:
  - 只做具体功能实现的二次技能选择
  - 只做单一 bug 修复路径判断
priority_order:
  - global-session-core
  - ai-coding-ok
  - using-agent-skills
default_chain:
  - global-session-core
  - ai-coding-ok
selection_rules:
  - 会话起点优先 global-session-core
  - 涉及编码与项目记忆时加入 ai-coding-ok
  - 需要补充技能发现流程时加入 using-agent-skills
anti_patterns:
  - 跳过全局记忆直接开始修改代码
  - 在未确定项目 guardrails 前加载大量实现类 skill
skills:
  - name: global-session-core
    when: 会话起点、读记忆、建立技能加载纪律
  - name: ai-coding-ok
    when: 任何编码类任务需要 PDCA 与项目 overlay
  - name: using-agent-skills
    when: 需要按 description 做技能发现与加载顺序约束
examples:
  - 新会话先读哪些 skill 和 memory
  - 开始编码前需要建立统一工作流
---
