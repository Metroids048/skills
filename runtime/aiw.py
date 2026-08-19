from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    from .aiw_core import SkillRegistry, audit_skill_sources, build_context, detect_project, search_memory
except ImportError:
    from aiw_core import SkillRegistry, audit_skill_sources, build_context, detect_project, search_memory


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def private_memory_root() -> Path:
    raw = os.environ.get("AIW_PRIVATE_MEMORY_ROOT")
    return Path(raw).expanduser() if raw else Path.home() / ".ai-workspace" / "private-memory"


def load_projects(root: Path) -> dict:
    path = root / "registry" / "projects.json"
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {"projects": []}


def load_registry(root: Path) -> SkillRegistry:
    return SkillRegistry.load(root / "registry" / "skills.json")


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="aiw", description="Personal AI Runtime")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("doctor")
    sub.add_parser("project")
    route = sub.add_parser("route")
    route.add_argument("task")
    route.add_argument("--top-k", type=int, default=5)
    ctx = sub.add_parser("context")
    ctx.add_argument("task")
    ctx.add_argument("--max-chars", type=int, default=12000)
    memory = sub.add_parser("memory")
    msub = memory.add_subparsers(dest="memory_command", required=True)
    search = msub.add_parser("search")
    search.add_argument("query")
    search.add_argument("--project")
    skills = sub.add_parser("skills")
    ssub = skills.add_subparsers(dest="skills_command", required=True)
    ssub.add_parser("audit")
    args = parser.parse_args(argv)

    root = repo_root()
    public_memory = root / "memory"
    private_memory = private_memory_root()
    registry = load_registry(root)
    project = detect_project(Path.cwd(), load_projects(root))

    if args.command == "doctor":
        report = {
            "python": sys.version.split()[0],
            "repo_root": str(root),
            "private_memory_root": str(private_memory),
            "private_memory_exists": private_memory.exists(),
            "registry_exists": (root / "registry" / "skills.json").exists(),
            "canonical_skills_exists": (root / "skills-src").exists(),
            "project": project.get("project_id"),
        }
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return 0
    if args.command == "project":
        print(json.dumps(project, ensure_ascii=False, indent=2))
        return 0
    if args.command == "route":
        selected = registry.route(args.task, project.get("skill_profiles", []), args.top_k)
        print(json.dumps([
            {"id": s.canonical_id, "description": s.description, "path": str(root / "skills-src" / s.canonical_id / "SKILL.md")}
            for s in selected
        ], ensure_ascii=False, indent=2))
        return 0
    if args.command == "context":
        print(build_context(args.task, project, public_memory, private_memory, registry, args.max_chars))
        return 0
    if args.command == "memory" and args.memory_command == "search":
        pid = args.project or project.get("project_id")
        hits = search_memory(args.query, pid, public_memory, private_memory, limit=8, include_sessions=True)
        print(json.dumps([
            {"source": h.source, "score": h.score, "path": str(h.path), "preview": h.text[:600]}
            for h in hits
        ], ensure_ascii=False, indent=2))
        return 0
    if args.command == "skills" and args.skills_command == "audit":
        print(json.dumps(audit_skill_sources(root, registry), ensure_ascii=False, indent=2))
        return 0
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
