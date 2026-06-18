#!/usr/bin/env node
/** Fix SVG files with invalid UTF-8 (strip control bytes, set ASCII title from filename). */
import fs from "node:fs";
import path from "node:path";

const files = process.argv.slice(2);
const titleMap = {
  "ai-platform-positioning.svg": "AI platform positioning",
  "ai-platform-feedback-routing.svg": "AI platform feedback routing",
  "ai-platform-haineng-integration.svg": "AI platform Haineng integration",
};

function isValidUtf8(buf) {
  try {
    new TextDecoder("utf-8", { fatal: true }).decode(buf);
    return true;
  } catch {
    return false;
  }
}

for (const file of files) {
  const buf = fs.readFileSync(file);
  if (isValidUtf8(buf)) {
    console.log("skip ok:", file);
    continue;
  }
  const base = path.basename(file);
  const title = titleMap[base] || base.replace(/\.svg$/i, "");
  let s = buf.toString("latin1");
  s = s.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
  if (/<title>/i.test(s)) {
    s = s.replace(/<title>[^<]*<\/title>/i, `<title>${title}</title>`);
  } else if (/<svg/i.test(s)) {
    s = s.replace(/<svg([^>]*)>/i, `<svg$1><title>${title}</title>`);
  }
  const out = Buffer.from(s, "utf8");
  new TextDecoder("utf-8", { fatal: true }).decode(out);
  fs.writeFileSync(file, out);
  console.log("fixed:", file);
}
