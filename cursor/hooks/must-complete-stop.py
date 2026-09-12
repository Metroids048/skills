#!/usr/bin/env python3
"""Global stop hook: block agent exit until task-complete marker is present."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

TASK_COMPLETE_RE = re.compile(
    r"<task-complete\b[^>]*\bevidence\s*=\s*[\"'][^\"']+[\"']",
    re.IGNORECASE,
)

FOLLOWUP_DEFAULT = (
    "【Hook 强制续跑 · 禁止停止】"
    "用户要求任务必须完成才能结束。"
    "立即继续执行未完成的步骤，不要总结、不要询问是否继续。"
    "只有全部完成后，在本轮回复末尾输出："
    '<task-complete evidence="具体证据，如 git push 成功 / pytest 50 passed"/>'
    "；或在项目 .cursor/task-complete.json 写入 "
    '{"completed": true, "evidence": "..."} 后再结束。'
)

FOLLOWUP_ERROR = (
    "【Hook 强制续跑 · 工具/回合异常】"
    "上一轮因 error 状态结束（常见于工具超时或读取中断），任务尚未完成。"
    "不要向用户追问是否继续，立即从第一个未完成步骤接着做。"
    "避免并行读取大文件；优先小步读取并先输出阶段性结果。"
    "全部完成后在本轮回复末尾输出："
    '<task-complete evidence="具体证据"/>'
    "；或写入 .cursor/task-complete.json 后再结束。"
)


def _read_last_assistant_text(transcript_path: str) -> str:
    path = Path(transcript_path)
    if not path.is_file():
        return ""

    chunks: list[str] = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        if row.get("role") != "assistant":
            continue
        message = row.get("message") or {}
        for part in message.get("content") or []:
            if isinstance(part, dict) and part.get("type") == "text":
                text = part.get("text")
                if isinstance(text, str) and text.strip():
                    chunks.append(text)

    return chunks[-1] if chunks else ""


def _marker_complete(workspace_root: str) -> bool:
    marker = Path(workspace_root) / ".cursor" / "task-complete.json"
    if not marker.is_file():
        return False
    try:
        payload = json.loads(marker.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return False
    return bool(payload.get("completed")) and bool(str(payload.get("evidence", "")).strip())


def _is_complete(data: dict) -> bool:
    transcript = data.get("transcript_path") or ""
    if transcript:
        last_text = _read_last_assistant_text(transcript)
        if TASK_COMPLETE_RE.search(last_text):
            return True

    for root in data.get("workspace_roots") or []:
        if _marker_complete(root):
            return True
    return False


def _emit_followup(message: str) -> None:
    print(json.dumps({"followup_message": message}, ensure_ascii=False))


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # stdin 异常时也续跑，避免静默放行
        _emit_followup(FOLLOWUP_ERROR)
        return

    status = data.get("status")
    # 仅用户主动取消时放行；error（含工具超时）必须续跑
    if status == "aborted":
        print("{}")
        return

    if _is_complete(data):
        print("{}")
        return

    followup = FOLLOWUP_ERROR if status == "error" else FOLLOWUP_DEFAULT
    _emit_followup(followup)


if __name__ == "__main__":
    main()
