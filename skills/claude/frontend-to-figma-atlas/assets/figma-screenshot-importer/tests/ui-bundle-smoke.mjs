import fs from 'node:fs/promises'
import path from 'node:path'
import vm from 'node:vm'
import { fileURLToPath } from 'node:url'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const html = await fs.readFile(path.join(root, 'dist', 'ui.html'), 'utf8')
const marker = '/*__UI_BUNDLE__*/'
if (html.includes(marker)) throw new Error('UI bundle 占位符未被替换')

const openTag = '<script>'
const closeTag = '</script>'
const open = html.indexOf(openTag)
const close = html.lastIndexOf(closeTag)
if (open < 0 || close <= open) throw new Error('dist/ui.html 缺少内联脚本')
if (html.indexOf(closeTag, open + openTag.length) !== close) {
  throw new Error('UI bundle 含有未转义的 </script>')
}

const source = html.slice(open + openTag.length, close)
new vm.Script(source, { filename: 'dist/ui.inline.js' })

process.stdout.write(`UI_BUNDLE_SMOKE_PASS bytes=${source.length}\n`)
