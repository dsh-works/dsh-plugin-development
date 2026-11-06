/**
 * Package metadata checks every bundle should keep.
 *
 * These run under plain Node with no harness and no browser, as part of the
 * plugin repository's `check` script.
 */

import { existsSync } from 'node:fs'
import { readFile } from 'node:fs/promises'
import assert from 'node:assert/strict'
import { test } from 'node:test'

const root = new URL('../', import.meta.url)

/** Read and parse a JSON file relative to the package root. */
async function readJson(relative) {
  return JSON.parse(await readFile(new URL(relative, root), 'utf8'))
}

/** Read a text file relative to the package root. */
async function readText(relative) {
  return readFile(new URL(relative, root), 'utf8')
}

test('every exported and published file exists', async () => {
  const pkg = await readJson('package.json')

  for (const target of Object.values(pkg.exports)) {
    if (typeof target !== 'string' || target.includes('*')) continue
    assert.ok(existsSync(new URL(target, root)), `${target} is exported but missing`)
  }

  for (const entry of pkg.files) {
    if (entry.includes('*')) continue
    assert.ok(existsSync(new URL(entry, root)), `${entry} is in files but missing`)
  }
})

test('the bundle is declared with its patch and a valid harness range', async () => {
  const pkg = await readJson('package.json')

  assert.equal(pkg.type, 'module')
  assert.equal(pkg.private, true)
  assert.ok(pkg.engines?.dsh, 'engines.dsh must pin the tested harness range')
  assert.equal(pkg.dsh?.bundle?.patch, './cordis.patch.yml')

  if (pkg.dsh?.client) {
    assert.equal(pkg.dsh.client.platform, 'web')
    assert.ok(pkg.exports['./client'], 'dsh.client requires the ./client export')
  }
})

test('the browser half parses as a classic script', async () => {
  const pkg = await readJson('package.json')
  if (!pkg.dsh?.client) return

  const source = await readText('client.js')

  assert.ok(!/^\s*(import|export)\s/m.test(source), 'client.js must not use ESM syntax')
  assert.ok(source.includes('__ModuleLoader__'), 'client.js must register through the module loader')

  // Parse without executing: a classic script body compiles as a function body.
  assert.doesNotThrow(() => new Function(source), 'client.js must parse')
})

test('locale files carry the display metadata', async () => {
  for (const language of ['en', 'zh']) {
    const meta = (await readJson(`locale/${language}.json`)).meta

    assert.ok(typeof meta?.title === 'string' && meta.title.length > 0, `${language} title`)
    assert.ok(typeof meta?.description === 'string' && meta.description.length > 0, `${language} description`)
  }
})
