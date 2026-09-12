#!/usr/bin/env python3
"""Render a polished, privacy-safe PDF from analysis.json."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Flowable,
    Frame,
    KeepTogether,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)

INK = colors.HexColor("#0F0E15")
INK_2 = colors.HexColor("#191720")
CREAM = colors.HexColor("#F3EDE2")
PAPER = colors.HexColor("#E9E1D4")
RED = colors.HexColor("#F43D3F")
MUTED = colors.HexColor("#6F6870")
LINE = colors.HexColor("#C9BFB2")
WHITE = colors.HexColor("#FFFAF2")


def register_fonts() -> tuple[str, str]:
    regular = Path("C:/Windows/Fonts/msyh.ttc")
    bold = Path("C:/Windows/Fonts/msyhbd.ttc")
    try:
        pdfmetrics.registerFont(TTFont("JobFitCN", str(regular)))
        pdfmetrics.registerFont(TTFont("JobFitCN-Bold", str(bold)))
        return "JobFitCN", "JobFitCN-Bold"
    except Exception:
        from reportlab.pdfbase.cidfonts import UnicodeCIDFont

        pdfmetrics.registerFont(UnicodeCIDFont("STSong-Light"))
        return "STSong-Light", "STSong-Light"


FONT, FONT_BOLD = register_fonts()


def safe(value: object) -> str:
    return escape(str(value if value is not None else ""))


def rich(value: object) -> str:
    return safe(value).replace("\n", "<br/>")


def draw_grid(canvas, width: float, height: float) -> None:
    canvas.saveState()
    canvas.setStrokeColor(colors.Color(1, 1, 1, alpha=0.055))
    canvas.setLineWidth(0.35)
    step = 18 * mm
    x = 0
    while x <= width:
        canvas.line(x, 0, x, height)
        x += step
    y = 0
    while y <= height:
        canvas.line(0, y, width, y)
        y += step
    canvas.restoreState()


class CoverFlowable(Flowable):
    def __init__(self, data: dict, styles: dict[str, ParagraphStyle], height: float):
        super().__init__()
        self.data = data
        self.styles = styles
        self.width = A4[0] - 32 * mm
        self.height = height

    def draw(self) -> None:
        canvas = self.canv
        meta = self.data["meta"]
        job = self.data["job"]
        scores = self.data["scores"]
        rec = self.data["recommendation"]
        width, height = A4
        canvas.saveState()
        canvas.translate(-16 * mm, -14 * mm)
        canvas.setFillColor(INK)
        canvas.rect(0, 0, width, height, fill=1, stroke=0)
        draw_grid(canvas, width, height)

        canvas.setFillColor(RED)
        canvas.rect(0, height - 10 * mm, width, 10 * mm, fill=1, stroke=0)
        canvas.setFillColor(INK)
        canvas.setFont(FONT_BOLD, 8)
        canvas.drawString(16 * mm, height - 6.5 * mm, "JOB EVIDENCE LAB  /  ROLE MATCH REPORT")

        canvas.setFillColor(RED)
        canvas.setFont(FONT_BOLD, 9)
        canvas.drawString(16 * mm, height - 31 * mm, "// AI PRODUCT DIRECTOR")

        title = Paragraph(
            "岗位匹配<br/><font color='#F43D3F'>诊断报告</font>",
            self.styles["cover_title"],
        )
        _, title_h = title.wrap(width - 32 * mm, 80 * mm)
        title.drawOn(canvas, 16 * mm, height - 39 * mm - title_h)

        canvas.setStrokeColor(colors.Color(1, 1, 1, alpha=0.35))
        canvas.setLineWidth(0.8)
        canvas.line(16 * mm, height - 104 * mm, width - 16 * mm, height - 104 * mm)

        canvas.setFillColor(CREAM)
        canvas.setFont(FONT_BOLD, 17)
        canvas.drawString(16 * mm, height - 118 * mm, safe(job.get("title", "岗位诊断")))

        score = int(scores.get("job_fit", 0))
        canvas.setFillColor(WHITE)
        canvas.setFont(FONT_BOLD, 60)
        canvas.drawRightString(width - 17 * mm, height - 129 * mm, f"{score}")
        canvas.setFillColor(RED)
        canvas.setFont(FONT_BOLD, 10)
        canvas.drawRightString(width - 17 * mm, height - 136 * mm, "JOB FIT / 100")

        canvas.setFillColor(RED)
        canvas.rect(16 * mm, height - 151 * mm, 44 * mm, 12 * mm, fill=1, stroke=0)
        canvas.setFillColor(INK)
        canvas.setFont(FONT_BOLD, 13)
        canvas.drawCentredString(38 * mm, height - 147 * mm, safe(rec.get("label", "")))

        summary = Paragraph(rich(job.get("summary", "")), self.styles["cover_body"])
        _, summary_h = summary.wrap(width - 32 * mm, 50 * mm)
        summary.drawOn(canvas, 16 * mm, height - 164 * mm - summary_h)

        canvas.setStrokeColor(colors.Color(1, 1, 1, alpha=0.25))
        canvas.line(16 * mm, 43 * mm, width - 16 * mm, 43 * mm)
        canvas.setFillColor(colors.HexColor("#AAA5AE"))
        canvas.setFont(FONT, 8)
        canvas.drawString(16 * mm, 34 * mm, f"ANALYSIS ID  {safe(meta.get('analysis_id', ''))}")
        canvas.drawRightString(width - 16 * mm, 34 * mm, safe(meta.get("generated_at", "")))
        canvas.setFillColor(CREAM)
        canvas.setFont(FONT, 8)
        canvas.drawString(16 * mm, 25 * mm, "隐私说明：姓名、照片、电话、邮箱和出生年月未参与分析，也未写入本报告。")
        canvas.restoreState()


def make_styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "cover_title": ParagraphStyle(
            "cover_title",
            parent=base["Title"],
            fontName=FONT_BOLD,
            fontSize=40,
            leading=45,
            textColor=CREAM,
            alignment=TA_LEFT,
            spaceAfter=0,
        ),
        "cover_body": ParagraphStyle(
            "cover_body",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=11,
            leading=19,
            textColor=colors.HexColor("#C2BBC3"),
        ),
        "kicker": ParagraphStyle(
            "kicker",
            parent=base["BodyText"],
            fontName=FONT_BOLD,
            fontSize=8,
            leading=11,
            textColor=RED,
            spaceAfter=3 * mm,
        ),
        "h1": ParagraphStyle(
            "h1",
            parent=base["Heading1"],
            fontName=FONT_BOLD,
            fontSize=23,
            leading=29,
            textColor=INK,
            spaceAfter=5 * mm,
        ),
        "h2": ParagraphStyle(
            "h2",
            parent=base["Heading2"],
            fontName=FONT_BOLD,
            fontSize=14,
            leading=19,
            textColor=INK,
            spaceBefore=3 * mm,
            spaceAfter=2.5 * mm,
        ),
        "body": ParagraphStyle(
            "body",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=9,
            leading=14,
            textColor=colors.HexColor("#474249"),
            spaceAfter=2 * mm,
        ),
        "small": ParagraphStyle(
            "small",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=7.5,
            leading=11,
            textColor=MUTED,
        ),
        "label": ParagraphStyle(
            "label",
            parent=base["BodyText"],
            fontName=FONT_BOLD,
            fontSize=7.2,
            leading=10,
            textColor=MUTED,
        ),
        "card_title": ParagraphStyle(
            "card_title",
            parent=base["Heading3"],
            fontName=FONT_BOLD,
            fontSize=10.5,
            leading=15,
            textColor=INK,
            spaceAfter=1.5 * mm,
        ),
        "card_body": ParagraphStyle(
            "card_body",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=8.2,
            leading=13,
            textColor=colors.HexColor("#4F4950"),
        ),
        "white_small": ParagraphStyle(
            "white_small",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=7.6,
            leading=11,
            textColor=CREAM,
            alignment=TA_CENTER,
        ),
    }


def section_title(index: str, title: str, subtitle: str, styles: dict) -> list:
    return [
        Paragraph(f"// {safe(index)}", styles["kicker"]),
        Paragraph(safe(title), styles["h1"]),
        Paragraph(safe(subtitle), styles["body"]),
        Spacer(1, 3 * mm),
    ]


def score_table(data: dict, styles: dict) -> Table:
    scores = data["scores"]
    values = [
        ("岗位匹配度", scores.get("job_fit", 0)),
        ("证据完整度", scores.get("evidence_completeness", 0)),
        ("ATS 可读性", scores.get("ats_readability", 0)),
        ("分析置信度", scores.get("analysis_confidence", 0)),
    ]
    cells = []
    for label, score in values:
        cells.append(
            Paragraph(
                f"<font size='7'>{safe(label)}</font><br/><font size='25'><b>{int(score)}</b></font><font size='8'> /100</font>",
                ParagraphStyle(
                    f"score-{label}",
                    parent=styles["white_small"],
                    fontName=FONT,
                    leading=26,
                    textColor=CREAM,
                ),
            )
        )
    table = Table([cells], colWidths=[(A4[0] - 32 * mm) / 4] * 4, rowHeights=[35 * mm])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), INK),
                ("BOX", (0, 0), (-1, -1), 0.8, INK),
                ("INNERGRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#403C46")),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                ("LINEBELOW", (0, 0), (-1, 0), 3, RED),
                ("LEFTPADDING", (0, 0), (-1, -1), 3 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3 * mm),
            ]
        )
    )
    return table


def two_col_cards(items: list, builder, width: float) -> list:
    rows = []
    for i in range(0, len(items), 2):
        row = [builder(items[i])]
        row.append(builder(items[i + 1]) if i + 1 < len(items) else "")
        rows.append(row)
    if not rows:
        return []
    table = Table(rows, colWidths=[width / 2 - 2 * mm] * 2, hAlign="LEFT")
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BOX", (0, 0), (-1, -1), 0.5, LINE),
                ("INNERGRID", (0, 0), (-1, -1), 0.5, LINE),
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F8F2E8")),
                ("LEFTPADDING", (0, 0), (-1, -1), 4 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 4 * mm),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4 * mm),
            ]
        )
    )
    return [table]


def build_story(data: dict) -> list:
    styles = make_styles()
    width = A4[0] - 32 * mm
    story: list = [CoverFlowable(data, styles, A4[1] - 28 * mm), PageBreak()]

    story += section_title(
        "00 / DECISION",
        "先看结论",
        "这个分数衡量的是当前材料与当前岗位的证据匹配，不代表候选人的总体潜力。",
        styles,
    )
    story += [
        score_table(data, styles),
        Spacer(1, 7 * mm),
        Paragraph("投递建议", styles["h2"]),
        Table(
            [
                [
                    Paragraph(
                        safe(data["recommendation"].get("label", "")),
                        ParagraphStyle(
                            "rec",
                            parent=styles["card_title"],
                            fontSize=18,
                            leading=22,
                            textColor=INK,
                            alignment=TA_CENTER,
                        ),
                    ),
                    Paragraph(rich(data["recommendation"].get("rationale", "")), styles["card_body"]),
                ]
            ],
            colWidths=[38 * mm, width - 38 * mm],
            style=TableStyle(
                [
                    ("BACKGROUND", (0, 0), (0, 0), RED),
                    ("BACKGROUND", (1, 0), (1, 0), colors.HexColor("#F8F2E8")),
                    ("BOX", (0, 0), (-1, -1), 0.6, INK),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 5 * mm),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 5 * mm),
                    ("TOPPADDING", (0, 0), (-1, -1), 5 * mm),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 5 * mm),
                ]
            ),
        ),
        Spacer(1, 8 * mm),
        Paragraph("岗位本质", styles["h2"]),
        Paragraph(rich(data["job"].get("role_goal", "")), styles["body"]),
        Spacer(1, 4 * mm),
    ]

    story += section_title(
        "01 / HARD GATES",
        "硬门槛核验",
        "硬条件与能力得分分开判断，任何缺失项都不会被综合分掩盖。",
        styles,
    )
    gate_rows = [
        [
            Paragraph("状态", styles["label"]),
            Paragraph("要求", styles["label"]),
            Paragraph("简历证据与影响", styles["label"]),
        ]
    ]
    for gate in data["job"].get("hard_gates", []):
        status = gate.get("status", "unknown")
        gate_rows.append(
            [
                Paragraph(safe(status.upper()), styles["card_title"]),
                Paragraph(rich(gate.get("requirement", "")), styles["card_body"]),
                Paragraph(
                    f"{rich(gate.get('evidence', ''))}<br/><font color='#F43D3F'><b>影响：</b></font>{rich(gate.get('impact', ''))}",
                    styles["card_body"],
                ),
            ]
        )
    gates = Table(gate_rows, colWidths=[23 * mm, 58 * mm, width - 81 * mm], repeatRows=1)
    gates.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), INK),
                ("TEXTCOLOR", (0, 0), (-1, 0), CREAM),
                ("BOX", (0, 0), (-1, -1), 0.6, INK),
                ("INNERGRID", (0, 1), (-1, -1), 0.4, LINE),
                ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F8F2E8")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 3 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 3 * mm),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3 * mm),
            ]
        )
    )
    story += [gates, PageBreak()]

    story += section_title(
        "02 / EVIDENCE MATRIX",
        "要求与证据",
        "关键词只用于定位要求；最终判断取决于项目事实、本人动作、结果和可迁移性。",
        styles,
    )
    for req in data.get("requirements", []):
        top = Table(
            [
                [
                    Paragraph(safe(req.get("id", "")), styles["card_title"]),
                    Paragraph(rich(req.get("requirement", "")), styles["card_title"]),
                    Paragraph(
                        f"{safe(req.get('priority', ''))} / L{req.get('evidence_level', 0)}",
                        styles["label"],
                    ),
                ],
                [
                    "",
                    Paragraph(
                        f"<b>简历证据：</b>{rich(req.get('resume_evidence') or '未发现直接证据')}<br/>"
                        f"<b>判断：</b>{rich(req.get('analysis', ''))}",
                        styles["card_body"],
                    ),
                    Paragraph(safe(req.get("status", "")), styles["label"]),
                ],
            ],
            colWidths=[14 * mm, width - 42 * mm, 28 * mm],
        )
        top.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (0, -1), RED),
                    ("BACKGROUND", (1, 0), (-1, -1), colors.HexColor("#F8F2E8")),
                    ("BOX", (0, 0), (-1, -1), 0.5, LINE),
                    ("LINEBELOW", (1, 0), (-1, 0), 0.4, LINE),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 3 * mm),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 3 * mm),
                    ("TOPPADDING", (0, 0), (-1, -1), 3 * mm),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3 * mm),
                ]
            )
        )
        story += [KeepTogether([top, Spacer(1, 2.5 * mm)])]

    story += section_title(
        "03 / SIGNALS",
        "优势与缺口",
        "能力不足、证据不足、表达问题和岗位定位必须分别处理。",
        styles,
    )
    story += [Paragraph("已验证优势", styles["h2"])]

    def strength_card(item: dict) -> Paragraph:
        return Paragraph(
            f"<b>{safe(item.get('title', ''))}</b><br/>{rich(item.get('evidence', ''))}<br/>"
            f"<font color='#F43D3F'><b>岗位价值：</b></font>{rich(item.get('value', ''))}",
            styles["card_body"],
        )

    story += two_col_cards(data.get("strengths", []), strength_card, width)
    story += [Spacer(1, 6 * mm), Paragraph("优先缺口", styles["h2"])]

    def gap_card(item: dict) -> Paragraph:
        return Paragraph(
            f"<font color='#F43D3F'><b>{safe(item.get('priority', ''))}</b></font> "
            f"<b>{safe(item.get('title', ''))}</b><br/>{rich(item.get('impact', ''))}<br/>"
            f"<b>行动：</b>{rich(item.get('action', ''))}",
            styles["card_body"],
        )

    story += two_col_cards(data.get("gaps", []), gap_card, width)
    story += [PageBreak()]

    story += section_title(
        "04 / RESUME DIFF",
        "简历修改建议",
        "只重组已有事实；待确认内容不会被包装成既成成果。",
        styles,
    )
    for change in data.get("resume_changes", []):
        block = Table(
            [
                [
                    Paragraph(
                        f"<font color='#F43D3F'><b>{safe(change.get('location', ''))}</b></font><br/>"
                        f"<b>{safe(change.get('title', ''))}</b>",
                        styles["card_title"],
                    ),
                    Paragraph(
                        f"<b>证据状态：</b>{safe(change.get('evidence_status', ''))}<br/>"
                        f"<b>虚构风险：</b>{safe(change.get('fabrication_risk', ''))}",
                        styles["small"],
                    ),
                ],
                [
                    Paragraph(f"<b>原文</b><br/>{rich(change.get('original', ''))}", styles["card_body"]),
                    Paragraph(f"<b>建议</b><br/>{rich(change.get('suggested', ''))}", styles["card_body"]),
                ],
                [
                    Paragraph(f"<b>理由：</b>{rich(change.get('reason', ''))}", styles["card_body"]),
                    "",
                ],
            ],
            colWidths=[width / 2, width / 2],
        )
        block.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), INK),
                    ("TEXTCOLOR", (0, 0), (-1, 0), CREAM),
                    ("BACKGROUND", (0, 1), (0, 1), colors.HexColor("#EEE7DC")),
                    ("BACKGROUND", (1, 1), (1, 1), colors.HexColor("#F8F2E8")),
                    ("SPAN", (0, 2), (1, 2)),
                    ("BOX", (0, 0), (-1, -1), 0.6, INK),
                    ("INNERGRID", (0, 1), (-1, 1), 0.4, LINE),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 4 * mm),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 4 * mm),
                    ("TOPPADDING", (0, 0), (-1, -1), 4 * mm),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 4 * mm),
                ]
            )
        )
        story += [KeepTogether([block, Spacer(1, 4 * mm)])]

    story += section_title(
        "05 / INTERVIEW",
        "高概率面试题",
        "题目由岗位核心要求、简历强证据和风险缺口触发。",
        styles,
    )
    for idx, question in enumerate(data.get("interview_questions", []), 1):
        points = "；".join(map(str, question.get("evaluation_points", [])))
        follow = "；".join(map(str, question.get("follow_ups", [])))
        q = Table(
            [
                [
                    Paragraph(f"{idx:02d}", styles["card_title"]),
                    Paragraph(rich(question.get("question", "")), styles["card_title"]),
                ],
                [
                    "",
                    Paragraph(
                        f"<b>为什么问：</b>{rich(question.get('why', ''))}<br/>"
                        f"<b>优秀答案：</b>{safe(points)}<br/>"
                        f"<b>答题结构：</b>{rich(question.get('answer_structure', ''))}<br/>"
                        f"<b>可能追问：</b>{safe(follow)}<br/>"
                        f"<font color='#F43D3F'><b>风险：</b></font>{rich(question.get('risk_note', ''))}",
                        styles["card_body"],
                    ),
                ],
            ],
            colWidths=[14 * mm, width - 14 * mm],
        )
        q.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (0, -1), RED),
                    ("BACKGROUND", (1, 0), (1, -1), colors.HexColor("#F8F2E8")),
                    ("BOX", (0, 0), (-1, -1), 0.5, LINE),
                    ("LINEBELOW", (1, 0), (1, 0), 0.4, LINE),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 4 * mm),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 4 * mm),
                    ("TOPPADDING", (0, 0), (-1, -1), 3.5 * mm),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5 * mm),
                ]
            )
        )
        story += [KeepTogether([q, Spacer(1, 3 * mm)])]

    story += [PageBreak()]
    story += section_title(
        "06 / ACTION PLAN",
        "行动计划",
        "先修正岗位定位，再补影响下一阶段求职的硬证据。",
        styles,
    )
    action_cells = []
    for item in data.get("action_plan", [])[:3]:
        action_cells.append(
            Paragraph(
                f"<font color='#F43D3F'><b>{safe(item.get('horizon', ''))}</b></font><br/>"
                f"<b>{safe(item.get('action', ''))}</b><br/>{rich(item.get('output', ''))}",
                styles["card_body"],
            )
        )
    action_table = Table([action_cells], colWidths=[width / 3] * 3)
    action_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F8F2E8")),
                ("BOX", (0, 0), (-1, -1), 0.6, INK),
                ("INNERGRID", (0, 0), (-1, -1), 0.5, LINE),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5 * mm),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 5 * mm),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5 * mm),
            ]
        )
    )
    story += [action_table, Spacer(1, 8 * mm), Paragraph("报告局限", styles["h2"])]
    for item in data.get("limitations", []):
        story.append(Paragraph(f"• {safe(item)}", styles["body"]))
    story += [
        Spacer(1, 10 * mm),
        Paragraph(
            "最终结论：不建议将 AI 产品总监作为当前主投岗位。现有优势更适合用户增长、会员、商业化或数据驱动产品经理；AI 方向应先通过真实 Agent 项目完成能力迁移。",
            ParagraphStyle(
                "final",
                parent=styles["body"],
                fontName=FONT_BOLD,
                fontSize=12,
                leading=19,
                textColor=INK,
                borderColor=RED,
                borderWidth=1.5,
                borderPadding=5 * mm,
                backColor=colors.HexColor("#F8F2E8"),
            ),
        ),
    ]
    return story


def body_page(canvas, doc) -> None:
    width, height = A4
    canvas.saveState()
    canvas.setFillColor(CREAM)
    canvas.rect(0, 0, width, height, fill=1, stroke=0)
    canvas.setFillColor(RED)
    canvas.rect(0, height - 5 * mm, width, 5 * mm, fill=1, stroke=0)
    canvas.setStrokeColor(LINE)
    canvas.line(16 * mm, 14 * mm, width - 16 * mm, 14 * mm)
    canvas.setFont(FONT, 7)
    canvas.setFillColor(MUTED)
    canvas.drawString(16 * mm, 9 * mm, "JOB EVIDENCE LAB  /  匿名候选人")
    canvas.drawRightString(width - 16 * mm, 9 * mm, f"{doc.page}")
    canvas.restoreState()


def cover_page(canvas, doc) -> None:
    return None


def render(data: dict, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    doc = BaseDocTemplate(
        str(output),
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=14 * mm,
        bottomMargin=18 * mm,
        title=f"{data['job'].get('title', '岗位')} - 匹配诊断报告",
        author="Job Evidence Lab",
        subject="证据化岗位匹配、简历差距与面试准备",
    )
    cover_frame = Frame(
        16 * mm,
        14 * mm,
        A4[0] - 32 * mm,
        A4[1] - 28 * mm,
        leftPadding=0,
        rightPadding=0,
        topPadding=0,
        bottomPadding=0,
        id="cover",
    )
    body_frame = Frame(
        16 * mm,
        18 * mm,
        A4[0] - 32 * mm,
        A4[1] - 32 * mm,
        leftPadding=0,
        rightPadding=0,
        topPadding=0,
        bottomPadding=0,
        id="body",
    )
    doc.addPageTemplates(
        [
            PageTemplate(id="cover", frames=[cover_frame], onPage=cover_page, autoNextPageTemplate="body"),
            PageTemplate(id="body", frames=[body_frame], onPage=body_page),
        ]
    )
    doc.build(build_story(data))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    data = json.loads(args.input.read_text(encoding="utf-8"))
    render(data, args.output)
    print(args.output.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
