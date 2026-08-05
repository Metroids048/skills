#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""全局审查：对照方案验收脚手架 vs 真实内容完整度。"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

CENTRAL = Path(__file__).resolve().parent.parent
REGISTRY = CENTRAL / "项目注册表.yaml"


def stubby(text: str) -> bool:
    markers = ["由全局知识管理中心安装", "（待同步）", "待定\n"]
    if len(text) < 120:
        return True
    if "梳理时间" in text or "自 USER_KNOWLEDGE_BASE" in text or "登记名" in text:
        return False
    return any(m in text for m in markers)


def main() -> int:
    reg = yaml.safe_load(REGISTRY.read_text(encoding="utf-8"))
    enabled = [p for p in reg["projects"] if p.get("enabled")]
    rows = []
    stub_count = 0
    filled = 0
    for p in enabled:
        root = Path(p["path"])
        kb = root / "项目知识库"
        overview = kb / "项目总览.md"
        status = "MISSING"
        chars = 0
        if overview.is_file():
            t = overview.read_text(encoding="utf-8", errors="ignore")
            chars = len(t)
            if stubby(t):
                status = "STUB"
                stub_count += 1
            else:
                status = "FILLED"
                filled += 1
        rows.append({"name": p["name"], "status": status, "overview_chars": chars, "path": p["path"]})

    tools = {x.name for x in (CENTRAL / "工具").glob("*.py")}
    expected = [
        "初始化管理中心.py",
        "扫描本机项目.py",
        "安装项目记忆.py",
        "开始AI任务.py",
        "结束并归档.py",
        "同步项目知识.py",
        "导入聊天记录.py",
        "检查隐私.py",
        "检查冲突与重复.py",
        "生成每周复盘.py",
        "提取视频内容.py",
        "汇总跨项目经验.py",
        "梳理项目知识.py",
        "同步用户主知识拆分.py",
        "端到端验收.py",
    ]
    missing_tools = [e for e in expected if e not in tools]

    xp_targets = [
        CENTRAL / "跨项目经验" / "Agent错误模式.md",
        CENTRAL / "跨项目经验" / "已验证解决方案.md",
        CENTRAL / "跨项目经验" / "架构与产品经验.md",
        CENTRAL / "跨项目经验" / "工具与Skills经验.md",
        CENTRAL / "内容素材中心" / "可公开证据索引.md",
        CENTRAL / "内容素材中心" / "已发布内容复盘.md",
    ]
    xp_placeholder = []
    for p in xp_targets:
        if not p.is_file():
            xp_placeholder.append(f"MISSING:{p.name}")
            continue
        t = p.read_text(encoding="utf-8", errors="ignore")
        if "模块 7 汇总前占位" in t:
            xp_placeholder.append(p.name)
            continue
        if any(ln.strip() in {"（占位）", "(占位)"} for ln in t.splitlines()):
            xp_placeholder.append(p.name)
            continue
        body = "\n".join(ln for ln in t.splitlines() if ln.strip() and not ln.strip().startswith("#"))
        if len(body.strip()) < 40:
            xp_placeholder.append(p.name)

    verdict = "COMPLETE" if filled == len(enabled) and not missing_tools and not xp_placeholder else "PARTIAL"
    if stub_count:
        verdict = "PARTIAL"

    md = CENTRAL / "日志" / "全局审查报告.md"
    lines = [
        f"# 全局审查报告",
        "",
        f"- 时间：{datetime.now().isoformat(timespec='seconds')}",
        f"- 总判：`{verdict}`",
        f"- 启用项目：{len(enabled)}",
        f"- 已填充总览：{filled}",
        f"- 仍为 stub：{stub_count}",
        f"- 缺失工具：{', '.join(missing_tools) or '无'}",
        f"- 跨项目经验占位：{', '.join(xp_placeholder) or '无'}",
        "",
        "## 诚实结论",
        "",
        "此前模块 0–9 完成的是**可运行脚手架 + 安装/同步/验收链路**。",
        "若项目知识库仍是安装器占位文案，则**不算**完成「本机项目汇总梳理」。",
        "若 `跨项目经验/` 或内容素材索引仍含「（占位）」，则**不算**完成模块 7 内容层。",
        "本轮以 `梳理项目知识.py` + `同步用户主知识拆分.py` + `汇总跨项目经验.py` 补齐内容层。",
        "",
        "## 分项目",
        "",
        "| 项目 | 总览状态 | 字数 |",
        "|------|----------|------|",
    ]
    for r in rows:
        lines.append(f"| {r['name']} | {r['status']} | {r['overview_chars']} |")
    lines += [
        "",
        "## 对照方案仍未 100% 的项",
        "",
        "- Cursor CLI 真实 live 调用（非 simulate）未在本机强制跑通",
        "- 权限 YAML 需手工贴入 Cursor CLI 权限 UI",
        "- GUI 完整聊天无法自动截获（需导出导入）",
        "- 独立只读 Reviewer 子 Agent 未对每个模块强制跑（人工/本报告替代）",
        "- Agent Video Studio 在 UKB 为 USER_REPORTED，桌面未单独登记独立仓（若另有路径需补登记）",
        "",
    ]
    md.write_text("\n".join(lines), encoding="utf-8")
    (CENTRAL / "日志" / "全局审查报告.json").write_text(
        json.dumps(
            {
                "verdict": verdict,
                "rows": rows,
                "missing_tools": missing_tools,
                "xp_placeholder": xp_placeholder,
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    print(md.read_text(encoding="utf-8"))
    return 0 if verdict == "COMPLETE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
