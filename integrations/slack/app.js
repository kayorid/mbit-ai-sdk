// integrations/slack/app.js
// MBit Slack bot — Bolt JS.
// Mock mode: MB_MOCK_SLACK=1 (não conecta ao Slack; usado em testes E2E).

import { registerRetroHandler } from './handlers/retro.js';
import { registerHelpHandler } from './handlers/help.js';

const MOCK = process.env.MB_MOCK_SLACK === '1';

async function buildApp() {
  if (MOCK) {
    const handlers = [];
    const fakeApp = {
      message(pattern, handler) {
        handlers.push({ pattern, handler });
      },
      async start() {
        console.log('[mbit-slack] mock mode — bot pronto sem conectar a Slack');
        return { handlers };
      },
      _handlers: handlers,
    };
    registerRetroHandler(fakeApp);
    registerHelpHandler(fakeApp);
    return fakeApp;
  }

  const { App } = await import('@slack/bolt');
  const app = new App({
    token: process.env.SLACK_BOT_TOKEN,
    signingSecret: process.env.SLACK_SIGNING_SECRET,
    socketMode: !!process.env.SLACK_APP_TOKEN,
    appToken: process.env.SLACK_APP_TOKEN,
  });
  registerRetroHandler(app);
  registerHelpHandler(app);
  return app;
}

async function main() {
  const app = await buildApp();
  const port = Number(process.env.PORT || 3000);
  await app.start(port);
  if (!MOCK) console.log(`[mbit-slack] bot rodando em :${port}`);
}

// Permite import em testes sem auto-start
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((e) => { console.error(e); process.exit(1); });
}

export { buildApp };
