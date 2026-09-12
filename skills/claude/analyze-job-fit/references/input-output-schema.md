# 输入与输出结构

## 输入

- `jd_text`：必填；JD 原文或从文件/网页提取的正文。
- `resume_text`：可选；简历正文。缺失时不得生成候选人匹配分。
- `target_context`：可选；地点、职级、行业、求职目标、面试轮次。
- `output_language`：默认跟随用户语言。

## analysis.json

顶层字段：

```json
{
  "meta": {
    "analysis_id": "string",
    "generated_at": "ISO-8601",
    "language": "zh-CN",
    "role_family": "product|engineering|design|operations|ecommerce_operations",
    "specialty": "string",
    "seniority": "string",
    "classification_confidence": 0,
    "source_completeness": 0
  },
  "job": {
    "title": "string",
    "company": "string",
    "industry": "string",
    "role_goal": "string",
    "summary": "string",
    "hard_gates": []
  },
  "scores": {},
  "recommendation": {},
  "requirements": [],
  "strengths": [],
  "gaps": [],
  "resume_changes": [],
  "interview_questions": [],
  "action_plan": [],
  "limitations": []
}
```

`hard_gates` 每项：`requirement`、`status`（met/partial/missing/unknown）、`evidence`、`impact`。

`scores`：`job_fit`、`evidence_completeness`、`ats_readability`、`analysis_confidence`，均为 0–100。

`recommendation`：`label`（建议投/修改后投/谨慎投/信息不足）、`priority`、`rationale`。

`requirements` 每项：

```json
{
  "id": "R1",
  "category": "能力类别",
  "requirement": "JD 要求",
  "jd_evidence": "JD 原文",
  "priority": "must|core|preferred",
  "weight": 1,
  "evidence_level": 0,
  "transfer_factor": 1,
  "status": "matched|transferable|weak|missing|unknown",
  "resume_evidence": "简历原文或空",
  "gap_type": "capability|evidence|expression|positioning|hard_condition|none",
  "analysis": "判断理由"
}
```

`strengths` 每项：`title`、`evidence`、`value`。

`gaps` 每项：`title`、`type`、`priority`、`evidence`、`impact`、`action`。

`resume_changes` 每项：`location`、`original`、`suggested`、`reason`、`evidence_status`、`fabrication_risk`。

`interview_questions` 每项：`question`、`type`、`trigger`、`why`、`evaluation_points`、`answer_structure`、`follow_ups`、`risk_note`。
`action_plan` 每项：`horizon`、`action`、`output`。

所有引用字段尽量保存短原文；无法确认时使用空值并写入 `limitations`，不要猜。
