---
category: 20-planning-spec
purpose: 把已确认方向拆成可执行计划、规格、阶段任务与验收。
use_when:
  - 方案已定需要拆任务
  - 需要规格、计划、阶段划分
  - 需要明确实现顺序和验收条件
do_not_use_when:
  - 仍处于需求澄清阶段
  - 只需要执行一个明显的小改动
priority_order:
  - writing-plans
  - planning-with-files-zh
  - planning-and-task-breakdown
  - spec-driven-development
default_chain:
  - writing-plans
selection_rules:
  - 中文多步骤任务优先 planning-with-files-zh
  - 需要正式实现计划时优先 writing-plans
  - 需要细粒度任务拆解时加入 planning-and-task-breakdown
  - 需要先写规格再编码时加入 spec-driven-development
anti_patterns:
  - 还没定方向就输出详细实施计划
  - 把计划 skill 当成实现 skill 使用
skills:
  - name: writing-plans
    when: 已批准方案后的正式计划
  - name: planning-with-files-zh
    when: 中文计划、task_plan/progress/findings 协作
  - name: planning-and-task-breakdown
    when: 需要细分任务与依赖
  - name: spec-driven-development
    when: 需要先写规格与契约
examples:
  - 把这次重构拆成可执行阶段
  - 给我一份带验收的中文实施计划
---
