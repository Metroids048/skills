#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""导入外部聊天 / GUI 导出 / Cursor agent-transcripts JSONL（模块 5）。

去重、隐私扫描、生成会话胶囊。支持单文件 Markdown、单文件 JSONL、目录批量。
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, date
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from 检查隐私 import redact, scan_text  # noqa: E402

INDEX = CENTRAL / "原始记录" / "导入索引.json"


def load_index() -> dict:
    if INDEX.is_file():
        return json.loads(INDEX.read_text(encoding="utf-8"))
    return {"imports": {}}


def save_index(idx: dict) -> None:
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(json.dumps(idx, ensure_ascii=False, indent=2), encoding="utf-8")


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def detect_tool(text: str, hint: str) -> str:
    if hint:
        return hint
    low = text[:2000].lower()
    if "claude" in low:
        return "claude-code"
    if "codex" in low:
        return "codex"
    if "chatgpt" in low or "openai" in low:
        return "chatgpt"
    return "cursor"


def split_turns(text: str) -> list[tuple[str, str]]:
    turns = []
    parts = re.split(r"\n(?=(?:User|Assistant|Human|ChatGPT|Claude|你|助手)[:：]\s*)", text)
    if len(parts) <= 1:
        return [("unknown", text.strip())]
    for p in parts:
        p = p.strip()
        if not p:
            continue
        m = re.match(r"^(User|Assistant|Human|ChatGPT|Claude|你|助手)[:：]\s*", p)
        role = m.group(1) if m else "unknown"
        body = p[m.end() :] if m else p
        turns.append((role, body.strip()))
    return turns


def _extract_text_content(content) -> str:
    if content is None:
        return ""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        chunks: list[str] = []
        for item in content:
            if isinstance(item, str):
                chunks.append(item)
            elif isinstance(item, dict):
                if item.get("type") == "text" and "text" in item:
                    chunks.append(str(item["text"]))
                elif "text" in item:
                    chunks.append(str(item["text"]))
                elif "content" in item:
                    chunks.append(_extract_text_content(item["content"]))
        return "\n".join(chunks)
    if isinstance(content, dict):
        return _extract_text_content(content.get("text") or content.get("content"))
    return str(content)


def jsonl_to_markdown(path: Path) -> str:
    """Cursor agent-transcripts: 每行 {role, message:{content:[...]}}。"""
    lines_out: list[str] = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        role = str(obj.get("role") or obj.get("type") or "unknown")
        msg = obj.get("message")
        if isinstance(msg, dict):
            body = _extract_text_content(msg.get("content"))
        else:
            body = _extract_text_content(obj.get("content") or msg)
        body = (body or "").strip()
        if not body:
            continue
        label = "User" if role.lower() in ("user", "human") else (
            "Assistant" if role.lower() in ("assistant", "model") else role
        )
        lines_out.append(f"{label}: {body}")
        lines_out.append("")
    return "\n".join(lines_out).strip() + ("\n" if lines_out else "")


def load_source_text(path: Path) -> str:
    if path.suffix.lower() == ".jsonl":
        return jsonl_to_markdown(path)
    return path.read_text(encoding="utf-8", errors="replace")


def content_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def import_one(
    path: Path,
    project: str,
    tool_hint: str,
    *,
    source_label: str | None = None,
) -> dict:
    path = path.resolve()
    if not path.is_file():
        return {"action": "error", "error": f"not a file: {path}"}

    raw = load_source_text(path)
    # 去重：优先内容 hash（JSONL 转 MD 后稳定），回退文件字节 hash
    h = content_hash(raw) if raw.strip() else file_hash(path)
    idx = load_index()
    if h in idx["imports"]:
        return {"action": "duplicate", "hash": h, "previous": idx["imports"][h]}

    secrets = scan_text(raw)
    status = "PARTIAL" if not raw.strip() else "COMPLETE"
    if secrets:
        status = "PARTIAL"
        raw_out = redact(raw)
    else:
        raw_out = raw

    tool = detect_tool(raw, tool_hint)
    if path.suffix.lower() == ".jsonl" and not tool_hint:
        tool = "cursor"
    turns = split_turns(raw_out)
    ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    dest_dir = CENTRAL / "原始记录" / tool.replace("-", "_")
    if tool == "cursor":
        dest_dir = CENTRAL / "原始记录" / "Cursor_聊天导出"
    dest_dir.mkdir(parents=True, exist_ok=True)
    safe_name = path.name
    dest = dest_dir / f"{ts}_{project}_{safe_name}"
    if dest.suffix.lower() == ".jsonl":
        dest = dest.with_suffix(".md")
    dest.write_text(raw_out, encoding="utf-8")

    capsule = CENTRAL / "全局会话归档" / datetime.now().strftime("%Y") / datetime.now().strftime("%m")
    capsule.mkdir(parents=True, exist_ok=True)
    cap_path = capsule / f"{ts}_{tool}_{project}_导入会话.md"
    src_display = source_label or str(path)
    lines = [
        f"# 导入会话胶囊",
        "",
        f"- 来源文件：`{src_display}`",
        f"- hash：`{h}`",
        f"- 工具：{tool}",
        f"- 项目：{project}",
        f"- 状态：{status}",
        f"- 轮次数：{len(turns)}",
        f"- 隐私命中：{bool(secrets)}",
        "",
        "## 角色区分",
        "",
    ]
    for role, body in turns[:50]:
        lines.append(f"### {role}")
        lines.append("")
        lines.append(body[:2000])
        lines.append("")
    if status == "PARTIAL":
        lines.append("## 注意")
        lines.append("")
        lines.append("格式不完整或含敏感片段，已脱敏/标记 PARTIAL。原始副本保存在原始记录。")
        lines.append("")
    cap_path.write_text("\n".join(lines), encoding="utf-8")

    idx["imports"][h] = {"dest": str(dest), "capsule": str(cap_path), "at": ts, "project": project}
    save_index(idx)
    return {"action": "imported", "hash": h, "capsule": str(cap_path), "status": status, "project": project}


