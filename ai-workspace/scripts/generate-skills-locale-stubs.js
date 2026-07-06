#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const home = process.env.USERPROFILE || process.env.HOME;
const localePath = path.join(home, '.ai-workspace', 'skills-locale-zh.json');
const syncConfigPath = path.join(home, '.ai-workspace', 'scripts', 'skills-sync.config.json');
const skillRoots = [
  path.join(home, '.cursor', 'skills'),
  path.join(home, '.claude', 'skills'),
  path.join(home, '.codex', 'skills'),
];

const PART_ZH = {
  ab: 'AB', accessibility: '无障碍', academic: '学术', act: '法案', agent: 'Agent',
  agentic: 'Agentic', ai: 'AI', analysis: '分析', analytics: '分析', and: '与',
  api: 'API', app: '应用', architect: '架构', architecture: '架构', art: '艺术',
  audit: '审计', auth: '认证', automation: '自动化', awesome: 'Awesome', backend: '后端',
  banner: 'Banner', before: '前', brainstorming: '脑暴', brief: 'Brief', browser: '浏览器',
  build: '构建', bundle: '打包', canvas: 'Canvas', check: '检查', ci: 'CI',
  claude: 'Claude', clean: '清理', code: '代码', coding: '编码', commit: '提交',
  common: '通用', completion: '完成', config: '配置', configure: '配置', content: '内容',
  context: '上下文', continuous: '持续', convert: '转换', copilot: 'Copilot', core: '核心',
  create: '创建', creating: '创建', cursor: 'Cursor', customer: '客户', council: '合议',
  data: '数据', database: '数据库', debugging: '调试', deep: '深度', delivery: '交付',
  deploy: '部署', design: '设计', designing: '设计', devops: 'DevOps', diagnose: '诊断',
  doc: '文档', docs: '文档', document: '文档', documentation: '文档', e2e: 'E2E', ecc: 'ECC',
  edit: '编辑', end: '端', engine: '引擎', engineering: '工程', error: '错误',
  eval: '评估', everything: 'Everything', experiment: '实验', expert: '专家', expertise: '经验',
  extractor: '提取', feature: '功能', figma: 'Figma', file: '文件', files: '文件', fix: '修复',
  flow: '流程', for: '', format: '格式', frontend: '前端', gate: '门禁', gdpr: 'GDPR',
  generate: '生成', generator: '生成', git: 'Git', global: '全局', go: 'Go', graph: '图谱',
  growth: '增长', guide: '指南', guidelines: '准则', handoff: '交接', healthcare: '医疗',
  high: '高', history: '历史', hook: 'Hook', hooks: 'Hooks', html: 'HTML', image: '图片',
  implement: '实现', incremental: '增量', install: '安装', installer: '安装器', integrity: '完整性',
  interface: '接口', introspection: '内省', investor: '投资人', java: 'Java', javascript: 'JavaScript',
  journey: '旅程', json: 'JSON', karpathy: 'Karpathy', kit: '套件', kotlin: 'Kotlin', launch: '发布',
  learning: '学习', library: '库', lint: 'Lint', llm: 'LLM', loop: '循环', lookup: '查询',
  map: '地图', mapping: '映射', market: '市场', marketing: '营销', mcp: 'MCP', memory: '记忆',
  migrate: '迁移', migration: '迁移', minimalist: '极简', mobile: '移动', model: '模型',
  module: '模块', monitor: '监控', network: '网络', nextjs: 'Next.js', node: 'Node',
  observability: '可观测', of: '', ok: 'OK', one: '一', open: '开源', or: '或',
  ouro: 'Ouro', paper: '论文', parallel: '并行', patterns: '模式', performance: '性能',
  pipeline: '流水线', plan: '计划', planner: '规划', planning: '规划', platform: '平台',
  plugin: '插件', pm: 'PM', ppt: 'PPT', prd: 'PRD', pre: '预', presenton: 'Presenton',
  preview: '预览', production: '生产', profile: '画像', programming: '编程', project: '项目',
  prompt: 'Prompt', prompting: '提示词', prompts: 'Prompt', proto: '原型', prototype: '原型',
  python: 'Python', qa: 'QA', quality: '质量', query: '查询', react: 'React', readiness: '就绪',
  recall: '回忆', recap: '回顾', refactor: '重构', reference: '参考', regression: '回归',
  remember: '记住', report: '报告', research: '研究', review: '审查', reviewer: '审稿',
  rezvani: 'Rezvani', router: '路由', routing: '路由', rule: '规则', rules: '规则', run: '运行',
  rust: 'Rust', scan: '扫描', schema: 'Schema', scaffold: '脚手架', script: '脚本',
  search: '搜索', security: '安全', seo: 'SEO', server: '服务端', session: '会话', setup: '设置',
  shell: 'Shell', shipping: '交付', skill: 'Skill', skills: 'Skills', slides: '幻灯片', soc2: 'SOC2',
  source: '源码', spec: '规格', split: '拆分', sql: 'SQL', stocktake: '盘点', strategy: '策略',
  style: '风格', superpowers: 'Superpowers', swift: 'Swift', sync: '同步', systematic: '系统化',
  tactus: 'Tactus', task: '任务', tdd: 'TDD', tech: '技术', technical: '技术', template: '模板',
  test: '测试', testing: '测试', the: '', to: '', tool: '工具', tour: '导览', triage: '分诊',
  typescript: 'TypeScript', ui: 'UI', understand: '理解', update: '更新', url: 'URL', use: '使用',
  using: '使用', ux: 'UX', verification: '验证', verify: '验证', verifier: '审计', visual: '视觉',
  vibe: 'Vibe', web: 'Web', with: '', workflow: '工作流', writing: '编写', zero: '0', zh: '中文',
  deprecation: '弃用', deprecated: '已弃用', instinct: '直觉', ambiguous: '模糊', decision: '决策',
  tradeoff: '权衡', interactive: '交互式', installer: '安装向导', standards: '标准', structure: '结构',
  engineering: '工程', progressive: '渐进式', discovery: '发现', loading: '加载', end: '端',
  to: '到', end: '端', map: '地图', touchpoint: '触点', onboarding: ' onboarding',
};

