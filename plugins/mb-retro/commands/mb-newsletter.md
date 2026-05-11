---
description: Gera newsletter trimestral (Markdown + HTML) a partir das retros recentes
argument-hint: [YYYY-Qn]
---

# /mb-newsletter

Gera **newsletter trimestral** consolidando retros do período em `docs/newsletter/<YYYY-QN>.md` + `.html`.

Diferente de `/mb-retro-quarterly` (que invoca a skill `mb-learning-extractor` para gerar análise narrativa), este comando produz **artefato distribuível** pronto para email/intranet — HTML inline-styled compatível com Gmail/Outlook.

## Como rodar

```bash
bash plugins/mb-retro/scripts/newsletter.sh           # trimestre atual
bash plugins/mb-retro/scripts/newsletter.sh 2026-Q2   # trimestre específico
```

## Output

- `docs/newsletter/<YYYY-QN>.md` — leitura humana / fonte para revisão
- `docs/newsletter/<YYYY-QN>.html` — pronto para distribuição (inline CSS)

## Seções geradas

1. **Highlights** — linhas marcadas com `## Highlight`, `✨` ou `## Decisão` nas retros
2. **Blockers recorrentes** — heurística por `block`, `🚨`, `fragilidade`, `impedimento`
3. **Squads em destaque** — proxy por quantidade de retros realizadas

## Cadência sugerida

**1x por trimestre.** Não há cron automático — disparar manualmente após o último retro do trimestre. Revisar o Markdown antes de distribuir o HTML.
