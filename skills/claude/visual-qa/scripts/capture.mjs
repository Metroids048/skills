import { chromium } from '../runtime/node_modules/playwright-core/index.mjs';
import fs from 'node:fs';
const url = process.argv[2];
const out = process.argv[3] || 'visual-qa-evidence';
if (!url) throw new Error('Usage: node capture.mjs <url> [output-dir]');
fs.mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
for (const [name, viewport] of [['desktop',{width:1440,height:900}],['mobile',{width:390,height:844}]]) {
  const page = await browser.newPage({ viewport });
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.screenshot({ path: `${out}/${name}.png`, fullPage: true });
  await page.close();
}
await browser.close();
console.log('VISUAL_QA_SCREENSHOTS=PASS');
