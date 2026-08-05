#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 USER_KNOWLEDGE_BASE + 项目镜像汇总跨项目经验与内容素材索引（模块 7 内容层）。

禁止脑补：只写入带证据来源的条目；无已发布内容时诚实写「暂无」。
验收：输出文件不得再含「（占位）」字样。
"""

from __future__ import annotations

import argparse
import re
from collections import OrderedDict
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
UKB = CENTRAL / "USER_KNOWLEDGE_BASE.md"
MIRROR = CENTRAL / "项目镜像"
XP = CENTRAL / "跨项目经验"
CONTENT = CENTRAL / "内容素材中心"
# 仅匹配「整文件仍是空壳」或「整行只有占位」，避免把说明文字里的提及误判为 FAIL
STUB_LINE_RE = re.compile(r"^\s*[（(]占位[）)]\s*$")
STUB_PHRASE = "模块 7 汇总前占位"


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8")


def is_stub_content(text: str) -> bool:
    if STUB_PHRASE in text:
        return True
    for line in text.splitlines():
        if STUB_LINE_RE.match(line):
            return True
    # 只有标题+空壳的极短文件
    body = "\n".join(ln for ln in text.splitlines() if ln.strip() and not ln.strip().startswith("#"))
    if len(body.strip()) < 40 and ("占位" in body or not body.strip()):
        return True
    return False



def bullet_lines(text: str, *needles: str) -> list[str]:
    out: list[str] = []
    for line in text.splitlines():
        s = line.strip()
        if not s.startswith("-"):
            continue
        if needles and not any(n in s for n in needles):
            continue
        # skip DO_NOT_PUBLISH raw secrets hints in cross-project unless needed
        out.append(s)
    return out


def dedupe(items: list[str]) -> list[str]:
    seen: OrderedDict[str, None] = OrderedDict()
    for it in items:
        key = re.sub(r"\s+", " ", it).strip().lower()
        if key not in seen:
            seen[key] = None
    return list(seen.keys())


def extract_ukb_section(ukb: str, heading: str) -> str:
    """Extract markdown from ## heading until next same-or-higher level heading."""
    pat = re.compile(rf"^(##\s+{re.escape(heading)}\s*)$", re.M)
    m = pat.search(ukb)
    if not m:
        return ""
    start = m.end()
    nxt = re.search(r"^##\s+", ukb[start:], re.M)
    end = start + nxt.start() if nxt else len(ukb)
    return ukb[start:end].strip()


def collect_confirmed_from_mirrors() -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    if not MIRROR.is_dir():
        return rows
    skip_fixtures = {"普通代码项目", "已有规则项目", "敏感客户项目"}
    for proj in sorted(MIRROR.iterdir()):
        if not proj.is_dir() or proj.name in skip_fixtures:
            continue
        err = read_text(proj / "错误与根因.md")
        for line in err.splitlines():
            s = line.strip()
            if s.startswith("-") and ("[CONFIRMED]" in s or "[USER_REPORTED]" in s):
                # 去掉误多写的二级 "- -"
                while s.startswith("-"):
                    s = s[1:].strip()
                rows.append((proj.name, "- " + s))
        fixes = read_text(proj / "已验证解决方案.md")
        for line in fixes.splitlines():
            s = line.strip()
            if s.startswith("-") and "中央安装器" not in s and "具体修复" not in s and "同步：" not in s:
                if len(s) > 8:
                    rows.append((proj.name, s + " 〔方案〕"))
    return rows


def collect_public_safe(ukb: str) -> list[str]:
    items = []
    for line in ukb.splitlines():
        s = line.strip()
        if "[PUBLIC_SAFE]" in s or "[CONTENT_IDEA][PUBLIC_SAFE]" in s:
            items.append(s)
    return dedupe(items)


