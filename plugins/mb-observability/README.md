# mb-observability

Garante que toda feature nova nasça com observabilidade adequada — sem opinar sobre stack (Datadog, Grafana+Prometheus, NewRelic, OTel são equivalentes para o SDK).

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-observability-design` | Design de observabilidade para a feature corrente (gera OBSERVABILITY.md) |
| `/mb-observability-review` | Audita implementação contra checklist de observabilidade |
| `/mb-runbook-from-incident <descrição>` | Gera runbook a partir de incidente recente |

## Skills

- `mb-observability-designer` — entrevista o dev sobre fluxos críticos e propõe instrumentação.
- `mb-observability-reviewer` — audita código contra checklist.

## Filosofia

Observabilidade não é opcional para sistemas em produção — especialmente em uma exchange. O SDK define **o que** observar (RED, USE, golden signals, eventos de domínio) e deixa **como** instrumentar para o squad escolher conforme stack.

## Saídas

- `docs/specs/_active/<feature>/OBSERVABILITY.md` por feature.
- `.mb/runbooks/<runbook>.md` por incidente/fluxo.
