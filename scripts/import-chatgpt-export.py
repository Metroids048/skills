#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

SECRET_PATTERNS = [
    re.compile(r"\bsk-proj-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bghp_[A-Za-z0-9]{20,}\b"),
    re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"(?i)(Bearer\s+)[A-Za-z0-9._~+/=-]{12,}"),
]


def _inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def redact(text: str) -> str:
    for pattern in SECRET_PATTERNS:
        text = pattern.sub("[REDACTED_SECRET]", text)
    return text


def _message_text(message: dict) -> str:
    content = message.get("content") or {}
    parts = content.get("parts") or []
    return "\n".join(p for p in parts if isinstance(p, str)).strip()


def _slug(index: int, title: str) -> str:
    safe = re.sub(r"[^A-Za-z0-9\u4e00-\u9fff_-]+", "-", title or "untitled").strip("-")[:60]
    return f"{index:05d}-{safe or 'untitled'}"


def import_export(source: Path, output: Path, repo_root: Path) -> dict:
    source, output, repo_root = map(Path, (source, output, repo_root))
    if _inside(output, repo_root):
        raise ValueError("ChatGPT imports must be written outside the Git repository; use ~/.ai-workspace/private-memory/imports/chatgpt")
    data = json.loads(source.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise ValueError("Expected ChatGPT conversations.json to contain a list")
    sessions_dir = output / "sessions"
    proposals_dir = output / "proposed-updates"
    sessions_dir.mkdir(parents=True, exist_ok=True)
    proposals_dir.mkdir(parents=True, exist_ok=True)
    written: list[str] = []
    index_rows: list[dict] = []
    for idx, conv in enumerate(data, 1):
        title = str(conv.get("title") or "Untitled")
        rows = []
        mapping = conv.get("mapping") or {}
        for node in mapping.values():
            msg = (node or {}).get("message")
            if not msg:
                continue
            text = _message_text(msg)
            if not text:
                continue
            role = ((msg.get("author") or {}).get("role") or "unknown").upper()
            rows.append((msg.get("create_time") or 0, role, redact(text)))
        rows.sort(key=lambda x: x[0])
        if not rows:
            continue
        path = sessions_dir / f"{_slug(idx, title)}.md"
        body = ["---", "source: chatgpt-export", "status: PROPOSED_NOT_DURABLE", "privacy: PRIVATE", "---", "", f"# {redact(title)}", ""]
        for _, role, text in rows:
            body.extend([f"## {role}", text, ""])
        path.write_text("\n".join(body), encoding="utf-8")
        written.append(str(path))
        index_rows.append({"title": redact(title), "path": str(path), "messages": len(rows)})
    index_path = output / "import-index.json"
    index_path.write_text(json.dumps({
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "status": "PROPOSED_NOT_DURABLE",
        "conversations": index_rows,
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    (proposals_dir / "README.md").write_text(
        "# Proposed memory updates\n\nChatGPT export sessions are evidence only. Extract durable facts/decisions/root causes into project packs after review; never auto-overwrite durable memory.\n",
        encoding="utf-8",
    )
    return {"sessions": written, "index": str(index_path)}


def main() -> int:
    parser = argparse.ArgumentParser(description="Import ChatGPT conversations.json into private AIW evidence storage")
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, default=Path.home() / ".ai-workspace" / "private-memory" / "imports" / "chatgpt")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    result = import_export(args.source, args.output, args.repo_root)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
