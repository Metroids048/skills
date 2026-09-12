type CaptureAction = {
  type: string
  target: string
  value?: string
}

type CaptureScene = {
  id: string
  module: string
  flow: string
  role: string
  screenName: string
  stateName: string
  route: string
  viewport?: { width: number; height: number }
  screenshotName: string
  notes?: string
  actions?: CaptureAction[]
  status?: 'success' | 'failed'
  issues?: string[]
  needsManualReview?: boolean
  imageWidth?: number
  imageHeight?: number
}

type ImageBatchItem = {
  id: string
  screenshotName: string
  bytes: Uint8Array
}

type SceneNodes = {
  frameId: string
  imageNodeId?: string
  scene: CaptureScene
  reused: boolean
}

type ReusableImage = {
  imageHash: string
  width: number
  height: number
}

const FRAME_GAP_X = 160
const FRAME_GAP_Y = 200
const SECTION_PADDING = 120
const META_HEIGHT = 156
const SECTION_GAP_Y = 360
const MAX_IMAGE_EDGE = 4096
const DEFAULT_IMAGE_WIDTH = 1440
const DEFAULT_IMAGE_HEIGHT = 900
const atlasPageName = 'Atlas｜产品截图图谱'
const sceneNodes = new Map<string, SceneNodes>()
let totalScenes = 0
let completedImages = 0
let successImages = 0
let failedImages = 0
let skippedImages = 0
let reusedImages = 0
let renamedUploads = 0
let duplicateUploads = 0

figma.showUI(__html__, { width: 560, height: 720, themeColors: true })

function rgb(hex: string): RGB {
  const value = hex.replace('#', '')
  return {
    r: Number.parseInt(value.slice(0, 2), 16) / 255,
    g: Number.parseInt(value.slice(2, 4), 16) / 255,
    b: Number.parseInt(value.slice(4, 6), 16) / 255,
  }
}

function solid(hex: string): SolidPaint {
  return { type: 'SOLID', color: rgb(hex) }
}

async function loadFonts() {
  await figma.loadFontAsync({ family: 'Inter', style: 'Regular' })
  await figma.loadFontAsync({ family: 'Inter', style: 'Semi Bold' })
}

function createText(
  text: string,
  size: number,
  color: string,
  width: number,
  style: 'Regular' | 'Semi Bold' = 'Regular',
  name = '文本',
) {
  const node = figma.createText()
  node.name = name
  node.fontName = { family: 'Inter', style }
  node.fontSize = size
  node.characters = text
  node.fills = [solid(color)]
  node.textAutoResize = 'HEIGHT'
  node.resize(width, Math.max(size * 1.4, 20))
  return node
}

function actionSummary(scene: CaptureScene) {
  if (!scene.actions?.length) return '操作步骤：直接打开页面'
  const labels: Record<string, string> = {
    click: '点击',
    fill: '填写',
    scrollIntoView: '定位至',
    waitForText: '等待显示',
    selectOption: '选择',
  }
  return `操作步骤：${scene.actions.map((action) => {
    const verb = labels[action.type] || '执行'
    const value = action.value ? `为「${action.value}」` : ''
    return `${verb}「${action.target}」${value}`
  }).join(' → ')}`
}

function sceneNotes(scene: CaptureScene) {
  return [
    actionSummary(scene),
    scene.notes ? `备注：${scene.notes}` : '',
    scene.needsManualReview ? '人工检查：需要人工复核' : '',
  ].filter(Boolean).join('\n') || '备注：无'
}

function isSupplementary(scene: CaptureScene) {
  const text = `${scene.stateName} ${scene.screenName} ${(scene.issues || []).join(' ')}`
  return /(空|错误|异常|失败|权限|校验|弹窗|抽屉|维护|导入|创建|新增|表单|待执行)/.test(text)
}

function extractSceneId(name: string) {
  return name.match(/(?:^|[^\d])(\d{2}-\d{2})(?:[^\d]|$)/)?.[1]
}

function imagePaintFor(node: SceneNode) {
  if (!('fills' in node) || node.fills === figma.mixed) return undefined
  return node.fills.find((paint): paint is ImagePaint => paint.type === 'IMAGE' && Boolean(paint.imageHash))
}

