#!/usr/bin/env python3
"""Validate an analysis JSON before rendering."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

REQUIRED_OBJECTS = ("meta", "job", "scores", "recommendation")
REQUIRED_LISTS = (
    "requirements",
    "strengths",
    "gaps",
    "resume_changes",
    "interview_questions",
    "action_plan",
    "limitations",
)


def validate(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for key in REQUIRED_OBJECTS:
        if not isinstance(data.get(key), dict):
            errors.append(f"{key} 必须是对象")
    for key in REQUIRED_LISTS:
        if not isinstance(data.get(key), list):
            errors.append(f"{key} 必须是数组")

    for key in ("job_fit", "evidence_completeness", "ats_readability", "analysis_confidence"):
        value = data.get("scores", {}).get(key)
        if not isinstance(value, (int, float)) or not 0 <= value <= 100:
            errors.append(f"scores.{key} 必须是 0–100")

    allowed_labels = {"建议投", "修改后投", "谨慎投", "信息不足"}
    if data.get("recommendation", {}).get("label") not in allowed_labels:
        errors.append("recommendation.label 非法")

    ids: set[str] = set()
    for index, item in enumerate(data.get("requirements", [])):
        prefix = f"requirements[{index}]"
        item_id = str(item.get("id", ""))
        if not item_id:
            errors.append(f"{prefix}.id 缺失")
        elif item_id in ids:
            errors.append(f"{prefix}.id 重复")
        ids.add(item_id)
        if item.get("priority") not in {"must", "core", "preferred"}:
            errors.append(f"{prefix}.priority 非法")
        if item.get("evidence_level") not in {0, 1, 2, 3, 4}:
            errors.append(f"{prefix}.evidence_level 必须是 0–4")
        transfer = item.get("transfer_factor")
        if not isinstance(transfer, (int, float)) or not 0 <= transfer <= 1:
            errors.append(f"{prefix}.transfer_factor 必须是 0–1")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    args = parser.parse_args()
    data = json.loads(args.input.read_text(encoding="utf-8"))
    errors = validate(data)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("analysis.json 验证通过")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
