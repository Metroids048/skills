#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""校验知识库 schema / 去重 / 冲突保护（模块 1 验收）。"""

from __future__ import annotations

import json
import sys
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(CENTRAL / "工具"))

from 知识模型 import (  # noqa: E402
    KNOWLEDGE_STORE,
    MAIN_KB,
    find_duplicates,
    load_jsonl,
    load_schema,
    make_item,
    propose_upsert,
    protect_main_kb_write,
    validate_item,
)


def run_acceptance() -> int:
    schema = load_schema()
    assert schema.get("knowledge_item_required_fields"), "schema missing required fields"
    print("PASS: schema loaded")

    # 合法项
    good = make_item(
        statement="用户偏好：默认中文沟通",
        type="USER_PREFERENCE",
        confidence="CONFIRMED",
        evidence=["USER_KNOWLEDGE_BASE.md"],
        confirmed=True,
    )
    errs = validate_item(good, schema)
    assert not errs, errs
    print("PASS: valid item")

    # 缺字段
    bad = {"id": "x", "statement": "nope"}
    errs = validate_item(bad, schema)
    assert errs, "expected validation errors"
    print("PASS: invalid item rejected")

    # 写入 store（用临时）
    store = CENTRAL / "测试夹具" / "知识项_验收.jsonl"
    if store.exists():
        store.unlink()
    r1 = propose_upsert(good, store)
    assert r1["action"] == "appended", r1
    print("PASS: append")

    # 重复
    dup = make_item(
        statement="用户偏好：默认中文沟通",
        type="USER_PREFERENCE",
        confidence="MEDIUM",
        evidence=["dup-test"],
    )
    r2 = propose_upsert(dup, store)
    assert r2["action"] in ("duplicate", "conflict_saved"), r2
    print(f"PASS: duplicate detected action={r2['action']}")

    # 已确认冲突 → 待确认补丁，不覆盖
    conflict_in = make_item(
        statement="用户偏好：默认中文沟通",
        type="USER_PREFERENCE",
        confidence="HIGH",
        evidence=["conflict-test"],
    )
    # 确保 store 中 confirmed 项存在
    items = load_jsonl(store)
    assert any(i.get("confirmed") for i in items)
    r3 = propose_upsert(conflict_in, store)
    assert r3["action"] == "conflict_saved", r3
    assert Path(r3["path"]).is_file()
    # store 行数未因覆盖减少/替换
    items2 = load_jsonl(store)
    assert len(items2) == len(items)
    print("PASS: conflict saved without overwrite")

    # 主知识库保护
    assert protect_main_kb_write(MAIN_KB) is False
    print("PASS: main KB overwrite blocked")

    # 去重扫描
    dups = find_duplicates(items2 + [dup])
    assert dups, "expected duplicates in scan"
    print(f"PASS: find_duplicates count={len(dups)}")

    # 种子：若主 store 不存在则写入一条全局偏好（不碰 USER_KNOWLEDGE_BASE.md）
    if not KNOWLEDGE_STORE.is_file():
        seed = make_item(
            statement="收口模式：单目标、可验收、真实验证、完成后停止",
            type="USER_CONSTRAINT",
            confidence="CONFIRMED",
            evidence=["MEMORY_AGENTS.md", "USER_KNOWLEDGE_BASE.md"],
            confirmed=True,
            tags=["收口模式"],
        )
        propose_upsert(seed, KNOWLEDGE_STORE)
        print(f"PASS: seeded {KNOWLEDGE_STORE}")
    else:
        print(f"PASS: store exists {KNOWLEDGE_STORE}")

    summary = {
        "module": 1,
        "schema_ok": True,
        "duplicate_ok": True,
        "conflict_ok": True,
        "main_kb_protected": True,
    }
    out = CENTRAL / "日志" / "模块1_验收.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    print("OK: 模块1验收全部通过")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(run_acceptance())
    except AssertionError as e:
        print(f"FAIL: {e}", file=sys.stderr)
        raise SystemExit(1)
