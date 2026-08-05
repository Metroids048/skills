import json
import os
import urllib.error
import urllib.request

key = json.load(open(os.path.join(os.environ["USERPROFILE"], ".codex", "auth.json"), encoding="utf-8"))[
    "OPENAI_API_KEY"
]
base = "https://api.tangguo.xin/v1"
headers = {
    "Authorization": f"Bearer {key}",
    "Content-Type": "application/json",
}
body = json.dumps({"model": "gpt-5.5", "input": "ping"}).encode("utf-8")

for path in ("/models", "/responses"):
    req = urllib.request.Request(f"{base}{path}", data=body if path == "/responses" else None, headers=headers, method="POST" if path == "/responses" else "GET")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            print(f"{path}: HTTP {resp.status} OK")
    except urllib.error.HTTPError as e:
        print(f"{path}: HTTP {e.code} {e.read().decode('utf-8', errors='replace')[:300]}")

# Config sanity
toml = open(os.path.join(os.environ["USERPROFILE"], ".codex", "config.toml"), encoding="utf-8").read()
print("config base_url tangguo:", "api.tangguo.xin" in toml)
print("config base_url hctopup:", "ai.hctopup.com" in toml)
print("provider name One-API:", 'name = "One-API"' in toml)