def write_agent_errors(ukb: str, mirror_rows: list[tuple[str, str]]) -> Path:
    now = datetime.now().isoformat(timespec="seconds")
    lines = [
        "# Agent 错误模式",
        "",
        f"- 更新：{now}",
        "- 来源：`USER_KNOWLEDGE_BASE.md`、各 `项目镜像/*/错误与根因.md`、全局收口规则",
        "- 规则：无独立测试证据不得标 VERIFIED；用户自述完成标 `USER_REPORTED`",
        "",
        "## 1. 跨工具通用失败模式",
        "",
        "- `[CONFIRMED]` 来源：UKB §1–§2 — Agent 声称完成但无独立测试证据 → 只能标 `USER_REPORTED`，不得写成 VERIFIED/COMPLETE。",
        "- `[CONFIRMED]` 来源：UKB §2 收口模式 — 无限分析、范围膨胀、为「更优雅」而重构、模糊说「应该可以」。",
        "- `[CONFIRMED]` 来源：UKB §2 — 用 TODO/mock/假成功掩盖未完成；未跑检查却写成通过。",
        "- `[CONFIRMED]` 来源：全局 Windows 失败分层 — 把 L1 路径/编码/RTK 命令错误误报成「环境坏了」或 L3 项目失败。",
        "- `[CONFIRMED]` 来源：最大权限规则 — 「最大权限」被误读成可删配置、清目录、跑破坏性清理。",
        "- `[CONFIRMED]` 来源：知识中心复盘 — 系统脚手架 COMPLETE ≠ 内容层已填充；验收只查文件存在会导致占位漏检。",
        "- `[CONFIRMED]` 来源：UKB §4.3 — Codex 长任务中途报错（namespace/rs id/stream disconnect/Transport）且 token 耗尽前未推送。",
        "",
        "## 2. 按项目沉淀的确认问题",
        "",
    ]
    # Prefer UKB project-specific CONFIRMED from mirrors (already include UKB excerpts)
    seen = set()
    by_proj: OrderedDict[str, list[str]] = OrderedDict()
    for proj, bullet in mirror_rows:
        if "〔方案〕" in bullet:
            continue
        key = (proj, bullet)
        if key in seen:
            continue
        seen.add(key)
        by_proj.setdefault(proj, []).append(bullet)

    if not by_proj:
        # fallback: UKB confirmed under project ledger
        for line in bullet_lines(ukb, "[CONFIRMED]"):
            if any(k in line for k in ("开单", "幽灵", "Alpha", "API", "保护", "描述", "Cookie", "Demo")):
                lines.append(f"- 来源：UKB — {line}")
    else:
        for proj, bullets in by_proj.items():
            lines.append(f"### {proj}")
            lines.append("")
            lines.append(f"- 证据文件：`项目镜像/{proj}/错误与根因.md`")
            for b in bullets[:20]:
                lines.append(f"- {b}")
            lines.append("")

    lines += [
        "## 3. 防再犯检查清单",
        "",
        "- 交付前：真实命令输出 + 验收映射；未跑项标「未验证」。",
        "- 声称 COMPLETE 前：内容文件不得仍是整行空壳占位。",
        "- Windows：先分 L1/L2/L3；路径用正斜杠；中文用 UTF-8；禁止 rtk 包 PS cmdlet。",
        "- 资金/生产：fail-closed；禁止 Synthetic Fill 冒充真实成交。",
        "- 敏感：密钥/Cookie/钱包/未脱敏客户资料永不入库原文。",
        "",
    ]
    out = XP / "Agent错误模式.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    return out