const PHRASE_ZH = [
  [/Use when (.+?)(?:\.|$)/gi, '适用于：$1'],
  [/Use for (.+?)(?:\.|$)/gi, '用于：$1'],
  [/Triggers on[:\s]*(.+?)(?:\.|$)/gi, '触发：$1'],
  [/Triggers[:\s]*(.+?)(?:\.|$)/gi, '触发：$1'],
  [/NOT when[:\s]*(.+?)(?:\.|$)/gi, '不适用于：$1'],
  [/Do NOT use when[:\s]*(.+?)(?:\.|$)/gi, '不适用于：$1'],
  [/Before (.+?)(?:\.|$)/gi, '在$1之前使用'],
  [/After (.+?)(?:\.|$)/gi, '在$1之后使用'],
  [/Interactive installer for (.+?)(?:\.|$)/gi, '交互式安装 $1'],
  [/Guides (.+?) through (.+?)(?:\.|$)/gi, '引导 $1 完成 $2'],
  [/Convene (.+?) for (.+?)(?:\.|$)/gi, '召集 $1 处理 $2'],
  [/Orchestrat(?:e|or) for (.+?)(?:\.|$)/gi, '编排 $1 全流程'],
  [/Create (?:an? )?(.+?)(?:\.|$)/gi, '创建 $1'],
  [/Generate (?:an? )?(.+?)(?:\.|$)/gi, '生成 $1'],
  [/Analyze (.+?)(?:\.|$)/gi, '分析 $1'],
  [/Design (.+?)(?:\.|$)/gi, '设计 $1'],
  [/Review (.+?)(?:\.|$)/gi, '审查 $1'],
  [/Debug (.+?)(?:\.|$)/gi, '调试 $1'],
  [/Manage[sd]? (.+?)(?:\.|$)/gi, '管理 $1'],
  [/Map (.+?)(?:\.|$)/gi, '绘制/映射 $1'],
];

