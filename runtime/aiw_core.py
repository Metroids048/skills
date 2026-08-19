from __future__ import annotations

import json
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

HISTORY_TERMS = (
    "之前", "历史", "曾经", "上次", "以前", "过去", "last time", "history", "previous", "before"
)
PROJECT_PACK_FILES = (
    "PROJECT.md", "CURRENT_STATE.md", "DECISIONS.md", "PITFALLS.md", "PROVEN_FIXES.md", "ACCEPTANCE.md"
)


def _norm(text: str) -> str:
    return text.casefold().strip()


def _tokens(text: str) -> list[str]:
    text = _norm(text)
    out: list[str] = []
    for part in re.findall(r"[a-z0-9_.+/-]+|[\u4e00-\u9fff]+", text):
        if re.fullmatch(r"[\u4e00-\u9fff]+", part):
            if len(part) <= 2:
                out.append(part)
            else:
                out.append(part)
                out.extend(part[i:i+2] for i in range(len(part) - 1))
        else:
            out.append(part)
    return list(dict.fromkeys(t for t in out if t))


@dataclass(frozen=True)
class Skill:
    id: str
    canonical_id: str
    active: bool
    priority: int
    positive_triggers: tuple[str, ...]
    negative_triggers: tuple[str, ...]
    profiles: tuple[str, ...]
    description: str = ""


class SkillRegistry:
    def __init__(self, skills: Sequence[Skill]):
        self.skills = list(skills)

    @classmethod
    def load(cls, path: Path) -> "SkillRegistry":
        raw = json.loads(Path(path).read_text(encoding="utf-8"))
        skills = []
        for item in raw.get("skills", []):
            sid = item["id"]
            skills.append(Skill(
                id=sid,
                canonical_id=item.get("canonical_id", sid),
                active=bool(item.get("active", True)),
                priority=int(item.get("priority", 0)),
                positive_triggers=tuple(item.get("positive_triggers", [])),
                negative_triggers=tuple(item.get("negative_triggers", [])),
                profiles=tuple(item.get("profiles", [])),
                description=item.get("description", ""),
            ))
        return cls(skills)

    def route(self, task: str, profiles: Sequence[str] = (), top_k: int = 5) -> list[Skill]:
        top_k = max(1, min(int(top_k), 5))
        hay = _norm(task)
        profile_set = {_norm(p) for p in profiles}
        best: dict[str, tuple[float, Skill]] = {}
        for skill in self.skills:
            if not skill.active:
                continue
            if any(_norm(t) in hay for t in skill.negative_triggers if t):
                continue
            positives = [t for t in skill.positive_triggers if t and _norm(t) in hay]
            overlap = len(profile_set.intersection(_norm(p) for p in skill.profiles))
            if not positives:
                continue
            score = len(positives) * 1000 + overlap * 120 + skill.priority
            current = best.get(skill.canonical_id)
            if current is None or score > current[0]:
                best[skill.canonical_id] = (score, skill)
        return [pair[1] for pair in sorted(best.values(), key=lambda x: (-x[0], -x[1].priority, x[1].id))[:top_k]]


@dataclass(frozen=True)
class MemoryHit:
    path: Path
    source: str
    score: float
    text: str


def _iter_memory_files(root: Path | None, project_id: str | None, include_sessions: bool = False) -> Iterable[Path]:
    if root is None or not root.exists():
        return []
    candidates: list[Path] = []
    global_root = root / "global"
    if global_root.exists():
        candidates.extend(global_root.rglob("*.md"))
    if project_id:
        project_root = root / "projects" / project_id
        if project_root.exists():
            candidates.extend(project_root.rglob("*.md"))
        if include_sessions:
            session_root = root / "sessions" / project_id
            if session_root.exists():
                candidates.extend(session_root.rglob("*.md"))
    return candidates


def search_memory(query: str, project_id: str | None, public_root: Path, private_root: Path | None = None,
                  limit: int = 8, include_sessions: bool = False) -> list[MemoryHit]:
    tokens = _tokens(query)
    hits: list[MemoryHit] = []
    roots = [(private_root, "private", 30.0), (public_root, "public", 0.0)]
    for root, source, boost in roots:
        if root is None:
            continue
        for path in _iter_memory_files(root, project_id, include_sessions=include_sessions):
            try:
                text = path.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            low = _norm(text)
            name = _norm(path.name)
            score = boost
            matched = 0
            for token in tokens:
                if token in low:
                    score += 2.0 + min(low.count(token), 4) * 0.25
                    matched += 1
                if token in name:
                    score += 2.5
            if matched:
                hits.append(MemoryHit(path=path, source=source, score=score, text=text))
    hits.sort(key=lambda h: (-h.score, h.path.as_posix()))
    return hits[:max(1, int(limit))]


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _git_remote(cwd: Path) -> str | None:
    try:
        proc = subprocess.run(
            ["git", "-C", str(cwd), "remote", "get-url", "origin"],
            capture_output=True, text=True, timeout=2, check=False,
        )
        value = proc.stdout.strip()
        return value or None
    except (OSError, subprocess.SubprocessError):
        return None


