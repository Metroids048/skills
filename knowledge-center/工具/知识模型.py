#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""中央知识库数据模型：校验、去重、冲突保存（不覆盖已确认主库）。"""

from __future__ import annotations

import hashlib
import json
import re
import unicodedata
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

CENTRAL = Path(__file__).resolve().parent.parent
SCHEMA_PATH = CENTRAL / "配置" / "知识数据模型.yaml"
CONFLICT_DIR = CENTRAL / "冲突与过期记录"
PENDING_DIR = CENTRAL / "待确认更新"
KNOWLEDGE_STORE = CENTRAL / "用户长期记忆" / "知识项.jsonl"
MAIN_KB = CENTRAL / "USER_KNOWLEDGE_BASE.md"

REQUIRED = (
    "id",
    "date",
    "source_tool",
    "project",
    "type",
    "statement",
    "confidence",
    "evidence",
    "sensitivity",
    "public_eligible",
    "status",
    "supersedes",
    "conflicts_with",
    "tags",
)


@dataclass
class KnowledgeItem:
    id: str
    date: str
    source_tool: str
    project: str
    type: str
    statement: str
    confidence: str
    evidence: list[str] | str
    sensitivity: str
    public_eligible: bool | str
    status: str
    supersedes: list[str] | str | None = None
    conflicts_with: list[str] | str | None = None
    tags: list[str] = field(default_factory=list)
    confirmed: bool = False

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        if d["supersedes"] is None:
            d["supersedes"] = []
        if d["conflicts_with"] is None:
            d["conflicts_with"] = []
        if isinstance(d["evidence"], str):
            d["evidence"] = [d["evidence"]] if d["evidence"] else []
        if isinstance(d["supersedes"], str):
            d["supersedes"] = [d["supersedes"]] if d["supersedes"] else []
        if isinstance(d["conflicts_with"], str):
            d["conflicts_with"] = [d["conflicts_with"]] if d["conflicts_with"] else []
        return d


def load_schema() -> dict[str, Any]:
    if not SCHEMA_PATH.is_file():
        return {}
    text = SCHEMA_PATH.read_text(encoding="utf-8")
    if yaml is None:
        return {"raw": text}
    return yaml.safe_load(text) or {}


def normalize_statement(text: str) -> str:
    t = unicodedata.normalize("NFKC", text or "")
    t = t.strip().lower()
    t = re.sub(r"\s+", " ", t)
    return t


def fingerprint(item: dict[str, Any]) -> str:
    base = "|".join(
        [
            str(item.get("project", "")),
            str(item.get("type", "")),
            normalize_statement(str(item.get("statement", ""))),
        ]
    )
    return hashlib.sha256(base.encode("utf-8")).hexdigest()[:16]


def new_id(prefix: str = "K") -> str:
    ts = datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")
    rnd = hashlib.sha1(f"{ts}-{prefix}".encode()).hexdigest()[:6]
    return f"{prefix}-{ts}-{rnd}"


def validate_item(item: dict[str, Any], schema: dict[str, Any] | None = None) -> list[str]:
    errors: list[str] = []
    schema = schema or load_schema()
    for key in REQUIRED:
        if key not in item:
            errors.append(f"missing field: {key}")
    if not item.get("id"):
        errors.append("id empty")
    if not str(item.get("statement", "")).strip():
        errors.append("statement empty")
    types = set(schema.get("record_types") or [])
    if types and item.get("type") not in types:
        errors.append(f"invalid type: {item.get('type')}")
    tools = set(schema.get("source_tools") or [])
    if tools and item.get("source_tool") not in tools:
        errors.append(f"invalid source_tool: {item.get('source_tool')}")
    conf = set(schema.get("confidence") or [])
    if conf and item.get("confidence") not in conf:
        errors.append(f"invalid confidence: {item.get('confidence')}")
    sens = set(schema.get("sensitivity") or [])
    if sens and item.get("sensitivity") not in sens:
        errors.append(f"invalid sensitivity: {item.get('sensitivity')}")
    st = set(schema.get("status") or [])
    if st and item.get("status") not in st:
        errors.append(f"invalid status: {item.get('status')}")
    return errors


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.is_file():
        return []
    items = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        items.append(json.loads(line))
    return items


def append_jsonl(path: Path, item: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(item, ensure_ascii=False) + "\n")