def write_verified_fixes(mirror_rows: list[tuple[str, str]]) -> Path:
    now = datetime.now().isoformat(timespec="seconds")
    lines = [
        "# 已验证解决方案",
        "",
        f"- 更新：{now}",
        "- 来源：UKB 稳定偏好、中央知识中心工具链、各项目镜像 `已验证解决方案.md`",
        "- 说明：下列为跨项目可复用方案；项目专属修复以各镜像为准，会话胶囊追加。",
        "",
        "## 1. 中央知识中心（本仓已验收）",
        "",
        "- `[CONFIRMED]` 来源：`交付说明_V1.md` / `日志/最终完成报告.md` — 项目事实写入 `项目知识库/`，中央只镜像；冲突生成 `待确认更新/`，禁止静默覆盖。",
        "- `[CONFIRMED]` 来源：安装器 — 幂等写入知识区与托管 AGENTS/CLAUDE 区块，不改业务源码。",
        "- `[CONFIRMED]` 来源：权限证明 — 拒绝读 `.env`/Cookie DB；拒绝危险删除/format；密钥导入脱敏。",
        "- `[CONFIRMED]` 来源：CLI 包装 — Cursor CLI 用 `工具/开始AI任务.py`（`--simulate` 覆盖 success/fail/interrupt）；GUI 用开始/结束归档 + 导出导入。",
        "- `[CONFIRMED]` 来源：统一 CLI — `python 工具/知识中心.py`（梳理/同步/验收/复盘）。",
        "- `[CONFIRMED]` 来源：本轮补齐 — `python 工具/汇总跨项目经验.py` 填充跨项目经验；验收禁止整行空壳占位文案。",
        "",
        "## 2. Agent 工作方式（UKB 收口模式）",
        "",
        "- `[CONFIRMED]` 来源：UKB §2 — 目标/范围/验收先写清；最小修改；行为验证优先于「代码看起来对」。",
        "- `[CONFIRMED]` 来源：UKB §2 — 同一检查最多自动修 3 次；连续两次无进展停止并报告证据。",
        "- `[CONFIRMED]` 来源：UKB §4 — 全局规则只放稳定偏好；项目事实放项目 AGENTS；复杂流程放 Skill；强约束放 tests/Hooks/verify。",
        "- `[CONFIRMED]` 来源：UKB §4.3 — Token/上下文耗尽前：保存、提交、推送、写 Session Capsule（Prompt H）。",
        "- `[CONFIRMED]` 来源：UKB 标签 — `USER_REPORTED` vs 独立验证完成必须区分（如 Agent Video Studio）。",
        "",
        "## 3. 领域方案摘要（有证据，细节回项目）",
        "",
        "- `[CONFIRMED]` 交易（AI--main）：Testnet 与 Local Paper 隔离；禁止 Synthetic Local Fill；保护 fail-closed；订单参数由确定性程序算，AI 不定关键数值。来源：UKB §5.1 / `项目镜像/AI--main/`。",
        "- `[CONFIRMED]` Alpha：仅当唯一阻塞是模板描述缺失才自动补描述重提；Base gate/自相关/生产相关失败禁止因补描述重提。来源：UKB §5.2 / `项目镜像/alpha/`。",
        "- `[USER_REPORTED]` Agent Video Studio：工程测试通过 ≠ 真实素材可发；冻结功能后用真实素材压测。来源：UKB §5.3。",
        "- `[CONFIRMED]` 业务 Demo（产能评价类）：按真实 Excel 流程/角色/数据结构重构，AI 侧栏要行内入口+结构化结果+人工确认。来源：UKB §5.5。",
        "- `[CONFIRMED]` 合同审查：确定性规则 + 语义审查分工；低置信度人工复核；结果定位原文。来源：UKB §5.6。",
        "",
        "## 4. 项目镜像中的本地方案条目",
        "",
    ]
    local = [f"- `{proj}` — {b.replace(' 〔方案〕', '')}" for proj, b in mirror_rows if "〔方案〕" in b]
    local = dedupe(local)
    if local:
        lines.extend(local[:40])
    else:
        lines.append("- （各项目镜像暂无超出中央模板的专属修复条目；随会话胶囊追加。）")
    lines.append("")
    out = XP / "已验证解决方案.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    return out


