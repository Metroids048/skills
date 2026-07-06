---
category: 60-ui-figma
purpose: UI 设计实现、现有页面改版、Figma 对照开发与图转代码。
use_when:
  - Figma 转代码
  - 对照设计稿实现
  - 现有页面改版
  - UI 优化或截图复刻
do_not_use_when:
  - 只做业务逻辑调试
  - 只做文档研究
priority_order:
  - figma-workflow
  - figma2code
  - image-to-code
  - redesign-existing-projects
  - design-taste-frontend
default_chain:
  - figma-workflow
selection_rules:
  - 涉及 Agent Platform figma.config 同步时选 figma-workflow
  - 纯 Figma URL 或 frame 实现时选 figma2code
  - 截图或参考图实现时选 image-to-code
  - 现有页面优化时选 redesign-existing-projects
  - 需要提升整体设计感时选 design-taste-frontend
anti_patterns:
  - figma-workflow 与 figma2code 无边界同时重载
  - 用设计 skill 处理纯后端或调试任务
skills:
  - name: figma-workflow
    when: 需要 figma.config、三端 Figma 同步、Agent Platform 设计流程
  - name: figma2code
    when: 纯 Figma frame 或 URL 到前端实现
  - name: image-to-code
    when: 截图、参考图、静态视觉对照
  - name: redesign-existing-projects
    when: 现有页面层级、间距、排版优化
  - name: design-taste-frontend
    when: 需要更强设计感与 anti-slop 方向
examples:
  - 按这个 Figma frame 实现页面
  - 把现有 dashboard 做一轮改版
  - 按截图把页面还原出来
---
