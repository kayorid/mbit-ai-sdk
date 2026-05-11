# v1.0 — Design técnico

## Arquitetura

```
integrations/
├── slack/
│   ├── app.js                  (Bolt JS)
│   ├── package.json
│   ├── Dockerfile
│   ├── handlers/
│   │   ├── retro.js
│   │   └── help.js
│   ├── adapters/
│   │   └── retro-reader.js
│   ├── fixtures/               (mock para tests)
│   ├── manifest.yaml           (existente)
│   └── README.md               (deploy + env)
├── jira/
│   ├── adapter.sh              (curl + jq)
│   ├── mock-fixtures/
│   └── README.md
└── pagerduty/
    ├── webhook.js              (Express)
    ├── runbook-template.md
    ├── mock-fixtures/
    └── README.md

plugins/mb-sdd/
└── commands/
    └── mb-spec-from-ticket.md  (novo) → invoca integrations/jira/adapter.sh

plugins/mb-retro/
└── commands/
    └── mb-adoption-report.md   (novo) → script em scripts/adoption-report.sh

docs/governance/
└── champion-certification.md   (novo)
```

## Contratos

### Slack bot
- **Stack:** Node 20, @slack/bolt 3.x
- **Triggers:** `app_mention` → comandos: `retro <squad>`, `help`, `status`
- **Env:** `SLACK_BOT_TOKEN`, `SLACK_SIGNING_SECRET`, `MB_RETROS_PATH` (default `.mb/retros`)
- **Mock mode:** `MB_MOCK_SLACK=1` → bot inicia em modo dry-run lendo fixtures, não conecta a Slack.

### Jira adapter
- **Input:** ticket key (JIRA-1234)
- **Output:** JSON com `{title, description, acceptance_criteria, stakeholders}`
- **Modo:** `MB_MOCK_JIRA=1` lê de `integrations/jira/mock-fixtures/JIRA-1234.json`.
- **Real:** `curl -u "$JIRA_USER:$JIRA_TOKEN" $JIRA_BASE_URL/rest/api/3/issue/$KEY | jq ...`

### `/mb-spec-from-ticket`
- Invoca adapter, popula template `docs/specs/_active/<slug>/requirements.md`.
- Slug: `<YYYY-MM-DD>-<ticket-lower>` (ex.: `2026-05-11-jira-1234`).

### PagerDuty webhook
- **Stack:** Node 20, Express 4
- **Endpoint:** `POST /webhook` valida assinatura `X-PagerDuty-Signature`
- **Output:** escreve `.mb/runbooks/INC-<id>.md` baseado em `runbook-template.md`
- **Mock:** invocar diretamente `node webhook.js --mock fixtures/inc-001.json`

### `/mb-adoption-report`
- Lê `git log` (commits `[squad:X]`), `.mb/retros/`, `.mb/achievements.json`
- Output: terminal table + opcional `--json` para CI/dashboard

## Mudanças por arquivo

| Arquivo | Mudança |
|---|---|
| `integrations/slack/app.js` | **novo** |
| `integrations/slack/package.json` | **novo** (Bolt + deps) |
| `integrations/slack/Dockerfile` | **novo** |
| `integrations/slack/handlers/{retro,help}.js` | **novos** |
| `integrations/slack/adapters/retro-reader.js` | **novo** |
| `integrations/slack/fixtures/` | mock retros |
| `integrations/slack/test/app.test.js` | **novo** (node:test) |
| `integrations/slack/README.md` | **novo** ou substitui stub |
| `integrations/jira/adapter.sh` | **novo** |
| `integrations/jira/mock-fixtures/JIRA-DEMO.json` | **novo** |
| `integrations/jira/README.md` | **novo** |
| `integrations/pagerduty/webhook.js` | **novo** |
| `integrations/pagerduty/runbook-template.md` | **novo** |
| `integrations/pagerduty/mock-fixtures/inc-demo.json` | **novo** |
| `integrations/pagerduty/package.json` | **novo** |
| `integrations/pagerduty/README.md` | **novo** |
| `plugins/mb-sdd/commands/mb-spec-from-ticket.md` | **novo** |
| `plugins/mb-sdd/scripts/spec-from-ticket.sh` | **novo** |
| `plugins/mb-retro/commands/mb-adoption-report.md` | **novo** |
| `plugins/mb-retro/scripts/adoption-report.sh` | **novo** |
| `docs/governance/champion-certification.md` | **novo** |
| `tests/e2e/run.sh` | adiciona fluxos integrações com mocks |
| `tests/smoke/run.sh` | testes para CA |
| `tests/completeness-check.sh` | atualiza |
| `CHANGELOG.md`, `RELEASE-NOTES.md`, `MIGRATION.md` | seção v1.0 |
| `plugins/*/plugin.json` + marketplace | bump 0.5.0 → 1.0.0 |

## Riscos

- Slack bot real exige token/secret nunca commitados. **Mitigação:** `.env.example`, doc explícita, hook bloqueante em segredos cobre.
- PagerDuty webhook precisa endpoint público. **Mitigação:** doc inclui setup com cloudflared/tunnel para dev; produção fica a cargo da Plataforma MB.
- Certificação pode virar burocracia. **Mitigação:** critérios numéricos auto-computáveis via `mb-adoption-report --champions`.
- Node como nova dep para o repo (até agora puro shell). **Mitigação:** Node fica isolado em `integrations/`; tests E2E pulam graciosamente se `node` não estiver instalado.

## Alternativas consideradas

- Slack bot em Python (Bolt PY) — Node ganha por stack uniforme e deploy mais simples.
- PagerDuty via Lambda — over-engineering; Express container é mais portátil.
- Jira adapter como plugin Node — overkill; bash + curl + jq basta.
