---
category: 40-debugging
purpose: 修 bug、排查回归、定位根因，并区分“只诊断”和“进入修复”。
use_when:
  - 报错
  - 回归
  - 根因分析
  - 测试失败
  - 表现异常但原因不清
do_not_use_when:
  - 纯代码审计
  - 纯新功能实现
priority_order:
  - task-intake-bridge
  - diagnose
  - systematic-debugging
  - ai-regression-testing
default_chain:
  - task-intake-bridge
  - diagnose
selection_rules:
  - 只诊断不改代码时选 diagnose
  - 明确要修复时选 systematic-debugging
  - 涉及回归覆盖时加入 ai-regression-testing
anti_patterns:
  - 未定位问题就直接猜修法
  - 把验证或审计误当成调试
skills:
  - name: diagnose
    when: 只做复现、定位、结论
  - name: systematic-debugging
    when: 已进入修复路径
  - name: ai-regression-testing
    when: 修复后需要补回归策略
examples:
  - 这个报错为什么会发生
  - 把这个回归修掉
---
