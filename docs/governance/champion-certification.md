# MB AI Champion · Programa de Certificação

> Trilha de **4 níveis** com critérios mensuráveis, complementar (não substitui) à comunidade aberta descrita em `ai-champions.md`.

## Filosofia

Certificação é **opcional** e **acumulativa**. Existe para:
- Sinalizar profundidade técnica em ferramental MB AI
- Atrelar reconhecimento formal à trilha de carreira (em conjunto com People)
- Dar critério objetivo onde antes havia indicação subjetiva

**Não é**: gatekeeping para usar o SDK; nem requisito para participar da comunidade.

## Níveis

### Apprentice — "Iniciado"

**Pré-requisitos** (todos):
- ≥ 3 ciclos SDD completos como contribuinte principal
- ≥ 5 commits taggeados ao MBit em seu squad
- ≥ 1 hook bloqueante respeitado (não bypassado) com retro registrado
- Onboarding interno feito (≥ 2 AI Labs assistidos)

**Avaliação**: 1 entrevista (30min) com Champion ativo.

**Reconhecimento**: badge `mbit-apprentice` em `.mb/people.json` (opt-in).

---

### Practitioner — "Praticante"

**Pré-requisitos** (Apprentice +):
- ≥ 1 PR mergeado ao mbit-ai-sdk (correção, doc ou comando novo)
- ≥ 1 retrospectiva facilitada (não apenas participada)
- ≥ 1 padrão promovido via `/mb-retro-promote`
- Demonstrar domínio dos 4 plugins core: `mb-sdd`, `mb-review`, `mb-observability`, `mb-security`

**Avaliação**: code review pareado com 2 Champions ativos + apresentação curta (15min) em reunião comunitária.

**Reconhecimento**: badge `mbit-practitioner` + elegibilidade para facilitar AI Labs.

---

### Expert — "Especialista"

**Pré-requisitos** (Practitioner +):
- ≥ 3 PRs mergeados ao mbit-ai-sdk (≥ 1 hook ou skill nova)
- ≥ 2 AI Labs facilitados como host principal
- ≥ 1 sessão de onboarding de squad novo conduzida
- Contribuição mensurável ao charter, governance ou roadmap (commit em `docs/governance/` ou `docs/plans/`)

**Avaliação**: dossiê + entrevista painel com 3 Champions ativos + chapter AI.

**Reconhecimento**: badge `mbit-expert` + cadeira rotativa no Comitê Champion + indicação para representar MB em eventos externos sobre AI eng. interna.

---

### Master — "Mestre"

**Pré-requisitos** (Expert +):
- ≥ 1 plugin novo no mbit-ai-sdk como autor principal **ou** ≥ 1 milestone de roadmap entregue como tech lead
- Reconhecimento sustentado da comunidade (≥ 75% dos Champions ativos endossam)
- Contribuição estratégica documentada em ADR ou RFC corporativo
- ≥ 12 meses como Expert ativo

**Avaliação**: nomeação pelo Comitê + ratificação por Chapter AI + endorso de Diretoria.

**Reconhecimento**: badge `mbit-master` + co-design do roadmap anual + mentoria formal a Practitioners e Experts.

---

## Critérios computáveis automaticamente

A maioria dos pré-requisitos é auditável via:

```bash
bash plugins/mb-retro/scripts/adoption-report.sh --period 365d --json
bash plugins/mb-retro/scripts/leaderboard.sh --period 365d
```

Métricas extraídas automaticamente:
- PRs mergeados (via `gh pr list --author <user> --state merged --repo kayorid/mbit-ai-sdk`)
- Ciclos SDD (via `git log --grep "[spec:" --author <user>`)
- Retros facilitadas (via campo `Facilitador:` nas retros)
- Padrões promovidos (via commits `[learnings] consolidação`)

## Cadência de avaliação

| Nível | Frequência mínima entre avaliações |
|---|---|
| Apprentice | Sob demanda |
| Practitioner | Trimestral |
| Expert | Semestral |
| Master | Anual |

## Saída / desafiliação

- Inativo por 12 meses consecutivos → nível baixado um degrau (revisão anual).
- Violação de boundaries (ranking individual público, bypass de hooks bloqueantes, exposição de PII) → Comitê delibera (até suspensão completa).

## Revisão

Este programa é revisado **anualmente**. Última revisão: 2026-05-11 (v1.0.0).
