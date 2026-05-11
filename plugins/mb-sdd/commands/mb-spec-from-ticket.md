---
description: Gera spec inicial a partir de um ticket Jira/Linear
argument-hint: <TICKET-KEY>
---

# /mb-spec-from-ticket

Bootstrap de spec SDD a partir de um ticket existente. Consulta o adapter em `integrations/jira/adapter.sh`, normaliza o ticket e popula `docs/specs/_active/<YYYY-MM-DD>-<ticket>/requirements.md`.

## Uso

```bash
# Mock (offline / CI)
MB_MOCK_JIRA=1 bash plugins/mb-sdd/scripts/spec-from-ticket.sh JIRA-DEMO

# Real
export JIRA_BASE_URL=https://mb.atlassian.net
export JIRA_USER=...
export JIRA_TOKEN=...
bash plugins/mb-sdd/scripts/spec-from-ticket.sh JIRA-1234
```

## Output

`docs/specs/_active/2026-05-11-jira-1234/requirements.md` com seções:

- Contexto do ticket (description importada)
- User stories (esqueleto a preencher)
- Critérios EARS (esqueleto a preencher)
- Fora de escopo
- Clarifications

## Próximos passos sugeridos

1. `/mb-sdd-clarify` — refinar ambiguidades
2. `/mb-sdd-design` — design técnico
3. `/mb-sdd-tasks` — quebra executável

## Linear

Para tickets Linear, defina `MB_TICKET_PROVIDER=linear` e use `integrations/linear/adapter.sh` (compat — gera mesmo JSON canônico). Implementação Linear stub em v1.0; planejada para v1.1.