const TITLE_OVERRIDES = {
  'configure-ecc': 'ECC 配置安装',
  'context-engineering': '上下文工程',
  'council': '四视角合议决策',
  'customer-journey-map': '客户旅程地图',
  'continuous-learning': '持续学习（旧版）',
  'continuous-learning-v2': '持续学习 V2',
  'commit-context': '提交上下文',
  'figma2code': 'Figma 转前端代码',
  'figma-workflow': 'Figma 工作流',
  'executing-plans': '执行实施计划',
  'error-handling': '错误处理模式',
  'eval-harness': '评估测试框架',
  'awesome-ai-ppt': 'AI PPT 工具选型',
  'bruce-pptx-generator': 'Bruce PPTX 代码生成',
  'guizang-ppt-skill': '归藏 · 网页杂志风 PPT',
  'html-slide-to-pptx': 'HTML 幻灯转 PPTX',
  'revealjs': 'Reveal.js 演示',
  'huashu-design': '花叔 Design',
  'ppt-master': 'PPT Master 原生生成',
  'frontend-slides': 'Frontend Slides',
  'full-output-enforcement': '完整输出约束',
  'git-advanced': 'Git 进阶操作',
  'forget': '遗忘清理',
  'finishing-a-development-branch': '开发分支收尾',
  'authentication-patterns': '认证模式',
  'aws-cloud-patterns': 'AWS 云模式',
  'beachhead-segment': '滩头细分市场',
};

