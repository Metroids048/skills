import test from 'node:test'
import assert from 'node:assert/strict'
import { scenarios } from '../src/scenarios.mjs'

test('截图场景 ID 与文件名唯一且尺寸符合规范', () => {
  assert.equal(new Set(scenarios.map((item) => item.id)).size, scenarios.length)
  assert.equal(new Set(scenarios.map((item) => item.screenshotName)).size, scenarios.length)
  for (const item of scenarios) {
    assert.deepEqual(item.viewport, { width: 1440, height: 900 })
    assert.match(item.screenshotName, /\.png$/)
    assert.ok(item.screenshotName.length < 180)
    assert.ok(Array.isArray(item.actions))
    assert.ok(Array.isArray(item.preconditions))
  }
})

test('交互动作优先使用语义定位器', () => {
  const allowed = new Set(['role', 'label', 'text', 'placeholder', 'testId'])
  for (const item of scenarios) {
    for (const action of item.actions) {
      if (action.type === 'waitForText') continue
      assert.ok(action.locator, `${item.id} ${action.target} 缺少 locator`)
      assert.ok(allowed.has(action.locator.by), `${item.id} 使用了不允许的定位方式`)
    }
  }
})
