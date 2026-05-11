---
name: mb-evals
description: Use ao desenhar, executar ou comparar avaliações de qualidade de features que usam IA em runtime (chatbot, classificador, sumarização, RAG, antifraude). Acione quando o usuário disser "eval", "avaliar prompt", "rubrica", "golden dataset", "qualidade do modelo", "A/B prompt", "comparar modelos", "regressão de qualidade", "LLM-as-judge". Distingue da skill mb-sdd (que avalia código) — esta avalia saída de modelos. Produz dataset.jsonl + rubric.md + runner.sh + threshold.yaml por feature.
---

# MB Evals

Framework de avaliação de IA em produção. Garante que toda feature AI tem:
1. **Dataset golden** — exemplos representativos com saída esperada.
2. **Rubrica** — critérios objetivos para julgar saídas.
3. **Runner** — script que executa o eval contra dataset.
4. **Threshold** — passing score acordado com produto.
5. **Histórico** — runs versionadas para detectar regressão.

## Quando aplicar

- Feature nova que envolve LLM em runtime.
- Mudança de prompt/modelo (sempre rodar antes de PR).
- A/B test entre versões.
- Auditoria periódica de qualidade.

## Fluxo

### 1. Init (uma vez por feature)

`/mb-evals-init <feature>` cria scaffolding em `evals/<feature>/`.

### 2. Construir dataset golden

`dataset.jsonl` — uma linha por exemplo, formato:
```json
{"id": "001", "input": {...}, "expected": {...}, "tags": ["edge-case", "happy-path"]}
```

Tamanho mínimo recomendado:
- Chatbot/RAG: 50+ exemplos (mix de cenários).
- Classificador: 200+ exemplos balanceados.
- Sumarização: 30+ documentos com summaries de referência.

### 3. Definir rubrica

`rubric.md` lista critérios:
```markdown
## Critérios

### C-1: Resposta correta (peso 40%)
- Determinística: comparar `output.label == expected.label`.
- Fonte: dataset.

### C-2: Citação correta (peso 30%)
- LLM-as-judge.
- Prompt: "Avalie 1-5 se a citação X suporta a afirmação Y..."

### C-3: Tom apropriado (peso 30%)
- Custom script: detecta tom formal/informal via regex.

## Threshold
- Passing: score ponderado >= 0.85
- Failing: < 0.70 → bloqueia PR
```

### 4. Implementar runner

`runner.sh` — chama o sistema sob teste para cada exemplo, aplica rubrica, calcula score.

### 5. Rodar e comparar

- `/mb-evals-run` — eval simples, gera relatório.
- `/mb-evals-compare prompt-v1 prompt-v2` — A/B side-by-side.
- `/mb-evals-ci` — em PR, falha se abaixo do threshold.

## Princípios

- **Eval é parte do contrato** — sem dataset golden, feature AI não vai a produção.
- **Threshold acordado com produto** — não é decisão técnica unilateral.
- **Versionar tudo** — dataset, rubric, prompt, modelo, run results.
- **Custo importa** — rodar eval frequente em LLM caro vira problema; equilibrar.
- **LLM-as-judge é frágil** — sempre ter um critério determinístico se possível.

## Integração com mb-sdd

Para feature AI, fase VERIFY do ciclo SDD ganha sub-fase EVAL:
- `verification.md` referencia `evals/<feature>/runs/<latest>.jsonl`.
- Score abaixo do threshold = não pode SHIP.
