#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""一键端到端验收（模块 9）。"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
PY = sys.executable
REPORT = CENTRAL / "日志" / "端到端验收报告.md"


def run(args: list[str], check: bool = True) -> subprocess.CompletedProcess:
    print("+", " ".join(args))
    r = subprocess.run(args, cwd=str(CENTRAL), capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.stdout:
        print(r.stdout[-2000:])
    if r.stderr:
        print(r.stderr[-1000:], file=sys.stderr)
    if check and r.returncode != 0:
        raise RuntimeError(f"cmd failed {args} code={r.returncode}")
    return r


def main() -> int:
    results = []
    try:
        run([PY, str(CENTRAL / "工具" / "校验知识库.py")])
        results.append(("模块1 知识校验", "PASS"))

        run([PY, str(CENTRAL / "工具" / "安装项目记忆.py"), "--self-test"])
        results.append(("模块2 安装器自测", "PASS"))

        run([PY, str(CENTRAL / "工具" / "检查隐私.py"), "--self-test"])
        results.append(("模块3/8 隐私", "PASS"))

        run([PY, str(CENTRAL / "工具" / "检查权限策略.py")])
        results.append(("模块8 权限", "PASS"))

        # 模块4：对第一个启用项目 simulate（需已安装知识库）；若未装则装到夹具
        fix = CENTRAL / "测试夹具" / "e2e项目"
        if fix.exists():
            shutil.rmtree(fix)
        fix.mkdir(parents=True)
        run([PY, str(CENTRAL / "工具" / "安装项目记忆.py"), "--path", str(fix), "--name", "e2e项目"])
        # 临时写入注册表？ 开始AI任务 需要登记 — 直接改用 path 扩展或临时 patch
        # 简化：把 e2e 加入扫描：修改开始AI任务支持 --path
        # 这里用导入+同步等不依赖登记的测试，CLI 用 registry 第一项 dry simulate 可能改真实项目 AI原始记录 — 可接受（只写知识区）
        import yaml

        reg = yaml.safe_load((CENTRAL / "项目注册表.yaml").read_text(encoding="utf-8"))
        enabled = [p for p in reg["projects"] if p.get("enabled")]
        assert enabled
        # 确保已安装
        run([PY, str(CENTRAL / "工具" / "安装项目记忆.py"), "--项目", enabled[0]["name"]])
        pname = enabled[0]["name"]
        run([PY, str(CENTRAL / "工具" / "开始AI任务.py"), "--项目", pname, "--任务", "e2e模拟成功", "--simulate", "success"])
        run([PY, str(CENTRAL / "工具" / "开始AI任务.py"), "--项目", pname, "--任务", "e2e模拟失败", "--simulate", "fail"])
        results.append(("模块4 CLI模拟", "PASS"))

        run([PY, str(CENTRAL / "工具" / "导入聊天记录.py"), "--self-test"])
        results.append(("模块5 导入", "PASS"))

        run([PY, str(CENTRAL / "工具" / "同步项目知识.py"), "--self-test"])
        results.append(("模块6 同步", "PASS"))

        run([PY, str(CENTRAL / "工具" / "提取视频内容.py"), "--self-test"])
        run([PY, str(CENTRAL / "工具" / "汇总跨项目经验.py")])
        run([PY, str(CENTRAL / "工具" / "汇总跨项目经验.py"), "--check-only"])
        run([PY, str(CENTRAL / "工具" / "生成每周复盘.py"), "--weekly", "--monthly"])
        results.append(("模块7 复盘/视频/跨项目经验", "PASS"))

        # 安装全部启用项目（真实知识区，不改业务源码）
        run([PY, str(CENTRAL / "工具" / "安装项目记忆.py"), "--all-enabled"])
        run([PY, str(CENTRAL / "工具" / "同步项目知识.py"), "--all"])
        results.append(("全项目安装+同步", "PASS"))

        status = "COMPLETE"
    except Exception as e:
        results.append(("ERROR", str(e)))
        status = "BLOCKED"
        print(f"FAIL: {e}", file=sys.stderr)

    lines = [
        f"# 端到端验收报告",
        "",
        f"- 时间：{datetime.now().isoformat(timespec='seconds')}",
        f"- 状态：{status}",
        "",
        "## 结果",
        "",
    ]
    for name, st in results:
        lines.append(f"- {name}: {st}")
    lines += [
        "",
        "## 已知限制",
        "",
        "- GUI 无法保证完整聊天截获；需导出后导入。",
        "- Cursor CLI 真实调用依赖本机 `cursor agent`；验收默认用 --simulate。",
        "- 权限 YAML 为策略文档，需手工应用到 Cursor CLI 权限配置。",
        "",
        "## 回滚",
        "",
        "- 中央：`git revert` / `git reset`",
        "- 项目：`备份/项目安装/` 中的 AGENTS/CLAUDE 备份；或运行安装器 `--uninstall`",
        "",
    ]
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print(REPORT)
    # also json
    (CENTRAL / "日志" / "端到端验收.json").write_text(
        json.dumps({"status": status, "results": results}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return 0 if status == "COMPLETE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