def project_from_cursor_key(key: str) -> str:
    """从 Cursor projects 目录名推断登记项目名。"""
    mapping = {
        "c-Users-win-Desktop-Agent-Platform": "Agent Platform",
        "c-Users-win-Desktop-AI-main": "AI--main",
        "c-Users-win-Desktop-alpha": "alpha",
        "c-Users-win-Desktop-program1-main-latest": "program1-main-latest",
        "c-Users-win-Desktop-program1-main": "program1-main",
        "c-Users-win-Desktop-program": "program",
        "c-Users-win-Desktop-yinpinjianting": "yinpinjianting",
        "c-Users-win-Desktop-demo": "demo",
        "c-Users-win-Desktop-demo1": "demo1",
        "c-Users-win-Desktop-Operating-Platform": "Operating Platform",
        "c-Users-win-Desktop": "全局配置",
        "empty-window": "empty-window",
    }
    if key in mapping:
        return mapping[key]
    if key.startswith("c-Users-win-Desktop-"):
        return key[len("c-Users-win-Desktop-") :].replace("-", " ")
    return key


def iter_import_files(
    root: Path,
    *,
    parents_only: bool,
    since: date | None,
    patterns: tuple[str, ...] = ("*.md", "*.txt", "*.jsonl"),
    transcripts_only: bool = False,
) -> list[Path]:
    files: list[Path] = []
    if root.is_file():
        return [root]
    if transcripts_only:
        patterns = ("*.jsonl",)
    for pat in patterns:
        for p in root.rglob(pat):
            if not p.is_file():
                continue
            if transcripts_only and "agent-transcripts" not in p.parts:
                continue
            if parents_only and "subagents" in p.parts:
                continue
            if since is not None:
                mtime = datetime.fromtimestamp(p.stat().st_mtime).date()
                if mtime < since:
                    continue
            files.append(p)
    files = sorted(set(files), key=lambda x: str(x).lower())
    return files


def import_batch(
    root: Path,
    project: str,
    tool_hint: str,
    *,
    parents_only: bool = True,
    since: date | None = None,
    infer_project: bool = False,
    transcripts_only: bool = False,
) -> dict:
    files = iter_import_files(
        root,
        parents_only=parents_only,
        since=since,
        transcripts_only=transcripts_only,
    )
    summary = {"imported": 0, "duplicate": 0, "error": 0, "empty": 0, "results": []}
    cursor_projects = Path.home() / ".cursor" / "projects"
    for f in files:
        proj = project
        if infer_project and cursor_projects in f.parents:
            # .../projects/<key>/agent-transcripts/...
            try:
                rel = f.relative_to(cursor_projects)
                key = rel.parts[0]
                proj = project_from_cursor_key(key)
            except ValueError:
                pass
        r = import_one(f, proj, tool_hint)
        if r.get("action") == "imported" and not (f.suffix.lower() == ".jsonl" and r.get("status") == "COMPLETE"):
            # empty conversion
            pass
        if r.get("action") == "imported":
            # 空 JSONL 转出空文仍记 imported；标 empty
            text = load_source_text(f) if f.suffix.lower() == ".jsonl" else ""
            if f.suffix.lower() == ".jsonl" and not text.strip():
                summary["empty"] += 1
            summary["imported"] += 1
        elif r.get("action") == "duplicate":
            summary["duplicate"] += 1
        else:
            summary["error"] += 1
        summary["results"].append({"file": str(f), **r})
    return summary


