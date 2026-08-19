import importlib.util
import json
from pathlib import Path

import pytest

SCRIPT = Path(__file__).parents[1] / "scripts" / "import-chatgpt-export.py"
spec = importlib.util.spec_from_file_location("chatgpt_importer", SCRIPT)
mod = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(mod)


def test_importer_rejects_output_inside_repo(tmp_path):
    repo = tmp_path / "repo"
    repo.mkdir()
    source = tmp_path / "conversations.json"
    source.write_text("[]", encoding="utf-8")
    with pytest.raises(ValueError, match="outside the Git repository"):
        mod.import_export(source, repo / "memory" / "imports", repo_root=repo)


def test_importer_redacts_secret_like_values(tmp_path):
    source = tmp_path / "conversations.json"
    payload = [{"title": "test", "create_time": 1, "mapping": {"a": {"message": {"author": {"role": "user"}, "content": {"parts": ["token sk-proj-abcdefghijklmnopqrstuvwxyz123456"]}}}}}]
    source.write_text(json.dumps(payload), encoding="utf-8")
    out = tmp_path / "private"
    result = mod.import_export(source, out, repo_root=tmp_path / "repo")
    text = Path(result["sessions"][0]).read_text(encoding="utf-8")
    assert "abcdefghijklmnopqrstuvwxyz123456" not in text
    assert "[REDACTED_SECRET]" in text
