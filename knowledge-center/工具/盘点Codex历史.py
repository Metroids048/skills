#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""只读盘点 Codex rollout JSONL。

默认只输出结构、数量和时间信息，不输出消息正文、工具参数或环境变量。
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable


CODEX_ROOT = Path.home() / ".codex"
ROLLOUT_ROOTS = (
    CODEX_ROOT / "sessions",
    CODEX_ROOT / "archived_sessions",
)
SESSION_INDEX = CODEX_ROOT / "session_index.jsonl"
REGISTERED_PROJECTS = {
    "AI--main": Path("C:/Users/win/Desktop/AI--main"),
    "alpha": Path("C:/Users/win/Desktop/alpha"),
    "program1-main-latest": Path("C:/Users/win/Desktop/program1-main-latest"),
    "yinpinjianting": Path("C:/Users/win/Desktop/yinpinjianting"),
    "敖钦储能项目": Path("C:/Users/win/Desktop/敖钦储能项目"),
    "海小南": Path("C:/Users/win/Desktop/海小南"),
    "Agent Platform": Path("C:/Users/win/Desktop/Agent Platform"),
    "产能评价": Path("C:/Users/win/Desktop/产能评价"),
    "合同审查": Path("C:/Users/win/Desktop/合同审查"),
}
CENTRAL_ROOT = Path("C:/Users/win/Desktop/全局配置")


def iter_rollouts() -> Iterable[tuple[str, Path]]:
    for root in ROLLOUT_ROOTS:
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("rollout-*.jsonl")):
            if path.is_file():
                yield root.name, path


def parse_timestamp(value: Any) -> datetime | None:
    if not isinstance(value, str) or not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def update_time_range(
    current: tuple[datetime | None, datetime | None],
    value: Any,
) -> tuple[datetime | None, datetime | None]:
    parsed = parse_timestamp(value)
    if parsed is None:
        return current
    earliest, latest = current
    earliest = parsed if earliest is None or parsed < earliest else earliest
    latest = parsed if latest is None or parsed > latest else latest
    return earliest, latest


def scan_schema() -> dict[str, Any]:
    source_files: Counter[str] = Counter()
    source_bytes: Counter[str] = Counter()
    top_types: Counter[str] = Counter()
    payload_types: Counter[str] = Counter()
    payload_keys: dict[str, Counter[str]] = {}
    malformed_lines = 0
    total_lines = 0
    time_range: tuple[datetime | None, datetime | None] = (None, None)

    for source, path in iter_rollouts():
        source_files[source] += 1
        source_bytes[source] += path.stat().st_size
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            for line in handle:
                total_lines += 1
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    malformed_lines += 1
                    continue
                top_type = str(obj.get("type") or "<missing>")
                top_types[top_type] += 1
                time_range = update_time_range(time_range, obj.get("timestamp"))
                payload = obj.get("payload")
                if not isinstance(payload, dict):
                    continue
                payload_type = str(payload.get("type") or "<missing>")
                payload_types[payload_type] += 1
                payload_keys.setdefault(payload_type, Counter()).update(payload.keys())

    earliest, latest = time_range
    return {
        "sources": {
            name: {"files": source_files[name], "bytes": source_bytes[name]}
            for name in sorted(source_files)
        },
        "total_files": sum(source_files.values()),
        "total_lines": total_lines,
        "malformed_lines": malformed_lines,
        "timestamp_earliest": earliest.isoformat() if earliest else None,
        "timestamp_latest": latest.isoformat() if latest else None,
        "top_level_types": dict(top_types.most_common()),
        "payload_types": dict(payload_types.most_common()),
        "payload_key_names": {
            payload_type: sorted(keys)
            for payload_type, keys in sorted(payload_keys.items())
        },
        "session_index": scan_index_schema(),
    }


