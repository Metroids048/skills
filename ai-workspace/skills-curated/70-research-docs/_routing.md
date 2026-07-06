---
category: 70-research-docs
purpose: 深度研究、PRD/文档写作、分析报告与结论性输出。
use_when:
  - 深度研究
  - 竞品或事实核查
  - 写 PRD、需求文档、分析文档
  - 需要结构化文档产出
do_not_use_when:
  - 主要工作是代码实现或回归修复
priority_order:
  - deep-research
  - pm-prd-writer
  - create-prd
  - article-writing
default_chain:
  - deep-research
selection_rules:
  - 多源研究与引用优先 deep-research
  - 中文 PRD 与需求文档优先 pm-prd-writer
  - 通用 PRD 可选 create-prd
  - 文章式说明与长文输出用 article-writing
anti_patterns:
  - 用研究类 skill 直接替代实施与验证
  - PRD 混入工程实现细节
skills:
  - name: deep-research
    when: 多源调研、事实核查、研究结论
  - name: pm-prd-writer
    when: 中文 PRD、需求文档、功能说明书
  - name: create-prd
    when: 通用 PRD 模板化输出
  - name: article-writing
    when: 长文说明、分析型文档
examples:
  - 做一份 skills 治理方案研究
  - 把这个模糊产品需求写成 PRD
---
