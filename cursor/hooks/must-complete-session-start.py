#!/usr/bin/env python3
"""Global sessionStart hook: reset task marker and inject must-complete discipline."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def _clear_markers(data: dict) -> None:
    for root in data.get("workspace_roots") or []:
        marker = Path(root) / ".cursor" / "task-complete.json"
        if marker.is_file():
            try:
                marker.unlink()
            except OSError:
                pass


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        data = {}

    _clear_markers(data)

    context = (
        "<MUST_COMPLETE_TASK>\n"
        "全局 Hook 已启用：Agent 不得在任务未完成时停止。\n"
        "完成用户终点后，必须在回复末尾输出 "
        '<task-complete evidence="命令输出证据"/>，'
        "或写入 .cursor/task-complete.json。\n"
        "否则 stop hook 会自动注入续跑指令（最多 30 轮）。\n"
        "禁止阶段总结后停止；禁止问「是否继续」。\n"
        "</MUST_COMPLETE_TASK>"
    )
    print(json.dumps({"additional_context": context}, ensure_ascii=False))


if __name__ == "__main__":
    main()
