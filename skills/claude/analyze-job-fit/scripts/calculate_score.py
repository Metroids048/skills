#!/usr/bin/env python3
"""Calculate deterministic evidence-based job-fit scores."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

PRIORITY = {"must": 3.0, "core": 2.0, "preferred": 1.0}
EVIDENCE = {0: 0.0, 1: 0.2, 2: 0.5, 3: 0.8, 4: 1.0}


def clamp(value: float) -> int:
    return round(max(0.0, min(100.0, value)))


def calculate(data: dict[str, Any]) -> dict[str, Any]:
    requirements = data.get("requirements", [])
    denominator = 0.0
    fit_total = 0.0
    evidence_total = 0.0

    for item in requirements:
        priority = str(item.get("priority", "core"))
        weight = float(item.get("weight", 1))
        level = int(item.get("evidence_level", 0))
        transfer = max(0.0, min(1.0, float(item.get("transfer_factor", 1))))
        capacity = PRIORITY.get(priority, 2.0) * max(0.1, weight)
        evidence_score = EVIDENCE.get(level, 0.0)
        denominator += capacity
        fit_total += capacity * evidence_score * transfer
        evidence_total += capacity * evidence_score

        if level == 0:
            item["status"] = "missing"
        elif evidence_score * transfer >= 0.75:
            item["status"] = "matched"
        elif transfer < 1 and evidence_score * transfer >= 0.35:
            item["status"] = "transferable"
        else:
            item["status"] = "weak"

    scores = data.setdefault("scores", {})
    scores["job_fit"] = clamp(100 * fit_total / denominator) if denominator else 0
    scores["evidence_completeness"] = (
        clamp(100 * evidence_total / denominator) if denominator else 0
    )

    source = int(data.get("meta", {}).get("source_completeness", 0))
    confidence = int(scores.get("analysis_confidence", source))
    hard_statuses = {
        str(gate.get("status", "unknown"))
        for gate in data.get("job", {}).get("hard_gates", [])
    }
    fit = scores["job_fit"]

    if source < 50 or confidence < 50:
        label = "信息不足"
    elif "missing" in hard_statuses:
        label = "谨慎投"
    elif "partial" in hard_statuses:
        label = "修改后投"
    elif fit >= 80:
        label = "建议投"
    elif fit >= 60:
        label = "修改后投"
    else:
        label = "谨慎投"

    recommendation = data.setdefault("recommendation", {})
    recommendation["label"] = label
    recommendation["priority"] = {
        "建议投": "high",
        "修改后投": "medium",
        "谨慎投": "low",
        "信息不足": "unknown",
    }[label]
    return data


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()

    data = json.loads(args.input.read_text(encoding="utf-8"))
    result = calculate(data)
    if args.write:
        args.input.write_text(
            json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    else:
        print(json.dumps(result.get("scores", {}), ensure_ascii=False, indent=2))
        print(result.get("recommendation", {}).get("label", ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