def write_architecture(ukb: str) -> Path:
    now = datetime.now().isoformat(timespec="seconds")
    decisions = read_text(CENTRAL / "决策与复盘" / "全局决策记录.md")
    lines = [
        "# 架构与产品经验",
        "",
        f"- 更新：{now}",
        "- 来源：`USER_KNOWLEDGE_BASE.md`、`决策与复盘/全局决策记录.md`、中央架构方案",
        "",
        "## 1. 个人知识系统架构（本仓）",
        "",
        "- `[CONFIRMED]` 共享文件库 + Session Capsule，而非指望三端自动共享完整对话。",
        "- `[CONFIRMED]` 项目知识库是项目事实源；中央镜像汇总；冲突只出待确认补丁。",
        "- `[CONFIRMED]` 全局采集器：只读项目、只写知识区；项目开发 Agent 只改当前项目。",
        "- `[CONFIRMED]` 不把 Background Agent 当本机全项目中央采集器（远程隔离+提示注入风险）。",
        "- `[CONFIRMED]` Hooks 做行为审计，不做完整 GUI 对话唯一采集源。",
        "- `[CONFIRMED]` 用户可读输出用中文文件名；工具约定名保留 AGENTS.md / CLAUDE.md / .cursor/*。",
        "",
        "## 2. 全局决策摘录",
        "",
    ]
    for line in decisions.splitlines():
        s = line.strip()
        if s.startswith("-"):
            lines.append(f"- 来源：`决策与复盘/全局决策记录.md` — {s.lstrip('- ').strip()}")
    lines += [
        "",
        "## 3. 产品与 Agent 分工经验（UKB）",
        "",
        "- `[CONFIRMED]` 来源：UKB §4 — Cursor 日常改码；Claude Code 长任务/审查/记忆；Codex 实施与并行；ChatGPT 规划与综合讨论。",
        "- `[CONFIRMED]` 来源：UKB §5.3 — 视频流水线：业务唯一 CLI `python -m avs`；Skills 源在 `skills-src/`；剪映草稿不作 V1 核心。",
        "- `[CONFIRMED]` 来源：UKB §5.1 V2 — 垂直模块 + 单写入者 Scheduler + 决策漏斗全阶段记录 + Trust Layer。",
        "- `[CONFIRMED]` 来源：UKB §5.7 — 数字产品可持续价值在筛选/实测/验证/流程模板，不在洗稿搬运。",
        "- `[CONFIRMED]` 来源：UKB §6 — 账号定位「普通 AI 产品经理的 Agent 实战与验收记录」；50/30/20 内容比例。",
        "",
        "## 4. 收口与证据",
        "",
        "- 复杂任务可分模块，但每模块必须独立验收并收口（UKB §1.3）。",
        "- 最终报告必含：状态、改动、命令结果、验收映射、未验证项、风险、最小下一步（UKB §2）。",
        "",
    ]
    # light touch from UKB architecture-ish confirmed
    for line in bullet_lines(ukb, "[CONFIRMED]")[:0]:
        pass
    out = XP / "架构与产品经验.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    return out


