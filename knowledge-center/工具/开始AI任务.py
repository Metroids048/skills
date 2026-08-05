#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Cursor CLI 任务包装器（模块 4）。支持 --simulate 验收，不保存 CoT。"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from 检查隐私 import is_secret_path, redact  # noqa: E402


def stamp() -> tuple[str, str]:
    now = datetime.now()
    return now.strftime("%Y-%m-%d"), now.strftime("%H%M%S")


def resolve_project(name: str) -> Path | None:
    import yaml

    reg = yaml.safe_load((CENTRAL / "项目注册表.yaml").read_text(encoding="utf-8"))
    for p in reg.get("projects") or []:
        if p.get("enabled") and (p.get("name") == name or p.get("id") == name):
            return Path(p["path"])
    return None


def write_capsule(path: Path, meta: dict) -> None:
    path.write_text(
        "\n".join(
            [
                f"# 会话记录",
                "",
                f"- 任务ID：{meta['task_id']}",
                f"- 项目：{meta['project']}",
                f"- 状态：{meta['status']}",
                f"- 开始：{meta['started']}",
                f"- 结束：{meta['ended']}",
                f"- 退出码：{meta['exit_code']}",
                f"- 耗时秒：{meta['duration_sec']}",
                "",
                "## 用户目标",
                "",
                meta["prompt"],
                "",
                "## 验证",
                "",
                meta.get("verification", "未运行真实测试") ,
                "",
                "## 说明",
                "",
                "不包含模型私有思维过程；密钥已脱敏。",
                "",
            ]
        ),
        encoding="utf-8",
    )


def collect_git(project: Path) -> tuple[str, str]:
    def run(args: list[str]) -> str:
        try:
            r = subprocess.run(args, cwd=str(project), capture_output=True, text=True, encoding="utf-8", errors="replace")
            return r.stdout
        except Exception as e:
            return f"(git unavailable: {e})"

    if not (project / ".git").exists():
        return "NO_GIT", ""
    status = run(["git", "status", "--short"])
    diff = run(["git", "diff"])
    return status, diff


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--项目", required=True)
    ap.add_argument("--任务", required=True, help="用户 Prompt")
    ap.add_argument("--model", default="")
    ap.add_argument("--simulate", choices=["success", "fail", "interrupt"], help="不调用真实 CLI，用于验收")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    project = resolve_project(args.项目)
    if project is None or not project.is_dir():
        print(f"ERROR: 项目未登记或路径不存在: {args.项目}", file=sys.stderr)
        return 2

    date_s, time_s = stamp()
    task_id = f"{date_s}_{time_s}"
    tool = "CursorCLI"
    out_dir = project / "AI原始记录"
    out_dir.mkdir(parents=True, exist_ok=True)
    kb_sess = project / "项目知识库" / "会话记录"
    kb_sess.mkdir(parents=True, exist_ok=True)

    prompt = args.任务
    if any(is_secret_path(p) for p in prompt.split()):
        print("ERROR: prompt 含秘密路径", file=sys.stderr)
        return 2
    prompt_safe = redact(prompt)

    user_file = out_dir / f"{task_id}_{tool}_{args.项目}_用户输入.md"
    events_file = out_dir / f"{task_id}_{tool}_{args.项目}_原始事件.jsonl"
    ai_file = out_dir / f"{task_id}_{tool}_{args.项目}_AI输出.md"
    patch_file = out_dir / f"{task_id}_{args.项目}_代码差异.patch"
    verify_file = out_dir / f"{task_id}_{args.项目}_验证报告.md"
    capsule_file = kb_sess / f"{task_id}_{tool}_{args.项目}_会话记录.md"

    user_file.write_text(f"# 用户输入\n\n{prompt_safe}\n", encoding="utf-8")
    started = datetime.now().isoformat(timespec="seconds")
    t0 = time.time()
    exit_code = 0
    status = "COMPLETE"
    ai_text = ""

    if args.simulate:
        events = []
        if args.simulate == "success":
            events = [
                {"type": "system", "message": "simulate start"},
                {"type": "assistant", "message": "模拟成功完成任务"},
                {"type": "result", "exit": 0},
            ]
            ai_text = "模拟成功完成任务\n"
            exit_code = 0
            status = "COMPLETE"
        elif args.simulate == "fail":
            events = [{"type": "error", "message": "simulated failure"}, {"type": "result", "exit": 1}]
            ai_text = "模拟失败\n"
            exit_code = 1
            status = "BLOCKED"
        else:
            events = [{"type": "assistant", "message": "interrupted"}, {"type": "result", "exit": 130}]
            ai_text = "模拟中断\n"
            exit_code = 130
            status = "PARTIAL"
        with events_file.open("w", encoding="utf-8") as f:
            for e in events:
                f.write(json.dumps(e, ensure_ascii=False) + "\n")
    else:
        # 尝试 cursor agent；找不到则 PARTIAL
        cmd = ["cursor", "agent", "--print", "--output-format", "stream-json", prompt_safe]
        try:
            with events_file.open("w", encoding="utf-8") as ef:
                proc = subprocess.Popen(
                    cmd,
                    cwd=str(project),
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    encoding="utf-8",
                    errors="replace",
                )
                assert proc.stdout is not None
                chunks = []
                for line in proc.stdout:
                    ef.write(line if line.endswith("\n") else line + "\n")
                    chunks.append(line)
                exit_code = proc.wait()
            ai_text = redact("".join(chunks)[-20000:])
            status = "COMPLETE" if exit_code == 0 else "BLOCKED"
        except FileNotFoundError:
            events_file.write_text(json.dumps({"error": "cursor CLI not found"}, ensure_ascii=False) + "\n", encoding="utf-8")
            ai_text = "cursor CLI 不可用"
            exit_code = 127
            status = "BLOCKED"
        except KeyboardInterrupt:
            ai_text = "用户中断"
            exit_code = 130
            status = "PARTIAL"

    ai_file.write_text(f"# AI输出\n\n{redact(ai_text)}\n", encoding="utf-8")
    status_txt, diff = collect_git(project)
    patch_file.write_text(diff or status_txt or "(no diff)\n", encoding="utf-8")
    verify_file.write_text(
        f"# 验证报告\n\n- exit_code: {exit_code}\n- status: {status}\n- git_status:\n\n```\n{status_txt}\n```\n",
        encoding="utf-8",
    )
    ended = datetime.now().isoformat(timespec="seconds")
    write_capsule(
        capsule_file,
        {
            "task_id": task_id,
            "project": args.项目,
            "status": status,
            "started": started,
            "ended": ended,
            "exit_code": exit_code,
            "duration_sec": round(time.time() - t0, 2),
            "prompt": prompt_safe,
            "verification": f"exit={exit_code}; simulate={args.simulate or 'live'}",
        },
    )
    print(json.dumps({"task_id": task_id, "status": status, "exit_code": exit_code, "capsule": str(capsule_file)}, ensure_ascii=False))
    return 0 if status != "BLOCKED" or args.simulate == "fail" else exit_code


if __name__ == "__main__":
    raise SystemExit(main())
