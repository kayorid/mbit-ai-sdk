# mb-cost

Exposição de custo de IA — princípio MBit #9: "custo de IA é decisão de engenharia". Sem visibilidade, custo escala silenciosamente.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-cost` | Resumo do dia/semana corrente |
| `/mb-cost-feature <slug>` | Custo total de uma feature por fase |
| `/mb-cost-budget set <valor>` | Define orçamento mensal do squad |
| `/mb-cost-alert` | Alerta se consumo > X% do budget |

## Mecânica

- Hook `PostToolUse` captura input/output tokens reportados nos resultados de tool.
- Persiste em `.mb/audit/cost.log` (linha por evento, append-only).
- Agrega por fase SDD (lê spec ativa), feature, dia, dev.

Esquema do log:

```
2026-05-10T14:32:11Z | feature=onboarding-v2 | phase=DESIGN | tool=Read | in_tokens=2400 | out_tokens=850 | model=claude-opus | actor=joao@mb
```

## Pré-requisitos

- `mb-ai-core` ativo (constitution + audit dir).
- Idealmente `mb-sdd` (para mapear fase atual).
