---
description: Leaderboard saudável agregado por squad (nunca por pessoa)
argument-hint: [--period 30d|90d|365d]
---

# /mb-leaderboard

Mostra adoção do SDK agregada por squad. **Nunca exibe ranking individual de pessoas** — princípio explícito da comunidade MB AI Champions (`docs/governance/ai-champions.md`).

## O que mostra

1. Top 5 squads por **diversidade de comandos** (não volume) usados no período
2. Top 5 squads por **retros realizadas**
3. **Conquistas mais raras** desbloqueadas no repositório

## Como rodar

```bash
bash plugins/mb-retro/scripts/leaderboard.sh           # default 90 dias
bash plugins/mb-retro/scripts/leaderboard.sh --period 30d
bash plugins/mb-retro/scripts/leaderboard.sh --period 365d
```

## Fontes de dados

- `git log` do repo (commits `[<categoria>(:squad:nome)]`)
- `.mb/retros/`, `docs/specs/_archive/*/retro.md`, `docs/specs/_completed/*/retro*.md`
- `.mb/achievements.json`

## Privacidade

Squads com <3 commits no período são agrupados como "outros". Dados pessoais nunca são lidos nem exibidos.
