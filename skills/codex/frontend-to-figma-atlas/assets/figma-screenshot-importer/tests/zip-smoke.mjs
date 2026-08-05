import fs from 'node:fs/promises'
import path from 'node:path'
import process from 'node:process'
import JSZip from 'jszip'
import { PNG } from 'pngjs'

const zipPath = path.resolve(process.argv[2] || '')
const buffer = await fs.readFile(zipPath)
const zip = await JSZip.loadAsync(buffer)
const manifestEntry = zip.file('capture-manifest.json')
if (!manifestEntry) throw new Error('ZIP 缺少 capture-manifest.json')
const manifest = JSON.parse(await manifestEntry.async('string'))
if (!Array.isArray(manifest) || !manifest.length) throw new Error('Manifest 为空或格式错误')

let checked = 0
for (const scene of manifest) {
  if (scene.status === 'failed') continue
  const entry = zip.file(`images/${scene.screenshotName}`)
  if (!entry) throw new Error(`ZIP 缺少图片：${scene.screenshotName}`)
  const image = PNG.sync.read(await entry.async('nodebuffer'))
  if (image.width > 4096 || image.height > 4096) throw new Error(`图片超过 4096：${scene.screenshotName}`)
  if (image.width !== scene.imageWidth || image.height !== scene.imageHeight) {
    throw new Error(`Manifest 尺寸不一致：${scene.screenshotName}`)
  }
  checked += 1
}

process.stdout.write(`ZIP_SMOKE_PASS scenes=${manifest.length} images=${checked} path=${zipPath}\n`)
