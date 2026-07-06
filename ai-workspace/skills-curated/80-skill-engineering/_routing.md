---
category: 80-skill-engineering
purpose: Skill 设计、盘点、合并裁剪、触发质量修复与路由工程。
use_when:
  - 创建或修改 SKILL.md
  - 技能盘点与去重
  - skill 没被调用
  - 需要修复 routing / description / trigger
do_not_use_when:
  - 只是普通业务功能实现
priority_order:
  - writing-skills
  - skill-stocktake
  - agent-sort
  - skill-creator
default_chain:
  - writing-skills
  - skill-stocktake
selection_rules:
  - 写或改 SKILL.md 优先 writing-skills
  - 做 inventory/keep-merge-retire 优先 skill-stocktake
  - 做 DAILY/LIBRARY 裁剪时加入 agent-sort
  - 从零创建新 skill 时加入 skill-creator
anti_patterns:
  - 把 skill 工程当成普通文档写作
  - 不做触发边界设计就新增 skill
skills:
  - name: writing-skills
    when: 编写、修改、验证技能文件
  - name: skill-stocktake
    when: 审计 inventory、Keep/Improve/Retire/Merge
  - name: agent-sort
    when: DAILY/LIBRARY、核心/扩展分桶
  - name: skill-creator
    when: 从零创建新 skill 结构
examples:
  - 为什么这个 skill 没有被调用
  - 把三端 skills 去重并重建路由
---