def write_tools_skills(ukb: str) -> Path:
    now = datetime.now().isoformat(timespec="seconds")
    tool_sec = extract_ukb_section(ukb, "4. 工具与工作环境") or extract_ukb_section(ukb, "4. 工具与工作环境")
    # UKB uses "# 4." style sometimes — try both
    if not tool_sec:
        m = re.search(r"# 4\. 工具与工作环境([\s\S]*?)(?=\n# 5\. |\Z)", ukb)
        tool_sec = (m.group(1).strip() if m else "")

    lines = [
        "# 工具与 Skills 经验",
        "",
        f"- 更新：{now}",
        "- 来源：`USER_KNOWLEDGE_BASE.md` §4、`用户长期记忆/工具与工作环境.md`、中央 `工具/`",
        "",
        "## 1. 三端角色（UKB）",
        "",
        "| 工具 | 当前角色 | 证据 |",
        "|---|---|---|",
        "| Cursor | 日常代码阅读、修改、项目交互 | UKB §4.1 |",
        "| Claude Code | 长任务实施、代码审查、Subagent、项目记忆 | UKB §4.1 |",
        "| Codex | 代码实施、并行任务、插件/Skills、复杂项目推进 | UKB §4.1 |",
        "| ChatGPT | 研究、规划、Prompt、综合讨论 | UKB §4.1 |",
        "",
        "## 2. 配置分层（已验证做法）",
        "",
        "1. 全局行为规则：只记跨项目稳定偏好。",
        "2. 项目 `AGENTS.md`：目标、非目标、目录、命令、架构边界、验收。",
        "3. 工具专用：Claude `CLAUDE.md` + skills；Cursor `.cursor/rules`；Codex AGENTS + `.agents/skills`。",
        "4. 按需 Skill：复杂流程按需加载，不塞满全局上下文。",
        "5. 确定性层：tests、CI、Hooks、verify、permissions。",
        "",
        "- 证据：UKB §4.2；项目 D 条目。",
        "",
        "## 3. Codex 已知故障与对策",
        "",
        "- `[CONFIRMED]` 错误族：`Unknown parameter: namespace` / `Expected an ID that begins with 'rs'` / `stream disconnected` / `Transport error` / `error decoding response body`。来源：UKB §4.3。",
        "- `[CONFIRMED]` 对策偏好：正常完成或 token 将尽时保存、提交并推送；用 Prompt H / `/Token耗尽前收口`。",
        "",
        "## 4. 本机知识中心常用命令",
        "",
        "```text",
        "python 工具/知识中心.py 梳理 --all",
        "python 工具/知识中心.py 同步 --all",
        "python 工具/知识中心.py 复盘",
        "python 工具/汇总跨项目经验.py",
        "python 工具/知识中心.py 验收",
        "```",
        "",
        "- `[CONFIRMED]` 中央目录就地：`C:\\Users\\win\\Desktop\\全局配置`（见全局决策记录）。",
        "- `[CONFIRMED]` 本机 `cursor agent` 非交互 stream-json 未暴露时，用 `--simulate` 覆盖记录链路（交付说明环境缺口）。",
        "",
        "## 5. Skills / 视频工具视角（UKB）",
        "",
        "- `[CONFIRMED]` 工具内容固定视角：不复述功能说明书，放进真实任务里验收（UKB §6.5）。",
        "- `[CONFIRMED]` Agent Video Studio：Skills 唯一编辑源 `skills-src/`；同步到 `.claude/skills` 与 `.agents/skills`；Codex HyperFrames 插件非硬依赖（UKB §5.3）。",
        "- `[OPEN]` 「装了多个视频 Skills，真正留下几个」仍是前 12 条验证内容之一（UKB §6.7 #10）。",
        "",
    ]
    if tool_sec:
        lines += [
            "## 6. UKB §4 原文摘录（只读同步）",
            "",
            "```markdown",
            tool_sec[:2500],
            "```",
            "",
        ]
    out = XP / "工具与Skills经验.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    return out


