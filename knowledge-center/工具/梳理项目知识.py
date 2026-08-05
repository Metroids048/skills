#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""梳理各登记项目真实知识：从本机仓库证据 + USER_KNOWLEDGE_BASE 写入项目知识库（覆盖 stub）。"""

from __future__ import annotations

import json
import re
import subprocess
from datetime import datetime
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

CENTRAL = Path(__file__).resolve().parent.parent
REGISTRY = CENTRAL / "项目注册表.yaml"
UKB = CENTRAL / "USER_KNOWLEDGE_BASE.md"

# 桌面项目 ↔ 主知识库章节映射
UKB_SECTIONS = {
    "AI--main": "5.1",
    "alpha": "5.2",
    "Agent Platform": "5.4",  # 也含统一配置；平台原型另见本地 memory
    "产能评价": "5.5",
    "敖钦储能项目": "5.5",
    "合同审查": "5.6",
    "program1-main-latest": None,  # 主知识库未单列；本地为 AI 求职台
    "yinpinjianting": None,  # 与 program1 同源产品线（辅助面试）
    "海小南": None,
}


def load_enabled() -> list[dict]:
    data = yaml.safe_load(REGISTRY.read_text(encoding="utf-8")) if yaml else {}
    return [p for p in (data.get("projects") or []) if p.get("enabled")]


def read_text(path: Path, limit: int = 12000) -> str:
    if not path.is_file():
        return ""
    try:
        return path.read_text(encoding="utf-8", errors="ignore")[:limit]
    except OSError:
        return ""


def extract_ukb_section(marker: str | None) -> str:
    if not marker:
        return ""
    text = UKB.read_text(encoding="utf-8")
    # e.g. ## 5.1
    pat = rf"(## {re.escape(marker)}[^\n]*\n)(.*?)(?=\n## 5\.|\n# 6\.|\Z)"
    m = re.search(pat, text, re.S)
    return (m.group(0).strip() if m else "")[:8000]


def git_info(root: Path) -> dict:
    if not (root / ".git").exists():
        return {"has_git": False}
    out: dict = {"has_git": True}

    def g(*args: str) -> str:
        try:
            return subprocess.check_output(
                ["git", *args],
                cwd=str(root),
                text=True,
                encoding="utf-8",
                errors="replace",
                stderr=subprocess.DEVNULL,
            ).strip()
        except Exception:
            return ""

    out["branch"] = g("rev-parse", "--abbrev-ref", "HEAD")
    out["head"] = g("rev-parse", "--short", "HEAD")
    out["status_short"] = g("status", "--short")[:2000]
    out["log"] = g("log", "-5", "--oneline")
    return out


def package_scripts(root: Path) -> list[str]:
    pj = root / "package.json"
    if not pj.is_file():
        return []
    try:
        data = json.loads(pj.read_text(encoding="utf-8"))
        scripts = data.get("scripts") or {}
        return [f"`npm run {k}`" for k in list(scripts)[:20]]
    except Exception:
        return []


def top_dirs(root: Path) -> list[str]:
    skip = {
        "node_modules",
        ".git",
        "venv",
        ".venv",
        "dist",
        "build",
        "__pycache__",
        "AI原始记录",
        "项目知识库",
        ".cursor",
    }
    dirs = []
    try:
        for p in sorted(root.iterdir(), key=lambda x: x.name.lower()):
            if p.is_dir() and p.name not in skip and not p.name.startswith("."):
                dirs.append(p.name)
    except OSError:
        pass
    return dirs[:25]


def load_memory_blob(root: Path) -> str:
    chunks = []
    for rel in [
        ".github/agent/memory/project-memory.md",
        ".github/agent/memory/decisions-log.md",
        "README.md",
        "SESSION.md",
        "AGENTS.md",
    ]:
        t = read_text(root / rel, 6000 if "AGENTS" in rel else 8000)
        if t:
            chunks.append(f"### 来源 `{rel}`\n\n{t}\n")
    return "\n".join(chunks)[:20000]


