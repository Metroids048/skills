#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""扫描本机项目：只扫同步配置中的根；不改业务源码。"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore

CENTRAL = Path(__file__).resolve().parent.parent
DEFAULT_SYNC = CENTRAL / "同步配置.yaml"
DEFAULT_REGISTRY = CENTRAL / "项目注册表.yaml"
PENDING_DIR = CENTRAL / "待确认更新"

PROJECT_MARKERS_DEFAULT = (
    ".git",
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
)


@dataclass
class Candidate:
    id: str
    name: str
    path: str
    enabled: bool
    sensitive: bool
    has_git: bool
    markers: list[str]
    notes: str
    discovered_at: str


def load_yaml(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if yaml is not None:
        data = yaml.safe_load(text) or {}
        if not isinstance(data, dict):
            raise ValueError(f"YAML root must be mapping: {path}")
        return data
    return _minimal_yaml_load(text)


def _minimal_yaml_load(text: str) -> dict:
    """无 PyYAML 时的极简解析：仅支持本配置用到的标量/列表。"""
    result: dict = {}
    current_list_key: str | None = None
    for raw in text.splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        if line.startswith("  - "):
            if current_list_key is None:
                continue
            val = line[4:].strip().strip('"').strip("'")
            result.setdefault(current_list_key, []).append(val)
            continue
        if ":" in line and not line.startswith(" "):
            key, _, rest = line.partition(":")
            key = key.strip()
            rest = rest.strip()
            current_list_key = None
            if rest == "" or rest == "|":
                if rest == "|":
                    result[key] = ""
                    current_list_key = None
                else:
                    result[key] = []
                    current_list_key = key
            else:
                result[key] = rest.strip('"').strip("'")
                if key in (
                    "project_roots",
                    "exclude_root_children",
                    "exclude_dir_names",
                    "project_markers",
                ):
                    # scalar mistaken — wait for list items under wrong parse
                    pass
        elif line.startswith("  ") and ":" in line:
            # nested ignored for module 0
            current_list_key = None
    # fix max_depth int
    if "max_depth" in result and isinstance(result["max_depth"], str):
        try:
            result["max_depth"] = int(result["max_depth"])
        except ValueError:
            result["max_depth"] = 4
    return result


def dump_registry(projects: list[Candidate]) -> str:
    lines = [
        "# 项目注册表 — draft（模块 0）",
        "# 全部 enabled: false；人工确认后再启用。",
        "version: 1",
        "status: draft",
        f'updated: "{datetime.now().strftime("%Y-%m-%d")}"',
        "projects:",
    ]
    if not projects:
        lines.append("  []")
        return "\n".join(lines) + "\n"
    for p in projects:
        lines.append(f'  - id: "{p.id}"')
        lines.append(f'    name: "{p.name}"')
        lines.append(f'    path: "{p.path}"')
        lines.append(f"    enabled: {str(p.enabled).lower()}")
        lines.append(f"    sensitive: {str(p.sensitive).lower()}")
        lines.append(f"    has_git: {str(p.has_git).lower()}")
        markers = ", ".join(f'"{m}"' for m in p.markers)
        lines.append(f"    markers: [{markers}]")
        notes = p.notes.replace('"', "'")
        lines.append(f'    notes: "{notes}"')
        lines.append(f'    discovered_at: "{p.discovered_at}"')
    return "\n".join(lines) + "\n"


def slug_id(name: str) -> str:
    keep = []
    for ch in name:
        if ch.isalnum() or ch in "-_" or "\u4e00" <= ch <= "\u9fff":
            keep.append(ch)
        elif ch in " .":
            keep.append("-")
    s = "".join(keep).strip("-") or "project"
    return s[:64]


def is_excluded_name(name: str, exclude_names: set[str]) -> bool:
    return name in exclude_names or name.startswith(".")


def detect_markers(path: Path, marker_names: tuple[str, ...]) -> list[str]:
    found = []
    for m in marker_names:
        if m == ".git":
            if (path / ".git").exists():
                found.append(".git")
        elif (path / m).is_file():
            found.append(m)
    return found


def _is_under(path: Path, ancestor: Path) -> bool:
    try:
        path.resolve().relative_to(ancestor.resolve())
        return True
    except ValueError:
        return False


def scan_root(
    root: Path,
    *,
    max_depth: int,
    exclude_names: set[str],
    exclude_children: set[str],
    markers: tuple[str, ...],
    central: Path | None,
    skip_central_tree: bool = True,
) -> list[Candidate]:
    root = root.resolve()
    central_res = central.resolve() if central is not None else None
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    found: list[Candidate] = []
    seen: set[Path] = set()

    def walk(current: Path, depth: int) -> None:
        if depth > max_depth:
            return
        try:
            entries = sorted(current.iterdir(), key=lambda p: p.name.lower())
        except PermissionError:
            return
        for entry in entries:
            if not entry.is_dir():
                continue
            name = entry.name
            if is_excluded_name(name, exclude_names):
                continue
            if depth == 0 and name in exclude_children:
                continue
            resolved = entry.resolve()
            if (
                skip_central_tree
                and central_res is not None
                and (resolved == central_res or _is_under(resolved, central_res))
            ):
                continue

            hit = detect_markers(entry, markers)
            if hit:
                if resolved in seen:
                    continue
                seen.add(resolved)
                parent_name = entry.parent.name
                cid = slug_id(name)
                # 同名子目录（如多个 prototype）用父目录区分
                if any(x.id == cid for x in found):
                    cid = slug_id(f"{parent_name}-{name}")
                cand = Candidate(
                    id=cid,
                    name=name,
                    path=resolved.as_posix(),
                    enabled=False,
                    sensitive=False,
                    has_git=".git" in hit,
                    markers=hit,
                    notes="自动发现候选，待人工确认",
                    discovered_at=now,
                )
                found.append(cand)
                # 已是项目根则不再向下挖（避免 monorepo 内包全进注册表）
                continue
            walk(entry, depth + 1)

    walk(root, 0)
    return found

def write_candidate_md(
    path: Path,
    candidates: list[Candidate],
    root_label: str,
    review_dirs: list[str] | None = None,
) -> None:
    lines = [
        f"# 候选项目清单",
        "",
        f"- 生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- 扫描根：`{root_label}`",
        f"- 候选数：{len(candidates)}",
        f"- 说明：全部为 draft，`enabled: false`；确认后请回复要启用的项目。",
        "",
        "## 发现的项目",
        "",
        "| 名称 | 路径 | Git | 标记 | enabled |",
        "|------|------|-----|------|---------|",
    ]
    for c in candidates:
        markers = ", ".join(c.markers)
        lines.append(
            f"| {c.name} | `{c.path}` | {c.has_git} | {markers} | false |"
        )
    lines.append("")
    lines.append("## 人工复核（桌面顶层无工程标记）")
    lines.append("")
    if review_dirs:
        for d in review_dirs:
            lines.append(f"- `{d}`")
    else:
        lines.append("- （无）")
    lines.append("")
    lines.append("## 人工复核提示")
    lines.append("")
    lines.append("- 上表仅为自动发现候选；`Agent Platform` 等无根标记目录可能出现在人工复核区。")
    lines.append("- 敏感项目请将 `sensitive: true`，原始记录勿提交公共 Git。")
    lines.append("- 确认后将对应条目的 `enabled` 改为 `true` 再进入模块 1/2。")
    lines.append("")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def list_unmarked_children(
    root: Path,
    *,
    exclude_children: set[str],
    exclude_names: set[str],
    markers: tuple[str, ...],
    central: Path,
    found_paths: set[str],
) -> list[str]:
    """桌面直接子目录中：无标记、且未被注册为项目的路径，供人工复核。"""
    out: list[str] = []
    root = root.resolve()
    central = central.resolve()
    try:
        entries = sorted(root.iterdir(), key=lambda p: p.name.lower())
    except PermissionError:
        return out
    for entry in entries:
        if not entry.is_dir():
            continue
        name = entry.name
        if name in exclude_children or is_excluded_name(name, exclude_names):
            continue
        resolved = entry.resolve()
        if resolved == central or _is_under(resolved, central):
            continue
        if resolved.as_posix() in found_paths:
            continue
        if detect_markers(entry, markers):
            continue
        out.append(resolved.as_posix())
    return out


def ensure_fixtures(fixture_root: Path) -> None:
    """创建 3 个假项目 + 故意放入的 node_modules（应被排除）。"""
    projects = [
        ("夹具项目甲", [".git"]),
        ("夹具项目乙", ["package.json"]),
        ("夹具项目丙", ["pyproject.toml"]),
    ]
    fixture_root.mkdir(parents=True, exist_ok=True)
    for name, markers in projects:
        p = fixture_root / name
        p.mkdir(parents=True, exist_ok=True)
        for m in markers:
            if m == ".git":
                (p / ".git").mkdir(exist_ok=True)
                (p / ".git" / "HEAD").write_text("ref: refs/heads/main\n", encoding="utf-8")
            else:
                (p / m).write_text("# fixture\n", encoding="utf-8")
        # 每个项目内放 node_modules，确保不把其中内容扫成项目
        nm = p / "node_modules" / "fake-pkg"
        nm.mkdir(parents=True, exist_ok=True)
        (nm / "package.json").write_text('{"name":"fake"}\n', encoding="utf-8")
    # 根下也放一个应被忽略的 node_modules「假项目」
    decoy = fixture_root / "node_modules" / "should-not-appear"
    decoy.mkdir(parents=True, exist_ok=True)
    (decoy / "package.json").write_text('{"name":"decoy"}\n', encoding="utf-8")


def run_fixture_test(cfg: dict) -> int:
    fixture_root = CENTRAL / "测试夹具" / "发现根"
    ensure_fixtures(fixture_root)
    exclude_names = set(cfg.get("exclude_dir_names") or [])
    markers = tuple(cfg.get("project_markers") or PROJECT_MARKERS_DEFAULT)
    max_depth = int(cfg.get("max_depth") or 4)
    # 夹具扫描：exclude_root_children 空；central 判断放宽——root 在中央内
    cands = scan_root(
        fixture_root,
        max_depth=max_depth,
        exclude_names=exclude_names,
        exclude_children=set(),
        markers=markers,
        central=None,
        skip_central_tree=False,
    )
    names = {c.name for c in cands}
    expected = {"夹具项目甲", "夹具项目乙", "夹具项目丙"}
    ok = names == expected
    print(f"fixture_root={fixture_root}")
    print(f"found={sorted(names)}")
    print(f"expected={sorted(expected)}")
    if not ok:
        print("FAIL: fixture 发现结果不符合预期")
        return 1
    if len(cands) != 3:
        print(f"FAIL: 期望 3 条，实际 {len(cands)}")
        return 1
    # 确认未扫到 fake-pkg / should-not-appear
    bad = [c for c in cands if "node_modules" in c.path or c.name in ("fake-pkg", "should-not-appear")]
    if bad:
        print("FAIL: 进入了排除目录", bad)
        return 1
    print("PASS: fixture 验收通过（3 项目，未进入 node_modules）")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="扫描本机项目（只读发现）")
    parser.add_argument("--config", type=Path, default=DEFAULT_SYNC)
    parser.add_argument("--fixture", action="store_true", help="运行夹具验收")
    parser.add_argument(
        "--desktop-dry-run",
        action="store_true",
        help="扫描同步配置中的桌面根，写入待确认清单与 draft 注册表",
    )
    parser.add_argument(
        "--write-registry",
        action="store_true",
        help="将候选写入 项目注册表.yaml（仍全部 enabled:false）",
    )
    args = parser.parse_args()

    if not args.config.is_file():
        print(f"ERROR: 缺少同步配置 {args.config}", file=sys.stderr)
        return 2
    cfg = load_yaml(args.config)

    if args.fixture:
        return run_fixture_test(cfg)

    if not args.desktop_dry_run and not args.write_registry:
        # 默认：desktop dry-run
        args.desktop_dry_run = True

    roots = [Path(p) for p in (cfg.get("project_roots") or [])]
    if not roots:
        print("ERROR: project_roots 为空", file=sys.stderr)
        return 2

    exclude_names = set(cfg.get("exclude_dir_names") or [])
    exclude_children = set(cfg.get("exclude_root_children") or [])
    markers = tuple(cfg.get("project_markers") or PROJECT_MARKERS_DEFAULT)
    max_depth = int(cfg.get("max_depth") or 4)
    central = Path(cfg.get("central_root") or CENTRAL).resolve()

    all_cands: list[Candidate] = []
    for root in roots:
        if not root.is_dir():
            print(f"WARN: 根不存在，跳过 {root}")
            continue
        # 安全：拒绝明显整盘
        resolved = root.resolve()
        if resolved in (Path("C:/").resolve(), Path("D:/").resolve(), Path("/")):
            print(f"ERROR: 拒绝扫描整盘根 {resolved}", file=sys.stderr)
            return 3
        part = scan_root(
            resolved,
            max_depth=max_depth,
            exclude_names=exclude_names,
            exclude_children=exclude_children,
            markers=markers,
            central=central,
            skip_central_tree=True,
        )
        all_cands.extend(part)

    # 去重 by path
    by_path: dict[str, Candidate] = {}
    for c in all_cands:
        by_path[c.path] = c
    unique = sorted(by_path.values(), key=lambda x: x.name.lower())

    pending = PENDING_DIR / "候选项目清单.md"
    found_paths = {c.path for c in unique}
    review: list[str] = []
    for root in roots:
        if root.is_dir():
            review.extend(
                list_unmarked_children(
                    root.resolve(),
                    exclude_children=exclude_children,
                    exclude_names=exclude_names,
                    markers=markers,
                    central=central,
                    found_paths=found_paths,
                )
            )
    write_candidate_md(pending, unique, ", ".join(str(r) for r in roots), review)
    print(f"wrote {pending} count={len(unique)} review={len(review)}")

    if args.write_registry or args.desktop_dry_run:
        reg_text = dump_registry(unique)
        DEFAULT_REGISTRY.write_text(reg_text, encoding="utf-8")
        print(f"wrote {DEFAULT_REGISTRY} (all enabled=false)")

    for c in unique:
        print(f"- {c.name} git={c.has_git} markers={c.markers} path={c.path}")
    print("OK: dry-run 完成，未修改任何业务项目")
    return 0


if __name__ == "__main__":
    sys.exit(main())
