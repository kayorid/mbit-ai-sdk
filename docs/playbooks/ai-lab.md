# MB AI Lab — Workshop hands-on quinzenal

> Workshop curto (90min) onde um Champion facilita uma trilha prática do SDK.

## Estrutura padrão

| Tempo | Atividade |
|---|---|
| 0-10min | Contexto: por que essa trilha, em que squad ela apareceu |
| 10-60min | Hands-on guiado (todos rodam no laptop) |
| 60-75min | Q&A + casos reais |
| 75-90min | Retro relâmpago do Lab + próximos passos |

## Trilhas iniciais (6)

### Trilha 1 — Spec-Driven Development na prática

**Objetivo:** participante sai com uma spec real escrita em pt-BR, EARS notation, validada com `scripts/validate_spec.py`.

**Sequência:**
1. `bash plugins/mb-sdd/scripts/init-spec.sh minha-feature`
2. Preencher `requirements.md` com 3 user stories + 5 critérios EARS
3. Rodar `/mb-spec-review` (gera feedback automatizado)
4. Discutir ambiguidades em pares

**Pré-requisito:** SDK instalado, plugin mb-sdd ativo.

### Trilha 2 — Observability como primeira classe

**Objetivo:** instrumentar 1 endpoint dummy com logs estruturados + métricas + 1 trace.

**Sequência:**
1. Abrir repo dummy do Lab (`tests/e2e/fixtures/`)
2. Rodar `/mb-obs-checklist` no endpoint
3. Implementar correções; rodar `/mb-obs-slo` para definir SLO
4. Discutir trade-offs (cardinalidade, custo de armazenamento)

### Trilha 3 — Security gates como reflexo

**Objetivo:** entender por que cada hook bloqueante existe e como contribuir com novos.

**Sequência:**
1. Tentar commitar segredos / CPF / chave em sandbox — ver bloqueio
2. Ler `plugins/mb-security/hooks/scripts/pre-write-guard.sh`
3. Propor regra nova (formato livre), discutir falsos-positivos
4. Esboçar PR com regra + teste smoke

### Trilha 4 — Cost-aware coding

**Objetivo:** entender como o SDK captura custo de IA e quando vale otimizar.

**Sequência:**
1. Rodar `/mb-cost-report` no repo do Lab
2. Identificar prompts caros (top 3)
3. Aplicar técnicas: caching, modelo menor, truncamento
4. Comparar antes/depois

### Trilha 5 — Evals de features de IA

**Objetivo:** escrever 1 conjunto de eval para uma feature AI hipotética e rodar.

**Sequência:**
1. `/mb-evals-init <feature>`
2. Definir golden dataset (5-10 exemplos)
3. Escrever rubricas / asserts
4. Rodar `/mb-evals-run` e analisar resultado

### Trilha 6 — Retrospectivas que geram aprendizado

**Objetivo:** retro de feature real culminando em padrão promovido para o core (via `/mb-retro-promote`).

**Sequência:**
1. Escolher feature recentemente entregue
2. Rodar `/mb-retro` (estrutura guiada)
3. Identificar 1 padrão repetível
4. Propor inclusão em `constitution.md` ou novo hook

## Template de proposta de Lab

Qualquer Champion pode propor sessão preenchendo:

```markdown
## Lab: <título>
- **Facilitador:** <nome>
- **Trilha:** <1-6 ou nova>
- **Data sugerida:** YYYY-MM-DD
- **Pré-requisitos:** ...
- **Output esperado:** o que cada participante leva
```

PR para `docs/playbooks/labs/YYYY-MM-DD-<slug>.md`.

## Cadência

Quinzenal, 90min, em janela protegida (sem reuniões em paralelo). Rotativo entre Champions; alvo: 6+ Labs por trimestre.