def project_aliases(name: str) -> dict:
    """人工可读别名与定位（结合 UKB + 本地事实）。"""
    table = {
        "AI--main": {
            "title": "7×24 自动量化交易系统",
            "ukb": "5.1",
            "role": "Binance Demo/Testnet 自动交易研究与执行平台",
            "verify": "项目内 pytest / 既有 verify；禁止伪造成交",
            "sensitive": "交易密钥、真实订单、收益数据 — DO_NOT_PUBLISH",
        },
        "alpha": {
            "title": "WorldQuant Alpha 自动化",
            "ukb": "5.2",
            "role": "Alpha 生成、校验、描述与提交流水线",
            "verify": "tests/ + pipeline runners",
            "sensitive": "Brain cookie、提交凭证 — DO_NOT_PUBLISH",
        },
        "program1-main-latest": {
            "title": "辅助面试 / AI 求职台",
            "ukb": None,
            "role": "JD intake → 资料底座 → 模拟面试 → 实时提词 → 复盘",
            "verify": "npm run verify / test:browser-flow",
            "sensitive": "用户简历与 JD 原文 — PRIVATE",
        },
        "yinpinjianting": {
            "title": "辅助面试 / AI 求职台（同源线）",
            "ukb": None,
            "role": "与 program1-main-latest 同产品线（音频/面试辅助）",
            "verify": "npm run verify",
            "sensitive": "用户简历与会话 — PRIVATE",
        },
        "Agent Platform": {
            "title": "Agent Platform 运营/开发双平台原型",
            "ukb": "5.4（配置体系相关）",
            "role": "HTML 原型 + skills 库；verify-all + 导航旅程",
            "verify": "node prototype/scripts/verify-all.js",
            "sensitive": "平台内部运营数据 — PRIVATE",
        },
        "产能评价": {
            "title": "储量及产量规划协同（前端原型）",
            "ukb": "5.5",
            "role": "储量/产量规划 Demo；按真实 Excel 流程迭代",
            "verify": "原型走查 + 客户反馈对照",
            "sensitive": "客户名/业务数据 — DO_NOT_PUBLISH",
        },
        "敖钦储能项目": {
            "title": "储能相关客户/演示项目",
            "ukb": "5.5 相关",
            "role": "前端 demo + 项目文档",
            "verify": "文档与 demo 对照",
            "sensitive": "客户资料 — DO_NOT_PUBLISH",
        },
        "合同审查": {
            "title": "AI 合同智能审查及履约核查",
            "ukb": "5.6",
            "role": "方案/报价沟通阶段；OCR+规则+语义审查",
            "verify": "方案文档 V0.3/V0.4；样本验证优先",
            "sensitive": "合同原文/报价 — DO_NOT_PUBLISH",
        },
        "海小南": {
            "title": "海小南能力升级原型/分享包",
            "ukb": None,
            "role": "真实页面代码 + Demo 分享包",
            "verify": "原型走查",
            "sensitive": "业务页面与用户需求 — PRIVATE",
        },
    }
    return table.get(name, {"title": name, "ukb": None, "role": "待补", "verify": "待定", "sensitive": "PRIVATE"})


