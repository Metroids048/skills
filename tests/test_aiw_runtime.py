import json
from pathlib import Path

from runtime.aiw_core import SkillRegistry, build_context, detect_project, search_memory


def write_json(path: Path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def test_router_selects_debugging_skills_and_suppresses_design(tmp_path):
    registry_path = tmp_path / "registry" / "skills.json"
    write_json(registry_path, {
        "skills": [
            {"id": "systematic-debugging", "active": True, "priority": 100,
             "positive_triggers": ["根因", "回归", "之前明明可以", "不开单"],
             "negative_triggers": [], "profiles": ["engineering", "trading"]},
            {"id": "verification-before-completion", "active": True, "priority": 90,
             "positive_triggers": ["验收", "修复", "完成"], "negative_triggers": [],
             "profiles": ["engineering"]},
            {"id": "frontend-design", "active": True, "priority": 60,
             "positive_triggers": ["UI", "网页", "视觉"], "negative_triggers": ["根因", "不开单"],
             "profiles": ["design"]},
        ]
    })
    reg = SkillRegistry.load(registry_path)
    selected = reg.route("之前明明可以自动开单，现在又不开单，先定位根因并验收", profiles=["engineering", "trading"], top_k=3)
    ids = [s.id for s in selected]
    assert "systematic-debugging" in ids
    assert "verification-before-completion" in ids
    assert "frontend-design" not in ids
    assert len(ids) <= 3


def test_router_deduplicates_aliases_to_one_canonical_skill(tmp_path):
    registry_path = tmp_path / "registry" / "skills.json"
    write_json(registry_path, {"skills": [
        {"id": "verify-work", "canonical_id": "verification-before-completion", "active": True,
         "priority": 50, "positive_triggers": ["验收"], "negative_triggers": [], "profiles": ["engineering"]},
        {"id": "verification-before-completion", "active": True, "priority": 100,
         "positive_triggers": ["验收"], "negative_triggers": [], "profiles": ["engineering"]},
    ]})
    reg = SkillRegistry.load(registry_path)
    selected = reg.route("请做最终验收", profiles=["engineering"], top_k=5)
    assert [s.canonical_id for s in selected].count("verification-before-completion") == 1


def test_detect_project_prefers_nearest_project_manifest(tmp_path):
    root = tmp_path / "repo"
    nested = root / "a" / "b"
    nested.mkdir(parents=True)
    write_json(root / ".ai" / "project.json", {
        "project_id": "automated-trading", "memory_pack": ["automated-trading"], "skill_profiles": ["engineering", "trading"]})
    project = detect_project(nested, registry_projects={})
    assert project["project_id"] == "automated-trading"
    assert "trading" in project["skill_profiles"]


def test_memory_search_uses_private_root_before_public_root(tmp_path):
    public = tmp_path / "repo" / "memory"
    private = tmp_path / "private-memory"
    (public / "projects" / "alpha").mkdir(parents=True)
    (private / "projects" / "alpha").mkdir(parents=True)
    (public / "projects" / "alpha" / "PITFALLS.md").write_text("public marker: correlation", encoding="utf-8")
    (private / "projects" / "alpha" / "PITFALLS.md").write_text("private marker: face scan broke login chain", encoding="utf-8")
    hits = search_memory("face scan login", project_id="alpha", public_root=public, private_root=private, limit=5)
    assert hits
    assert hits[0].source == "private"
    assert "face scan" in hits[0].text


def test_context_loads_history_only_when_prompt_requests_history(tmp_path):
    public = tmp_path / "memory"
    private = tmp_path / "private"
    (public / "global").mkdir(parents=True)
    (public / "projects" / "p").mkdir(parents=True)
    (private / "sessions" / "p").mkdir(parents=True)
    (public / "global" / "WORKING_CONTRACT.md").write_text("global-contract", encoding="utf-8")
    (public / "projects" / "p" / "CURRENT_STATE.md").write_text("current-state", encoding="utf-8")
    (private / "sessions" / "p" / "old.md").write_text("old-session-evidence", encoding="utf-8")
    no_history = build_context("修当前问题", {"project_id": "p", "skill_profiles": []}, public, private, registry=None)
    assert "old-session-evidence" not in no_history
    with_history = build_context("找一下之前历史怎么修过", {"project_id": "p", "skill_profiles": []}, public, private, registry=None)
    assert "old-session-evidence" in with_history


def test_context_has_bounded_size(tmp_path):
    public = tmp_path / "memory"
    (public / "global").mkdir(parents=True)
    (public / "global" / "WORKING_CONTRACT.md").write_text("x" * 50000, encoding="utf-8")
    text = build_context("普通任务", {"project_id": None, "skill_profiles": []}, public, None, registry=None, max_chars=4000)
    assert len(text) <= 4000
