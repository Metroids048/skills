#!/usr/bin/env python3
"""Render a self-contained job-fit HTML report."""

from __future__ import annotations

import argparse
import html
import json
from pathlib import Path
from typing import Any


def esc(value: Any) -> str:
    return html.escape(str(value if value is not None else ""))


def tag(value: str, style: str = "") -> str:
    return f'<span class="badge {style}">{esc(value)}</span>'


def cards(items: list[dict[str, Any]], kind: str) -> str:
    result = []
    for item in items:
        title = item.get("title") or item.get("question") or "未命名"
        if kind == "gap":
            detail = f"<p>{esc(item.get('impact',''))}</p><p><b>行动：</b>{esc(item.get('action',''))}</p>"
            labels = tag(item.get("priority", ""), "red") + tag(item.get("type", ""))
        elif kind == "change":
            detail = (
                '<div class="diff"><div><span class="micro">Before</span><br>'
                f"{esc(item.get('original',''))}</div><div class=\"after\"><span class=\"micro\">After</span><br>"
                f"{esc(item.get('suggested',''))}</div></div><p>{esc(item.get('reason',''))}</p>"
            )
            labels = tag(item.get("location", ""), "dark") + tag(item.get("evidence_status", ""))
        else:
            detail = f"<p>{esc(item.get('evidence',''))}</p><p>{esc(item.get('value',''))}</p>"
            labels = ""
        result.append(f'<article class="card"><div>{labels}</div><h3>{esc(title)}</h3>{detail}</article>')
    return "".join(result) or '<p class="section-note">暂无可展示内容。</p>'


