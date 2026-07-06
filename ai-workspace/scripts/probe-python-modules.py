import importlib.util
import json
import sys

mods = {m: importlib.util.find_spec(m) is not None for m in ("win32com", "pptx", "docx", "openpyxl", "fitz")}
print(json.dumps({"executable": sys.executable, "modules": mods}))
