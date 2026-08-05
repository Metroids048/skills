#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""幂等初始化 AI 全局知识管理中心目录与缺省配置。不覆盖已有知识库/设计稿。"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent

DIRS = [
    "用户长期记忆",
    "项目镜像",
    "全局会话归档",
    "跨项目经验",
    "内容素材中心",
    "决策与复盘/每周复盘",
    "决策与复盘/每月复盘",
    "原始记录/Cursor_CLI",
    "原始记录/Cursor_聊天导出",
    "原始记录/Codex",
    "原始记录/Claude_Code",
    "原始记录/其他AI工具",
    "待整理输入",
    "待确认更新",
    "冲突与过期记录",
    "备份",
    "配置/权限模板",
    "配置/项目模板",
    "配置/Cursor规则模板",
    "工具",
    "测试夹具/发现根",
    "日志",
]

SYNC_CONFIG = """\
# 全局知识管理中心 — 同步与发现配置（模块 0）
version: 1
status: draft
central_root: "C:/Users/win/Desktop/全局配置"
project_roots:
  - "C:/Users/win/Desktop"
exclude_root_children:
  - "全局配置"
  - "记录"
exclude_dir_names:
  - "node_modules"
  - ".git"
  - "venv"
  - ".venv"
  - "__pycache__"
  - "dist"
  - "build"
  - ".next"
  - "coverage"
  - ".turbo"
  - ".cache"
  - "_cache"
  - "vendor"
  - "target"
  - ".pytest_cache"
  - ".mypy_cache"
max_depth: 1
project_markers:
  - ".git"
  - "package.json"
  - "pyproject.toml"
  - "Cargo.toml"
  - "go.mod"
notes: |
  仅扫描 project_roots。enabled 项目以 项目注册表.yaml 为准。
  发现脚本不得修改业务源码。
"""

NAMING_RULES = """\
# 文件命名规则
version: 1
user_readable: chinese
tool_required_english:
  - AGENTS.md
  - CLAUDE.md
  - README.md
  - .gitignore
  - .cursor/rules/
  - .cursor/commands/
  - .cursor/hooks.json
  - .cursor/cli.json
session_artifact_pattern: "{date}_{time}_{tool}_{project}_{kind}.{ext}"
examples:
  - "2026-07-28_143205_Cursor_自动量化交易系统_用户输入.md"
  - "2026-07-28_143205_CursorCLI_自动量化交易系统_原始事件.jsonl"
date_format: "%Y-%m-%d"
time_format: "%H%M%S"
path_style: forward_slash_in_yaml
"""

PRIVACY = """\
# 隐私与安全规则

版本：1  
适用范围：中央目录与各项目知识区

## 禁止读取 / 保存 / 输出

- `.env`、API Key、Token、Cookie、私钥、SSH 密钥
- 钱包、助记词、`wallet.dat`
- 浏览器登录数据库
- 未脱敏客户原始资料
- 模型私有思维过程

## 写入边界

- **全局采集器**：可读已登记项目；只写中央知识区与各项目 `项目知识库/`、`AI原始记录/`、受控 `.cursor` 规则/命令；**禁止**改业务源码
- **项目开发 Agent**：只改当前项目；不得直接重写中央主知识库；不得静默覆盖项目事实源

## 冲突处理

中央发现冲突时只生成「待确认补丁」，不得静默覆盖项目内容。

## 公开内容

仅 `PUBLIC_SAFE` 且已脱敏的内容可进入视频选题；交易收益承诺、客户隐私、未验证完成案例禁止公开。

## 危险操作

删除目录、格式化、注册表、系统服务、生产部署、真实交易/付款、SSH/SCP/FTP 自动上传 —— 必须人工确认，默认拒绝。
"""