def write_kb(root: Path, name: str, force: bool = True) -> list[str]:
    kb = root / "项目知识库"
    kb.mkdir(parents=True, exist_ok=True)
    (kb / "会话记录").mkdir(exist_ok=True)
    meta = project_aliases(name)
    ukb = extract_ukb_section(UKB_SECTIONS.get(name) or meta.get("ukb"))
    mem = load_memory_blob(root)
    gi = git_info(root)
    dirs = top_dirs(root)
    scripts = package_scripts(root)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    path_posix = root.as_posix()

    overview = f"""# 项目总览

- 梳理时间：{now}
- 登记名：`{name}`
- 产品名：{meta['title']}
- 路径：`{path_posix}`
- 角色：{meta['role']}
- 主知识库映射：{meta.get('ukb') or '（未在 USER_KNOWLEDGE_BASE 单列，以本地事实为准）'}
- Git：{'有' if gi.get('has_git') else '无（后续可补）'} {('`'+gi.get('branch','')+'` @ `'+gi.get('head','')+'`') if gi.get('has_git') else ''}

## 一句话

{meta['role']}

## 顶层目录（摘录）

{chr(10).join(f'- `{d}`' for d in dirs) or '- （空或不可读）'}

## 主知识库摘录

{ukb or '（无对应章节；以下依赖本地 README / project-memory / AGENTS）'}

## 本地事实摘录

{mem[:9000] if mem else '（未找到 project-memory / README）'}
"""

    status = f"""# 当前状态

- 更新：{now}
- 完成判定：以本地测试/用户确认区分 `USER_REPORTED` vs `VERIFIED`
- Git 分支：{gi.get('branch') or 'N/A'}
- HEAD：{gi.get('head') or 'N/A'}

## 工作树摘要

```
{gi.get('status_short') or '(clean or no git)'}
```

## 最近提交

```
{gi.get('log') or '(no git log)'}
```

## 状态说明

本文件由中央 `梳理项目知识.py` 根据仓库证据自动生成。若与用户口头进度冲突，以用户最新纠正为准，并写入「用户反馈与纠正」。
"""

    goals = f"""# 目标与验收标准

## 目标

{meta['role']}

## 验收偏好（全局收口模式）

1. 锁定唯一目标与可观察验收标准
2. 只处理阻塞问题，不无关重构
3. 真实验证；无证据不得写 COMPLETE/VERIFIED
4. 敏感内容不公开、不进公共仓库

## 本项目建议验证

{meta['verify']}

## npm scripts（若有）

{chr(10).join(f'- {s}' for s in scripts) or '- （无 package.json scripts 或非 Node 项目）'}
"""

    arch = f"""# 架构与关键目录

## 顶层

{chr(10).join(f'- `{d}/`' for d in dirs)}

## 说明

详细模块边界以仓库内 `AGENTS.md`、`docs/`、`.github/agent/memory/` 为准。中央镜像只同步知识摘要，不是源码备份。
"""

    env = f"""# 真实命令与环境

- OS：Windows
- 建议 Python：`$env:AGENT_PYTHON` 或项目 venv
- Node：以项目 `package.json` 为准
- 中央同步：`python "C:/Users/win/Desktop/全局配置/工具/同步项目知识.py" --项目 "{name}"`

## 常用

{chr(10).join(f'- {s}' for s in scripts) or '- 见项目 README / AGENTS.md'}

## Git

- has_git: {gi.get('has_git')}
- branch: {gi.get('branch')}
- head: {gi.get('head')}
"""

    decisions = f"""# 决策记录

## 来自中央梳理（{now}）

- 本项目已纳入全局知识管理中心登记根（enabled=true）
- 项目事实源：`项目知识库/`；中央仅镜像，冲突不静默覆盖

## 本地决策日志摘录

详见仓库 `.github/agent/memory/decisions-log.md`（若存在）。下方保留自动摘录开头：

{(read_text(root / '.github/agent/memory/decisions-log.md', 4000) or '（无 decisions-log）')}
"""

    errors = f"""# 错误与根因

## 已知跨项目模式（参考）

- Agent 声称完成但无独立测试证据 → 标 `USER_REPORTED`，不得写成 VERIFIED
- Windows 路径 `\\U`、编码、RTK 包 cmdlet → 先分 L1/L2/L3
- 「最大权限」≠ 可删配置/破坏性清理

## 本项目

请在后续会话中追加真实错误；主知识库相关问题见下方摘录：

{(ukb[:2500] if ukb else '（暂无 UKB 错误清单；以本地 postmortem / task-history 为准）')}
"""

    fixes = f"""# 已验证解决方案

- 中央安装器：幂等写入知识区与托管 AGENTS/CLAUDE 区块
- 同步：项目事实 → 镜像可覆盖；中央偏好 → 项目冲突则待确认
- 验证命令：{meta['verify']}

（具体修复条目随会话胶囊追加）
"""

    feedback = f"""# 用户反馈与纠正

- 2026-07-28：用户确认桌面清单项目均为真实项目；无 git 的后续会补
- 2026-07-28：用户要求全局审查查缺补漏 — 知识库不得停留在 stub

（后续用户纠正追加于此）
"""

    open_items = f"""# 开放事项

## 来自 USER_KNOWLEDGE_BASE / 本地

- 核对本项目与主知识库状态标签（OPEN / USER_REPORTED / VERIFIED）
- 补全真实验收证据链接（测试输出、commit）
- 敏感边界：{meta['sensitive']}

## Git

{'无 git — 建议后续 `git init` 并纳入版本管理' if not gi.get('has_git') else '保持主分支可构建可验证'}
"""

    content = f"""# 内容素材

## PUBLIC_SAFE 候选方向

从主知识库/项目经验提取时必须脱敏。本项目敏感级：{meta['sensitive']}

## 禁止

- 客户名、合同原文、交易密钥、收益承诺、未验证成功案例

## 来源

- 中央 `内容素材中心/视频选题总库.md`
- 主知识库对应章节 PUBLIC_SAFE 条目
"""

    boundary = f"""# 敏感信息边界

- 级别：{meta['sensitive']}
- 禁止写入：`.env`、API Key、Cookie、私钥、钱包、未脱敏客户/合同/交易数据
- 原始聊天默认不提交公共 Git（见 `.gitignore` 托管块）
- 公开内容仅 `PUBLIC_SAFE` 且已脱敏
"""

    files = {
        "项目总览.md": overview,
        "当前状态.md": status,
        "目标与验收标准.md": goals,
        "架构与关键目录.md": arch,
        "真实命令与环境.md": env,
        "决策记录.md": decisions,
        "错误与根因.md": errors,
        "已验证解决方案.md": fixes,
        "用户反馈与纠正.md": feedback,
        "开放事项.md": open_items,
        "内容素材.md": content,
        "敏感信息边界.md": boundary,
    }

    written = []
    for fname, body in files.items():
        path = kb / fname
        if path.exists() and not force:
            old = path.read_text(encoding="utf-8", errors="ignore")
            if "由全局知识管理中心安装" not in old and "梳理时间" not in old and len(old) > 200:
                written.append(f"skip keep {fname}")
                continue
        path.write_text(body, encoding="utf-8")
        written.append(f"write {fname} ({len(body)} chars)")
    return written


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser()
    ap.add_argument("--项目")
    ap.add_argument("--all", action="store_true")
    args = ap.parse_args()
    projects = load_enabled()
    if args.项目:
        projects = [p for p in projects if p.get("name") == args.项目 or p.get("id") == args.项目]
    elif not args.all:
        args.all = True

    report = []
    for p in projects:
        name = str(p["name"])
        root = Path(p["path"])
        print(f"=== {name} ===")
        if not root.is_dir():
            print("MISSING ROOT")
            report.append({"name": name, "ok": False})
            continue
        acts = write_kb(root, name, force=True)
        for a in acts:
            print(a)
        report.append({"name": name, "ok": True, "files": len(acts)})

    out = CENTRAL / "日志" / "项目知识梳理报告.json"
    out.write_text(
        json.dumps({"at": datetime.now().isoformat(timespec="seconds"), "projects": report}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"OK wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
