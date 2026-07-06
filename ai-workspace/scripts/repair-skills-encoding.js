#!/usr/bin/env node
'use strict';

/** Pick the cleanest SKILL.md per slug and sync to cursor/claude/codex roots. */
const fs = require('fs');
const path = require('path');

const home = process.env.USERPROFILE || process.env.HOME;
const roots = [
  path.join(home, '.cursor', 'skills'),
  path.join(home, '.claude', 'skills'),
  path.join(home, '.codex', 'skills'),
];

function hasCjk(t) {
  return /[\u4e00-\u9fff]/.test(t);
}
function isMojibake(t) {
  if (!t) return false;
  return /[鈥鈫鈹閫浠瀹鍓娴姝ラ]/u.test(t) || (/\?/.test(t) && hasCjk(t));
}
function h1(content) {
  const body = content.replace(/^---[\s\S]*?---\s*/, '');
  return (body.match(/^#\s+(.+)$/m) || [])[1]?.trim() || '';
}
function score(content) {
  const title = h1(content);
  let s = content.length;
  if (title && hasCjk(title) && !isMojibake(title)) s += 2000;
  if (isMojibake(title)) s -= 3000;
  if (isMojibake(content.slice(0, 500))) s -= 500;
  return s;
}

const dryRun = process.argv.includes('--dry-run');
const slugs = new Map();

for (const root of roots) {
  if (!fs.existsSync(root)) continue;
  for (const name of fs.readdirSync(root)) {
    const file = path.join(root, name, 'SKILL.md');
    if (!fs.existsSync(file)) continue;
    const content = fs.readFileSync(file, 'utf8');
    const sc = score(content);
    const prev = slugs.get(name);
    if (!prev || sc > prev.score) slugs.set(name, { content, score, path: file });
  }
}

let synced = 0;
for (const [slug, best] of slugs) {
  for (const root of roots) {
    const dir = path.join(root, slug);
    const file = path.join(dir, 'SKILL.md');
    if (!fs.existsSync(file)) continue;
    const cur = fs.readFileSync(file, 'utf8');
    if (cur === best.content) continue;
    const curScore = score(cur);
    if (curScore >= best.score) continue;
    if (dryRun) {
      console.log(`[dry-run] sync ${slug} -> ${file}`);
    } else {
      fs.writeFileSync(file, best.content, 'utf8');
      console.log(`sync ${slug} -> ${file}`);
    }
    synced++;
  }
}
console.log(`repair-skills-encoding done. synced=${synced} slugs=${slugs.size}`);
