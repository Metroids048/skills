#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""每周 / 每月复盘生成（模块 7）。"""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent


def collect_sessions() -> list[Path]:
    files = []
    files.extend((CENTRAL / "全局会话归档").rglob("*.md"))
    for mirror in (CENTRAL / "项目镜像").glob("*"):
        sess = mirror / "会话记录"
        if sess.is_dir():
            files.extend(sess.glob("*.md"))
    return files


def collect_conflicts() -> list[Path]:
    return list((CENTRAL / "冲突与过期记录").glob("*.md")) + list(
        (CENTRAL / "冲突与过期记录").glob("*.json")
    )


def write_weekly() -> Path:
    now = datetime.now()
    out_dir = CENTRAL / "决策与复盘" / "每周复盘"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{now.strftime('%Y-%m-%d')}_周复盘.md"
    sessions = collect_sessions()
    conflicts = collect_conflicts()
    projects = [p.name for p in (CENTRAL / "项目镜像").iterdir() if p.is_dir()]
    lines = [
        f"# 周复盘 {now.strftime('%Y-%m-%d')}",
        "",
        f"- 会话/导入记录数：{len(sessions)}",
        f"- 冲突记录数：{len(conflicts)}",
        f"- 项目镜像数：{len(projects)}",
        "",
        "## 项目",
        "",
    ]
    for p in projects:
        lines.append(f"- {p}")
    # 模块 7 内容层：把高频错误/方案真正写入跨项目经验（禁止只留「下一步」空话）
    import subprocess
    import sys

    agg = subprocess.run(
        [sys.executable, str(CENTRAL / "工具" / "汇总跨项目经验.py")],
        cwd=str(CENTRAL),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    agg_ok = agg.returncode == 0

    lines += [
        "",
        "## 开放注意",
        "",
        "- 无证据不得将任务标为 COMPLETE/VERIFIED",
        "- 冲突须人工确认，禁止静默覆盖主库",
        "",
        "## 跨项目经验汇总",
        "",
        f"- `工具/汇总跨项目经验.py`：{'PASS' if agg_ok else 'FAIL'}",
        "- 输出：`跨项目经验/*.md`、`内容素材中心/可公开证据索引.md`、`已发布内容复盘.md`",
        "",
        "## 下一步",
        "",
        "- 处理 `待确认更新/` 中补丁",
        "- 人工审阅跨项目经验新增条目，过时项标 `[STALE]`",
        "",
    ]
    out.write_text("\n".join(lines), encoding="utf-8")
    if not agg_ok:
        raise RuntimeError(f"汇总跨项目经验失败: {(agg.stderr or agg.stdout)[-500:]}")
    return out


def write_monthly() -> Path:
    now = datetime.now()
    out_dir = CENTRAL / "决策与复盘" / "每月复盘"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{now.strftime('%Y-%m')}_月复盘.md"
    out.write_text(
        "\n".join(
            [
                f"# 月复盘 {now.strftime('%Y-%m')}",
                "",
                "- 本月请合并重复经验、清理过期冲突、更新 USER_KNOWLEDGE_BASE 待确认项。",
                "- 去重：运行 `工具/校验知识库.py`",
                "- 内容：运行 `工具/提取视频内容.py`",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--weekly", action="store_true")
    ap.add_argument("--monthly", action="store_true")
    args = ap.parse_args()
    if not args.weekly and not args.monthly:
        args.weekly = True
    if args.weekly:
        print(write_weekly())
    if args.monthly:
        print(write_monthly())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
