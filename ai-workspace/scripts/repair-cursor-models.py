"""Repair Cursor model catalog: remove orphaned BYOK secret and stale model cache.

Run while Cursor is CLOSED for best results. Creates a timestamped backup first.
"""
from __future__ import annotations

import json
import shutil
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

APP_DATA = Path.home() / "AppData/Roaming/Cursor"
DB = APP_DATA / "User/globalStorage/state.vscdb"
PERSISTENT_KEY = (
    "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl."
    "persistentStorage.applicationUser"
)
SECRETS_TO_DELETE = (
    "secret://cursorAuth/openAIKey",
    "secret://cursorAuth/anthropicKey",
    "secret://cursorAuth/googleKey",
)
CACHE_DIRS = (
    APP_DATA / "Cache",
    APP_DATA / "CachedData",
    APP_DATA / "Code Cache",
    APP_DATA / "GPUCache",
    APP_DATA / "CachedExtensionVSIXs",
)


def backup_db() -> Path:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = DB.with_name(f"state.vscdb.bak-{stamp}")
    shutil.copy2(DB, backup)
    return backup


def repair_state(conn: sqlite3.Connection) -> list[str]:
    changes: list[str] = []
    cur = conn.cursor()

    for secret_key in SECRETS_TO_DELETE:
        cur.execute("SELECT 1 FROM ItemTable WHERE key = ?", (secret_key,))
        if cur.fetchone():
            cur.execute("DELETE FROM ItemTable WHERE key = ?", (secret_key,))
            changes.append(f"deleted {secret_key}")

    cur.execute("SELECT value FROM ItemTable WHERE key = ?", (PERSISTENT_KEY,))
    row = cur.fetchone()
    if not row:
        changes.append("persistent storage key missing")
        return changes

    raw = row[0].decode("utf-8") if isinstance(row[0], bytes) else row[0]
    data = json.loads(raw)

    if data.pop("availableDefaultModels2", None) is not None:
        changes.append("cleared availableDefaultModels2 (force server refresh)")
    if data.pop("availableDefaultModels", None) is not None:
        changes.append("cleared availableDefaultModels")

    if data.get("useOpenAIKey"):
        data["useOpenAIKey"] = False
        changes.append("set useOpenAIKey=false")

    if data.get("openAIBaseUrl"):
        data["openAIBaseUrl"] = None
        changes.append("cleared openAIBaseUrl")

    if data.get("availableAPIKeyModels"):
        data["availableAPIKeyModels"] = []
        changes.append("cleared availableAPIKeyModels")

    cur.execute(
        "UPDATE ItemTable SET value = ? WHERE key = ?",
        (json.dumps(data, ensure_ascii=False, separators=(",", ":")), PERSISTENT_KEY),
    )
    return changes


def clear_caches() -> list[str]:
    cleared: list[str] = []
    for path in CACHE_DIRS:
        if path.exists():
            shutil.rmtree(path, ignore_errors=True)
            cleared.append(str(path))
    return cleared


def main() -> int:
    if not DB.exists():
        print(f"ERROR: state db not found: {DB}")
        return 1

    backup = backup_db()
    print(f"backup: {backup}")

    conn = sqlite3.connect(str(DB))
    try:
        changes = repair_state(conn)
        conn.commit()
    finally:
        conn.close()

    caches = clear_caches()

    print("state changes:")
    for item in changes or ["no state changes needed"]:
        print(f"  - {item}")

    print("cache cleared:")
    for item in caches or ["no cache dirs found"]:
        print(f"  - {item}")

    print("\nDONE. Fully quit Cursor (all windows), reopen, then:")
    print("  1) Settings -> Models -> click refresh")
    print("  2) New Agent chat -> pick Auto or Claude/GPT")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
