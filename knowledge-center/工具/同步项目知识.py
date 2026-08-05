#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""双向增量知识同步（模块 6）。冲突不覆盖，生成待确认报告。"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

CENTRAL = Path(__file__).resolve().parent.parent
REGISTRY = CENTRAL / "项目注册表.yaml"
MIRROR_ROOT = CENTRAL / "项目镜像"
CONFLICT_DIR = CENTRAL / "冲突与过期记录"
PENDING = CENTRAL / "待确认更新"

SYNC_NAMES = [
    "项目总览.md",
    "当前状态.md",
    "目标与验收标准.md",
    "决策记录.md",
    "错误与根因.md",
    "已验证解决方案.md",
    "开放事项.md",
    "内容素材.md",
    "用户反馈与纠正.md",
]

CENTRAL_TO_PROJECT = [
    ("用户长期记忆/用户偏好与约束.md", "用户偏好摘要.md"),
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def load_enabled() -> list[dict]:
    data = yaml.safe_load(REGISTRY.read_text(encoding="utf-8")) if yaml else {}
    return [p for p in (data.get("projects") or []) if p.get("enabled")]


def atomic_write(path: Path, content: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_bytes(content)
    tmp.replace(path)


def sync_file(
    src: Path,
    dst: Path,
    dry_run: bool,
    stats: dict,
    project: str,
    *,
    on_diff: str = "conflict",
) -> None:
    """on_diff: conflict | overwrite（项目事实源→镜像用 overwrite）。"""
    if not src.is_file():
        stats["skip"] += 1
        return
    src_hash = sha256_file(src)
    if dst.is_file():
        dst_hash = sha256_file(dst)
        if src_hash == dst_hash:
            stats["unchanged"] += 1
            return
        if on_diff == "overwrite":
            stats["copied"] += 1
            if not dry_run:
                atomic_write(dst, src.read_bytes())
            return
        stats["conflict"] += 1
        ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        report = CONFLICT_DIR / f"{ts}_{project}_{dst.name}_同步冲突.md"
        if not dry_run:
            CONFLICT_DIR.mkdir(parents=True, exist_ok=True)
            report.write_text(
                f"# 同步冲突\n\n- 项目：{project}\n- 源：`{src}`\n- 目标：`{dst}`\n"
                f"- src_hash：{src_hash}\n- dst_hash：{dst_hash}\n\n"
                "未覆盖目标。请人工合并后确认。\n",
                encoding="utf-8",
            )
            PENDING.mkdir(parents=True, exist_ok=True)
            (PENDING / f"{ts}_{project}_同步待确认.md").write_text(
                f"冲突文件：{dst.name}\n报告：{report}\n", encoding="utf-8"
            )
        return
    stats["copied"] += 1
    if not dry_run:
        atomic_write(dst, src.read_bytes())


def sync_project(project: dict, dry_run: bool) -> dict:
    name = str(project.get("name") or project.get("id"))
    root = Path(project["path"])
    kb = root / "项目知识库"
    mirror = MIRROR_ROOT / name
    stats = {"copied": 0, "unchanged": 0, "conflict": 0, "skip": 0, "project": name}
    if not kb.is_dir():
        stats["error"] = "missing 项目知识库"
        return stats
    mirror.mkdir(parents=True, exist_ok=True)

    # 项目事实源 → 中央镜像（可覆盖镜像）
    for fname in SYNC_NAMES:
        sync_file(kb / fname, mirror / fname, dry_run, stats, name, on_diff="overwrite")

    src_sess = kb / "会话记录"
    dst_sess = mirror / "会话记录"
    if src_sess.is_dir():
        for f in src_sess.glob("*.md"):
            target = dst_sess / f.name
            if target.exists() and sha256_file(f) == sha256_file(target):
                stats["unchanged"] += 1
            elif target.exists() and sha256_file(f) != sha256_file(target):
                # 会话记录以项目为准覆盖镜像
                stats["copied"] += 1
                if not dry_run:
                    shutil.copy2(f, target)
            else:
                stats["copied"] += 1
                if not dry_run:
                    dst_sess.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(f, target)

    # 中央 → 项目：稳定偏好；冲突不覆盖项目
    for rel, dest_name in CENTRAL_TO_PROJECT:
        src = CENTRAL / rel
        sync_file(src, kb / dest_name, dry_run, stats, name, on_diff="conflict")

    manifest = {
        "project": name,
        "time": datetime.now().isoformat(timespec="seconds"),
        "dry_run": dry_run,
        "stats": stats,
    }
    if not dry_run:
        (mirror / "同步清单.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        (kb / "最后同步.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
        )
    return stats


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--项目", dest="name")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        return self_test()

    projects = load_enabled()
    if args.name:
        projects = [p for p in projects if p.get("name") == args.name or p.get("id") == args.name]
    elif not args.all:
        print("指定 --项目 或 --all", file=sys.stderr)
        return 2

    for p in projects:
        st = sync_project(p, args.dry_run)
        print(json.dumps(st, ensure_ascii=False))
    return 0


def self_test() -> int:
    base = CENTRAL / "测试夹具" / "同步验收"
    if base.exists():
        shutil.rmtree(base)
    proj = base / "demo"
    kb = proj / "项目知识库"
    kb.mkdir(parents=True)
    (kb / "当前状态.md").write_text("# A\nversion1\n", encoding="utf-8")
    # 偏好文件两侧制造冲突
    pref_central = CENTRAL / "用户长期记忆" / "用户偏好与约束.md"
    assert pref_central.is_file()
    (kb / "用户偏好摘要.md").write_text("# local divergent\n", encoding="utf-8")
    fake = {"name": "同步夹具", "path": str(proj), "enabled": True}
    global MIRROR_ROOT
    old = MIRROR_ROOT
    MIRROR_ROOT = base / "镜像"
    try:
        st1 = sync_project(fake, dry_run=False)
        assert st1["copied"] >= 1, st1
        st2 = sync_project(fake, dry_run=False)
        assert st2["unchanged"] >= 1, st2
        # 项目事实更新应覆盖镜像
        (kb / "当前状态.md").write_text("# A\nversion2\n", encoding="utf-8")
        st3 = sync_project(fake, dry_run=False)
        mirror_file = MIRROR_ROOT / "同步夹具" / "当前状态.md"
        assert "version2" in mirror_file.read_text(encoding="utf-8"), st3
        # 中央→项目偏好冲突不覆盖
        assert "local divergent" in (kb / "用户偏好摘要.md").read_text(encoding="utf-8")
        assert st3["conflict"] >= 1 or st1["conflict"] >= 1 or st2["conflict"] >= 1
        print("PASS: sync first/idempotent/overwrite-mirror/conflict-central")
    finally:
        MIRROR_ROOT = old
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