function existingUploads(manifest: CaptureScene[]) {
  const manifestById = new Map(manifest.map((scene) => [scene.id, scene]))
  const reusable = new Map<string, ReusableImage>()
  const ambiguousIds = new Set<string>()

  for (const node of figma.currentPage.children) {
    const id = extractSceneId(node.name)
    const scene = id ? manifestById.get(id) : undefined
    const imagePaint = imagePaintFor(node)
    if (!id || !scene || !imagePaint?.imageHash) continue

    node.name = `原始上传｜${scene.screenshotName}`
    renamedUploads += 1
    if (ambiguousIds.has(id)) {
      duplicateUploads += 1
      continue
    }
    if (reusable.has(id)) {
      duplicateUploads += 1
      reusable.delete(id)
      ambiguousIds.add(id)
      continue
    }
    reusable.set(id, {
      imageHash: imagePaint.imageHash,
      width: node.width,
      height: node.height,
    })
  }

  return { reusable, ambiguousIds }
}

function sectionName(moduleName: string, flow: string) {
  return `模块｜${moduleName}｜流程｜${flow}`
}

function sectionForFlow(page: PageNode, moduleName: string, flow: string) {
  const name = sectionName(moduleName, flow)
  const existing = page.children.find((node) => node.type === 'SECTION' && node.name === name)
  if (existing?.type === 'SECTION') return { section: existing, created: false }
  const section = figma.createSection()
  section.name = name
  return { section, created: true }
}

function atlasPage() {
  const existing = figma.root.children.find((page) => page.name === atlasPageName)
  if (existing) return existing
  const page = figma.createPage()
  page.name = atlasPageName
  return page
}

function existingSceneFrames(page: PageNode) {
  const frames = new Map<string, FrameNode>()
  for (const section of page.children) {
    if (section.type !== 'SECTION') continue
    for (const child of section.children) {
      if (child.type !== 'FRAME') continue
      const id = extractSceneId(child.name)
      if (id && !frames.has(id)) frames.set(id, child)
    }
  }
  return frames
}

function sceneImageSize(scene: CaptureScene) {
  const width = scene.imageWidth || scene.viewport?.width || DEFAULT_IMAGE_WIDTH
  const height = scene.imageHeight || scene.viewport?.height || DEFAULT_IMAGE_HEIGHT
  return {
    width: Math.min(width, MAX_IMAGE_EDGE),
    height: Math.min(height, MAX_IMAGE_EDGE),
  }
}

function createSceneFrame(scene: CaptureScene, reusable?: ReusableImage) {
  const imageSize = reusable
    ? {
        width: Math.min(reusable.width, MAX_IMAGE_EDGE),
        height: Math.min(reusable.height, MAX_IMAGE_EDGE),
      }
    : sceneImageSize(scene)
  const contentWidth = Math.max(imageSize.width, 720)
  const frameWidth = contentWidth + 64
  const frame = figma.createFrame()
  frame.name = `${scene.id} ${scene.screenName}｜${scene.stateName}`
  frame.layoutMode = 'VERTICAL'
  frame.resize(frameWidth, 100)
  frame.primaryAxisSizingMode = 'AUTO'
  frame.counterAxisSizingMode = 'FIXED'
  frame.counterAxisAlignItems = 'MIN'
  frame.itemSpacing = 12
  frame.paddingTop = 28
  frame.paddingRight = 32
  frame.paddingBottom = 28
  frame.paddingLeft = 32
  frame.fills = [solid(scene.status === 'failed' ? '#FFF7F0' : '#FFFFFF')]
  frame.strokes = [solid(scene.status === 'failed' ? '#D4380D' : '#D9DEE7')]
  frame.strokeWeight = 1
  frame.cornerRadius = 12
  frame.clipsContent = false

  frame.appendChild(createText(`${scene.id} ${scene.screenName}｜${scene.stateName}`, 24, '#172033', contentWidth, 'Semi Bold', '标题'))
  frame.appendChild(createText(`角色：${scene.role}　 流程：${scene.flow}`, 14, '#4F5B6E', contentWidth, 'Regular', '元信息'))

  let imageNodeId: string | undefined
  if (scene.status !== 'failed') {
    const imageNode = figma.createRectangle()
    imageNode.name = `截图｜${scene.screenshotName}`
    imageNode.resize(imageSize.width, imageSize.height)
    imageNode.fills = reusable
      ? [{ type: 'IMAGE', imageHash: reusable.imageHash, scaleMode: 'FIT' }]
      : [solid('#EEF1F5')]
    imageNode.cornerRadius = 4
    frame.appendChild(imageNode)
    imageNodeId = imageNode.id
  } else {
    const failure = createText(
      `截图失败占位\n${(scene.issues || ['未提供失败原因']).join('\n')}`,
      18,
      '#B42318',
      contentWidth,
      'Semi Bold',
    )
    frame.appendChild(failure)
  }

  frame.appendChild(createText(sceneNotes(scene), 13, '#667085', contentWidth, 'Regular', '操作说明'))

  return { frame, imageNodeId, reused: Boolean(reusable) }
}