GLOBAL_STATUS = """\
# 当前全局状态

- 更新日期：2026-07-28
- 模块进度：模块 0（架构冻结与项目发现）实施中 / 完成后更新
- 中央目录：`C:/Users/win/Desktop/全局配置`
- 扫描根：`C:/Users/win/Desktop`（排除 `全局配置`、`记录`）
- 项目注册表：draft（全部 `enabled: false`，待人工确认）
- 下一动作：确认候选项目清单后进入模块 1

## 完成判定约定

- `USER_REPORTED`：用户声称完成，无独立测试证据
- `VERIFIED`：有独立测试/命令证据
- 未经真实验证不得声称完成
"""

REGISTRY = """\
# 项目注册表 — draft（模块 0）
# 全部 enabled: false；人工确认后再启用。发现脚本可追加候选，不得自动 enabled。
version: 1
status: draft
updated: "2026-07-28"
projects: []
"""

USER_MEMORY_STUBS = {
    "用户长期记忆/用户画像.md": "# 用户画像\n\n见根目录 `USER_KNOWLEDGE_BASE.md`。本文件由模块 1 细化。\n",
    "用户长期记忆/用户偏好与约束.md": "# 用户偏好与约束\n\n见 `MEMORY_AGENTS.md` 与 `USER_KNOWLEDGE_BASE.md`。\n",
    "用户长期记忆/长期目标.md": "# 长期目标\n\n见 `USER_KNOWLEDGE_BASE.md`。\n",
    "用户长期记忆/个人开放事项.md": "# 个人开放事项\n\n见 `USER_KNOWLEDGE_BASE.md` 开放任务字段。\n",
    "跨项目经验/Agent错误模式.md": "# Agent 错误模式\n\n（模块 7 汇总前占位）\n",
    "跨项目经验/已验证解决方案.md": "# 已验证解决方案\n\n（占位）\n",
    "跨项目经验/架构与产品经验.md": "# 架构与产品经验\n\n（占位）\n",
    "跨项目经验/工具与Skills经验.md": "# 工具与 Skills 经验\n\n（占位）\n",
    "内容素材中心/视频选题总库.md": "# 视频选题总库\n\n（占位）\n",
    "内容素材中心/可公开证据索引.md": "# 可公开证据索引\n\n（占位）\n",
    "内容素材中心/禁止公开内容.md": "# 禁止公开内容\n\n见 `隐私与安全规则.md`。\n",
    "内容素材中心/已发布内容复盘.md": "# 已发布内容复盘\n\n（占位）\n",
    "决策与复盘/全局决策记录.md": "# 全局决策记录\n\n- 2026-07-28：中央目录就地使用桌面 `全局配置`；扫描根为桌面。\n",
}


def write_if_absent(path: Path, content: str) -> str:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        return f"skip {path.relative_to(CENTRAL)}"
    path.write_text(content, encoding="utf-8")
    return f"create {path.relative_to(CENTRAL)}"


def ensure_gitkeep(dir_path: Path) -> None:
    dir_path.mkdir(parents=True, exist_ok=True)
    keep = dir_path / ".gitkeep"
    if not keep.exists() and not any(dir_path.iterdir()):
        keep.write_text("", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="初始化中央知识管理中心")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    actions: list[str] = []

    for rel in DIRS:
        p = CENTRAL / rel
        if args.dry_run:
            actions.append(f"mkdir {rel}")
            continue
        ensure_gitkeep(p)
        actions.append(f"mkdir {rel}")

    files = {
        "同步配置.yaml": SYNC_CONFIG,
        "配置/文件命名规则.yaml": NAMING_RULES,
        "隐私与安全规则.md": PRIVACY,
        "当前全局状态.md": GLOBAL_STATUS,
        "项目注册表.yaml": REGISTRY,
        **USER_MEMORY_STUBS,
    }
    for rel, content in files.items():
        if args.dry_run:
            actions.append(f"write {rel}")
            continue
        actions.append(write_if_absent(CENTRAL / rel, content))

    print(f"central={CENTRAL}")
    for a in actions:
        print(a)
    print("OK: 初始化完成（幂等，未覆盖已有文件）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
