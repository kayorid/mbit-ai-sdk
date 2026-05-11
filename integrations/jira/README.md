# Integração Jira

Adapter shell que normaliza um ticket Jira para JSON canônico usado pelo SDK.

## Uso

### Mock (testes / CI)

```bash
MB_MOCK_JIRA=1 bash integrations/jira/adapter.sh JIRA-DEMO
```

### Real (Jira Cloud)

```bash
export JIRA_BASE_URL=https://mb.atlassian.net
export JIRA_USER=devops@mercadobitcoin.com.br
export JIRA_TOKEN=ATATT...
bash integrations/jira/adapter.sh JIRA-1234
```

### Jira on-prem (legacy v2 API)

```bash
export JIRA_LEGACY=1
# resto igual
```

## Output canônico

```json
{
  "key": "JIRA-DEMO",
  "title": "...",
  "description": "...",
  "status": "To Do",
  "reporter": "...",
  "type": "Story",
  "labels": [],
  "url": "https://..."
}
```

Consumido pelo comando `/mb-spec-from-ticket` para gerar `docs/specs/_active/<slug>/requirements.md`.

## Segurança

- Token nunca commitado (`pre-write-guard.sh` bloqueia).
- Adapter não envia dados a terceiros — só lê do Jira.
- Em produção MB, rodar via cofre de credenciais da Plataforma.
