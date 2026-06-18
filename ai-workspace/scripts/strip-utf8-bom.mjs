#!/usr/bin/env node
/** Strip UTF-8 BOM from text files under repo. Usage: node strip-utf8-bom.mjs <repoPath> */
import fs from "node:fs";
import path from "node:path";

const textExtensions = new Set([
  ".md", ".mdc", ".txt", ".json", ".js", ".mjs", ".cjs", ".ts", ".tsx",
  ".jsx", ".css", ".html", ".htm", ".svg", ".xml", ".yml", ".yaml",
  ".ps1", ".cmd", ".sh", ".sql", ".toml",
]);
const skipDirs = new Set([
  "node_modules", ".git", "dist", "build", ".venv", "__pycache__",
  "coverage", ".next", ".turbo", ".encoding-audit",
]);

const repoPath = path.resolve(process.argv[2] || ".");
let fixed = 0;

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
    const buf = fs.readFileSync(full);
    if (buf.length >= 3 && buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) {
      fs.writeFileSync(full, buf.subarray(3));
      fixed++;
      console.log("stripped BOM:", path.relative(repoPath, full));
    }
  }
}

walk(repoPath);
console.log(`Done. Fixed ${fixed} files.`);
