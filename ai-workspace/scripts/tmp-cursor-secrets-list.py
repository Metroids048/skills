"""List all cursorAuth secrets in Cursor state."""
from __future__ import annotations

import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT key, length(value) FROM ItemTable WHERE key LIKE 'secret://cursorAuth/%'")
    for key, length in cur.fetchall():
        print(f"{key} len={length}")
    conn.close()


if __name__ == "__main__":
    main()
