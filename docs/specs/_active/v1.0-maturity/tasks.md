# v1.0 — Tasks

## Slack bot
- [ ] T1 — `integrations/slack/package.json` com Bolt 3.x, scripts start/dev/test. [P]
- [ ] T2 — `integrations/slack/app.js` boot + mock-mode flag. [depende T1]
- [ ] T3 — `integrations/slack/handlers/retro.js` + `help.js`. [depende T2]
- [ ] T4 — `integrations/slack/adapters/retro-reader.js`. [P]
- [ ] T5 — `integrations/slack/fixtures/` + `test/app.test.js` (node:test). [depende T3, T4]
- [ ] T6 — `Dockerfile` + `README.md` (deploy + env). [depende T2]

## Jira
- [ ] T7 — `integrations/jira/adapter.sh` com mock-mode. [P]
- [ ] T8 — `integrations/jira/mock-fixtures/JIRA-DEMO.json` + `README.md`. [P]
- [ ] T9 — `plugins/mb-sdd/scripts/spec-from-ticket.sh` + `commands/mb-spec-from-ticket.md`. [depende T7]

## PagerDuty
- [ ] T10 — `integrations/pagerduty/package.json` + `webhook.js`. [P]
- [ ] T11 — `runbook-template.md` + `mock-fixtures/inc-demo.json`. [P]
- [ ] T12 — `README.md` (deploy + env + signature validation). [depende T10]

## Comandos novos
- [ ] T13 — `plugins/mb-retro/scripts/adoption-report.sh` + `commands/mb-adoption-report.md`. [P]

## Docs
- [ ] T14 — `docs/governance/champion-certification.md` (4 níveis + critérios). [P]

## Integração & testes
- [ ] T15 — Atualizar `tests/e2e/run.sh` para incluir fluxos mock (slack/jira/pagerduty). [depende T1-T13]
- [ ] T16 — Testes smoke para CA-1..CA-7.
- [ ] T17 — Atualizar `tests/completeness-check.sh` com novos arquivos.
- [ ] T18 — `/mb-help` referencia novos comandos. [depende T9, T13]

## Release
- [ ] T19 — `[CHECKPOINT]` Bump 0.5.0 → 1.0.0 em 9 plugins + marketplace. CHANGELOG + RELEASE-NOTES + MIGRATION.
- [ ] T20 — Rodar smoke + completeness + e2e. Commit `feat: MBit v1.0.0 — maturidade pedagógica`. Tag `v1.0.0`. Mover specs para `_completed/`.
