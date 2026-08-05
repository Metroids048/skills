import fs from 'node:fs/promises'
import path from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'
import { chromium } from 'playwright'
import { PNG } from 'pngjs'
import JSZip from 'jszip'
import * as scenarioModule from './scenarios.mjs'

const scriptDir = path.dirname(fileURLToPath(import.meta.url))
const toolDir = path.resolve(scriptDir, '..')
const projectRoot = path.resolve(toolDir, '..', '..')
const {
  captureConfig = {},
  routeInventory,
  scenarios,
  users = {},
} = scenarioModule
const artifactsDir = path.join(projectRoot, 'artifacts', 'prototype-snapshots')
const imagesDir = path.join(artifactsDir, 'images')
const authDir = path.join(toolDir, 'playwright', '.auth')
const baseURL = String(process.env.BASE_URL || 'http://127.0.0.1:1111').replace(/\/$/, '')
const minPngBytes = 24_000
const allowedResourceFailures = [/favicon\.ico/i]
const authConfig = captureConfig?.auth || {}

const roleStateFiles = Object.fromEntries(
  Object.keys(users || {}).map((roleKey) => [roleKey, path.join(authDir, `${roleKey}.json`)]),
)

function locatorFor(page, spec) {
  if (!spec) throw new Error('动作缺少 locator')
  switch (spec.by) {
    case 'role':
      return page.getByRole(spec.role, { name: spec.name, exact: spec.exact ?? true })
    case 'label':
      return page.getByLabel(spec.text, { exact: spec.exact ?? true })
    case 'text':
      return page.getByText(spec.text, { exact: spec.exact ?? true })
    case 'placeholder':
      return page.getByPlaceholder(spec.text, { exact: spec.exact ?? true })
    case 'testId':
      return page.getByTestId(spec.text)
    default:
      throw new Error(`不支持的 locator 类型：${spec.by}`)
  }
}

async function firstVisible(locator) {
  const count = await locator.count()
  for (let index = 0; index < count; index += 1) {
    const candidate = locator.nth(index)
    if (await candidate.isVisible().catch(() => false)) return candidate
  }
  return locator.first()
}

async function applyAction(page, action) {
  if (action.type === 'waitForText') {
    const target = await firstVisible(page.getByText(action.target, { exact: false }))
    await target.waitFor({ state: 'visible', timeout: action.timeout || 8_000 })
    return
  }
  const locator = await firstVisible(locatorFor(page, action.locator))
  if (action.type === 'click') {
    await locator.click({ timeout: action.timeout || 8_000 })
  } else if (action.type === 'fill') {
    await locator.fill(action.value, { timeout: action.timeout || 8_000 })
  } else if (action.type === 'scrollIntoView') {
    await locator.waitFor({ state: 'visible', timeout: action.timeout || 8_000 })
    await locator.evaluate((element) => {
      element.scrollIntoView({ behavior: 'instant', block: 'start' })
      window.scrollBy(0, -96)
    })
  } else if (action.type === 'selectOption') {
    await locator.selectOption(action.value)
  } else {
    throw new Error(`不支持的动作类型：${action.type}`)
  }
}

async function settlePage(page) {
  await page.waitForLoadState('domcontentloaded')
  await page.waitForLoadState('networkidle', { timeout: 5_000 }).catch(() => undefined)
  await page.evaluate(async () => {
    if (document.fonts?.ready) await document.fonts.ready
  })
  await page.emulateMedia({ reducedMotion: 'reduce' })
  await page.addStyleTag({
    content: `
      *, *::before, *::after {
        animation-duration: 0s !important;
        animation-delay: 0s !important;
        transition-duration: 0s !important;
        caret-color: transparent !important;
        cursor: none !important;
      }
    `,
  })
  await page.waitForTimeout(180)
}

