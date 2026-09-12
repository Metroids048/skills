import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { build } from 'esbuild'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const dist = path.join(root, 'dist')
await fs.mkdir(dist, { recursive: true })

await build({
  entryPoints: [path.join(root, 'src', 'code.ts')],
  outfile: path.join(dist, 'code.js'),
  bundle: true,
  platform: 'browser',
  target: 'es2020',
  format: 'iife',
  legalComments: 'none',
})

const uiBundle = await build({
  entryPoints: [path.join(root, 'src', 'ui.ts')],
  bundle: true,
  platform: 'browser',
  target: 'es2020',
  format: 'iife',
  write: false,
  minify: true,
  legalComments: 'none',
})
const uiScript = uiBundle.outputFiles[0].text.replaceAll('</script>', '<\\/script>')
const template = await fs.readFile(path.join(root, 'src', 'ui.html'), 'utf8')
await fs.writeFile(
  path.join(dist, 'ui.html'),
  template.replace('/*__UI_BUNDLE__*/', () => uiScript),
  'utf8',
)

process.stdout.write(`Built ${path.join(dist, 'code.js')} and ${path.join(dist, 'ui.html')}\n`)