def render(data: dict[str, Any]) -> str:
    meta, job = data["meta"], data["job"]
    scores, rec = data["scores"], data["recommendation"]
    score_labels = [
        (
            "跟岗位有多合适",
            "job_fit",
            "看你的经历和能力，跟这份岗位要求对不对得上。低分不代表你能力差，只表示目前不适合这个岗位。",
        ),
        (
            "简历证明得够不够",
            "evidence_completeness",
            "看简历有没有用具体项目、你的动作和结果，把能力证明出来。可能会做但没有写，也会得到低分。",
        ),
        (
            "招聘系统能不能读懂",
            "ats_readability",
            "看招聘网站的 ATS 系统能不能顺利读出工作经历、时间、岗位和关键词。复杂排版、表格或图片简历会影响读取。",
        ),
        (
            "这次判断靠不靠谱",
            "analysis_confidence",
            "看这次分析使用的材料是否完整、清楚。高分只表示判断把握较大，不表示你和岗位很匹配。",
        ),
    ]
    score_html = "".join(
        f'<div class="score" style="--score:{int(scores.get(key,0))}%"><div class="score-name">{esc(label)}'
        f'<button class="help" type="button" aria-label="解释：{esc(label)}" aria-expanded="false" data-tip="{esc(tip)}">?</button></div>'
        f'<div class="score-value">{int(scores.get(key,0))}<small>/100</small></div></div>'
        for label, key, tip in score_labels
    )
    req_html = ""
    for item in data.get("requirements", []):
        level = int(item.get("evidence_level", 0))
        req_html += (
            '<div class="req">'
            f'<div class="req-id">{esc(item.get("id",""))}</div>'
            f'<div><div class="req-title">{esc(item.get("requirement",""))}</div><div class="micro">{esc(item.get("category",""))}</div></div>'
            f'<div>{tag(item.get("priority",""))}</div>'
            f'<div>{tag(item.get("status",""),"dark")}<div class="meter"><i style="width:{level*25}%"></i></div></div>'
            f'<div class="req-evidence">{esc(item.get("resume_evidence") or "未发现简历证据")}<br><span class="micro">{esc(item.get("analysis",""))}</span></div>'
            "</div>"
        )
    questions = ""
    for q in data.get("interview_questions", []):
        points = "；".join(map(str, q.get("evaluation_points", [])))
        follow = "；".join(map(str, q.get("follow_ups", [])))
        questions += (
            '<article class="card question">'
            f'<div>{tag(q.get("type",""),"red")}</div><h3>{esc(q.get("question",""))}</h3>'
            f'<p><b>验证：</b>{esc(q.get("why",""))}</p><p><b>优秀答案：</b>{esc(points)}</p>'
            f'<p><b>结构：</b>{esc(q.get("answer_structure",""))}</p><p><b>追问：</b>{esc(follow)}</p></article>'
        )
    gates = "".join(
        '<article class="card">'
        f'<div>{tag(gate.get("status",""),"red" if gate.get("status") == "missing" else "dark")}</div>'
        f'<h3>{esc(gate.get("requirement",""))}</h3><p>{esc(gate.get("evidence",""))}</p>'
        f'<p><b>影响：</b>{esc(gate.get("impact",""))}</p></article>'
        for gate in job.get("hard_gates", [])
    )
    plan = "".join(
        f'<div class="step"><span class="micro">{esc(x.get("horizon",""))}</span><h3>{esc(x.get("action",""))}</h3><p>{esc(x.get("output",""))}</p></div>'
        for x in data.get("action_plan", [])[:3]
    )
    limitations = "；".join(map(str, data.get("limitations", []))) or "无"
    ticker = " ".join(
        f"<span>{esc(text)}</span>"
        for text in (
            job.get("title", "岗位诊断"),
            meta.get("role_family", ""),
            meta.get("seniority", ""),
            f"FIT {scores.get('job_fit',0)}",
            rec.get("label", ""),
        )
    )
    return f"""
<button class="print" type="button">PRINT / PDF</button>
<header class="hero">
  <div class="shell">
    <div class="topbar"><div class="brand"><b>//</b> JOB EVIDENCE LAB</div><div class="topmeta">{esc(meta.get('analysis_id',''))}<br>{esc(meta.get('generated_at',''))}</div></div>
    <div class="hero-grid">
      <div><div class="eyebrow">// ROLE MATCH REPORT</div><h1>岗位匹配<span>JOB FIT</span></h1><p class="hero-summary">{esc(job.get('summary',''))}</p></div>
      <aside class="verdict"><div class="verdict-label">Recommendation / 投递建议</div><div class="verdict-main">{esc(rec.get('label',''))}</div><p>{esc(rec.get('rationale',''))}</p></aside>
    </div>
  </div>
</header>
<div class="ticker"><div class="ticker-track">{ticker} {ticker}</div></div>
<main><div class="shell">
  <section class="intro"><div class="section-label">// 00 BRIEF</div><div><h2>{esc(job.get('title','岗位诊断'))}</h2><p>{esc(job.get('role_goal',''))}</p><div>{tag(meta.get('role_family',''),"dark")}{tag(meta.get('specialty',''))}{tag(meta.get('seniority',''))}</div></div></section>
  <div class="score-grid">{score_html}</div>
  <section class="section"><div class="section-head"><div class="section-label">// GATE CHECK</div><div><h2>硬门槛</h2><p class="section-note">硬条件与能力得分分开判断，避免被综合分掩盖。</p></div></div><div class="cards">{gates or '<p class="section-note">JD 未识别出明确硬门槛。</p>'}</div></section>
  <section class="section"><div class="section-head"><div class="section-label">// 01 EVIDENCE</div><div><h2>要求与证据</h2><p class="section-note">分数来自逐条要求的证据等级与可迁移性，不是关键词命中率。</p></div></div>
    <div class="req-table"><div class="req head"><div>ID</div><div>岗位要求</div><div>优先级</div><div>状态</div><div>简历证据 / 判断</div></div>{req_html}</div>
  </section>
  <section class="section"><div class="section-head"><div class="section-label">// 02 SIGNALS</div><div><h2>优势与缺口</h2><p class="section-note">把能力不足、证据不足和表达问题分开处理。</p></div></div>
    <h3>已验证优势</h3><div class="cards">{cards(data.get('strengths',[]),'strength')}</div>
    <h3 style="margin-top:40px">优先缺口</h3><div class="cards">{cards(data.get('gaps',[]),'gap')}</div>
  </section>
  <section class="section"><div class="section-head"><div class="section-label">// 03 RESUME DIFF</div><div><h2>简历修改</h2><p class="section-note">只重组已有事实；待确认内容不会被包装成既成成果。</p></div></div><div class="cards">{cards(data.get('resume_changes',[]),'change')}</div></section>
  <section class="section"><div class="section-head"><div class="section-label">// 04 INTERVIEW</div><div><h2>高概率追问</h2><p class="section-note">问题由岗位核心要求、简历强证据和风险缺口触发。</p></div></div><div class="cards questions">{questions or '<p>暂无题目。</p>'}</div></section>
  <section class="section"><div class="section-head"><div class="section-label">// 05 ACTION</div><div><h2>行动计划</h2><p class="section-note">先补影响投递决策的证据，再补长期能力。</p></div></div><div class="timeline">{plan}</div></section>
</div></main>
<footer class="footer"><div class="shell footer-grid"><div>Evidence-based career analysis</div><div>局限：{esc(limitations)}</div></div></footer>
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    data = json.loads(args.input.read_text(encoding="utf-8"))
    template_path = Path(__file__).resolve().parent.parent / "assets" / "report-template.html"
    template = template_path.read_text(encoding="utf-8")
    title = f"{data.get('job',{}).get('title','岗位')}｜岗位匹配诊断"
    output = template.replace("{{REPORT_TITLE}}", esc(title)).replace("{{REPORT_BODY}}", render(data))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output, encoding="utf-8")
    print(args.output.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
