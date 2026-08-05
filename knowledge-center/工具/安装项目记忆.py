#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""项目端记忆安装器（模块 2+3）：只写知识区与受控 Cursor 配置，不改业务源码。"""

from __future__ import annotations

import argparse
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
BACKUP_ROOT = CENTRAL / "备份" / "项目安装"

MANAGED_START = "<!-- AI-KNOWLEDGE-MANAGED-START -->"
MANAGED_END = "<!-- AI-KNOWLEDGE-MANAGED-END -->"
GITIGNORE_START = "# AI-KNOWLEDGE-MANAGED-START"
GITIGNORE_END = "# AI-KNOWLEDGE-MANAGED-END"

KB_FILES = [
    "项目总览.md",
    "当前状态.md",
    "目标与验收标准.md",
    "架构与关键目录.md",
    "真实命令与环境.md",
    "决策记录.md",
    "错误与根因.md",
    "已验证解决方案.md",
    "用户反馈与纠正.md",
    "开放事项.md",
    "内容素材.md",
    "敏感信息边界.md",
]

RULE_MDC = """---
description: 读取项目长期知识，并在有意义任务完成后生成会话记录和同步项目知识
alwaysApply: true
---

# 项目知识

开始非简单任务前读取：

- 项目知识库/项目总览.md
- 项目知识库/当前状态.md
- 项目知识库/目标与验收标准.md
- 项目知识库/开放事项.md

按相关性读取决策、错误与根因、已验证解决方案、用户反馈。

# 行为

- 默认中文回复；代码和命令保持原语言。
- 使用收口模式：单目标、可验收、真实验证、完成后停止。
- 不无关重构；不伪造验证；不读取秘密。
- 不自动发布、部署、交易、付款。
- 不直接覆盖中央主知识库。

# 归档

有意义任务结束后生成中文会话记录，更新当前状态，提取 PUBLIC_SAFE 素材，运行隐私检查并同步中央。
"""

COMMANDS = {
    "开始任务记录.md": """现在开始记录本次任务。

1. 读取项目知识库中的项目总览、当前状态、目标与验收标准和开放事项。
2. 生成唯一任务 ID。
3. 保存当前时间、用户目标、Git 状态、验收标准、非目标、敏感级别到 AI原始记录/ 或 项目知识库/会话记录/。
4. 不修改业务源码。
5. 输出任务记录路径后继续用户任务。
""",
    "结束并归档.md": """现在结束业务开发，执行会话归档。

结合可见对话、Git diff、修改文件、命令测试、用户纠正，生成会话胶囊与验证报告。
无证据不得写 COMPLETE；不记录密钥与私有思维过程；冲突只生成待确认补丁。
完成后运行：python 中央/工具/同步项目知识.py --项目 <本项目>
""",
    "同步项目知识.md": """运行项目知识同步（先 dry-run 再执行）。

python "C:/Users/win/Desktop/全局配置/工具/同步项目知识.py" --项目 "<项目名>" --dry-run
确认无秘密与业务源码后去掉 --dry-run。
""",
    "生成视频素材.md": """从本项目知识库与最近会话提取 PUBLIC_SAFE 视频素材，写入 项目知识库/内容素材.md，并同步中央内容素材中心。
禁止泄露客户/密钥/交易秘密；禁止未验证成功案例。
""",
    "项目阶段复盘.md": """对本项目当前阶段做复盘：目标、完成证据、错误根因、用户纠正、开放事项、下一步最小动作。写入会话记录并同步中央。
""",
    "Token耗尽前收口.md": """停止新增分析，立即安全收口：保存进度、最小验证、WIP 记录、会话胶囊、同步知识。不开始新任务。
""",
}

HOOKS_JSON = {
    "version": 1,
    "hooks": {
        "preToolUse": [
            {
                "matcher": "Read|Write|Shell",
                "command": 'python "C:/Users/win/Desktop/全局配置/工具/检查隐私.py" --hook-stdin',
                "note": "拦截密钥路径与危险命令；不采集完整聊天",
            }
        ]
    },
}

AGENTS_BLOCK = f"""
{MANAGED_START}

## 共享用户记忆与项目知识

开始涉及本项目的非简单任务前，读取：

- `项目知识库/项目总览.md`
- `项目知识库/当前状态.md`
- `项目知识库/目标与验收标准.md`
- `项目知识库/开放事项.md`

默认收口模式；任务结束生成会话记录并调用中央同步；不得直接重写中央主知识库。

{MANAGED_END}
""".strip()

