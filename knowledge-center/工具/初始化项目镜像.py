#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""为已启用项目创建中央「项目镜像」骨架（不修改业务源码）。"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

CENTRAL = Path(__file__).resolve().parent.parent
REGISTRY = CENTRAL / "项目注册表.yaml"
MIRROR_ROOT = CENTRAL / "项目镜像"

MIRROR_FILES = {
    "项目总览.md": "# 项目总览\n\n（中央镜像；项目事实源在项目内 `项目知识库/`）\n\n- 项目：{name}\n- 路径：`{path}`\n- 同步状态：未首次同步\n",
    "当前状态.md": "# 当前状态\n\n- 状态：NOT_STARTED / 待同步\n- 更新日期：待定\n",
    "目标与验收标准.md": "# 目标与验收标准\n\n（待从项目同步）\n",
    "决策记录.md": "# 决策记录\n\n（待同步）\n",
    "错误与根因.md": "# 错误与根因\n\n（待同步）\n",
    "已验证解决方案.md": "# 已验证解决方案\n\n（待同步）\n",
    "开放事项.md": "# 开放事项\n\n（待同步）\n",
    "内容素材.md": "# 内容素材\n\n（待同步）\n",
    "同步状态.md": "# 同步状态\n\n- last_sync: never\n- direction: none\n",
}


def load_enabled() -> list[dict]:
    text = REGISTRY.read_text(encoding="utf-8")
    data = yaml.safe_load(text) if yaml else {}
    projects = data.get("projects") or []
    return [p for p in projects if p.get("enabled")]


def safe_dir_name(name: str) -> str:
    return name.replace("/", "-").replace("\\", "-").strip() or "project"


def main() -> int:
    enabled = load_enabled()
    if not enabled:
        print("ERROR: 无启用项目", file=sys.stderr)
        return 2
    MIRROR_ROOT.mkdir(parents=True, exist_ok=True)
    for p in enabled:
        name = str(p.get("name") or p.get("id"))
        path = str(p.get("path") or "")
        dname = safe_dir_name(name)
        root = MIRROR_ROOT / dname
        root.mkdir(parents=True, exist_ok=True)
        (root / "会话记录").mkdir(exist_ok=True)
        for fname, tmpl in MIRROR_FILES.items():
            fp = root / fname
            if fp.exists():
                print(f"skip {dname}/{fname}")
                continue
            fp.write_text(tmpl.format(name=name, path=path), encoding="utf-8")
            print(f"create {dname}/{fname}")
        meta = root / "镜像元数据.yaml"
        if not meta.exists():
            meta.write_text(
                f'project_id: "{p.get("id")}"\n'
                f'name: "{name}"\n'
                f'path: "{path}"\n'
                f"has_git: {str(bool(p.get('has_git'))).lower()}\n"
                f"mirror_only: true\n"
                f"note: \"中央镜像不是源码备份\"\n",
                encoding="utf-8",
            )
            print(f"create {dname}/镜像元数据.yaml")
    print(f"OK: 项目镜像 {len(enabled)} 个")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
