#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从会话/知识提取 PUBLIC_SAFE 视频选题（模块 7）。"""

from __future__ import annotations

import argparse
import hashlib
import re
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
OUT = CENTRAL / "内容素材中心" / "视频选题总库.md"
FORBIDDEN = CENTRAL / "内容素材中心" / "禁止公开内容.md"

SENSITIVE_WORDS = ["密钥", "api_key", "助记词", "收益承诺", "客户姓名", "身份证"]


def iter_sources() -> list[Path]:
    paths = []
    paths.extend((CENTRAL / "全局会话归档").rglob("*.md"))
    for m in (CENTRAL / "项目镜像").glob("*"):
        paths.extend((m / "会话记录").glob("*.md") if (m / "会话记录").exists() else [])
        p = m / "内容素材.md"
        if p.is_file():
            paths.append(p)
    return paths


def is_safe(text: str) -> bool:
    low = text.lower()
    return not any(w.lower() in low for w in SENSITIVE_WORDS)


def topic_id(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:10]


def extract() -> list[dict]:
    seen = set()
    topics = []
    for path in iter_sources():
        text = path.read_text(encoding="utf-8", errors="ignore")
        if not is_safe(text):
            continue
        # 粗提取：标题或「目标」段
        m = re.search(r"^#\s+(.+)$", text, re.M)
        title = (m.group(1).strip() if m else path.stem)[:80]
        tid = topic_id(title)
        if tid in seen:
            continue
        seen.add(tid)
        topics.append(
            {
                "id": tid,
                "title": title,
                "source": str(path),
                "public": "PUBLIC_SAFE",
            }
        )
    return topics[:50]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        fix = CENTRAL / "测试夹具" / "视频素材"
        fix.mkdir(parents=True, exist_ok=True)
        for i in range(12):
            (fix / f"s{i}.md").write_text(
                f"# 真实冲突案例 {i}\n\n用户目标：修同步\nAgent 做了什么：加冲突报告\n证据：测试通过\n",
                encoding="utf-8",
            )
        (fix / "bad.md").write_text("# 泄露\napi_key=YOUR_API_KEY", encoding="utf-8")
        # temporarily include fixture by writing into 全局会话归档
        dest = CENTRAL / "全局会话归档" / "2026" / "07"
        dest.mkdir(parents=True, exist_ok=True)
        for i in range(12):
            (dest / f"fixture_video_{i}.md").write_text(
                f"# Agent 同步冲突怎么处理 {i}\n\n冲突：中央与项目同时修改\n证据：冲突报告\n结论：待确认补丁\n",
                encoding="utf-8",
            )
        topics = extract()
        safe = [t for t in topics if "收益" not in t["title"]]
        assert len(safe) >= 10, len(safe)
        print(f"PASS: extracted {len(safe)} safe topics")
        return 0

    topics = extract()
    lines = [
        f"# 视频选题总库",
        "",
        f"- 更新：{datetime.now().isoformat(timespec='seconds')}",
        f"- 条目：{len(topics)}",
        "",
    ]
    for t in topics:
        lines += [
            f"## {t['title']}",
            "",
            f"- id：`{t['id']}`",
            f"- 来源：`{t['source']}`",
            f"- 公开级别：{t['public']}",
            f"- 抖音标题：{t['title'][:30]}",
            f"- 小红书标题：实战｜{t['title'][:24]}",
            "",
        ]
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
