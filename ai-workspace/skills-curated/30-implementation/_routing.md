---
category: 30-implementation
purpose: 已明确需求下的实现、重构、渐进交付与测试驱动编码。
use_when:
  - 明确功能实现
  - 渐进式重构
  - 需要 TDD 或多轮 build-verify 修复
do_not_use_when:
  - 需求尚未澄清
  - 主要目标是根因诊断或最终验收
priority_order:
  - incremental-implementation
  - tdd-workflow
  - ouro-loop
default_chain:
  - incremental-implementation
selection_rules:
  - 普通实现优先 incremental-implementation
  - 高风险改动或希望测试先行时加入 tdd-workflow
  - 多轮自驱构建与修复时加入 ouro-loop
anti_patterns:
  - 用实现 skill 替代前置澄清与计划
  - 一次性大改而不分步验证
skills:
  - name: incremental-implementation
    when: 小步实现、沿现有模式推进
  - name: tdd-workflow
    when: 测试先行、回归风险较高
  - name: ouro-loop
    when: 需要 map-plan-build-verify-remediate 循环
examples:
  - 按现有代码模式把这个功能补上
  - 先写测试再修这个共享逻辑
---