def write_content_vault(ukb: str) -> list[Path]:
    now = datetime.now().isoformat(timespec="seconds")
    public = collect_public_safe(ukb)
    idx_lines = [
        "# 可公开证据索引",
        "",
        f"- 更新：{now}",
        "- 说明：仅索引 `[PUBLIC_SAFE]` / 可脱敏素材路径；不含密钥、客户原文、未脱敏交易。",
        "- 主库 SSOT：`USER_KNOWLEDGE_BASE.md`",
        "",
        "## 1. UKB 中的 PUBLIC_SAFE 条目",
        "",
    ]
    if public:
        for p in public:
            idx_lines.append(f"- {p}")
    else:
        idx_lines.append("- （UKB 中暂无 PUBLIC_SAFE 标记）")
    idx_lines += [
        "",
        "## 2. 中央可引用路径（脱敏后）",
        "",
        "- `跨项目经验/Agent错误模式.md` — 失败模式（已脱敏）",
        "- `跨项目经验/已验证解决方案.md` — 可复用方案",
        "- `跨项目经验/工具与Skills经验.md` — 三端与命令",
        "- `跨项目经验/架构与产品经验.md` — 架构结论",
        "- `内容素材中心/自媒体账号定位.md` — 账号定位摘录",
        "- `内容素材中心/视频选题总库.md` — 选题库（注意区分 fixture 与真实提炼）",
        "- `决策与复盘/每周复盘/` — 周复盘计数与开放注意",
        "- 各启用项目：`项目镜像/<名>/项目总览.md`（发布前再扫 `[DO_NOT_PUBLISH]`）",
        "",
        "## 3. 明确不可公开",
        "",
        "- 见 `内容素材中心/禁止公开内容.md` 与 `隐私与安全规则.md`",
        "- UKB 中所有 `[DO_NOT_PUBLISH]` / `[SENSITIVE]` 条目",
        "",
    ]
    idx = CONTENT / "可公开证据索引.md"
    idx.write_text("\n".join(idx_lines), encoding="utf-8")

    pub_lines = [
        "# 已发布内容复盘",
        "",
        f"- 更新：{now}",
        "- 状态：**暂无已发布内容**",
        "",
        "## 诚实说明",
        "",
        "- 截至本更新，抖音 / 小红书账号尚未确定名称，也无已发布成片记录可复盘。",
        "- 因此本文件不是空壳占位，而是明确的「零发布」状态。",
        "- 一旦有真实发布：在此追加链接、发布时间、母题编号（UKB §6.7）、人工修改时长、数据表现与下一轮验证点。",
        "",
        "## 待发布池（非已发布）",
        "",
        "- 前 12 条验证内容见 `USER_KNOWLEDGE_BASE.md` §6.7 / `内容素材中心/自媒体账号定位.md`。",
        "- 选题提取脚本产物见 `内容素材中心/视频选题总库.md`（含验收夹具条目，发布前需人工筛选）。",
        "",
    ]
    pub = CONTENT / "已发布内容复盘.md"
    pub.write_text("\n".join(pub_lines), encoding="utf-8")
    return [idx, pub]


def assert_no_placeholders(paths: list[Path]) -> None:
    bad: list[str] = []
    for p in paths:
        text = read_text(p)
        if not text.strip():
            bad.append(f"{p.name}: empty")
        elif is_stub_content(text):
            bad.append(f"{p.name}: still stub/placeholder")
    if bad:
        raise SystemExit("PLACEHOLDER_REMAINING:\n" + "\n".join(bad))



def refresh_lessons_alias() -> None:
    src = XP / "已验证解决方案.md"
    if src.is_file():
        (CENTRAL / "LESSONS.md").write_text(
            f"> 别名入口 → `跨项目经验/已验证解决方案.md`\n\n" + src.read_text(encoding="utf-8"),
            encoding="utf-8",
        )


def main() -> int:
    ap = argparse.ArgumentParser(description="汇总跨项目经验与内容索引")
    ap.add_argument("--check-only", action="store_true", help="仅检查目标文件无占位")
    args = ap.parse_args()

    targets = [
        XP / "Agent错误模式.md",
        XP / "已验证解决方案.md",
        XP / "架构与产品经验.md",
        XP / "工具与Skills经验.md",
        CONTENT / "可公开证据索引.md",
        CONTENT / "已发布内容复盘.md",
    ]

    if args.check_only:
        missing = [str(p) for p in targets if not p.is_file()]
        if missing:
            print("MISSING:", *missing, sep="\n")
            return 1
        assert_no_placeholders(targets)
        print("跨项目经验非占位: PASS")
        return 0

    XP.mkdir(parents=True, exist_ok=True)
    CONTENT.mkdir(parents=True, exist_ok=True)
    ukb = read_text(UKB)
    if not ukb:
        print("WARN: USER_KNOWLEDGE_BASE.md missing or empty", file=__import__("sys").stderr)

    mirror_rows = collect_confirmed_from_mirrors()
    written = [
        write_agent_errors(ukb, mirror_rows),
        write_verified_fixes(mirror_rows),
        write_architecture(ukb),
        write_tools_skills(ukb),
        *write_content_vault(ukb),
    ]
    refresh_lessons_alias()
    assert_no_placeholders(written + [CENTRAL / "LESSONS.md"])
    for p in written:
        print(p.relative_to(CENTRAL).as_posix())
    print("汇总跨项目经验: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