function inspectPng(buffer) {
  const png = PNG.sync.read(buffer)
  let nearWhite = 0
  let sampled = 0
  for (let y = 0; y < png.height; y += 12) {
    for (let x = 0; x < png.width; x += 12) {
      const index = (png.width * y + x) << 2
      const r = png.data[index]
      const g = png.data[index + 1]
      const b = png.data[index + 2]
      const a = png.data[index + 3]
      if (a > 240 && r > 247 && g > 247 && b > 247) nearWhite += 1
      sampled += 1
    }
  }
  return {
    width: png.width,
    height: png.height,
    nearWhiteRatio: sampled ? Number((nearWhite / sampled).toFixed(4)) : 1,
  }
}

async function ensureServer() {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 5_000)
  try {
    const response = await fetch(`${baseURL}/`, { signal: controller.signal })
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
  } catch (error) {
    throw new Error(`原型服务不可用：${baseURL}。请先启动当前项目配置的前端开发服务。${error.message}`)
  } finally {
    clearTimeout(timeout)
  }
}

async function createAuthStates(browser) {
  await fs.mkdir(authDir, { recursive: true })
  for (const [stateName, filePath] of Object.entries(roleStateFiles)) {
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 })
    const page = await context.newPage()
    await page.goto(`${baseURL}${authConfig.loginRoute || '/'}`, { waitUntil: 'domcontentloaded' })
    if (authConfig.localStorageKey) {
      await page.evaluate(({ key, user }) => localStorage.setItem(key, JSON.stringify(user)), {
        key: authConfig.localStorageKey,
        user: users[stateName],
      })
    }
    await context.storageState({ path: filePath })
    await context.close()
  }
}

async function launchChromium() {
  try {
    return await chromium.launch({ headless: true })
  } catch (primaryError) {
    const cacheRoot = path.join(process.env.LOCALAPPDATA || '', 'ms-playwright')
    const entries = await fs.readdir(cacheRoot, { withFileTypes: true }).catch(() => [])
    const candidates = entries
      .filter((entry) => entry.isDirectory() && /^chromium-\d+$/.test(entry.name))
      .map((entry) => entry.name)
      .sort((a, b) => b.localeCompare(a, undefined, { numeric: true }))
    for (const directory of candidates) {
      for (const relative of ['chrome-win64/chrome.exe', 'chrome-win/chrome.exe']) {
        const executablePath = path.join(cacheRoot, directory, relative)
        try {
          await fs.access(executablePath)
          process.stdout.write(`BROWSER_FALLBACK ${executablePath}\n`)
          return await chromium.launch({ headless: true, executablePath })
        } catch {
          // 继续检查下一个已安装 Chromium。
        }
      }
    }
    const systemBrowsers = [
      'C:/Program Files/Google/Chrome/Application/chrome.exe',
      'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
      'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
      'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
    ]
    for (const executablePath of systemBrowsers) {
      try {
        await fs.access(executablePath)
        process.stdout.write(`BROWSER_FALLBACK ${executablePath}\n`)
        return await chromium.launch({ headless: true, executablePath })
      } catch {
        // 继续检查下一个本机浏览器。
      }
    }
    throw primaryError
  }
}

function statePathFor(roleKey) {
  return roleStateFiles[roleKey]
}

