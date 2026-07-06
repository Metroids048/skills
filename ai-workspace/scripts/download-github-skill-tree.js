#!/usr/bin/env node
'use strict';
const fs = require('fs');
const path = require('path');
const https = require('https');

const home = process.env.USERPROFILE || process.env.HOME;
const vendor = path.join(home, '.ai-workspace', 'vendor');

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'skills-installer' } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return get(res.headers.location).then(resolve, reject);
      }
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => {
        const buf = Buffer.concat(chunks);
        if (res.statusCode !== 200) {
          reject(new Error(`${url} -> ${res.statusCode}`));
          return;
        }
        resolve(buf);
      });
    }).on('error', reject);
  });
}

async function fetchJson(url) {
  const buf = await get(url);
  return JSON.parse(buf.toString('utf8'));
}

async function downloadTree(apiUrl, destDir, opts = {}) {
  const skipDirs = opts.skipDirs || new Set();
  const skipExt = opts.skipExt || new Set();
  const entries = await fetchJson(apiUrl);
  if (!Array.isArray(entries)) throw new Error(`Not a directory: ${apiUrl}`);
  for (const entry of entries) {
    if (entry.type === 'dir' && skipDirs.has(entry.name)) {
      console.log('skip dir', entry.path);
      continue;
    }
    const ext = path.extname(entry.name).toLowerCase();
    if (entry.type === 'file' && skipExt.has(ext)) {
      console.log('skip file', entry.path);
      continue;
    }
    const target = path.join(destDir, entry.name);
    if (entry.type === 'file') {
      fs.mkdirSync(path.dirname(target), { recursive: true });
      const data = await get(entry.download_url);
      fs.writeFileSync(target, data);
      console.log('file', entry.path);
    } else if (entry.type === 'dir') {
      fs.mkdirSync(target, { recursive: true });
      await downloadTree(entry.url, target, opts);
    }
  }
}

async function main() {
  const jobs = [
    {
      name: 'ppt-master',
      api: 'https://api.github.com/repos/hugohe3/ppt-master/contents/skills/ppt-master?ref=main',
      dest: path.join(vendor, 'ppt-master', 'skills', 'ppt-master'),
    },
    {
      name: 'huashu-design',
      api: 'https://api.github.com/repos/alchaincyf/huashu-design/contents/?ref=master',
      dest: path.join(vendor, 'huashu-design'),
      shallow: true,
    },
  ];

  const treeOpts = {
    skipDirs: new Set(['ai-image-comparison']),
    skipExt: new Set(['.png', '.jpg', '.jpeg', '.gif', '.webp', '.mp4', '.zip']),
  };

  for (const job of jobs) {
    console.log(`\n=== ${job.name} ===`);
    fs.mkdirSync(job.dest, { recursive: true });
    const entries = await fetchJson(job.api);
    for (const entry of entries) {
      if (job.shallow) {
        const skipDirs = new Set(['examples', 'demos', 'assets', 'gallery', 'showcase', '.github', 'output', 'dist', 'node_modules']);
        if (entry.type === 'dir' && skipDirs.has(entry.name)) {
          console.log('skip dir', entry.name);
          continue;
        }
      }
      const target = path.join(job.dest, entry.name);
      if (entry.type === 'file') {
        const data = await get(entry.download_url);
        fs.writeFileSync(target, data);
        console.log('file', entry.path);
      } else if (entry.type === 'dir') {
        fs.mkdirSync(target, { recursive: true });
        await downloadTree(entry.url, target, job.name === 'ppt-master' ? treeOpts : { skipExt: treeOpts.skipExt });
      }
    }
    const skillMd = path.join(job.dest, 'SKILL.md');
    console.log(`${job.name} SKILL.md: ${fs.existsSync(skillMd)}`);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
