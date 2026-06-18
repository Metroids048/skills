#!/usr/bin/env node
/** Scan repo for UTF-8 BOM, invalid UTF-8, and common mojibake patterns. */
import fs from "node:fs";
import path from "node:path";

const textExtensions = new Set([
  ".md", ".mdc", ".txt", ".json", ".js", ".mjs", ".cjs", ".ts", ".tsx",
  ".jsx", ".css", ".html", ".htm", ".svg", ".xml", ".yml", ".yaml",
  ".ps1", ".cmd", ".sh", ".sql", ".toml", ".env.example",
]);
const skipDirs = new Set([
  "node_modules", ".git", "dist", "build", ".venv", "__pycache__",
  "coverage", ".next", ".turbo", ".encoding-audit",
]);
const mojibakeRe = new RegExp(
  [
    "\\u9225\\?",
    "\\uFFFD",
    "ï¿½",
    "Ã©",
    "â€™",
    "â€œ",
    "锟斤拷",
  ].join("|"),
);

const repoPath = path.resolve(process.argv[2] || ".");
const reportDir = path.resolve(process.argv[3] || path.join(repoPath, ".encoding-audit"));
fs.mkdirSync(reportDir, { recursive: true });

const issues = [];
let fileCount = 0;

function walk(dir) {
  for (const name of fs.readdirSync(dir, { withFileTypes: true })) {
    if (skipDirs.has(name.name)) continue;
    const full = path.join(dir, name.name);
    if (name.isDirectory()) {
      walk(full);
      continue;
    }
    const ext = path.extname(name.name).toLowerCase();
    if (!textExtensions.has(ext)) continue;
    const rel = path.relative(repoPath, full).split(path.sep).join("/");
    if (rel.endsWith("scan-encoding-issues.mjs")) continue;
    fileCount++;
    const buf = fs.readFileSync(full);
    if (buf.length >= 3 && buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) {
      issues.push({ severity: "error", kind: "utf8_bom", path: rel, message: "UTF-8 BOM present" });
    }
    let text;
    try {
      text = new TextDecoder("utf-8", { fatal: true }).decode(buf);
    } catch {
      issues.push({ severity: "error", kind: "invalid_utf8", path: rel, message: "Invalid UTF-8 byte sequence" });
      continue;
    }
    if (mojibakeRe.test(text)) {
      issues.push({ severity: "warn", kind: "mojibake", path: rel, message: "Possible mojibake pattern" });
    }
  }
}

walk(repoPath);

const errors = issues.filter((i) => i.severity === "error");
const warns = issues.filter((i) => i.severity === "warn");
const summary = {
  repo: repoPath,
  scannedAt: new Date().toISOString(),
  files: fileCount,
  errorCount: errors.length,
  warnCount: warns.length,
  issues,
};

fs.writeFileSync(path.join(reportDir, "encoding-audit.json"), JSON.stringify(summary, null, 2), "utf8");

const lines = [
  "# Encoding audit",
  "",
  `Repo: ${repoPath}`,
  `Files scanned: ${fileCount}`,
  `Errors: ${errors.length}`,
  `Warnings: ${warns.length}`,
  "",
];
if (errors.length) {
  lines.push("## Errors", "");
  for (const i of errors) lines.push(`- [${i.kind}] ${i.path} — ${i.message}`);
  lines.push("");
}
if (warns.length) {
  lines.push("## Warnings", "");
  for (const i of warns) lines.push(`- [${i.kind}] ${i.path} — ${i.message}`);
}
fs.writeFileSync(path.join(reportDir, "encoding-audit.md"), lines.join("\n"), "utf8");

console.log(`Scanned ${fileCount} files — errors: ${errors.length}, warnings: ${warns.length}`);
console.log(`Report: ${path.join(reportDir, "encoding-audit.json")}`);
process.exit(errors.length > 0 ? 1 : 0);
