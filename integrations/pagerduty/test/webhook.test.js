import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, unlink } from 'node:fs/promises';
import { writeRunbook } from '../webhook.js';

test('writeRunbook gera runbook a partir de fixture', async () => {
  const raw = await readFile(new URL('../mock-fixtures/inc-demo.json', import.meta.url), 'utf8');
  const payload = JSON.parse(raw);
  const { outPath, vars } = await writeRunbook(payload, '/tmp/mbit-pd-test');
  assert.equal(vars.id, 'PD-DEMO-001');
  const written = await readFile(outPath, 'utf8');
  assert.match(written, /INC-PD-DEMO-001/);
  assert.match(written, /Latência alta/);
  await unlink(outPath);
});
