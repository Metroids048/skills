#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""统一知识中心 CLI（Prompt A 要求的采集/校验/索引入口）。"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
PY = sys.executable
TOOLS = CENTRAL / "工具"


def run_tool(script: str, args: list[str]) -> int:
    cmd = [PY, str(TOOLS / script), *args]
    print("+", " ".join(cmd))
    return subprocess.call(cmd, cwd=str(CENTRAL))


def cmd_capsule(project: str, goal: str) -> int:
    return run_tool("结束并归档.py", ["start", "--项目", project, "--目标", goal])


def main() -> int:
    ap = argparse.ArgumentParser(prog="知识中心", description="本机 AI 全局知识管理中心统一 CLI")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("扫描", help="发现项目")
    p.add_argument("--fixture", action="store_true")
    p.add_argument("--desktop", action="store_true")

    p = sub.add_parser("安装", help="安装项目记忆")
    p.add_argument("--all", action="store_true")
    p.add_argument("--项目")
    p.add_argument("--self-test", action="store_true")

    p = sub.add_parser("梳理", help="汇总项目真实知识")
    p.add_argument("--all", action="store_true")
    p.add_argument("--项目")

    p = sub.add_parser("同步", help="双向同步")
    p.add_argument("--all", action="store_true")
    p.add_argument("--项目")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--self-test", action="store_true")

    p = sub.add_parser("任务", help="CLI 任务包装")
    p.add_argument("--项目", required=True)
    p.add_argument("--任务", required=True)
    p.add_argument("--simulate", choices=["success", "fail", "interrupt", ""])

    p = sub.add_parser("导入", help="导入聊天 / Cursor JSONL")
    p.add_argument("--file")
    p.add_argument("--dir")
    p.add_argument("--项目", default="global")
    p.add_argument("--tool", default="")
    p.add_argument("--since", default="", help="YYYY-MM-DD")
    p.add_argument("--include-subagents", action="store_true")
    p.add_argument("--infer-project", action="store_true")
    p.add_argument("--transcripts-only", action="store_true")
    p.add_argument("--self-test", action="store_true")

    p = sub.add_parser("胶囊", help="开始 GUI 任务记录")
    p.add_argument("--项目", required=True)
    p.add_argument("--目标", default="")

    p = sub.add_parser("归档", help="结束 GUI 归档")
    p.add_argument("--项目", required=True)

    sub.add_parser("校验", help="知识库 schema/去重")
    sub.add_parser("冲突", help="冲突与重复检查")
    sub.add_parser("隐私", help="隐私自测")
    sub.add_parser("权限", help="权限策略检查")
    sub.add_parser("复盘", help="周/月复盘")
    sub.add_parser("汇总经验", help="汇总跨项目经验（去占位）")
    sub.add_parser("视频", help="提取视频选题")
    sub.add_parser("拆分主库", help="UKB 拆分到长期记忆")
    sub.add_parser("审查", help="全局内容审查")
    sub.add_parser("验收", help="最终全量验收")

    args = ap.parse_args()
    c = args.cmd

    if c == "扫描":
        a = ["--fixture"] if args.fixture else ["--desktop-dry-run"]
        return run_tool("扫描本机项目.py", a)
    if c == "安装":
        if args.self_test:
            return run_tool("安装项目记忆.py", ["--self-test"])
        if args.all:
            return run_tool("安装项目记忆.py", ["--all-enabled"])
        return run_tool("安装项目记忆.py", ["--项目", args.项目])
    if c == "梳理":
        return run_tool("梳理项目知识.py", ["--all"] if args.all or not args.项目 else ["--项目", args.项目])
    if c == "同步":
        if args.self_test:
            return run_tool("同步项目知识.py", ["--self-test"])
        a = ["--dry-run"] if args.dry_run else []
        if args.all or not args.项目:
            a = ["--all", *a]
        else:
            a = ["--项目", args.项目, *a]
        return run_tool("同步项目知识.py", a)
    if c == "任务":
        a = ["--项目", args.项目, "--任务", args.任务]
        if args.simulate:
            a += ["--simulate", args.simulate]
        return run_tool("开始AI任务.py", a)
    if c == "导入":
        if args.self_test:
            return run_tool("导入聊天记录.py", ["--self-test"])
        a: list[str] = []
        if args.dir:
            a += ["--dir", args.dir]
        elif args.file:
            a += ["--file", args.file]
        else:
            print("导入需要 --file 或 --dir 或 --self-test", file=sys.stderr)
            return 2
        if args.项目:
            a += ["--项目", args.项目]
        if args.tool:
            a += ["--tool", args.tool]
        if args.since:
            a += ["--since", args.since]
        if args.include_subagents:
            a.append("--include-subagents")
        if args.infer_project:
            a.append("--infer-project")
        if args.transcripts_only:
            a.append("--transcripts-only")
        return run_tool("导入聊天记录.py", a)
    if c == "胶囊":
        return run_tool("结束并归档.py", ["start", "--项目", args.项目, "--目标", args.目标 or "任务"])
    if c == "归档":
        return run_tool("结束并归档.py", ["end", "--项目", args.项目])
    if c == "校验":
        return run_tool("校验知识库.py", [])
    if c == "冲突":
        return run_tool("检查冲突与重复.py", [])
    if c == "隐私":
        return run_tool("检查隐私.py", ["--self-test"])
    if c == "权限":
        return run_tool("检查权限策略.py", [])
    if c == "复盘":
        return run_tool("生成每周复盘.py", ["--weekly", "--monthly"])
    if c == "汇总经验":
        return run_tool("汇总跨项目经验.py", [])
    if c == "视频":
        return run_tool("提取视频内容.py", [])
    if c == "拆分主库":
        return run_tool("同步用户主知识拆分.py", [])
    if c == "审查":
        return run_tool("全局审查.py", [])
    if c == "验收":
        return run_tool("最终验收.py", [])
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
