#!/usr/bin/env python3
"""Resolve which Python/pytest to use for THIS project vs global agent stack.

Prints JSON. Exit 0 always when it can recommend a runner; exit 2 if no python at all.

Agents MUST call this before claiming "pytest missing" or "AGENT_PYTHON broken".
"""
from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path


def _exists(p: Path) -> bool:
    try:
        return p.is_file()
    except OSError:
        return False


def _has_pytest(python: Path) -> bool:
    try:
        r = subprocess.run(
            [str(python), "-c", "import pytest"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        return r.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False


def _py_launcher() -> Path | None:
    for name in ("py", "py.exe"):
        for d in os.environ.get("PATH", "").split(os.pathsep):
            cand = Path(d) / name
            if _exists(cand):
                return cand
    return None


def _resolve_py3() -> Path | None:
    launcher = _py_launcher()
    if not launcher:
        return None
    try:
        r = subprocess.run(
            [str(launcher), "-3", "-c", "import sys; print(sys.executable)"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        if r.returncode == 0:
            exe = Path(r.stdout.strip())
            if _exists(exe):
                return exe
    except (OSError, subprocess.TimeoutExpired):
        pass
    return None


def main() -> int:
    cwd = Path.cwd().resolve()
    agent = os.environ.get("AGENT_PYTHON") or str(
        Path.home() / ".ai-workspace" / "venv" / "Scripts" / "python.exe"
    )
    agent_path = Path(agent)
    project_venv = cwd / ".venv" / "Scripts" / "python.exe"
    if not _exists(project_venv):
        project_venv = cwd / ".venv" / "bin" / "python"

    looks_python_project = any(
        (cwd / name).exists()
        for name in (
            "pyproject.toml",
            "pytest.ini",
            "setup.cfg",
            "requirements.txt",
            "requirements-dev.txt",
            "tox.ini",
        )
    )

    choice = "none"
    python: Path | None = None
    notes: list[str] = []

    if _exists(project_venv):
        python = project_venv
        choice = "project_venv"
        notes.append("Prefer project .venv for business tests.")
    else:
        py3 = _resolve_py3()
        if py3 and looks_python_project:
            python = py3
            choice = "py_launcher"
            notes.append("No project .venv; using py -3 for project tests.")
        elif _exists(agent_path):
            python = agent_path
            choice = "agent_python"
            notes.append(
                "Using AGENT_PYTHON (global agent stack). "
                "OK for agent scripts/Office/CJK — NOT a substitute for project-only deps."
            )
        else:
            notes.append("No usable Python found. Run install-global-agent-python.ps1")
            print(
                json.dumps(
                    {
                        "cwd": str(cwd),
                        "choice": choice,
                        "python": None,
                        "pytest": False,
                        "pytest_cmd": None,
                        "layer_hint": "L2",
                        "notes": notes,
                        "do_not_report_as": "project code failure",
                    },
                    ensure_ascii=False,
                    indent=2,
                )
            )
            return 2

    pytest_ok = _has_pytest(python) if python else False
    if choice == "agent_python" and looks_python_project and not pytest_ok:
        notes.append(
            "L2/misuse risk: AGENT_PYTHON without pytest while cwd looks like a Python project. "
            "Create/use project .venv or: py -3 -m pip install pytest. "
            "Do NOT claim global stack is broken."
        )
        layer = "L2"
    elif not pytest_ok:
        notes.append(
            "pytest not importable on chosen interpreter. "
            "Global tooling: re-run install-global-agent-python.ps1. "
            "Project: install into project env only."
        )
        layer = "L2"
    else:
        layer = "ok"

    pytest_cmd = f'"{python}" -m pytest' if python else None

    out = {
        "cwd": str(cwd),
        "choice": choice,
        "python": str(python) if python else None,
        "agent_python": str(agent_path) if _exists(agent_path) else None,
        "looks_python_project": looks_python_project,
        "pytest": pytest_ok,
        "pytest_cmd": pytest_cmd,
        "layer_hint": layer,
        "notes": notes,
        "do_not_report_as": "project code failure"
        if layer != "ok"
        else "n/a",
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
