#!/usr/bin/env node
'use strict';
const fs = require('fs');
const path = require('path');

const localePath = path.join(process.env.USERPROFILE, '.ai-workspace', 'skills-locale-zh.json');
const raw = JSON.parse(fs.readFileSync(localePath, 'utf8'));

const manual = {
  'bruce-pptx-generator': {
    label_zh: 'Bruce PPTX 代码生成',
    summary_zh: '用 pptxgenjs 从零生成或编辑可编辑 PPTX，含多种商务风格预设。',
    picker_zh: '代码生成可编辑 PPTX：封面/目录/章节/内容页，支持编辑现有模板',
    triggers_zh: ['做PPT', '生成PPT', 'pptx', '幻灯片', '演示文稿', '路演', '可编辑pptx', 'bruce-pptx-generator'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
  'guizang-ppt-skill': {
    label_zh: '归藏 · 网页杂志风 PPT',
    summary_zh: '单文件 HTML 横向翻页幻灯（杂志风/瑞士国际主义风）。',
    picker_zh: '网页横向翻页 PPT：WebGL 背景、章节幕封、杂志/瑞士两种风格',
    triggers_zh: ['网页PPT', '杂志风', '瑞士风', '横向翻页', 'HTML幻灯', 'guizang-ppt-skill'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
  'html-slide-to-pptx': {
    label_zh: 'HTML 幻灯转 PPTX',
    summary_zh: 'HTML 幻灯片导出为可编辑 PPTX（dom-to-pptx 主路径，截图兜底）。',
    picker_zh: 'HTML 幻灯 → 可编辑 PowerPoint；浏览器一键导出',
    triggers_zh: ['html转ppt', 'HTML转PPTX', 'dom-to-pptx', '网页幻灯', '做一版ppt'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
  revealjs: {
    label_zh: 'Reveal.js 演示',
    summary_zh: '生成 reveal.js HTML 演示：主题、多栏、图表、演讲者备注。',
    picker_zh: 'Reveal.js 专业 HTML 幻灯片，浏览器直接播放',
    triggers_zh: ['reveal.js', 'revealjs', 'HTML演示', 'presentation', 'deck', 'slideshow'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
  'huashu-design': {
    label_zh: '花叔 Design',
    summary_zh: 'HTML 高保真原型/幻灯片/动画 + 五维设计评审，可导出 MP4/GIF。',
    picker_zh: '用 HTML 做原型、幻灯、动画与设计评审（花叔风格）',
    triggers_zh: ['花叔', '高保真原型', '设计风格', '设计评审', '导出MP4', 'UI mockup', 'huashu-design'],
    category_zh: '设计与原型',
    auto_generated: false,
  },
  'ppt-master': {
    label_zh: 'PPT Master 原生生成',
    summary_zh: '从文档/Markdown/URL 生成可编辑原生 PowerPoint，支持模板与旁白。',
    picker_zh: '文档/MD → 原生可编辑 PPTX（非纯图片幻灯）',
    triggers_zh: ['做PPT', 'markdown转PPT', '可编辑PPT', '原生PPT', 'ppt-master'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
  'frontend-slides': {
    label_zh: 'Frontend Slides',
    summary_zh: '零依赖 HTML 幻灯片（View Transitions / 滚动叙事 / 可选 PPTX 导出）。',
    picker_zh: '现代 HTML 幻灯片：零依赖、View Transitions、可导出 PPTX',
    triggers_zh: ['HTML幻灯', '网页演示', 'frontend-slides', 'View Transitions'],
    category_zh: '演示与幻灯片',
    auto_generated: false,
  },
};

for (const [key, entry] of Object.entries(manual)) {
  raw.skills[key] = { ...(raw.skills[key] || {}), ...entry };
}

fs.writeFileSync(localePath, JSON.stringify(raw, null, 2) + '\n', 'utf8');
console.log('Upserted locale entries:', Object.keys(manual).join(', '));