function updateText(node: TextNode | undefined, text: string, width: number, name: string) {
  if (!node) return
  node.name = name
  node.textAutoResize = 'HEIGHT'
  node.resize(width, Math.max(node.height, 20))
  node.characters = text
}

function syncSceneFrame(scene: CaptureScene, existing: FrameNode | undefined, reusable?: ReusableImage) {
  if (!existing) return createSceneFrame(scene, reusable)

  const imageNode = existing.children.find(
    (node): node is RectangleNode => node.type === 'RECTANGLE' && node.name.startsWith('截图｜'),
  )
  const imageSize = imageNode
    ? { width: imageNode.width, height: imageNode.height }
    : reusable
      ? { width: reusable.width, height: reusable.height }
      : sceneImageSize(scene)
  const contentWidth = Math.max(Math.min(imageSize.width, MAX_IMAGE_EDGE), 720)
  const frameWidth = contentWidth + 64
  existing.name = `${scene.id} ${scene.screenName}｜${scene.stateName}`
  existing.resize(frameWidth, Math.max(existing.height, 100))
  existing.primaryAxisSizingMode = 'AUTO'
  existing.counterAxisSizingMode = 'FIXED'

  const textNodes = existing.children.filter((node): node is TextNode => node.type === 'TEXT')
  updateText(textNodes[0], `${scene.id} ${scene.screenName}｜${scene.stateName}`, contentWidth, '标题')
  updateText(textNodes[1], `角色：${scene.role}　 流程：${scene.flow}`, contentWidth, '元信息')
  updateText(textNodes[textNodes.length - 1], sceneNotes(scene), contentWidth, '操作说明')

  let targetImage = imageNode
  if (scene.status !== 'failed' && !targetImage) {
    targetImage = figma.createRectangle()
    targetImage.cornerRadius = 4
    const notesNode = textNodes[textNodes.length - 1]
    const notesIndex = notesNode ? existing.children.indexOf(notesNode) : existing.children.length
    existing.insertChild(Math.max(notesIndex, 2), targetImage)
  }
  if (targetImage) {
    targetImage.name = `截图｜${scene.screenshotName}`
    if (!imagePaintFor(targetImage) && reusable) {
      targetImage.resize(Math.min(reusable.width, MAX_IMAGE_EDGE), Math.min(reusable.height, MAX_IMAGE_EDGE))
      targetImage.fills = [{ type: 'IMAGE', imageHash: reusable.imageHash, scaleMode: 'FIT' }]
    }
  }

  return {
    frame: existing,
    imageNodeId: targetImage?.id,
    reused: Boolean(targetImage && imagePaintFor(targetImage)),
  }
}

async function initializeAtlas(manifest: CaptureScene[]) {
  await loadFonts()
  totalScenes = manifest.length
  sceneNodes.clear()
  completedImages = 0
  successImages = 0
  failedImages = 0
  skippedImages = 0
  reusedImages = 0
  renamedUploads = 0
  duplicateUploads = 0
  const { reusable: uploadedImages, ambiguousIds } = existingUploads(manifest)
  const modules = new Map<string, CaptureScene[]>()
  for (const scene of manifest) {
    const items = modules.get(scene.module) || []
    items.push(scene)
    modules.set(scene.module, items)
  }

  const page = atlasPage()
  await figma.setCurrentPageAsync(page)
  const existingFrames = existingSceneFrames(page)
  const reusedSceneIds = new Set<string>()
  const createdSections: string[] = []
  const createdFrames: string[] = []
  const updatedFrames: string[] = []
  let sectionY = 0

  for (const [moduleName, moduleScenes] of modules) {
    const flows = new Map<string, CaptureScene[]>()
    for (const scene of moduleScenes.sort((a, b) => a.id.localeCompare(b.id, 'zh-CN', { numeric: true }))) {
      const items = flows.get(scene.flow) || []
      items.push(scene)
      flows.set(scene.flow, items)
    }

    for (const [flowName, flowScenes] of flows) {
      const { section, created } = sectionForFlow(page, moduleName, flowName)
      section.x = 0
      section.y = sectionY
      section.fills = [solid('#F4F6F9')]
      if (created) createdSections.push(section.id)

      const mainScenes = flowScenes.filter((scene) => !isSupplementary(scene))
      const supplementaryScenes = flowScenes.filter(isSupplementary)
      const rows = [mainScenes, supplementaryScenes].filter((row) => row.length)
      let rowY = SECTION_PADDING
      let sectionWidth = 0

      for (const row of rows) {
        let rowX = SECTION_PADDING
        let rowHeight = 0
        for (const scene of row) {
          const existingFrame = existingFrames.get(scene.id)
          const reusable = uploadedImages.get(scene.id)
          const { frame, imageNodeId, reused } = syncSceneFrame(scene, existingFrame, reusable)
          if (frame.parent !== section) section.appendChild(frame)
          frame.x = rowX
          frame.y = rowY
          rowX += frame.width + FRAME_GAP_X
          rowHeight = Math.max(rowHeight, frame.height)
          sectionWidth = Math.max(sectionWidth, rowX - FRAME_GAP_X + SECTION_PADDING)
          sceneNodes.set(scene.id, { frameId: frame.id, imageNodeId, scene, reused })
          if (reused) reusedSceneIds.add(scene.id)
          if (existingFrame) updatedFrames.push(frame.id)
          else createdFrames.push(frame.id)
        }
        rowY += rowHeight + FRAME_GAP_Y
      }

      const sectionHeight = Math.max(rowY - FRAME_GAP_Y + SECTION_PADDING, 480)
      section.resizeWithoutConstraints(Math.max(sectionWidth, 960), sectionHeight)
      sectionY += section.height + SECTION_GAP_Y
    }
  }
  reusedImages = reusedSceneIds.size
  successImages = reusedImages
  completedImages = reusedImages

  figma.ui.postMessage({
    type: 'ready',
    total: totalScenes,
    createdPages: 1,
    createdSections: createdSections.length,
    createdFrames: createdFrames.length,
    updatedFrames: updatedFrames.length,
    reusedImages,
    reusedSceneIds: [...reusedSceneIds],
    renamedUploads,
    duplicateUploads,
    duplicateSceneIds: [...ambiguousIds],
  })
}

