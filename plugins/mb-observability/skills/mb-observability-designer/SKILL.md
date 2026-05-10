---
name: mb-observability-designer
description: Use ao desenhar observabilidade para uma feature nova ou existente. Acione na fase PLAN do ciclo SDD, ou quando o usuário pedir "como instrumentar isso", "que métricas adicionar", "preciso desenhar observabilidade", "qual SLO definir", "que alertas criar". Stack-agnostic — opina sobre o que observar, não sobre qual ferramenta usar. Produz OBSERVABILITY.md estruturado.
---

# MB Observability Designer

Subagente que conduz design de observabilidade. Cobre logs, métricas, traces, eventos de domínio, alertas e SLOs.

## Como aplicar

### 1. Entender a feature

Leia `requirements.md` e `design.md`. Identifique:
- Fluxos principais (happy path).
- Pontos de integração (DB, APIs externas, filas, blockchains).
- Ações de domínio relevantes (criar ordem, executar trade, mover fundos).
- Operações irreversíveis ou financeiras.

### 2. Levantar o "para quem é"

Pergunte ao usuário:
- **Operação:** quem vai ser paginado quando isso quebrar?
- **Negócio:** quem precisa ver tendência (volume, conversão, falhas)?
- **Auditoria:** quem precisa rastrear "quem fez o quê, quando" (compliance)?
- **Dev:** quem vai depurar quando algo der errado em produção?

### 3. Propor instrumentação por dimensão

#### Logs (eventos)
Para cada operação relevante:
- **Nível:** INFO (acontecimento normal), WARN (anomalia tolerada), ERROR (falha).
- **Estrutura:** JSON com `timestamp`, `level`, `event`, `trace_id`, `user_id` (anonimizado), `tenant_id`, dados específicos.
- **Não logar:** PII, segredos, dados regulados completos.
- **Eventos de auditoria** (compliance): em sink separado, append-only, retenção definida.

#### Métricas (RED + USE + golden signals)
- **RED (Request-level):** Rate, Errors, Duration.
  - `<service>_requests_total` (counter, labels: route, method, status_class).
  - `<service>_request_duration_seconds` (histogram, labels: route, method).
  - `<service>_errors_total` (counter, labels: route, method, error_type).
- **USE (Resource-level):** Utilization, Saturation, Errors.
  - CPU, memória, conexões DB, fila size.
- **Golden signals:** latency, traffic, errors, saturation.
- **Métricas de domínio:** ordens criadas/min, volume negociado, retiradas pendentes.

#### Traces
- Trace context propagado em **toda** chamada externa (HTTP header `traceparent`, gRPC metadata).
- Spans por operação significativa (DB query, API externa, processamento async).
- Atributos relevantes (user_id, tenant_id, order_id) — sem PII bruto.

#### Alertas
Para cada SLO ou métrica crítica:
- **Sintoma vs causa:** alerta sobre sintoma (latência alta, taxa de erro), causa investigada via traces/logs.
- **Acionável:** alerta sem ação clara é ruído — defina runbook na criação.
- **Severidade:** P1 (acordar dev), P2 (próximo dia útil), P3 (backlog).
- **Anti-pattern:** alertar em métrica de baixo nível (CPU 80%) sem impacto em sintoma.

#### SLOs
Para a feature, defina ao menos:
- **SLI** (indicador): ex. `% de requests com latência < 500ms`.
- **SLO** (objetivo): ex. `99.5% em janela de 30 dias`.
- **Error budget:** derivado do SLO; consumo gera ações.

### 4. Produzir OBSERVABILITY.md

Use template `assets/templates/OBSERVABILITY.md.tpl`:

```markdown
# Observability — <feature>

## Contexto
- Fluxos cobertos: ...
- Audiência: operação / negócio / auditoria / dev

## Logs
| Evento | Nível | Campos | Sink | Retenção |
|--------|-------|--------|------|----------|
| order_created | INFO | user_id_hash, order_id, pair, qty | std + audit | 90d / 7y |

## Métricas
| Métrica | Tipo | Labels | Fonte |
|---------|------|--------|-------|
| orders_total | counter | pair, side | service |

## Traces
- Contexto propagado em: HTTP, gRPC, Kafka headers
- Spans relevantes: ... atributos: ...

## Alertas
| Alerta | Condição | Severidade | Runbook |
|--------|----------|-----------|---------|
| order_error_rate_high | rate(errors)/rate(total) > 5% por 5min | P1 | .mb/runbooks/orders-error.md |

## SLOs
| SLI | SLO | Janela | Error budget |
|-----|-----|--------|--------------|
| % requests <500ms | 99.5% | 30d | 3.6h |
```

### 5. Integração com o SDK

- Mencione no `design.md` da feature: "ver `OBSERVABILITY.md`".
- Crie tasks em `tasks.md` para cada peça de instrumentação não trivial.
- Para cada alerta, crie ou referencie um runbook (chame `/mb-runbook-from-incident` se aplicável).

## Princípios

- **Observe sintomas que afetam usuários, não componentes.**
- **Estruture logs desde o início.** JSON > texto.
- **Trace é para entender o "por quê"; métricas são para responder "o quê".**
- **Alerta sem runbook é dívida operacional.**
- **Custo importa.** Logs verbosos custam caro em volume — equilibre detalhe e custo.
