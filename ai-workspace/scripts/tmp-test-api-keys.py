import json
import os
import urllib.error
import urllib.request

key = json.load(open(os.path.join(os.environ["USERPROFILE"], ".codex", "auth.json"), encoding="utf-8"))[
    "OPENAI_API_KEY"
]
headers = {"Authorization": f"Bearer {key}"}

for name, url in [
    ("tangguo", "https://api.tangguo.xin/v1/models"),
    ("hctopup", "https://ai.hctopup.com/v1/models"),
]:
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"{name}: HTTP {resp.status} OK")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:200]
        print(f"{name}: HTTP {e.code} {body}")
    except Exception as e:
        print(f"{name}: ERROR {type(e).__name__}: {e}")