async function captureScenario(browser, scenario) {
  const context = await browser.newContext({
    viewport: scenario.viewport,
    deviceScaleFactor: 1,
    reducedMotion: 'reduce',
    storageState: statePathFor(scenario.roleKey),
  })
  const page = await context.newPage()
  const consoleErrors = []
  const pageErrors = []
  const resourceFailures = []
  const badResponses = []

  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text())
  })
  page.on('pageerror', (error) => pageErrors.push(error.message))
  page.on('requestfailed', (request) => {
    if (!allowedResourceFailures.some((pattern) => pattern.test(request.url()))) {
      resourceFailures.push(`${request.method()} ${request.url()} · ${request.failure()?.errorText || 'failed'}`)
    }
  })
  page.on('response', (response) => {
    if (response.status() >= 400 && !allowedResourceFailures.some((pattern) => pattern.test(response.url()))) {
      badResponses.push(`${response.status()} ${response.url()}`)
    }
  })

  const issues = []
  const warnings = []
  let actionError = ''
  const screenshotPath = path.join(imagesDir, scenario.screenshotName)
  let pngInfo = { width: 0, height: 0, nearWhiteRatio: 1 }
  let fileSize = 0

  try {
    const scenarioUser = users?.[scenario.roleKey]
    if (authConfig.localStorageKey && scenarioUser) {
      await page.addInitScript(({ key, user }) => {
        localStorage.setItem(key, JSON.stringify(user))
      }, {
        key: authConfig.localStorageKey,
        user: scenarioUser,
      })
    }
    await page.goto(`${baseURL}${scenario.route}`, { waitUntil: 'domcontentloaded', timeout: 20_000 })
    await settlePage(page)
    for (const action of scenario.actions) {
      try {
        await applyAction(page, action)
        await page.waitForTimeout(160)
      } catch (error) {
        actionError = `${action.type}「${action.target}」失败：${error.message}`
        break
      }
    }
    await settlePage(page)

    const expectedLocator = await firstVisible(page.getByText(scenario.waitFor, { exact: false }))
    await expectedLocator.waitFor({ state: 'visible', timeout: 8_000 }).catch((error) => {
      issues.push(`等待目标内容失败：${scenario.waitFor} · ${error.message}`)
    })

    const buffer = await page.screenshot({
      path: screenshotPath,
      type: 'png',
      fullPage: false,
      animations: 'disabled',
      caret: 'hide',
      scale: 'css',
    })
    fileSize = buffer.byteLength
    pngInfo = inspectPng(buffer)

    const bodyText = (await page.locator('body').textContent()) || ''
    for (const expected of scenario.expectedText) {
      if (!bodyText.includes(expected)) issues.push(`场景内容不一致：未找到「${expected}」`)
    }
    if (actionError) issues.push(actionError)
    if (fileSize < minPngBytes) issues.push(`PNG 文件过小：${fileSize} bytes`)
    if (pngInfo.width !== scenario.viewport.width || pngInfo.height !== scenario.viewport.height) {
      issues.push(`截图尺寸错误：${pngInfo.width}×${pngInfo.height}`)
    }
    if (pngInfo.nearWhiteRatio > 0.97) issues.push(`截图疑似空白：近白像素比 ${pngInfo.nearWhiteRatio}`)
    if (scenario.expectedOutcome !== 'error-page' && /页面不存在|系统异常/.test(bodyText)) issues.push('页面被错误页替代')
    if (scenario.route !== '/login' && page.url().includes('/login')) issues.push('页面被登录页替代')
    if (pageErrors.length) issues.push(...pageErrors.map((item) => `未捕获异常：${item}`))
    if (resourceFailures.length) issues.push(...resourceFailures.map((item) => `资源加载失败：${item}`))
    if (badResponses.length) warnings.push(...badResponses.map((item) => `HTTP 异常响应：${item}`))
    if (consoleErrors.length) warnings.push(...consoleErrors.map((item) => `控制台错误：${item}`))
  } catch (error) {
    issues.push(`截图流程异常：${error.message}`)
    try {
      const buffer = await page.screenshot({ path: screenshotPath, type: 'png', fullPage: false, animations: 'disabled', caret: 'hide', scale: 'css' })
      fileSize = buffer.byteLength
      pngInfo = inspectPng(buffer)
    } catch (screenshotError) {
      issues.push(`失败现场也无法截图：${screenshotError.message}`)
    }
  }

  const result = {
    ...scenario,
    status: issues.length ? 'failed' : 'success',
    actualUrl: page.url(),
    fileSize,
    imageWidth: pngInfo.width,
    imageHeight: pngInfo.height,
    nearWhiteRatio: pngInfo.nearWhiteRatio,
    issues,
    warnings,
    needsManualReview: warnings.length > 0 || scenario.expectedOutcome === 'error-page',
    capturedAt: new Date().toISOString(),
  }
  await context.close()
  return result
}

