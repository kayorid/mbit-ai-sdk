// integrations/pagerduty/webhook.js
// HTTP server que recebe webhooks do PagerDuty e gera runbooks em .mb/runbooks/.
// Usa apenas APIs nativas (http, crypto) — zero deps.
//
// Modos:
//   - default: HTTP server em PORT (default 4000) validando X-PagerDuty-Signature
//   - --mock <path>: processa fixture local sem subir server (para CI/dev)

import { createServer } from 'node:http';
import { createHmac } from 'node:crypto';
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TEMPLATE_PATH = resolve(__dirname, 'runbook-template.md');

async function loadTemplate() {
  return await readFile(TEMPLATE_PATH, 'utf8');
}

function renderTemplate(tpl, vars) {
  return tpl.replace(/\{\{(\w+)\}\}/g, (_, k) => vars[k] ?? `<${k}?>`);
}

function extractIncidentVars(payload) {
  // PagerDuty v3 webhook shape: { event: { data: { ... } } }
  const inc = payload?.event?.data || payload?.incident || payload;
  return {
    id: inc?.id || 'UNKNOWN',
    title: inc?.title || inc?.summary || 'sem título',
    urgency: inc?.urgency || 'unknown',
    service: inc?.service?.summary || inc?.service?.name || 'unknown',
    url: inc?.html_url || inc?.url || '',
    created_at: inc?.created_at || new Date().toISOString(),
    description: inc?.description || '',
  };
}

export async function writeRunbook(payload, outDir = '.mb/runbooks') {
  const vars = extractIncidentVars(payload);
  const tpl = await loadTemplate();
  const md = renderTemplate(tpl, vars);
  await mkdir(outDir, { recursive: true });
  const outPath = `${outDir}/INC-${vars.id}.md`;
  await writeFile(outPath, md, 'utf8');
  return { outPath, vars };
}

function verifySignature(rawBody, signatureHeader, secret) {
  if (!secret) return true; // dev mode
  if (!signatureHeader) return false;
  // PagerDuty: "v1=<hex>,v1=<hex>" (suporta múltiplos secrets)
  const expected = createHmac('sha256', secret).update(rawBody).digest('hex');
  const sigs = signatureHeader.split(',').map((s) => s.replace(/^v1=/, '').trim());
  return sigs.includes(expected);
}

async function runMock(fixturePath) {
  const raw = await readFile(fixturePath, 'utf8');
  const payload = JSON.parse(raw);
  const { outPath, vars } = await writeRunbook(payload);
  console.log(`[pagerduty] runbook gerado: ${outPath}`);
  console.log(`            incidente: ${vars.id} · ${vars.title}`);
  return outPath;
}

function startServer() {
  const port = Number(process.env.PORT || 4000);
  const secret = process.env.PAGERDUTY_WEBHOOK_SECRET || '';
  const server = createServer((req, res) => {
    if (req.method !== 'POST' || req.url !== '/webhook') {
      res.writeHead(404).end('not found');
      return;
    }
    let body = '';
    req.on('data', (c) => (body += c));
    req.on('end', async () => {
      const sig = req.headers['x-pagerduty-signature'];
      if (!verifySignature(body, sig, secret)) {
        res.writeHead(401).end('invalid signature');
        return;
      }
      try {
        const payload = JSON.parse(body);
        const { outPath } = await writeRunbook(payload);
        res.writeHead(200, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ ok: true, runbook: outPath }));
      } catch (e) {
        res.writeHead(500).end(`error: ${e.message}`);
      }
    });
  });
  server.listen(port, () => console.log(`[pagerduty] webhook em :${port}/webhook`));
  return server;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const mockIdx = process.argv.indexOf('--mock');
  if (mockIdx > 0 && process.argv[mockIdx + 1]) {
    runMock(process.argv[mockIdx + 1]).catch((e) => { console.error(e); process.exit(1); });
  } else {
    startServer();
  }
}
