import JSZip from 'jszip'

type Scene = {
  id: string
  module: string
  flow: string
  role: string
  screenName: string
  stateName: string
  route: string
  screenshotName: string
  status?: 'success' | 'failed'
  issues?: string[]
}

const input = document.querySelector<HTMLInputElement>('#zipFile')!
const startButton = document.querySelector<HTMLButtonElement>('#start')!
const status = document.querySelector<HTMLElement>('#status')!
const progress = document.querySelector<HTMLProgressElement>('#progress')!
const summary = document.querySelector<HTMLElement>('#summary')!
const errors = document.querySelector<HTMLElement>('#errors')!
let selectedFile: File | null = null
let batchResolver: (() => void) | null = null
let readyResolver: (() => void) | null = null
let completeResolver: (() => void) | null = null
let reusedSceneIds = new Set<string>()

function setStatus(text: string) {
  status.textContent = text
}

function addError(text: string) {
  const item = document.createElement('li')
  item.textContent = text
  errors.appendChild(item)
}

function waitForReady() {
  return new Promise<void>((resolve) => {
    readyResolver = resolve
  })
}

function waitForBatch() {
  return new Promise<void>((resolve) => {
    batchResolver = resolve
  })
}

function waitForComplete() {
  return new Promise<void>((resolve) => {
    completeResolver = resolve
  })
}

window.onmessage = (event) => {
  const message = event.data.pluginMessage
  if (!message) return
  if (message.type === 'ready') {
    reusedSceneIds = new Set(message.reusedSceneIds || [])
    summary.textContent = [
      `已同步 ${message.createdPages} 个 Atlas 页面：新增 ${message.createdSections} 个 Section、${message.createdFrames} 个 Frame，更新 ${message.updatedFrames || 0} 个已有 Frame。`,
      `复用已有截图 ${message.reusedImages} 张，修正原始上传图层名称 ${message.renamedUploads} 个。`,
      message.duplicateUploads
        ? `发现重复上传 ${message.duplicateUploads} 个（编号：${(message.duplicateSceneIds || []).join('、')}），这些编号不复用，改从 ZIP 导入。`
        : '',
    ].filter(Boolean).join(' ')
    readyResolver?.()
    readyResolver = null
  } else if (message.type === 'batch-done') {
    batchResolver?.()
    batchResolver = null
  } else if (message.type === 'progress') {
    progress.max = Math.max(message.total, 1)
    progress.value = message.completed
    setStatus(`导入 ${message.completed}/${message.total}；成功 ${message.success}，失败 ${message.failed}，跳过 ${message.skipped}`)
  } else if (message.type === 'item-error') {
    addError(`${message.id} ${message.screenshotName}：${message.message}`)
  } else if (message.type === 'complete') {
    setStatus(`完成：成功 ${message.success}，失败 ${message.failed}，跳过 ${message.skipped}`)
    summary.textContent = `共处理 ${message.total} 个场景。可关闭插件并在 Atlas｜产品截图图谱 页面查看。`
    startButton.disabled = false
    completeResolver?.()
    completeResolver = null
  } else if (message.type === 'fatal-error') {
    addError(`插件主线程错误：${message.message}`)
    setStatus('导入中断，请查看错误')
    startButton.disabled = false
  }
}

input.addEventListener('change', () => {
  selectedFile = input.files?.[0] || null
  startButton.disabled = !selectedFile
  setStatus(selectedFile ? `已选择：${selectedFile.name}` : '请选择 figma-import.zip')
})

startButton.addEventListener('click', async () => {
  if (!selectedFile) return
  startButton.disabled = true
  errors.innerHTML = ''
  progress.value = 0

  try {
    setStatus('读取 ZIP 与 Manifest…')
    const zip = await JSZip.loadAsync(await selectedFile.arrayBuffer())
    const manifestEntry = zip.file('capture-manifest.json')
    if (!manifestEntry) throw new Error('ZIP 缺少 capture-manifest.json')
    const manifest = JSON.parse(await manifestEntry.async('string')) as Scene[]
    if (!Array.isArray(manifest) || !manifest.length) throw new Error('capture-manifest.json 不是非空数组')

    const ids = new Set<string>()
    for (const scene of manifest) {
      if (!scene.id || !scene.module || !scene.flow || !scene.screenName || !scene.screenshotName) {
        throw new Error(`Manifest 场景字段不完整：${JSON.stringify(scene)}`)
      }
      if (ids.has(scene.id)) throw new Error(`Manifest 场景 ID 重复：${scene.id}`)
      ids.add(scene.id)
    }

    parent.postMessage({ pluginMessage: { type: 'initialize', manifest } }, '*')
    await waitForReady()

    const missing = manifest.filter((scene) =>
      scene.status !== 'failed'
      && !reusedSceneIds.has(scene.id)
      && !zip.file(`images/${scene.screenshotName}`),
    )
    for (const scene of missing) addError(`缺少图片：${scene.id} images/${scene.screenshotName}`)

    const importable = manifest.filter((scene) =>
      scene.status !== 'failed'
      && !reusedSceneIds.has(scene.id)
      && zip.file(`images/${scene.screenshotName}`),
    )
    const batchSize = 6
    for (let offset = 0; offset < importable.length; offset += batchSize) {
      const scenes = importable.slice(offset, offset + batchSize)
      const items = await Promise.all(scenes.map(async (scene) => ({
        id: scene.id,
        screenshotName: scene.screenshotName,
        bytes: await zip.file(`images/${scene.screenshotName}`)!.async('uint8array'),
      })))
      parent.postMessage({ pluginMessage: { type: 'image-batch', items } }, '*')
      await waitForBatch()
    }

    parent.postMessage({ pluginMessage: { type: 'finish' } }, '*')
    await waitForComplete()
  } catch (error) {
    addError(error instanceof Error ? error.message : String(error))
    setStatus('读取或导入失败')
    startButton.disabled = false
  }
})
