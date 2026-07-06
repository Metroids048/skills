---
category: 90-reference-optional
purpose: 只读参考、提示词研究、系统行为对照，不进入核心执行链。
use_when:
  - 研究内置 prompt 结构
  - 对照系统提示与技能设计
  - 需要只读参考资料
do_not_use_when:
  - 日常编码、调试、验证、规划
  - 普通需求实施
priority_order:
  - claude-code-prompts-reference
  - most-capable-agent-reference
default_chain:
  - claude-code-prompts-reference
selection_rules:
  - 仅在研究 prompt 架构或系统行为时读取
  - 不将本分类作为默认推荐链
anti_patterns:
  - 日常任务默认加载只读参考
  - 用参考 skill 取代执行 skill
skills:
  - name: claude-code-prompts-reference
    when: 研究 Claude Code prompt 结构
  - name: most-capable-agent-reference
    when: 研究 most-capable-agent 架构模式
examples:
  - 对照内置 prompt 看技能触发策略
  - 研究系统提示词怎么组织
---
