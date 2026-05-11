# mb-evals

Framework para avaliar qualidade de features que **usam** IA em runtime — chatbot de suporte, classificação de transações, antifraude, sumarização. Garante que mudança de prompt/modelo não regrediu qualidade.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-evals-init <feature>` | Scaffolding de eval (dataset + rubric + runner) |
| `/mb-evals-run <feature>` | Executa eval, gera relatório |
| `/mb-evals-compare <feature> <ver-a> <ver-b>` | A/B test de prompts/modelos |
| `/mb-evals-ci <feature>` | Modo CI: exit 0/1 conforme threshold |

## Estrutura por feature

```
evals/<feature>/
├── README.md
├── dataset.jsonl          # golden examples
├── rubric.md              # critérios de avaliação
├── runner.sh              # executa o eval
├── threshold.yaml         # passing score
└── runs/
    └── <YYYY-MM-DD-HHMM>-<modelo>.jsonl  # resultados históricos
```

## Tipos de rubrica suportados

- **Determinística** — regex, JSON schema, comparison exata.
- **LLM-as-judge** — score via LLM com prompt versionado.
- **Custom** — script bash/python com lógica do squad.

## Pré-requisitos

- `mb-ai-core` ativo.
- `mb-sdd` recomendado: ciclo SDD ganha fase EVAL extra entre VERIFY e REVIEW para features AI.
- `mb-cost` recomendado: relaciona qualidade vs custo.

## Quando usar

Squad construindo:
- Chatbot, RAG, agente.
- Classificador (fraude, KYC, risk score).
- Sumarização ou tradução.
- Recomendação ou ranking.
- Qualquer pipeline cuja saída precisa ser avaliada e não tem ground truth determinístico.