CLAUDE_BLOCK = f"""
{MANAGED_START}

@AGENTS.md
@项目知识库/项目总览.md
@项目知识库/当前状态.md
@项目知识库/目标与验收标准.md

复杂任务完成后执行会话归档与项目知识同步。不得将临时任务、猜测、秘密和未验证完成写入长期记忆。

{MANAGED_END}
""".strip()

GITIGNORE_BLOCK = f"""
{GITIGNORE_START}
AI原始记录/
项目知识库/会话记录/
**/.env
**/*.pem
**/*.key
{GITIGNORE_END}
""".strip()


def load_enabled() -> list[dict]:
    data = yaml.safe_load(REGISTRY.read_text(encoding="utf-8")) if yaml else {}
    return [p for p in (data.get("projects") or []) if p.get("enabled")]


def write_new(path: Path, content: str, dry_run: bool, actions: list[str]) -> None:
    if path.exists():
        actions.append(f"skip exists {path}")
        return
    actions.append(f"create {path}")
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")


def upsert_managed_block(path: Path, block: str, dry_run: bool, actions: list[str], backup_dir: Path) -> None:
    if path.exists():
        text = path.read_text(encoding="utf-8")
        if MANAGED_START in text and MANAGED_END in text:
            actions.append(f"skip managed block {path}")
            return
        actions.append(f"append managed block {path}")
        if not dry_run:
            backup_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, backup_dir / path.name)
            path.write_text(text.rstrip() + "\n\n" + block + "\n", encoding="utf-8")
    else:
        actions.append(f"create {path}")
        if not dry_run:
            path.write_text(block + "\n", encoding="utf-8")


def upsert_gitignore(path: Path, dry_run: bool, actions: list[str], backup_dir: Path) -> None:
    if path.exists():
        text = path.read_text(encoding="utf-8")
        if GITIGNORE_START in text:
            actions.append(f"skip gitignore managed {path}")
            return
        actions.append(f"append gitignore managed {path}")
        if not dry_run:
            backup_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, backup_dir / ".gitignore")
            path.write_text(text.rstrip() + "\n\n" + GITIGNORE_BLOCK + "\n", encoding="utf-8")
    else:
        actions.append(f"create {path}")
        if not dry_run:
            path.write_text(GITIGNORE_BLOCK + "\n", encoding="utf-8")


def sync_config_yaml(name: str, root: Path, sensitive: bool) -> str:
    return (
        f'版本: 1\n'
        f'项目编号: "{name}"\n'
        f'项目名称: "{name}"\n'
        f'项目根目录: "{root.as_posix()}"\n'
        f'中央目录: "{CENTRAL.as_posix()}"\n'
        f'中央镜像目录: "{(CENTRAL / "项目镜像" / name).as_posix()}"\n'
        f'敏感级别: "{"SENSITIVE" if sensitive else "PRIVATE"}"\n'
        f"同步:\n"
        f"  启用: true\n"
        f"  项目到中央: true\n"
        f"  中央到项目: true\n"
        f"  原始聊天: false\n"
        f"  会话摘要: true\n"
        f"Git:\n"
        f"  提交项目知识库: false\n"
        f"  提交Cursor规则: true\n"
        f"  提交原始记录: false\n"
    )


