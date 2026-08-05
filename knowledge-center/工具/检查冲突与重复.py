#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""检查知识项冲突与重复（架构清单中的检查冲突与重复.py）。"""

from __future__ import annotations

import json
import sys
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(CENTRAL / "工具"))
from 知识模型 import KNOWLEDGE_STORE, find_duplicates, load_jsonl  # noqa: E402


def main() -> int:
    items = load_jsonl(KNOWLEDGE_STORE)
    dups = find_duplicates(items)
    conflicts = list((CENTRAL / "冲突与过期记录").glob("*冲突*"))
    pending = list((CENTRAL / "待确认更新").glob("*待确认*"))
    report = {
        "knowledge_items": len(items),
        "duplicate_pairs": len(dups),
        "duplicates": [{"fp": a, "id_a": b, "id_b": c} for a, b, c in dups[:50]],
        "conflict_files": len(conflicts),
        "pending_patches": len(pending),
    }
    out = CENTRAL / "日志" / "冲突与重复检查.json"
    out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    md = CENTRAL / "冲突与过期记录" / "冲突与重复汇总.md"
    lines = [
        "# 冲突与重复汇总",
        "",
        f"- 知识项：{report['knowledge_items']}",
        f"- 重复对：{report['duplicate_pairs']}",
        f"- 冲突文件：{report['conflict_files']}",
        f"- 待确认补丁：{report['pending_patches']}",
        "",
    ]
    for d in report["duplicates"]:
        lines.append(f"- dup `{d['id_a']}` ↔ `{d['id_b']}` fp={d['fp']}")
    md.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    print("OK", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