function markdownTable(rows, fields) {
  const head = `| ${fields.map((field) => field.label).join(' | ')} |`
  const separator = `| ${fields.map(() => '---').join(' | ')} |`
  const body = rows.map((row) => `| ${fields.map((field) => String(row[field.key] ?? '').replaceAll('|', '\\|').replaceAll('\n', '<br>')).join(' | ')} |`)
  return [head, separator, ...body].join('\n')
}

function buildInventory(manifest) {
  const mainPages = routeInventory.filter((item) => item.kind === '主页面').length
  const redirectCount = routeInventory.filter((item) => item.kind === '兼容重定向').length
  return `# 产品页面清单

> 生成时间：${new Date().toLocaleString('zh-CN')}  
> 证据来源：项目路由、导航、页面组件、权限/身份配置与 Playwright 实际运行。  
> 页面口径：${mainPages} 个主要业务页面；另含登录、错误页与 ${redirectCount} 条兼容重定向。

${markdownTable(routeInventory, [
  { key: 'route', label: '路由' },
  { key: 'page', label: '页面/去向' },
  { key: 'module', label: '模块' },
  { key: 'kind', label: '类型' },
  { key: 'roles', label: '角色' },
  { key: 'states', label: '已识别关键状态' },
])}

## 组件与状态补充

- 以 scenarios.mjs 为截图状态单一事实源；页面、状态与动作均应可追溯到真实路由和可见控件。
- 对能改变主要业务内容、打开关键弹窗/抽屉或代表独立结果的状态单独截图。
- 身份与权限覆盖范围由项目任务卡决定；不要自动扩展到敏感或无授权角色。

## 未单独截图

- 鼠标悬停、按钮按下等不改变业务信息的微状态。
- 已重定向、无可访问路由或已被合并的旧组件不作为独立页面。
- 原型未实现或依赖正式外部服务的状态不得虚构；在项目报告中写明边界。

截图场景总数：${manifest.length}。
`
}

function buildReport(manifest) {
  const success = manifest.filter((item) => item.status === 'success')
  const failed = manifest.filter((item) => item.status === 'failed')
  const roles = [...new Set(manifest.map((item) => item.role))]
  const modules = [...new Set(manifest.map((item) => item.module))]
  const failures = failed.length
    ? markdownTable(failed, [
        { key: 'id', label: '编号' },
        { key: 'screenName', label: '页面' },
        { key: 'stateName', label: '状态' },
        { key: 'route', label: '路由' },
        { key: 'issuesText', label: '失败原因' },
      ])
    : '无。'
  const rows = manifest.map((item) => ({
    ...item,
    actionsText: item.actions.length ? item.actions.map((action) => `${action.type}：${action.target}${action.value ? `=${action.value}` : ''}`).join('；') : '直接进入',
    resultText: item.status === 'success' ? '成功' : '失败',
  }))
  const failureRows = failed.map((item) => ({ ...item, issuesText: item.issues.join('；') }))

  return `# 原型截图采集报告

> 生成时间：${new Date().toLocaleString('zh-CN')}  
> 运行地址：${baseURL}  
> Chromium / 1440×900 / deviceScaleFactor 1 / PNG / 动画禁用 / 标准视口。

## 汇总

- 路由记录：${routeInventory.length}（含 ${routeInventory.filter((item) => item.kind === '兼容重定向').length} 条兼容重定向）。
- 主要业务页面：${routeInventory.filter((item) => item.kind === '主页面').length}。
- 截图场景：${manifest.length}。
- 成功截图：${success.length}。
- 失败截图：${failed.length}。
- 需人工复核：${manifest.filter((item) => item.needsManualReview).length}。
- 覆盖角色：${roles.join('、')}。
- 覆盖模块：${modules.join('、')}。

## 场景明细

${markdownTable(rows, [
  { key: 'id', label: '编号' },
  { key: 'module', label: '模块' },
  { key: 'role', label: '角色' },
  { key: 'screenName', label: '页面' },
  { key: 'stateName', label: '状态' },
  { key: 'route', label: '路由' },
  { key: 'actionsText', label: '触发方式' },
  { key: 'resultText', label: '结果' },
])}

## 失败与人工补拍

${failures === '无。' ? failures : markdownTable(failureRows, [
  { key: 'id', label: '编号' },
  { key: 'screenName', label: '页面' },
  { key: 'stateName', label: '状态' },
  { key: 'route', label: '路由' },
  { key: 'issuesText', label: '失败原因' },
])}

## 未覆盖页面与状态

- 已重定向、无可访问路由或被现行页面合并的旧组件不单独截图。
- 角色、权限、空态、错误态与外部服务状态只覆盖任务明确授权且当前原型真实可执行的范围。
- 未实现或依赖生产服务的状态不虚构；把缺口记录在项目报告。
- Figma 插件导入后的视觉间距与大批量性能仍需在 Figma Desktop 真实运行后人工确认。
`
}