/** 按英文描述模式生成纯中文一句话摘要（picker 副标题） */
const PURPOSE_PATTERNS = [
  { test: /robust error handling|error boundaries|typed errors|circuit breaker|user-facing error/i, zh: '生产级错误处理：类型化错误、重试、熔断与用户可见提示' },
  { test: /eval harness|evaluation framework|quality gate.*eval/i, zh: '正式评估框架：用例集、评分与回归门禁' },
  { test: /written implementation plan to execute|executing plans|review checkpoints/i, zh: '按已写好的实施计划分步执行，并在检查点复盘' },
  { test: /interactive installer|installation wizard|configure ecc/i, zh: '交互式安装向导：选择并安装技能/规则，校验路径并可优化已装内容' },
  { test: /context engineering|prompt structure standards|signal-to-noise/i, zh: 'Agent 上下文工程与 Prompt 结构标准：信噪比、渐进发现、按需加载' },
  { test: /four-voice council|convene.*council|ambiguous decisions|go\/no-go/i, zh: '四视角顾问合议：处理模糊决策、方案权衡与 go/no-go 判断' },
  { test: /customer journey map|end-to-end customer journey|touchpoints|pain points/i, zh: '绘制端到端客户旅程：阶段、触点、情绪、痛点与改进机会' },
  { test: /instinct-based learning|continuous learning|observes sessions via hooks/i, zh: '通过 Hook 观察会话，沉淀可复用直觉/技能模式' },
  { test: /deprecation|migration|legacy.*deprecated/i, zh: '管理功能/API 弃用与迁移：兼容期、替换方案与变更说明' },
  { test: /academic paper writing|write paper|manuscript/i, zh: '学术论文写作流水线：大纲、修订、引用、格式与质量检查' },
  { test: /peer review|manuscript review|referee report/i, zh: '模拟多视角学术审稿，输出审稿意见与修订建议' },
  { test: /research pipeline|research -> write|end-to-end paper/i, zh: '编排研究→写作→审查→修订的完整论文工作流' },
  { test: /api and interface|rest or graphql|module boundaries/i, zh: '设计稳定 API/GraphQL 与模块公共契约、前后端边界' },
  { test: /product requirements document|\bprd\b/i, zh: '把模糊产品想法整理为可评审的产品需求文档（PRD）' },
  { test: /systematic debugging|root cause|before proposing fixes/i, zh: '系统化排错：先复现与定位根因，再提出修复方案' },
  { test: /test-driven|tdd workflow|write tests first/i, zh: '测试驱动开发：先写测试再实现，覆盖单元/集成/E2E' },
  { test: /figma\.config|sync html to figma|agent platform figma/i, zh: 'Agent Platform Figma 双向同步：按 figma.config 实现页面并写回设计' },
  { test: /implementing html.*figma|figma url|file key|mockup|frame extraction|figma2code/i, zh: '按 Figma 设计稿实现 HTML/CSS/JS，含节点提取与交互' },
  { test: /ai presentation tools|compare.*presentation|awesome-ai-ppt|choose ai ppt|ppt tools/i, zh: '对比推荐 AI 演示/PPT 工具与使用场景' },
  { test: /pptx|powerpoint|presentation|slides/i, zh: '演示文稿处理：创建/编辑 PPT 或 HTML 幻灯片' },
  { test: /security review|vulnerability|owasp/i, zh: '安全审查：注入、密钥泄露、SSRF 等风险检测与修复建议' },
  { test: /code review|review.*changes|pull request/i, zh: '代码审查：质量、模式、安全与可维护性检查' },
  { test: /performance|bundle size|core web vitals|slow page/i, zh: '性能分析与优化：瓶颈定位、包体与运行时改进' },
  { test: /accessibility|wcag|aria|screen reader/i, zh: '无障碍合规（WCAG）：ARIA、键盘导航与读屏适配' },
  { test: /e2e test|playwright|end-to-end/i, zh: '端到端测试：关键用户路径自动化与回归验证' },
  { test: /brainstorm|design.*before.*code|creative implementation/i, zh: '编码前脑暴：澄清需求、探索方案并确认设计' },
  { test: /writing plan|implementation plan|multi-step task/i, zh: '编写可执行实施计划：步骤拆分与验证顺序' },
  { test: /zero-to-one|greenfield|new module|new page/i, zh: '0→1 新模块门禁：先架构/方案确认，再写实现' },
  { test: /requirement clarif|fuzzy.*input|mini-spec/i, zh: '模糊需求澄清：整理 Mini-Spec 与可执行 Prompt' },
  { test: /verification before completion|claim done|fresh evidence/i, zh: '完成前验证：重读验收标准并附 fresh 命令输出' },
  { test: /deep research|multi-source|citations|fact-check/i, zh: '多源深度研究：检索、引用与事实核查' },
  { test: /seo|search engine|keyword|meta tag/i, zh: 'SEO 优化：技术审计、页面元数据与结构化数据' },
  { test: /git workflow|conventional commit|pull request process/i, zh: 'Git 工作流：分支、提交规范与 PR 流程' },
  { test: /docker|kubernetes|deploy|devops/i, zh: 'DevOps/部署：容器、流水线与环境配置' },
  { test: /database|sql|query optim|postgresql/i, zh: '数据库/SQL： schema 设计、查询优化与迁移' },
  { test: /react|vue|frontend|component/i, zh: '前端工程：组件、状态、构建与 UI 实现' },
  { test: /spring boot|java|backend api/i, zh: '后端/Java：API、分层架构与持久化' },
  { test: /python|django|fastapi/i, zh: 'Python 后端：框架、ORM、迁移与 API 设计' },
  { test: /rust|cargo|borrow checker/i, zh: 'Rust 工程：编译、所有权与 idiomatic 模式' },
  { test: /marketing|landing page|campaign|copywriting/i, zh: '营销/文案：落地页、活动与转化文案' },
  { test: /investor|pitch deck|fundraising/i, zh: '融资/投资人材料：路演叙事与数据呈现' },
  { test: /hook|pre-commit|automation script/i, zh: 'Hook/自动化：提交前检查与 Agent 工作流钩子' },
  { test: /skill.*skill\.md|creating.*skills|agent skills/i, zh: 'Skill 工程：编写/验证 SKILL.md 与触发条件设计' },
  { test: /mcp server|model context protocol/i, zh: 'MCP 服务：工具协议、集成模式与调试' },
  { test: /orchestrat|multi-agent|subagent/i, zh: '多 Agent 编排：子任务分发、汇总与验证闭环' },
  { test: /diagnos|reproduction steps|structured reproduction/i, zh: '结构化诊断：复现步骤、证据收集与问题定位' },
  { test: /refactor|dead code|cleanup|consolidat/i, zh: '重构/清理：去重、删死代码与结构收敛' },
  { test: /documentation|adr|architecture decision/i, zh: '文档/ADR：架构决策记录与技术说明撰写' },
  { test: /compliance|gdpr|soc2|ai act/i, zh: '合规审计：GDPR/SOC2/AI Act 等检查清单' },
  { test: /analytics|ab test|experiment|significance/i, zh: '实验/分析：A/B 测试解读与统计显著性判断' },
  { test: /workflow gate|plan mode|tier a|tier b/i, zh: '工作流门禁：澄清→设计→实现→验证的分阶段约束' },
  { test: /memory handoff|resume session|where were we/i, zh: '会话交接：恢复上下文、进度与未完成任务' },
  { test: /image to code|screenshot.*implement|visual fidelity/i, zh: '按截图/参考图实现界面，逐段还原视觉' },
  { test: /algorithmic art|generative art|p5\.js/i, zh: '算法/generative 艺术：p5.js 交互参数与随机种子' },
  { test: /network|routing|dns|connectivity/i, zh: '网络诊断：连通性、路由、DNS 与分层排查' },
  { test: /healthcare|clinical|emr|phi/i, zh: '医疗信息系统：临床安全、CDSS 与 PHI 合规' },
];

