---
category: 50-verification-review
purpose: 交付验证、代码审计、完成前 gate 与签收前检查。
use_when:
  - 用户要求验证、验收、sign-off
  - 准备声称 done、fixed、PASS
  - 需要 review 审计 agent 产出
do_not_use_when:
  - 仍在做需求澄清或方案选择
  - 主要工作是功能实现
priority_order:
  - ai-delivery-gate
  - global-delivery-gate
  - agent-verifier
  - review
default_chain:
  - global-delivery-gate
selection_rules:
  - Agent Platform 原型优先 ai-delivery-gate
  - 通用项目交付验证用 global-delivery-gate
  - 需要审计 agent 代码质量时加入 agent-verifier
  - 明确要 review 某批改动时加入 review
anti_patterns:
  - 未跑 fresh verify 就声称完成
  - 用实现类 skill 替代交付 gate
skills:
  - name: ai-delivery-gate
    when: 本 repo prototype 交付与 verify-all
  - name: global-delivery-gate
    when: 通用 repo 的交付验证
  - name: agent-verifier
    when: 审计 agent 生成代码质量
  - name: review
    when: 明确需要代码 review 视角
examples:
  - 帮我验收这次改动
  - 在提交前做一次代码审计
---