def install_one(project: dict, dry_run: bool) -> list[str]:
    root = Path(project["path"])
    name = str(project.get("name") or project.get("id"))
    sensitive = bool(project.get("sensitive"))
    actions: list[str] = []
    if not root.is_dir():
        actions.append(f"ERROR missing project root {root}")
        return actions

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = BACKUP_ROOT / f"{name}_{ts}"
    kb = root / "项目知识库"
    raw = root / "AI原始记录"
    actions.append(f"mkdir {kb}")
    actions.append(f"mkdir {raw}")
    if not dry_run:
        kb.mkdir(parents=True, exist_ok=True)
        raw.mkdir(parents=True, exist_ok=True)
        (kb / "会话记录").mkdir(exist_ok=True)

    for fname in KB_FILES:
        body = f"# {fname.replace('.md','')}\n\n- 项目：{name}\n- 路径：`{root.as_posix()}`\n- 由全局知识管理中心安装（不覆盖已有内容）\n"
        if fname == "敏感信息边界.md":
            body += "\n禁止写入密钥、Cookie、钱包、未脱敏客户资料。\n"
        write_new(kb / fname, body, dry_run, actions)

    write_new(kb / "同步配置.yaml", sync_config_yaml(name, root, sensitive), dry_run, actions)

    write_new(root / ".cursor" / "rules" / "全局知识与会话归档.mdc", RULE_MDC, dry_run, actions)
    for cname, cbody in COMMANDS.items():
        write_new(root / ".cursor" / "commands" / cname, cbody, dry_run, actions)

    hooks_path = root / ".cursor" / "hooks.json"
    if hooks_path.exists():
        actions.append(f"skip exists {hooks_path}")
    else:
        actions.append(f"create {hooks_path}")
        if not dry_run:
            hooks_path.parent.mkdir(parents=True, exist_ok=True)
            hooks_path.write_text(json.dumps(HOOKS_JSON, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    upsert_managed_block(root / "AGENTS.md", AGENTS_BLOCK, dry_run, actions, backup_dir)
    upsert_managed_block(root / "CLAUDE.md", CLAUDE_BLOCK, dry_run, actions, backup_dir)
    upsert_gitignore(root / ".gitignore", dry_run, actions, backup_dir)
    return actions


def uninstall_one(project: dict, dry_run: bool) -> list[str]:
    """仅移除托管区块与本安装器创建的标准空模板文件；不删用户已编辑内容（保守：只去 managed block）。"""
    root = Path(project["path"])
    actions: list[str] = []
    for fname in ("AGENTS.md", "CLAUDE.md"):
        path = root / fname
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        if MANAGED_START not in text:
            continue
        start = text.find(MANAGED_START)
        end = text.find(MANAGED_END)
        if start >= 0 and end > start:
            new = (text[:start] + text[end + len(MANAGED_END) :]).strip() + "\n"
            actions.append(f"remove managed block {path}")
            if not dry_run:
                path.write_text(new, encoding="utf-8")
    return actions


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--all-enabled", action="store_true")
    ap.add_argument("--项目", dest="project_name")
    ap.add_argument("--path", type=Path, help="直接指定项目根（夹具/单项目）")
    ap.add_argument("--name", default="fixture")
    ap.add_argument("--uninstall", action="store_true")
    ap.add_argument("--self-test", action="store_true", help="在测试夹具上验收安装/幂等/卸载")
    args = ap.parse_args()

    if args.self_test:
        return run_self_test()

    projects: list[dict] = []
    if args.path:
        projects = [{"name": args.name, "path": str(args.path), "enabled": True, "sensitive": False}]
    elif args.all_enabled:
        projects = load_enabled()
    elif args.project_name:
        projects = [p for p in load_enabled() if p.get("name") == args.project_name or p.get("id") == args.project_name]
    else:
        print("指定 --all-enabled 或 --项目 或 --path", file=sys.stderr)
        return 2

    all_actions: list[str] = []
    for p in projects:
        acts = uninstall_one(p, args.dry_run) if args.uninstall else install_one(p, args.dry_run)
        all_actions.extend(acts)
        for a in acts:
            print(a)
    mode = "dry-run" if args.dry_run else "apply"
    print(f"OK: {mode} projects={len(projects)} actions={len(all_actions)}")
    return 0


def run_self_test() -> int:
    base = CENTRAL / "测试夹具" / "安装验收"
    if base.exists():
        shutil.rmtree(base)
    cases = {
        "空项目": base / "空项目",
        "已有AGENTS": base / "已有AGENTS",
        "已有CLAUDE": base / "已有CLAUDE",
    }
    cases["空项目"].mkdir(parents=True)
    cases["已有AGENTS"].mkdir(parents=True)
    (cases["已有AGENTS"] / "AGENTS.md").write_text("# Existing\n\nkeep me\n", encoding="utf-8")
    cases["已有CLAUDE"].mkdir(parents=True)
    (cases["已有CLAUDE"] / "CLAUDE.md").write_text("# Claude existing\n", encoding="utf-8")

    for name, path in cases.items():
        p = {"name": name, "path": str(path), "sensitive": name == "已有CLAUDE"}
        a1 = install_one(p, dry_run=False)
        assert any("项目知识库" in x or "create" in x for x in a1), a1
        # 幂等
        a2 = install_one(p, dry_run=False)
        assert all(x.startswith("skip") or x.startswith("mkdir") for x in a2), a2
        assert (path / "项目知识库" / "项目总览.md").is_file()
        assert (path / ".cursor" / "rules" / "全局知识与会话归档.mdc").is_file()
        assert "AI-KNOWLEDGE-MANAGED-START" in (path / "AGENTS.md").read_text(encoding="utf-8")
        # 业务源码零改动：夹具无业务文件
        print(f"PASS install+idempotent {name}")

    # 卸载托管块
    p = {"name": "已有AGENTS", "path": str(cases["已有AGENTS"])}
    uninstall_one(p, dry_run=False)
    text = (cases["已有AGENTS"] / "AGENTS.md").read_text(encoding="utf-8")
    assert "AI-KNOWLEDGE-MANAGED-START" not in text
    assert "keep me" in text
    print("PASS uninstall restores non-managed content")
    print("OK: 模块2自测通过")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