const SCENARIO_KW = [
  ['prompt engineering', 'Prompt 设计'], ['context engineering', '上下文工程'], ['agent configuration', 'Agent 配置'],
  ['designing new api', '新 API 设计'], ['test fail', '测试失败'], ['bug', '缺陷排查'], ['performance issue', '性能问题'],
  ['pull request', 'PR 审查'], ['security', '安全审计'], ['deploy', '部署发布'], ['refactor', '重构'],
  ['customer experience', '客户体验'], ['onboarding', '新手引导优化'], ['friction', '体验摩擦点'],
  ['mapping the customer', '客户旅程梳理'], ['ambiguous', '方案不确定'], ['tradeoff', '权衡对比'],
  ['write paper', '写论文'], ['peer review', '论文审稿'], ['literature', '文献调研'],
  ['figma', 'Figma 还原'], ['landing page', '落地页'], ['redesign', '站点改版'],
  ['write prd', '写 PRD'], ['需求文档', '需求文档'], ['planning', '规划拆解'],
  ['prototype', '原型验收'], ['verify-all', '原型验证'], ['e2e', 'E2E 测试'],
  ['ppt', '做 PPT'], ['slides', '幻灯片'], ['presentation', '演示文稿'],
  ['sql', 'SQL 查询'], ['database', '数据库'], ['migration', '数据迁移'],
  ['marketing', '营销文案'], ['seo', 'SEO'], ['accessibility', '无障碍'],
  ['install', '安装配置'], ['skill', '技能管理'], ['rule', '规则配置'],
];