def find_duplicates(items: list[dict[str, Any]]) -> list[tuple[str, str, str]]:
    """返回 (fp, id_a, id_b) 重复对。"""
    seen: dict[str, str] = {}
    dups: list[tuple[str, str, str]] = []
    for it in items:
        fp = fingerprint(it)
        if fp in seen:
            dups.append((fp, seen[fp], str(it.get("id"))))
        else:
            seen[fp] = str(it.get("id"))
    return dups


def save_conflict(
    existing: dict[str, Any],
    incoming: dict[str, Any],
    reason: str,
) -> Path:
    CONFLICT_DIR.mkdir(parents=True, exist_ok=True)
    PENDING_DIR.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    cid = new_id("CF")
    report = {
        "conflict_id": cid,
        "created_at": datetime.now().isoformat(timespec="seconds"),
        "reason": reason,
        "existing": existing,
        "incoming": incoming,
        "resolution": "PENDING_CONFIRM",
        "rule": "不得静默覆盖已确认主知识库",
    }
    out = CONFLICT_DIR / f"{ts}_{cid}_冲突报告.json"
    out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    patch = PENDING_DIR / f"{ts}_{cid}_待确认补丁.md"
    patch.write_text(
        "\n".join(
            [
                f"# 待确认补丁 `{cid}`",
                "",
                f"- 原因：{reason}",
                f"- 已有 ID：`{existing.get('id')}`",
                f"- 新来 ID：`{incoming.get('id')}`",
                "",
                "## 已有陈述",
                "",
                str(existing.get("statement", "")),
                "",
                "## 新来陈述",
                "",
                str(incoming.get("statement", "")),
                "",
                "## 处理选项",
                "",
                "1. 保留已有，拒绝新来",
                "2. 用新来 supersede 已有",
                "3. 两者并存并标注 conflicts_with",
                "",
                "> 系统不会自动覆盖 `confirmed=true` 的主库条目。",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return out


def propose_upsert(
    incoming: dict[str, Any],
    store_path: Path = KNOWLEDGE_STORE,
    *,
    allow_overwrite_confirmed: bool = False,
) -> dict[str, Any]:
    """提议写入知识项。已确认条目冲突时只存冲突，不覆盖。"""
    schema = load_schema()
    errs = validate_item(incoming, schema)
    if errs:
        return {"ok": False, "errors": errs, "action": "reject"}

    items = load_jsonl(store_path)
    by_id = {str(x.get("id")): x for x in items}
    fp = fingerprint(incoming)

    # ID 冲突
    if incoming["id"] in by_id:
        old = by_id[incoming["id"]]
        if old.get("confirmed") and not allow_overwrite_confirmed:
            path = save_conflict(old, incoming, "同 ID 且已确认，拒绝静默覆盖")
            return {"ok": True, "action": "conflict_saved", "path": str(path)}
        return {"ok": False, "action": "reject", "errors": ["id exists; use supersede flow"]}

    # 语义重复
    for old in items:
        if fingerprint(old) == fp:
            if old.get("confirmed") and not allow_overwrite_confirmed:
                path = save_conflict(old, incoming, "语义重复且已确认，生成待确认补丁")
                return {"ok": True, "action": "conflict_saved", "path": str(path), "duplicate_of": old.get("id")}
            return {
                "ok": True,
                "action": "duplicate",
                "duplicate_of": old.get("id"),
                "fingerprint": fp,
            }

    append_jsonl(store_path, incoming)
    return {"ok": True, "action": "appended", "id": incoming["id"], "fingerprint": fp}


def make_item(
    *,
    statement: str,
    type: str,
    project: str = "global",
    source_tool: str = "system",
    confidence: str = "MEDIUM",
    evidence: list[str] | None = None,
    sensitivity: str = "PRIVATE",
    public_eligible: bool = False,
    status: str = "ACTIVE",
    tags: list[str] | None = None,
    confirmed: bool = False,
) -> dict[str, Any]:
    return KnowledgeItem(
        id=new_id("K"),
        date=datetime.now().strftime("%Y-%m-%d"),
        source_tool=source_tool,
        project=project,
        type=type,
        statement=statement,
        confidence=confidence,
        evidence=evidence or [],
        sensitivity=sensitivity,
        public_eligible=public_eligible,
        status=status,
        supersedes=[],
        conflicts_with=[],
        tags=tags or [],
        confirmed=confirmed,
    ).to_dict()


def protect_main_kb_write(target: Path) -> bool:
    """主知识库文件存在且非空时，禁止脚本直接整文件覆盖。"""
    if target.resolve() == MAIN_KB.resolve() and MAIN_KB.is_file() and MAIN_KB.stat().st_size > 0:
        return False
    return True
