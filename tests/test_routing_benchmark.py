import json
from pathlib import Path

from runtime.aiw_core import SkillRegistry

ROOT = Path(__file__).parents[1]


def test_curated_routing_benchmark_top5():
    registry = SkillRegistry.load(ROOT / "registry" / "skills.json")
    cases = json.loads((ROOT / "tests" / "fixtures" / "routing_cases.json").read_text(encoding="utf-8"))
    failures = []
    for case in cases:
        selected = registry.route(case["task"], case.get("profiles", []), top_k=5)
        ids = [s.canonical_id for s in selected]
        for required in case.get("required", []):
            if required not in ids:
                failures.append((case["task"], "missing", required, ids))
        for forbidden in case.get("forbidden", []):
            if forbidden in ids:
                failures.append((case["task"], "forbidden", forbidden, ids))
        assert len(ids) <= 5
    assert not failures, failures