function htmlEscapeJson(value) {
  return JSON.stringify(value).replaceAll('<', '\\u003c')
}

function buildIndex(manifest) {
  return `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Prototype Screenshot Atlas</title>
  <style>
    :root{font-family:Inter,"Microsoft YaHei",sans-serif;color:#172033;background:#f4f6f9}
    *{box-sizing:border-box}body{margin:0}.top{position:sticky;top:0;z-index:2;background:#fff;border-bottom:1px solid #dfe4ec;padding:18px 24px}
    h1{margin:0 0 12px;font-size:22px}.filters{display:flex;gap:10px;flex-wrap:wrap}select,input{height:36px;border:1px solid #c8d0dc;border-radius:8px;padding:0 10px;background:#fff}
    input{min-width:280px}.summary{margin-top:10px;color:#5d6778;font-size:13px}.grid{padding:24px;display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:20px}
    article{background:#fff;border:1px solid #dfe4ec;border-radius:12px;overflow:hidden;box-shadow:0 4px 14px #24304710}article.failed{border-color:#d4380d}
    img{display:block;width:100%;height:auto;background:#eef1f5}.meta{padding:14px}.meta h2{font-size:16px;margin:0 0 8px}.meta p{margin:4px 0;font-size:13px;line-height:1.5}.tag{display:inline-block;padding:2px 7px;border-radius:99px;background:#eef3ff;color:#2456a6;margin-right:6px}
    details{margin-top:8px}.error{color:#b42318}.empty{padding:60px;text-align:center;color:#667085}
  </style>
</head>
<body>
  <div class="top">
    <h1>开发交接用产品页面截图图谱</h1>
    <div class="filters">
      <select id="module"><option value="">全部模块</option></select>
      <select id="role"><option value="">全部角色</option></select>
      <select id="flow"><option value="">全部流程</option></select>
      <select id="status"><option value="">全部结果</option><option value="success">成功</option><option value="failed">失败</option><option value="review">待人工复核</option></select>
      <input id="search" placeholder="搜索页面、状态、路由或备注" />
    </div>
    <div class="summary" id="summary"></div>
  </div>
  <main class="grid" id="grid"></main>
  <script>
    const items=${htmlEscapeJson(manifest)};
    const selectors=['module','role','flow'];
    selectors.forEach(key=>{const el=document.getElementById(key);[...new Set(items.map(x=>x[key]))].sort().forEach(v=>{const o=document.createElement('option');o.value=v;o.textContent=v;el.appendChild(o)})});
    const esc=s=>String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
    function render(){
      const query=document.getElementById('search').value.toLowerCase();
      const filters=Object.fromEntries([...selectors,'status'].map(k=>[k,document.getElementById(k).value]));
      const view=items.filter(x=>(!filters.module||x.module===filters.module)&&(!filters.role||x.role===filters.role)&&(!filters.flow||x.flow===filters.flow)&&(!filters.status||(filters.status==='review'?x.needsManualReview:x.status===filters.status))&&(!query||JSON.stringify(x).toLowerCase().includes(query)));
      document.getElementById('summary').textContent='显示 '+view.length+' / '+items.length+' 个场景；成功 '+view.filter(x=>x.status==='success').length+'，失败 '+view.filter(x=>x.status==='failed').length+'，待人工复核 '+view.filter(x=>x.needsManualReview).length;
      document.getElementById('grid').innerHTML=view.length?view.map(x=>\`<article class="\${x.status}">
        \${x.fileSize?\`<img loading="lazy" src="images/\${encodeURIComponent(x.screenshotName)}" alt="\${esc(x.screenName+' '+x.stateName)}">\`:'<div class="empty">没有可用截图</div>'}
        <div class="meta"><h2>\${esc(x.id+' '+x.screenName+'｜'+x.stateName)}</h2>
        <p><span class="tag">\${esc(x.module)}</span><span class="tag">\${esc(x.role)}</span><span class="tag">\${esc(x.status)}</span></p>
        <p><b>流程：</b>\${esc(x.flow)}　<b>路由：</b><code>\${esc(x.route)}</code></p>
        <p><b>备注：</b>\${esc(x.notes||'—')}</p>
        <details><summary>截图前操作</summary><ol>\${(x.actions||[]).map(a=>\`<li>\${esc(a.type+'：'+a.target+(a.value?' = '+a.value:''))}</li>\`).join('')||'<li>直接进入页面</li>'}</ol></details>
        \${x.issues?.length?\`<p class="error"><b>失败：</b>\${esc(x.issues.join('；'))}</p>\`:''}
        \${x.warnings?.length?\`<p><b>待确认：</b>\${esc(x.warnings.join('；'))}</p>\`:''}
        </div></article>\`).join(''):'<div class="empty">没有匹配场景</div>';
    }
    [...selectors,'status','search'].forEach(k=>document.getElementById(k).addEventListener(k==='search'?'input':'change',render));render();
  </script>
</body>
</html>`
}