async function importImage(item: ImageBatchItem) {
  const target = sceneNodes.get(item.id)
  if (target?.reused) return
  if (!target?.imageNodeId) {
    skippedImages += 1
    return
  }
  const imageNode = await figma.getNodeByIdAsync(target.imageNodeId)
  if (!imageNode || imageNode.type !== 'RECTANGLE') {
    throw new Error(`找不到截图占位节点：${item.id}`)
  }
  const bytes = item.bytes instanceof Uint8Array ? item.bytes : new Uint8Array(item.bytes)
  const image = figma.createImage(bytes)
  const size = await image.getSizeAsync()
  if (size.width > MAX_IMAGE_EDGE || size.height > MAX_IMAGE_EDGE) {
    throw new Error(`图片超过 4096×4096：${item.screenshotName} ${size.width}×${size.height}`)
  }
  imageNode.resize(size.width, size.height)
  imageNode.fills = [{ type: 'IMAGE', imageHash: image.hash, scaleMode: 'FIT' }]
  successImages += 1
}

async function importBatch(items: ImageBatchItem[]) {
  for (const item of items) {
    try {
      await importImage(item)
    } catch (error) {
      failedImages += 1
      figma.ui.postMessage({
        type: 'item-error',
        id: item.id,
        screenshotName: item.screenshotName,
        message: error instanceof Error ? error.message : String(error),
      })
    } finally {
      completedImages += 1
      figma.ui.postMessage({
        type: 'progress',
        completed: completedImages,
        total: totalScenes,
        success: successImages,
        failed: failedImages,
        skipped: skippedImages,
      })
    }
  }
  figma.ui.postMessage({ type: 'batch-done' })
}

figma.ui.onmessage = async (message: { type: string; manifest?: CaptureScene[]; items?: ImageBatchItem[] }) => {
  try {
    if (message.type === 'initialize' && message.manifest) {
      await initializeAtlas(message.manifest)
      return
    }
    if (message.type === 'image-batch' && message.items) {
      await importBatch(message.items)
      return
    }
    if (message.type === 'finish') {
      const firstFrame = sceneNodes.values().next().value as SceneNodes | undefined
      if (firstFrame) {
        const node = await figma.getNodeByIdAsync(firstFrame.frameId)
        if (node && 'type' in node && node.type === 'FRAME') figma.viewport.scrollAndZoomIntoView([node])
      }
      figma.ui.postMessage({
        type: 'complete',
        total: totalScenes,
        success: successImages,
        failed: failedImages,
        skipped: skippedImages + [...sceneNodes.values()].filter((entry) => entry.scene.status === 'failed').length,
      })
    }
  } catch (error) {
    figma.ui.postMessage({
      type: 'fatal-error',
      message: error instanceof Error ? error.message : String(error),
    })
  }
}
