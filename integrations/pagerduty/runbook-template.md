# Runbook — INC-{{id}}

> **{{title}}**
> Urgência: **{{urgency}}** · Serviço: **{{service}}** · Criado em: {{created_at}}
> Origem: [{{url}}]({{url}})

## Contexto

{{description}}

## Diagnóstico inicial (sugerido)

1. Confirmar escopo do impacto:
   - `kubectl get pods -n {{service}}` (ou equivalente)
   - Conferir SLO no dashboard do serviço
2. Verificar deploys recentes:
   - `git log --oneline --since="2 hours ago" -- <path do serviço>`
3. Ativar canal de incidente no Slack: `#inc-{{id}}`

## Mitigações comuns

- [ ] Rollback do último deploy se < 1h
- [ ] Aumentar capacidade temporariamente (HPA / réplicas)
- [ ] Ativar feature flag de degradação se aplicável
- [ ] Notificar squads upstream/downstream

## Após mitigação

- [ ] Rodar `/mb-retro --post-mortem INC-{{id}}` no Claude Code
- [ ] Atualizar `docs/specs/_active/` com post-mortem
- [ ] Identificar lição reutilizável → `/mb-retro-promote`

## Histórico

_Adicione abaixo o timeline do incidente conforme evolui._

- {{created_at}} — incidente disparado
