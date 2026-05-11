// integrations/slack/adapters/retro-reader.js
// Lê retros de filesystem ou fixtures (mock mode).

import { readdir, readFile, stat } from 'node:fs/promises';
import { join } from 'node:path';

const FIXTURE_DIR = new URL('../fixtures/', import.meta.url).pathname;
function retrosPath() { return process.env.MB_RETROS_PATH || '.mb/retros'; }
function isMock() { return process.env.MB_MOCK_SLACK === '1'; }

async function listFiles(dir) {
  try {
    const entries = await readdir(dir, { withFileTypes: true });
    const files = [];
    for (const e of entries) {
      const p = join(dir, e.name);
      if (e.isFile() && e.name.endsWith('.md')) files.push(p);
      else if (e.isDirectory()) files.push(...await listFiles(p));
    }
    return files;
  } catch {
    return [];
  }
}

export async function findLatestRetro(squad) {
  const baseDir = isMock() ? FIXTURE_DIR : retrosPath();
  const files = await listFiles(baseDir);
  const matches = [];
  for (const f of files) {
    const content = await readFile(f, 'utf8');
    const squadLine = content.match(/^Squad:\s*(.+)$/m);
    if (squadLine && squadLine[1].trim().toLowerCase() === squad.toLowerCase()) {
      const s = await stat(f);
      matches.push({ path: f, mtime: s.mtimeMs, content });
    }
  }
  matches.sort((a, b) => b.mtime - a.mtime);
  return matches[0] || null;
}

export function summarizeRetro(content, maxLines = 12) {
  const lines = content.split('\n');
  const out = [];
  let inHighlights = false;
  for (const line of lines) {
    if (/^##\s+(highlight|decis|aprend)/i.test(line)) { inHighlights = true; out.push(line); continue; }
    if (inHighlights && line.startsWith('## ')) inHighlights = false;
    if (inHighlights && line.trim()) out.push(line);
    if (out.length >= maxLines) break;
  }
  return out.length ? out.join('\n') : content.split('\n').slice(0, maxLines).join('\n');
}
