---
name: analyze-job-fit
description: Analyze internet-industry job descriptions and optional resumes to infer role goals, seniority, hard requirements, capability expectations, evidence-backed fit, gaps, resume changes, and likely interview questions. Use for Chinese or English JD text, URLs, screenshots, PDF/DOCX/TXT job files, and uploaded resumes when users ask what a role requires, whether they fit, why they may be rejected, how to tailor a resume without inventing facts, how to prepare for interviews, compare one candidate with one role, or generate a self-contained HTML job-fit report. Covers product, engineering, design, general operations, and ecommerce/store operations.
---

# 互联网岗位 JD 与简历匹配诊断

## Overview

把 JD 拆成可验证的岗位需求，再用简历中的事实证据判断匹配与缺口。关键词只用于召回；所有结论都要能回指 JD 或简历原文，不能编造成果、经历或招聘概率。

## 工作模式

- 只有 JD：输出岗位画像、能力要求、风险点、准备建议和通用面试题，不生成候选人匹配分。
- JD + 简历：增加证据化匹配、缺口分类、简历修改建议和个性化面试题。
- JD + 简历 + 面试准备：在匹配报告基础上生成问题、追问、评价点和答题结构。
- 多个 JD：逐岗独立分析；只有在用户明确要求时再做横向比较。

## 执行流程

### 1. 读取并检查输入

- 对 PDF、DOCX、图片或网页先提取正文；版式复杂时同时做视觉检查。
- 只保留与求职判断有关的信息，忽略手机号、地址、身份证、婚育等无关信息。
- 标记缺失、模糊和推断信息。没有简历时不要输出候选人匹配分。
- 开始结构化前读取 [input-output-schema.md](references/input-output-schema.md)。

### 2. 解析 JD 和岗位类型

- 按 [jd-parsing-rules.md](references/jd-parsing-rules.md) 提取岗位目标、职级、硬门槛、核心职责、工具/方法、业务场景和隐含要求。
- 选择一个主岗位模型，必要时增加一个辅模型：[产品](references/role-product.md)、[研发](references/role-engineering.md)、[设计](references/role-design.md)、[运营](references/role-operations.md)、[电商/店铺运营](references/role-ecommerce-operations.md)。
- 不确定岗位族或职级时，给出分类置信度及原因，不强行确定。

### 3. 建立证据矩阵

- 每条要求记录：JD 原文、优先级、权重、简历证据、证据等级、可迁移系数、状态和缺口类型。
- 证据优先级：量化结果 > 具体项目和职责 > 可验证技能应用 > 仅列技能词 > 无证据。
- 缺口分为：能力缺口、证据缺口、表达缺口、定位缺口、硬条件缺口。
- 按 [privacy-and-fairness.md](references/privacy-and-fairness.md) 排除敏感属性和不公平代理变量。

### 4. 评分与结论

- 读取 [scoring-rubric.md](references/scoring-rubric.md)。
- 写出 `analysis.json` 后执行：

```bash
python scripts/calculate_score.py analysis.json --write
python scripts/validate_analysis.py analysis.json
```

- 分开展示岗位匹配度、证据完整度、ATS 可读性、分析置信度。
- 硬门槛单列并影响推荐结论，不要藏在综合分里。
- 结论使用“建议投 / 修改后投 / 谨慎投 / 信息不足”，不使用“录用概率”。

### 5. 简历修改与面试题

- 读取 [interview-and-resume.md](references/interview-and-resume.md)。
- 修改建议必须写成可审计 Diff：位置、原文、建议、理由、证据状态、虚构风险。
- 没有事实支撑时，只能提出补充信息问题或建议弱化表述，不能代写虚假数字。
- 面试题必须绑定 JD 要求、简历证据或缺口，并给出评价点、答题结构、追问和风险提示。

### 6. 生成报告

```bash
python scripts/render_report.py analysis.json report.html
```

HTML 必须自包含、可打印、适配移动端，不加载外部字体、脚本或图片。视觉使用深黑、米白、亮红、网格、细边框和切角卡片，但不复用参考站点的 Logo、文案或素材。

`assets/report-template.html` 是 HTML 报告的默认视觉基准，主题标识为
`job-evidence-v1`。后续报告必须通过 `render_report.py` 使用该模板生成；
不得在单份报告中另写一套临时样式。若确需升级视觉基准，应同步更新模板、
README 和 `scripts/run_evals.py` 中的样式回归约束。

## 输出纪律

- 先结论，再证据，再行动建议。
- 清楚区分“JD 明示”“简历明示”“合理推断”“信息缺失”。
- 每个缺口都给一条可执行补救动作和优先级。
- 不因学校、公司名气、年龄、性别、地域、婚育、照片等因素加减分。
- 不自动把转行、空窗或频繁跳槽判为负面；只分析与岗位要求直接相关的事实。
- 发现用户把他人简历用于招聘决策时，提醒人工复核并避免自动淘汰。

## 评测

修改评分或报告脚本后运行：

```bash
python scripts/run_evals.py
```

方法来源与许可证说明见 [open-source-attribution.md](references/open-source-attribution.md)。
