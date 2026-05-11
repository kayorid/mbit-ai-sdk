# Retrospectiva — Sprint 2026.05

Squad: cambio

## Highlights
- Latência do endpoint /quote caiu 35% após migração para cache local.
- Cobertura de eval da feature "explain-quote" atingiu 92%.

## Decisões
- Adotar fallback síncrono para Redis fora.
- Migrar de Sentry para OTLP até fim do trimestre.

## Aprendizados
- Hook `pre-write-guard` evitou commit de CPF de teste real (2 ocorrências).
- AI Lab de Observability ajudou novos devs a calibrar SLOs.
