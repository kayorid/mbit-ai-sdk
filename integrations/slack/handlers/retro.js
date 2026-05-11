// integrations/slack/handlers/retro.js
import { findLatestRetro, summarizeRetro } from '../adapters/retro-reader.js';

export function registerRetroHandler(app) {
  app.message(/retro\s+(\S+)/i, async ({ message, context, say }) => {
    const squad = context.matches[1];
    const retro = await findLatestRetro(squad);
    if (!retro) {
      await say({
        thread_ts: message.ts,
        text: `Sem retrospectivas encontradas para o squad *${squad}*.`,
      });
      return;
    }
    const summary = summarizeRetro(retro.content);
    await say({
      thread_ts: message.ts,
      text: `*Última retro de ${squad}*\n\`\`\`\n${summary}\n\`\`\``,
    });
  });
}
