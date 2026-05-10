# mb-retro

Transforma cada ciclo SDD em aprendizado coletivo. Extrai learnings, propõe evolução de constitution e skills, alimenta a memória organizacional do MB.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-retro` | Conduz retrospectiva estruturada da feature/fase corrente |
| `/mb-retro-promote` | Promove learning local para proposta de PR ao mb-ai-core |
| `/mb-retro-extract-skill` | Identifica padrões repetidos e propõe skill custom |
| `/mb-retro-quarterly` | Agrega retros do trimestre, gera relatório executivo |

## Skills

- `mb-retro-facilitator` — facilita a sessão de retrospectiva.
- `mb-learning-extractor` — analisa retros agregadas e identifica padrões promovíveis.

## Filosofia

A memória organizacional é vantagem competitiva. Cada feature gera aprendizado — sem captura sistemática, esse aprendizado se perde quando alguém sai do time ou quando contexto é trocado. `mb-retro` garante que learnings viram artefatos versionados, evoluem a constitution corporativa e retroalimentam o processo.

## Saídas

- `docs/specs/_active/<feature>/retro.md`
- `.mb/learnings/quarterly-<YYYY-Qn>.md`
- PRs ao `mb-ai-sdk` com propostas de mudança
- Skills custom em `.mb/skills/`