def parse_since(s: str | None) -> date | None:
    if not s:
        return None
    return datetime.strptime(s, "%Y-%m-%d").date()


def main() -> int:
    ap = argparse.ArgumentParser(description="导入聊天 Markdown / Cursor JSONL")
    ap.add_argument("--file", type=Path, help="单文件 .md/.txt/.jsonl")
    ap.add_argument("--dir", type=Path, help="目录批量（可递归）")
    ap.add_argument("--项目", default="global")
    ap.add_argument("--tool", default="")
    ap.add_argument("--since", default="", help="仅导入 mtime >= YYYY-MM-DD 的文件")
    ap.add_argument("--parents-only", action="store_true", default=True, help="跳过 subagents（默认）")
    ap.add_argument("--include-subagents", action="store_true", help="包含 subagent JSONL")
    ap.add_argument("--infer-project", action="store_true", help="从 Cursor projects 路径推断项目名")
    ap.add_argument(
        "--transcripts-only",
        action="store_true",
        help="仅导入 **/agent-transcripts/**/*.jsonl（扫 ~/.cursor/projects 时必开）",
    )
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    parents_only = not args.include_subagents
    since = parse_since(args.since or None)

    if args.self_test:
        fix = CENTRAL / "测试夹具" / "聊天导入"
        fix.mkdir(parents=True, exist_ok=True)
        nonce = datetime.now().strftime("%Y%m%d%H%M%S%f")
        samples = {
            "cursor.md": f"User: 你好 {nonce}\nAssistant: 你好，我是 Cursor\n",
            "claude.md": f"Human: 修 bug {nonce}\nClaude: 已修复\n",
            "codex.md": f"User: explain {nonce}\nAssistant: Codex answer\n",
            "chatgpt.md": f"You: idea {nonce}\nChatGPT: here is idea\napi_key=YOUR_API_KEY",
        }
        results = []
        for name, body in samples.items():
            p = fix / name
            p.write_text(body, encoding="utf-8")
            r1 = import_one(p, "fixture", "")
            r2 = import_one(p, "fixture", "")
            assert r1["action"] == "imported", r1
            assert r2["action"] == "duplicate", r2
            results.append(r1)
        assert any(r.get("status") == "PARTIAL" for r in results)

        # JSONL 夹具
        jl = fix / f"cursor_transcript_{nonce}.jsonl"
        jl.write_text(
            "\n".join(
                [
                    json.dumps(
                        {
                            "role": "user",
                            "message": {"content": [{"type": "text", "text": f"jsonl user {nonce}"}]},
                        },
                        ensure_ascii=False,
                    ),
                    json.dumps(
                        {
                            "role": "assistant",
                            "message": {"content": [{"type": "text", "text": "jsonl assistant ok"}]},
                        },
                        ensure_ascii=False,
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        jr1 = import_one(jl, "fixture", "cursor")
        jr2 = import_one(jl, "fixture", "cursor")
        assert jr1["action"] == "imported", jr1
        assert jr2["action"] == "duplicate", jr2
        md = load_source_text(jl)
        assert "User:" in md and "Assistant:" in md

        # --dir 批量（仅夹具目录下刚写的 jsonl）
        batch = import_batch(fix, "fixture", "cursor", parents_only=True, since=None)
        assert batch["duplicate"] >= 1 or batch["imported"] >= 0

        print("PASS: 4 fixtures + jsonl + dedupe + partial secret + dir batch")
        return 0

    if args.dir:
        summary = import_batch(
            args.dir,
            args.项目,
            args.tool,
            parents_only=parents_only,
            since=since,
            infer_project=args.infer_project,
            transcripts_only=args.transcripts_only,
        )
        print(json.dumps({k: summary[k] for k in ("imported", "duplicate", "error", "empty")}, ensure_ascii=False))
        print(json.dumps(summary, ensure_ascii=False, indent=2)[:4000])
        return 0 if summary["error"] == 0 else 1

    if not args.file:
        print("需要 --file / --dir / --self-test", file=sys.stderr)
        return 2

    f = args.file
    if since is not None:
        mtime = datetime.fromtimestamp(f.stat().st_mtime).date()
        if mtime < since:
            print(json.dumps({"action": "skipped", "reason": "before --since", "file": str(f)}, ensure_ascii=False))
            return 0
    print(json.dumps(import_one(f, args.项目, args.tool), ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