async function writeOutputs(manifest) {
  const manifestPath = path.join(artifactsDir, 'capture-manifest.json')
  await fs.writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8')
  await fs.writeFile(path.join(artifactsDir, 'page-inventory.md'), buildInventory(manifest), 'utf8')
  await fs.writeFile(path.join(artifactsDir, 'capture-report.md'), buildReport(manifest), 'utf8')
  await fs.writeFile(path.join(artifactsDir, 'index.html'), buildIndex(manifest), 'utf8')

  const zip = new JSZip()
  zip.file('capture-manifest.json', await fs.readFile(manifestPath))
  const zipImages = zip.folder('images')
  for (const item of manifest) {
    const imagePath = path.join(imagesDir, item.screenshotName)
    try {
      zipImages.file(item.screenshotName, await fs.readFile(imagePath))
    } catch {
      // 失败场景由 Figma 插件生成文字占位 Frame；无文件时不伪造图片。
    }
  }
  const zipBuffer = await zip.generateAsync({ type: 'nodebuffer', compression: 'DEFLATE', compressionOptions: { level: 6 } })
  await fs.writeFile(path.join(artifactsDir, 'figma-import.zip'), zipBuffer)
}

async function main() {
  await fs.mkdir(imagesDir, { recursive: true })
  await ensureServer()
  const browser = await launchChromium()
  const results = new Array(scenarios.length)
  try {
    await createAuthStates(browser)
    const concurrency = 6
    for (let offset = 0; offset < scenarios.length; offset += concurrency) {
      const batch = scenarios.slice(offset, offset + concurrency)
      const batchResults = await Promise.all(batch.map((scenario) => captureScenario(browser, scenario)))
      batchResults.forEach((result, index) => {
        results[offset + index] = result
        process.stdout.write(`${result.status === 'success' ? 'PASS' : 'FAIL'} ${result.id} ${result.screenshotName}\n`)
      })
    }
  } finally {
    await browser.close()
  }
  await writeOutputs(results)
  const failed = results.filter((item) => item.status === 'failed')
  process.stdout.write(`SUMMARY total=${results.length} success=${results.length - failed.length} failed=${failed.length} artifacts=${artifactsDir}\n`)
  if (failed.length) process.exitCode = 2
}

await main()
