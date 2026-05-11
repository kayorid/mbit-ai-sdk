// Testes do bot em mock mode. Roda com `node --test test/`.
// Não requer Slack nem network.

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { findLatestRetro, summarizeRetro } from '../adapters/retro-reader.js';

process.env.MB_MOCK_SLACK = '1';

test('findLatestRetro lê fixture do squad cambio', async () => {
  const retro = await findLatestRetro('cambio');
  assert.ok(retro, 'retro encontrada');
  assert.match(retro.content, /Squad: cambio/);
});

test('findLatestRetro retorna null para squad inexistente', async () => {
  const retro = await findLatestRetro('inexistente-xyz');
  assert.equal(retro, null);
});

test('summarizeRetro extrai seção de highlights', async () => {
  const retro = await findLatestRetro('cambio');
  const summary = summarizeRetro(retro.content);
  assert.match(summary, /Highlights|Decisões|Aprendizados/);
});

test('buildApp roda em mock mode sem erro', async () => {
  const { buildApp } = await import('../app.js');
  const app = await buildApp();
  assert.ok(app);
  assert.ok(Array.isArray(app._handlers));
  assert.ok(app._handlers.length >= 2, 'pelo menos 2 handlers registrados');
});
