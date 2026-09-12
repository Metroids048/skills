#!/usr/bin/env python3
"""Run deterministic scoring regression cases."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from calculate_score import calculate


def validate_report_baseline() -> list[str]:
    template = (ROOT / "assets" / "report-template.html").read_text(encoding="utf-8")
    required_tokens = {
        "theme marker": 'data-report-theme="job-evidence-v1"',
        "ink color": "--ink:#0f0e15",
        "cream color": "--cream:#f3ede2",
        "accent color": "--red:#f43d3f",
        "grid hero": ".hero{",
        "score grid": ".score-grid{",
        "evidence matrix": ".req-table{",
        "cut corner card": "clip-path:polygon(",
        "mobile breakpoint": "@media(max-width:820px)",
        "print styles": "@media print",
        "report title slot": "{{REPORT_TITLE}}",
        "report body slot": "{{REPORT_BODY}}",
        "print interaction": 'document.querySelector(".print")',
        "help interaction": 'document.querySelectorAll(".help")',
    }
    failures = [
        label for label, token in required_tokens.items() if token not in template
    ]
    if template.count("{{REPORT_TITLE}}") != 1:
        failures.append("single report title slot")
    if template.count("{{REPORT_BODY}}") != 1:
        failures.append("single report body slot")
    if re.search(r'(?:src|href)=["\']https?://', template, flags=re.IGNORECASE):
        failures.append("self-contained assets")
    return failures


def main() -> int:
    cases = json.loads((ROOT / "evals" / "scoring-cases.json").read_text(encoding="utf-8"))
    failures: list[str] = []
    for case in cases:
        requirements = []
        for index, item in enumerate(case["requirements"], 1):
            requirements.append(
                {
                    "id": f"R{index}",
                    "priority": item["priority"],
                    "weight": item["weight"],
                    "evidence_level": item["evidence_level"],
                    "transfer_factor": item["transfer_factor"],
                }
            )
        payload = {
            "meta": {"source_completeness": case["source_completeness"]},
            "job": {"hard_gates": case["hard_gates"]},
            "scores": {"analysis_confidence": case["confidence"]},
            "requirements": requirements,
            "recommendation": {},
        }
        result = calculate(payload)
        score = result["scores"]["job_fit"]
        label = result["recommendation"]["label"]
        expected = case["expected"]
        ok = score >= expected.get("min", 0) and score <= expected.get("max", 100)
        ok = ok and label == expected["label"]
        print(f"{'PASS' if ok else 'FAIL'} {case['name']}: {score} / {label}")
        if not ok:
            failures.append(case["name"])
    style_failures = validate_report_baseline()
    style_ok = not style_failures
    print(
        f"{'PASS' if style_ok else 'FAIL'} report style baseline: "
        f"{'job-evidence-v1' if style_ok else ', '.join(style_failures)}"
    )
    if not style_ok:
        failures.append("report style baseline")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