def scan_index_schema() -> dict[str, Any]:
    if not SESSION_INDEX.is_file():
        return {"present": False, "rows": 0, "malformed_lines": 0, "key_names": []}
    rows = 0
    malformed = 0
    keys: set[str] = set()
    time_range: tuple[datetime | None, datetime | None] = (None, None)
    with SESSION_INDEX.open("r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                malformed += 1
                continue
            if not isinstance(obj, dict):
                continue
            rows += 1
            keys.update(obj)
            for key in ("timestamp", "created_at", "updated_at"):
                time_range = update_time_range(time_range, obj.get(key))
    earliest, latest = time_range
    return {
        "present": True,
        "rows": rows,
        "malformed_lines": malformed,
        "key_names": sorted(keys),
        "timestamp_earliest": earliest.isoformat() if earliest else None,
        "timestamp_latest": latest.isoformat() if latest else None,
    }


def normalize_path(value: str) -> str:
    return value.replace("\\", "/").rstrip("/").casefold()


def project_from_cwd(cwd: str) -> tuple[str, str]:
    normalized = normalize_path(cwd)
    central = normalize_path(str(CENTRAL_ROOT))
    if normalized == central or normalized.startswith(central + "/"):
        return "全局配置", "central"
    for name, root in sorted(
        REGISTERED_PROJECTS.items(),
        key=lambda item: len(normalize_path(str(item[1]))),
        reverse=True,
    ):
        candidate = normalize_path(str(root))
        if normalized == candidate or normalized.startswith(candidate + "/"):
            return name, "registered"
    desktop_prefix = normalize_path("C:/Users/win/Desktop") + "/"
    if normalized.startswith(desktop_prefix):
        relative = cwd.replace("\\", "/")[len("C:/Users/win/Desktop/") :]
        return relative.split("/", 1)[0] or "<Desktop root>", "unregistered"
    if not cwd:
        return "<unknown>", "unknown"
    return "<outside Desktop>", "outside"


def load_index_titles() -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    if not SESSION_INDEX.is_file():
        return result
    with SESSION_INDEX.open("r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            if not isinstance(obj, dict) or not obj.get("id"):
                continue
            result[str(obj["id"])] = obj
    return result


def safe_title(value: Any) -> str:
    text = " ".join(str(value or "").split())
    text = re.sub(
        r"(?i)(api[_-]?key|secret|token|password|cookie|密钥|密码|私钥)\s*[:=]\s*\S+",
        r"\1=[REDACTED]",
        text,
    )
    text = re.sub(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}", "[REDACTED_EMAIL]", text)
    text = re.sub(r"(?<!\d)1[3-9]\d{9}(?!\d)", "[REDACTED_PHONE]", text)
    text = re.sub(r"(?<!\d)\d{17}[\dXx](?!\d)", "[REDACTED_ID]", text)
    return text[:240]


def extract_text_content(value: Any) -> str:
    if isinstance(value, str):
        return value
    if isinstance(value, list):
        chunks: list[str] = []
        for item in value:
            if isinstance(item, str):
                chunks.append(item)
            elif isinstance(item, dict):
                chunks.append(
                    extract_text_content(item.get("text") or item.get("content"))
                )
        return "\n".join(chunk for chunk in chunks if chunk)
    if isinstance(value, dict):
        return extract_text_content(value.get("text") or value.get("content"))
    return ""


def safe_excerpt(value: Any, limit: int = 6000) -> str:
    text = extract_text_content(value)
    text = re.sub(
        r"(?i)(api[_-]?key|secret|token|password|cookie|密钥|密码|私钥)\s*[:=]\s*[^\s`]+",
        r"\1=[REDACTED]",
        text,
    )
    text = re.sub(r"(?i)Bearer\s+\S+", "Bearer [REDACTED]", text)
    text = re.sub(r"\bsk-[A-Za-z0-9_-]{12,}\b", "[REDACTED_API_KEY]", text)
    text = re.sub(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}", "[REDACTED_EMAIL]", text)
    text = re.sub(r"(?<!\d)1[3-9]\d{9}(?!\d)", "[REDACTED_PHONE]", text)
    text = re.sub(r"(?<!\d)\d{17}[\dXx](?!\d)", "[REDACTED_ID]", text)
    text = re.sub(r"(?<!\d)\d{8,}(?!\d)", "[REDACTED_LONG_NUMBER]", text)
    text = re.sub(
        r"https?://[^\s)]+[?&][^\s)]+",
        "[REDACTED_URL_WITH_QUERY]",
        text,
    )
    text = re.sub(r"\b[A-Za-z0-9_-]{64,}\b", "[REDACTED_LONG_TOKEN]", text)
    return text[-limit:]


def extract_final_messages(session_ids: list[str]) -> dict[str, Any]:
    wanted = set(session_ids)
    titles = load_index_titles()
    found: dict[str, dict[str, Any]] = {}
    for source, path in iter_rollouts():
        file_ids: set[str] = set()
        final_candidates: list[str] = []
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            for line in handle:
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                payload = obj.get("payload")
                if not isinstance(payload, dict):
                    continue
                if obj.get("type") == "session_meta" and payload.get("id"):
                    file_ids.add(str(payload["id"]))
                payload_type = payload.get("type")
                if payload_type == "task_complete" and payload.get("last_agent_message"):
                    final_candidates.append(
                        extract_text_content(payload.get("last_agent_message"))
                    )
                elif (
                    payload_type == "message"
                    and payload.get("role") == "assistant"
                    and payload.get("phase") == "final"
                ):
                    final_candidates.append(
                        extract_text_content(payload.get("content"))
                    )
                elif payload_type == "agent_message" and payload.get("message"):
                    final_candidates.append(str(payload.get("message")))
        matched = file_ids & wanted
        if not matched:
            continue
        for session_id in matched:
            indexed = titles.get(session_id, {})
            found[session_id] = {
                "session_id": session_id,
                "source": source,
                "rollout_path": str(path),
                "title": safe_title(indexed.get("thread_name")),
                "updated_at": indexed.get("updated_at"),
                "final_excerpt": safe_excerpt(
                    next((item for item in reversed(final_candidates) if item.strip()), "")
                ),
            }
    return {
        "requested": len(wanted),
        "found": len(found),
        "sessions": [found[key] for key in session_ids if key in found],
    }


def scan_manifest(*, include_titles: bool) -> dict[str, Any]:
    titles = load_index_titles()
    groups: dict[tuple[str, str], dict[str, Any]] = {}
    root_sessions: list[dict[str, Any]] = []
    indexed_root_ids_seen: set[str] = set()
    files_seen = 0
    session_meta_records = 0

    for source, path in iter_rollouts():
        files_seen += 1
        metas: list[dict[str, Any]] = []
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            for line in handle:
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if obj.get("type") != "session_meta":
                    continue
                payload = obj.get("payload")
                if isinstance(payload, dict):
                    metas.append(payload)
        session_meta_records += len(metas)
        if not metas:
            continue
        primary = next(
            (
                meta
                for meta in metas
                if not meta.get("parent_thread_id")
                and not meta.get("forked_from_id")
                and not meta.get("agent_path")
            ),
            metas[0],
        )
        cwd = str(primary.get("cwd") or "")
        project, registration = project_from_cwd(cwd)
        key = (project, registration)
        group = groups.setdefault(
            key,
            {
                "project": project,
                "registration": registration,
                "rollout_files": 0,
                "bytes": 0,
                "root_session_ids": set(),
                "child_session_ids": set(),
                "indexed_title_ids": set(),
                "timestamp_earliest": None,
                "timestamp_latest": None,
                "sources": Counter(),
            },
        )
        group["rollout_files"] += 1
        group["bytes"] += path.stat().st_size
        group["sources"][source] += 1
        for meta in metas:
            session_id = str(meta.get("id") or path.stem.removeprefix("rollout-"))
            is_child = bool(
                meta.get("parent_thread_id")
                or meta.get("forked_from_id")
                or meta.get("agent_path")
            )
            target = "child_session_ids" if is_child else "root_session_ids"
            group[target].add(session_id)
            parsed = parse_timestamp(meta.get("timestamp"))
            if parsed is not None:
                if group["timestamp_earliest"] is None or parsed < group["timestamp_earliest"]:
                    group["timestamp_earliest"] = parsed
                if group["timestamp_latest"] is None or parsed > group["timestamp_latest"]:
                    group["timestamp_latest"] = parsed
            if session_id in titles:
                group["indexed_title_ids"].add(session_id)
                if not is_child and session_id not in indexed_root_ids_seen:
                    indexed_root_ids_seen.add(session_id)
                    root_sessions.append(
                        {
                            "session_id": session_id,
                            "project": project,
                            "registration": registration,
                            "timestamp": parsed.isoformat() if parsed else None,
                            "updated_at": titles[session_id].get("updated_at"),
                            "title": safe_title(titles[session_id].get("thread_name")),
                            "source": source,
                        }
                    )

    serialized_groups = []
    for group in groups.values():
        serialized_groups.append(
            {
                **{
                    key: value
                    for key, value in group.items()
                    if key
                    not in {
                        "root_session_ids",
                        "child_session_ids",
                        "indexed_title_ids",
                        "sources",
                        "timestamp_earliest",
                        "timestamp_latest",
                    }
                },
                "root_sessions": len(group["root_session_ids"]),
                "child_sessions": len(group["child_session_ids"]),
                "indexed_titles": len(group["indexed_title_ids"]),
                "sources": dict(group["sources"]),
                "timestamp_earliest": (
                    group["timestamp_earliest"].isoformat()
                    if group["timestamp_earliest"]
                    else None
                ),
                "timestamp_latest": (
                    group["timestamp_latest"].isoformat()
                    if group["timestamp_latest"]
                    else None
                ),
            }
        )
    serialized_groups.sort(key=lambda item: (item["registration"], item["project"]))
    root_sessions.sort(key=lambda item: item["updated_at"] or "", reverse=True)
    return {
        "rollout_files": files_seen,
        "session_meta_records": session_meta_records,
        "groups": serialized_groups,
        "indexed_root_sessions": root_sessions if include_titles else len(root_sessions),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="只读盘点 Codex rollout JSONL")
    parser.add_argument(
        "--schema-only",
        action="store_true",
        help="仅输出事件结构统计（默认行为）",
    )
    parser.add_argument(
        "--manifest-summary",
        action="store_true",
        help="输出项目归属、会话数与时间范围，不输出消息正文",
    )
    parser.add_argument(
        "--titles",
        action="store_true",
        help="随 manifest 输出脱敏后的 session_index 标题",
    )
    parser.add_argument(
        "--extract-final",
        nargs="+",
        metavar="SESSION_ID",
        help="只输出指定会话的脱敏最终回复，不输出用户消息或工具参数",
    )
    args = parser.parse_args()
    if args.extract_final:
        result = extract_final_messages(args.extract_final)
    elif args.manifest_summary or args.titles:
        result = scan_manifest(include_titles=args.titles)
    else:
        result = scan_schema()
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
