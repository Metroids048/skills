#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GUI 开始/结束任务归档（模块 5）。"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent


def resolve_project(name: str) -> Path:
    import yaml

    reg = yaml.safe_load((CENTRAL / "项目注册表.yaml").read_text(encoding="utf-8"))
    for p in reg.get("projects") or []:
        if p.get("enabled") and (p.get("name") == name or p.get("id") == name):
            return Path(p["path"])
    raise SystemExit(f"项目未找到: {name}")


def start_task(project_name: str, goal: str) -> Path:
    root = resolve_project(project_name)
    raw = root / "AI原始记录"
    raw.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    task_id = f"GUI_{ts}"
    path = raw / f"{ts}_Cursor_{project_name}_任务开始.json"
    data = {
        "task_id": task_id,
        "project": project_name,
        "goal": goal,
        "started_at": datetime.now().isoformat(timespec="seconds"),
        "git": {},
    }
    if (root / ".git").exists():
        try:
            data["git"]["status"] = subprocess.check_output(
                ["git", "status", "--short"], cwd=str(root), text=True, encoding="utf-8", errors="replace"
            )
        except Exception as e:
            data["git"]["error"] = str(e)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(path)
    return path


def end_task(project_name: str, notes: str = "") -> Path:
    root = resolve_project(project_name)
    sess = root / "项目知识库" / "会话记录"
    sess.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    # 找最近开始记录
    starts = sorted((root / "AI原始记录").glob("*_任务开始.json")) if (root / "AI原始记录").exists() else []
    start_meta = {}
    if starts:
        start_meta = json.loads(starts[-1].read_text(encoding="utf-8"))
    status = "PARTIAL"  # GUI 无法保证完整原文
    diff = ""
    if (root / ".git").exists():
        try:
            diff = subprocess.check_output(
                ["git", "diff"], cwd=str(root), text=True, encoding="utf-8", errors="replace"
            )[:50000]
        except Exception:
            diff = ""
    out = sess / f"{ts}_Cursor_{project_name}_会话记录.md"
    out.write_text(
        "\n".join(
            [
                "# GUI 会话归档",
                "",
                f"- task_id：{start_meta.get('task_id', 'unknown')}",
                f"- 状态：{status}（GUI 摘要归档，非完整聊天保证）",
                f"- 初始目标：{start_meta.get('goal', '')}",
                f"- 备注：{notes}",
                "",
                "## Git diff（摘要）",
                "",
                "```",
                diff[:8000] or "(无)",
                "```",
                "",
                "## 说明",
                "",
                "完整原文请使用 Cursor 导出聊天后再运行 导入聊天记录.py。",
                "",
            ]
        ),
        encoding="utf-8",
    )
    print(out)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("action", choices=["start", "end"])
    ap.add_argument("--项目", required=True)
    ap.add_argument("--目标", default="")
    ap.add_argument("--备注", default="")
    args = ap.parse_args()
    if args.action == "start":
        start_task(args.项目, args.目标 or "(未填写)")
    else:
        end_task(args.项目, args.备注)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