def detect_project(cwd: Path, registry_projects: dict) -> dict:
    current = Path(cwd).resolve()
    for base in [current, *current.parents]:
        manifest = base / ".ai" / "project.json"
        if manifest.exists():
            data = _read_json(manifest)
            data.setdefault("root", str(base))
            data.setdefault("memory_pack", [data.get("project_id")] if data.get("project_id") else [])
            data.setdefault("skill_profiles", [])
            return data
    remote = _git_remote(current)
    basename = current.name.casefold()
    for item in registry_projects.get("projects", []):
        remotes = [r.casefold() for r in item.get("remotes", [])]
        basenames = [b.casefold() for b in item.get("basenames", [])]
        if (remote and any(r in remote.casefold() for r in remotes)) or basename in basenames:
            return {
                "project_id": item["id"],
                "root": str(current),
                "memory_pack": item.get("memory_pack", [item["id"]]),
                "skill_profiles": item.get("skill_profiles", []),
            }
    return {"project_id": None, "root": str(current), "memory_pack": [], "skill_profiles": ["general"]}


def _append_section(parts: list[str], title: str, text: str, seen: set[Path] | None = None, path: Path | None = None):
    if not text.strip():
        return
    if path is not None and seen is not None:
        resolved = path.resolve()
        if resolved in seen:
            return
        seen.add(resolved)
    parts.append(f"## {title}\n{text.strip()}\n")


def build_context(task: str, project: dict, public_root: Path, private_root: Path | None,
                  registry: SkillRegistry | None, max_chars: int = 12000) -> str:
    parts: list[str] = ["# Personal AI Runtime Context"]
    seen: set[Path] = set()
    contract = public_root / "global" / "WORKING_CONTRACT.md"
    if contract.exists():
        _append_section(parts, "L0 Global Contract", contract.read_text(encoding="utf-8", errors="replace"), seen, contract)
    project_id = project.get("project_id")
    for root, label in ((private_root, "private"), (public_root, "public")):
        if root is None or not project_id:
            continue
        project_dir = root / "projects" / project_id
        for name in PROJECT_PACK_FILES:
            path = project_dir / name
            if path.exists():
                _append_section(parts, f"L1 Project {label}: {name}", path.read_text(encoding="utf-8", errors="replace"), seen, path)
    include_history = any(term.casefold() in task.casefold() for term in HISTORY_TERMS)
    hits = search_memory(task, project_id, public_root, private_root, limit=6, include_sessions=include_history)
    for hit in hits:
        _append_section(parts, f"L2{'/L3' if '/sessions/' in hit.path.as_posix() else ''} Memory {hit.source}: {hit.path.name}", hit.text, seen, hit.path)
    if include_history and private_root and project_id:
        session_root = private_root / "sessions" / project_id
        if session_root.exists():
            for path in sorted(session_root.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True)[:2]:
                _append_section(parts, f"L3 Historical Evidence: {path.name}", path.read_text(encoding="utf-8", errors="replace"), seen, path)
    if registry is not None:
        selected = registry.route(task, profiles=project.get("skill_profiles", []), top_k=5)
        if selected:
            listing = "\n".join(f"- {s.canonical_id}: {s.description}" for s in selected)
            _append_section(parts, "Selected Skills (load only these)", listing)
    text = "\n\n".join(parts)
    return text[:max(256, int(max_chars))]


def audit_skill_sources(repo_root: Path, registry: SkillRegistry) -> dict:
    source_root = repo_root / "skills-src"
    active = [s for s in registry.skills if s.active and s.id == s.canonical_id]
    missing = [s.id for s in active if not (source_root / s.id / "SKILL.md").exists()]
    return {
        "active_count": len(active),
        "missing_canonical_sources": missing,
        "legacy_endpoint_counts": {
            endpoint: len([p for p in (repo_root / "skills" / endpoint).iterdir() if p.is_dir()])
            if (repo_root / "skills" / endpoint).exists() else 0
            for endpoint in ("cursor", "claude", "codex", "agents")
        },
    }
