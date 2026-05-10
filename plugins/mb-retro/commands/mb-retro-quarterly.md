---
description: Agrega retros do trimestre e gera relatório executivo de tendências e propostas
argument-hint: [YYYY-Qn]
---

# /mb-retro-quarterly

Invoque a skill `mb-learning-extractor`:

1. Identifique o trimestre (argumento ou trimestre corrente).
2. Colete retros de `docs/specs/_archive/<YYYY-Qn>/*/retro.md`.
3. Categorize achados (positivos repetidos, fragilidades repetidas, surpresas convergentes).
4. Identifique padrões promovíveis (≥3 ocorrências).
5. Gere `.mb/learnings/quarterly-<YYYY-Qn>.md` com:
   - Fontes
   - Padrões
   - Propostas (constitution, hooks, skills, refinamentos)
   - Métricas do trimestre
6. Sugira PRs concretos para propostas maduras.
7. Material vai para reunião mensal/trimestral da comunidade de AI Champions.

Commit:
```
git commit -m "[learnings] consolidação trimestral <YYYY-Qn>"
```
