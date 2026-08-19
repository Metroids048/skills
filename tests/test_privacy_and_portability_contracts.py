from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_export_script_does_not_export_raw_sessions_by_default():
    text = (ROOT / "scripts" / "export-from-local.ps1").read_text(encoding="utf-8")
    assert "[switch]$IncludePrivateArchives" in text
    assert "Assert-PrivateRepository" in text
    assert "if ($IncludePrivateArchives)" in text
    assert "archives\\codex\\sessions" in text


def test_redaction_contract_includes_jsonl_and_has_no_1mb_skip():
    text = (ROOT / "scripts" / "export-from-local.ps1").read_text(encoding="utf-8")
    assert '"*.jsonl"' in text
    assert "Length -lt 1MB" not in text


def test_templates_and_runtime_rules_have_no_source_username_hardcode():
    paths = [ROOT / "claude" / "CLAUDE.md", ROOT / "codex" / "AGENTS.md", ROOT / "cursor" / "rules" / "01-personal-ai-runtime.mdc"]
    for path in paths:
        text = path.read_text(encoding="utf-8")
        assert "C:\\Users\\win" not in text
        assert "C:/Users/win" not in text


def test_gitignore_blocks_private_memory_and_raw_chat_exports():
    text = (ROOT / ".gitignore").read_text(encoding="utf-8")
    for token in ["private-memory/", "conversations.json", "chatgpt-export", "archives/"]:
        assert token in text


def test_installer_preserves_unrelated_cursor_rules():
    text = (ROOT / "install.ps1").read_text(encoding="utf-8")
    assert 'Backup-Path (Join-Path $UserHome ".cursor\\rules")' not in text
    assert 'Ensure-Dir (Join-Path $UserHome ".cursor\\rules")' in text
