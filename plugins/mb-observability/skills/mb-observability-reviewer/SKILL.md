---
name: mb-observability-reviewer
description: Use para auditar a observabilidade de código já implementado. Acione antes de SHIP, ou quando o usuário pedir "verificar instrumentação", "auditar observabilidade", "tem log/métrica suficiente?". Compara implementação com OBSERVABILITY.md (se existe) ou com checklist padrão. Produz seção "Observability" no REVIEW.md ou OBSERVABILITY-REVIEW.md dedicado.
---

# MB Observability Reviewer

Audita código contra checklist de observabilidade.

## Como aplicar

1. Leia `OBSERVABILITY.md` da feature (se existir). Se não, oriente criar via `/mb-observability-design`.
2. Liste arquivos da feature.
3. Para cada arquivo:
   - **Logs:** estruturado? PII vazando? níveis corretos? trace_id propagado?
   - **Métricas:** instrumentação presente nos pontos definidos? labels sem cardinalidade explosiva?
   - **Traces:** spans criados em operações significativas? contexto propagado em chamadas externas?
   - **Erros:** classificados (transient vs permanent)? mensagens acionáveis?
4. Verifique alertas e runbooks:
   - Cada alerta tem runbook?
   - Runbooks têm passos concretos?
5. SLOs:
   - Definidos? Calculáveis pelas métricas existentes?

## Checklist resumido

| Item | OK? |
|------|-----|
| Logs estruturados (JSON)? | |
| trace_id em todo log? | |
| PII mascarada/ausente em logs? | |
| Métricas RED para todos endpoints? | |
| Cardinalidade de labels controlada? | |
| Trace context propagado em chamadas externas? | |
| Spans em operações async? | |
| Alertas com runbook? | |
| Alertas sobre sintoma (não causa)? | |
| SLO definido e calculável? | |
| Eventos de auditoria em sink separado? | |

## Saída

Adicione seção `## Observability` ao `REVIEW.md` da feature, ou crie `OBSERVABILITY-REVIEW.md` se análise extensa.

Findings:
- BLOCK: ausência de instrumentação em fluxo crítico, PII em log.
- HIGH: alerta sem runbook, métrica de domínio crítica ausente.
- MEDIUM: estrutura de log inconsistente, cardinalidade alta.
- LOW: nomenclatura.
