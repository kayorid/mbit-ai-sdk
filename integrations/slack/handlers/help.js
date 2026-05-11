// integrations/slack/handlers/help.js
export function registerHelpHandler(app) {
  app.message(/\bhelp\b/i, async ({ message, say }) => {
    await say({
      thread_ts: message.ts,
      text: [
        '*MBit AI SDK · comandos disponíveis no Slack*',
        '',
        '• `@mbit-ai retro <squad>` — última retrospectiva do squad',
        '• `@mbit-ai help` — esta mensagem',
        '',
        'CLI completa: rode `/mb-help` no Claude Code para ver 60+ comandos.',
      ].join('\n'),
    });
  });
}