function readFrontmatterField(content, field) {
  const m = content.match(/^---\s*\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return '';
  const yaml = m[1];
  const re = new RegExp(`^${field}:\\s*(?:['"](.+?)['"]|(.+))\\s*$`, 'm');
  const fm = yaml.match(re);
  if (!fm) return '';
  return (fm[1] || fm[2] || '').trim().replace(/^["']|["']$/g, '');
}

function getBody(content) {
  return content.replace(/^---[\s\S]*?---\s*/, '');
}

function englishDescription(desc) {
  if (!desc) return '';
  const stripped = desc.replace(/^\[[^\]]+\]\s*/, '');
  const m = stripped.match(/\bEN:\s*(.+)$/s);
  return (m ? m[1] : stripped.replace(/\s*Triggers:[^.]+\.\s*/i, ' ')).trim();
}

function hasCjk(text) {
  return /[\u4e00-\u9fff]/.test(text);
}

function isMojibake(text) {
  if (!text) return false;
  return /[鈥鈫鈹閫浠瀹鍓娴姝ラ]/u.test(text) || (/\?/.test(text) && hasCjk(text));
}

function labelFromBody(content) {
  const body = getBody(content);
  const h1 = (body.match(/^#\s+(.+)$/m) || [])[1]?.trim() || '';
  if (!h1 || isMojibake(h1)) return '';
  if (hasCjk(h1)) return clip(h1, 36);
  return '';
}

function clipPicker(summary, labelZh, intel) {
  if (!summary) summary = '';
  let t = summary
    .replace(/^\[[^\]]+\]\s*/, '')
    .replace(/\s*Triggers:.*$/i, '')
    .replace(/\s*EN:.*$/s, '')
    .replace(/\s*NOT when:.*$/i, '')
    .trim();
  const parts = t.split(/[。！？；]/).map((p) => p.trim()).filter((p) => p && hasCjk(p));
  t = parts[0] || t;
  if (!t || !hasCjk(t) || isMostlyAscii(t)) {
    const p = matchPurpose(intel);
    if (p) t = p.split(/[。！？；]/)[0];
    else t = `${labelZh}`;
  }
  if (t.length > 72) return t.slice(0, 71) + '...';
  return t;
}

function isMostlyAscii(text) {
  if (!text) return true;
  const cjk = (text.match(/[\u4e00-\u9fff]/g) || []).length;
  return cjk / text.length < 0.25;
}

function slugToLabel(slug) {
  const words = slug.split('-').map((part) => {
    const key = part.toLowerCase();
    if (Object.prototype.hasOwnProperty.call(PART_ZH, key)) return PART_ZH[key];
    return part.charAt(0).toUpperCase() + part.slice(1);
  }).filter(Boolean);
  return words.length ? words.join(' ') : slug;
}

function translateWords(text) {
  let out = text;
  const sorted = Object.keys(PART_ZH).sort((a, b) => b.length - a.length);
  for (const word of sorted) {
    if (!PART_ZH[word]) continue;
    const re = new RegExp(`\\b${word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'gi');
    out = out.replace(re, PART_ZH[word]);
  }
  return out;
}

function translateEnLine(en) {
  if (!en) return '';
  let text = en.replace(/\s+/g, ' ').trim();
  for (const [re, repl] of PHRASE_ZH) {
    text = text.replace(re, repl);
  }
  text = translateWords(text);
  text = text
    .replace(/\bwhen\b/gi, '当')
    .replace(/\band\b/gi, '且')
    .replace(/\bor\b/gi, '或')
    .replace(/\bwith\b/gi, '与')
    .replace(/\bfor\b/gi, '用于')
    .replace(/\bthe\b/gi, '')
    .replace(/\s{2,}/g, ' ')
    .trim();
  return text;
}

function clip(text, max = 160) {
  if (!text) return '';
  const t = text.replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  return t.slice(0, max - 3) + '...';
}

function extractIntel(content) {
  const fmDesc = readFrontmatterField(content, 'description');
  const enDesc = englishDescription(fmDesc);
  const body = getBody(content);
  const h1 = (body.match(/^#\s+(.+)$/m) || [])[1]?.trim() || '';
  const h2 = (body.match(/^##\s+(.+)$/m) || [])[1]?.trim() || '';
  const whenBlock = (body.match(/## When to (?:Use|Activate)[^\n]*\n([\s\S]*?)(?=\n## |\n# |$)/i) || [])[1] || '';
  const overviewBlock = (body.match(/## Overview\n([\s\S]*?)(?=\n## |\n# |$)/i) || [])[1] || '';
  const bullets = [...whenBlock.matchAll(/^[-*]\s+(.+)$/gm)].map((m) => m[1].trim()).filter(Boolean);
  const paras = body
    .split(/\n\n+/)
    .map((p) => p.trim())
    .filter((p) => p && !p.startsWith('#') && !p.startsWith('```') && p.length > 20);
  const firstPara = paras[0] || '';
  const overviewPara = overviewBlock.split(/\n\n+/).map((p) => p.trim()).find(Boolean) || '';

  let enCore = enDesc || overviewPara || firstPara || bullets.join('. ');
  enCore = enCore.replace(/^\[[^\]]+\]\s*/, '').trim();
  const useWhen = [...enCore.matchAll(/\bUse when (.+?)(?:\.|;|$)/gi)].map((m) => m[1].trim());
  const triggersEn = (enDesc.match(/Triggers[:\s]*(.+?)(?:\.|$)/i) || [])[1] || '';

  return { fmDesc, enDesc, h1, h2, bullets, firstPara, overviewPara, enCore, useWhen, triggersEn };
}

function buildLabel(slug, content, intel, existing) {
  if (existing?.label_zh && existing.manual && !isMojibake(existing.label_zh) && !isMostlyAscii(existing.label_zh)) {
    return existing.label_zh;
  }
  if (TITLE_OVERRIDES[slug]) return TITLE_OVERRIDES[slug];
  const fromBody = labelFromBody(content);
  if (fromBody) return fromBody;
  if (existing?.label_zh && !isMojibake(existing.label_zh) && !isMostlyAscii(existing.label_zh)) {
    return existing.label_zh;
  }
  if (intel.h1 && hasCjk(intel.h1) && !isMojibake(intel.h1)) return clip(intel.h1, 36);
  const purpose = matchPurpose(intel);
  if (purpose) return clip(purpose.split(/[：:]/)[0], 36);
  const fromSlug = slugToLabel(slug);
  const slugZh = translateEnLine(fromSlug);
  if (!isMostlyAscii(slugZh) && !isMojibake(slugZh)) return slugZh;
  return TITLE_OVERRIDES[slug] || clip(fromSlug, 36);
}

function matchPurpose(intel) {
  const blob = `${intel.enCore} ${intel.h1} ${intel.firstPara} ${intel.overviewPara}`.toLowerCase();
  for (const p of PURPOSE_PATTERNS) {
    if (p.test.test(blob)) return p.zh;
  }
  return null;
}

function scenarioFromText(text) {
  if (!text) return '';
  const lower = text.toLowerCase();
  const hits = [];
  for (const [kw, zh] of SCENARIO_KW) {
    if (lower.includes(kw) && !hits.includes(zh)) hits.push(zh);
  }
  if (hits.length) return hits.slice(0, 2).join('、');
  if (hasCjk(text)) return clip(text, 24);
  return '';
}

function buildScenarios(intel) {
  const out = [];
  for (const uw of intel.useWhen.slice(0, 2)) {
    const s = scenarioFromText(uw);
    if (s) out.push(s);
  }
  for (const b of intel.bullets.slice(0, 3)) {
    const s = scenarioFromText(b);
    if (s && !out.includes(s)) out.push(s);
  }
  return [...new Set(out)].slice(0, 3);
}

function buildSummary(slug, intel, labelZh, descOverride) {
  const purpose = matchPurpose(intel);
  const scenarios = buildScenarios(intel);

  if (descOverride && hasCjk(descOverride)) {
    const clean = descOverride.replace(/\s*NOT when:.*$/i, '').replace(/\s*Triggers:.*$/i, '').trim();
    return clip(clean, 180);
  }

  if (purpose) {
    let out = purpose;
    if (scenarios.length) out += `。适用于${scenarios.join('、')}`;
    return clip(out, 180);
  }

  if (intel.enDesc && !hasCjk(intel.enDesc)) {
    const kw = scenarioFromText(intel.enDesc);
    if (kw) return clip(`${labelZh}：适用于${kw}等场景`, 180);
  }

  if (scenarios.length) {
    return clip(`${labelZh}：适用于${scenarios.join('、')}等场景`, 180);
  }

  return clip(`${labelZh}：辅助完成相关分析、生成或审查任务`, 180);
}

function buildTriggers(slug, intel, labelZh, summaryZh, keywordBoosts) {
  const set = new Set();
  if (keywordBoosts[slug]) keywordBoosts[slug].forEach((t) => set.add(t));
  if (intel.triggersEn) {
    intel.triggersEn.split(/[,，;；]/).map((t) => t.trim()).filter(Boolean).slice(0, 6).forEach((t) => set.add(t));
  }
  set.add(slug);
  if (labelZh) set.add(labelZh);
  [...summaryZh.matchAll(/[\u4e00-\u9fff]{2,8}/g)].slice(0, 8).forEach((m) => set.add(m[0]));
  buildScenarios(intel).forEach((s) => set.add(s));
  return [...set].filter(Boolean).slice(0, 12);
}

function isSkillDir(root, name) {
  try {
    const st = fs.statSync(path.join(root, name));
    return st.isDirectory() || st.isSymbolicLink();
  } catch {
    return false;
  }
}

function contentQuality(content) {
  const name = readFrontmatterField(content, 'name');
  const intel = extractIntel(content);
  let score = englishDescription(intel.fmDesc).length + content.length;
  const h1 = labelFromBody(content);
  if (h1) score += 800;
  if (isMojibake(name) || isMojibake(intel.h1)) score -= 1000;
  if (hasCjk(intel.fmDesc) && !isMojibake(intel.fmDesc)) score += 200;
  return score;
}

function collectSkills() {
  const bySlug = new Map();
  for (const root of skillRoots) {
    if (!fs.existsSync(root)) continue;
    for (const name of fs.readdirSync(root)) {
      if (!isSkillDir(root, name)) continue;
      const skillFile = path.join(root, name, 'SKILL.md');
      if (!fs.existsSync(skillFile)) continue;
      const content = fs.readFileSync(skillFile, 'utf8');
      const score = contentQuality(content);
      const prev = bySlug.get(name);
      if (!prev || score > prev.score) {
        bySlug.set(name, { content, score, path: skillFile });
      }
    }
  }
  return bySlug;
}

function shouldRefresh(slug, entry, refresh) {
  if (!entry) return true;
  if (!refresh) return false;
  if (entry.manual) return false;
  if (!entry.picker_zh) return true;
  if (entry.label_zh && (isMojibake(entry.label_zh) || isMostlyAscii(entry.label_zh))) return true;
  if (entry.summary_zh && (entry.summary_zh.includes('技能说明见正文') || /[a-zA-Z]{5,}/.test(entry.summary_zh))) return true;
  if (entry.auto_generated) return true;
  return false;
}

const dryRun = process.argv.includes('--dry-run');
const refresh = process.argv.includes('--refresh') || process.argv.includes('--force');

const descOverrides = {};
const keywordBoosts = {};
if (fs.existsSync(syncConfigPath)) {
  const cfg = JSON.parse(fs.readFileSync(syncConfigPath, 'utf8'));
  Object.assign(descOverrides, cfg.descriptionOverrides || {});
  Object.assign(keywordBoosts, cfg.promptKeywordBoosts || {});
}

const existing = {};
if (fs.existsSync(localePath)) {
  const raw = JSON.parse(fs.readFileSync(localePath, 'utf8'));
  Object.assign(existing, raw.skills || {});
}

const allSkills = collectSkills();
let added = 0;
let updated = 0;
let kept = 0;

for (const slug of [...allSkills.keys()].sort()) {
  const { content } = allSkills.get(slug);
  const intel = extractIntel(content);
  const prev = existing[slug];

  if (prev && !shouldRefresh(slug, prev, refresh)) {
    kept++;
    continue;
  }

  const labelZh = buildLabel(slug, content, intel, prev);
  const summaryZh = buildSummary(slug, intel, labelZh, descOverrides[slug]);
  const pickerZh = clipPicker(summaryZh, labelZh, intel);
  const triggersZh = buildTriggers(slug, intel, labelZh, summaryZh, keywordBoosts);

  existing[slug] = {
    label_zh: labelZh,
    summary_zh: summaryZh,
    picker_zh: pickerZh,
    en_desc: intel.enDesc || '',
    triggers_zh: triggersZh,
    category_zh: prev?.category_zh && prev.category_zh !== '库' ? prev.category_zh : '技能库',
    auto_generated: !(prev && prev.manual),
    ...(prev?.manual ? { manual: true } : {}),
  };

  if (prev) updated++;
  else added++;
}

const sortedSkills = {};
for (const key of Object.keys(existing).sort()) {
  sortedSkills[key] = existing[key];
}

const out = {
  version: 2,
  note: 'SSOT for tri-end skill Chinese metadata. Regenerate: node generate-skills-locale-stubs.js --refresh && apply-skills-locale.ps1',
  skills: sortedSkills,
};

const seeBody = Object.values(sortedSkills).filter((x) => (x.summary_zh || '').includes('技能说明见正文')).length;
const asciiLabels = Object.values(sortedSkills).filter((x) => isMostlyAscii(x.label_zh || '')).length;

if (dryRun) {
  console.log(`[dry-run] total=${Object.keys(sortedSkills).length} add=${added} update=${updated} kept=${kept} see-body=${seeBody} ascii-labels=${asciiLabels}`);
} else {
  fs.writeFileSync(localePath, JSON.stringify(out, null, 2), 'utf8');
  console.log(`Locale enrich done. total=${Object.keys(sortedSkills).length} add=${added} update=${updated} kept=${kept} see-body=${seeBody} ascii-labels=${asciiLabels}`);
}
