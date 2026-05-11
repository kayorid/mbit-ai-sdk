# v1.0 — Maturidade pedagógica

## WHY

v1.0 marca o SDK como pronto para uso corporativo. Sai do "produto interno experimental" para "ferramenta com integrações reais com o stack MB". Inclui: Slack bot funcional (não mais stub), integração Jira/Linear via `/mb-spec-from-ticket`, runbook automático via PagerDuty, programa formal de **certificação** AI Champion, e dashboard de adoção corporativa.

## Stakeholders

- **Squad de Plataforma** — vai operar o Slack bot e os webhooks
- **Tech Leads MB** — recebem dashboard de adoção
- **People/RH** — programa de certificação Champion (atrelado a trilha técnica)
- **SRE/Oncall** — runbook PagerDuty

## User stories

- **US-1** Como dev MB, quero mencionar o bot no Slack `@mbit-ai retro <squad>` e receber resumo da última retro daquele squad.
- **US-2** Como dev MB, quero rodar `/mb-spec-from-ticket JIRA-1234` e ter um `docs/specs/_active/<slug>/requirements.md` gerado a partir do ticket.
- **US-3** Como SRE oncall, quero que incidentes do PagerDuty gerem um runbook automático em `.mb/runbooks/INC-<id>.md` com contexto + comandos sugeridos.
- **US-4** Como Tech Lead, quero `/mb-adoption-report` com adoção por squad, comandos top, gaps de uso.
- **US-5** Como Champion, quero trilha de certificação documentada com 4 níveis (Apprentice → Practitioner → Expert → Master) e critérios objetivos para cada um.

## Critérios de aceitação (EARS)

- **CA-1** Quando o bot Slack receber `@mbit-ai retro <squad>`, o sistema **deve** ler a última retro daquele squad em `.mb/retros/` e responder no thread. Modo offline para testes: lê de `integrations/slack/fixtures/`.
- **CA-2** Quando o usuário invocar `/mb-spec-from-ticket JIRA-XXX`, o sistema **deve** consultar adapter Jira (env `JIRA_BASE_URL`, `JIRA_TOKEN`) ou modo mock (`MB_MOCK_JIRA=1`) e gerar requirements.md preenchido com US/CA.
- **CA-3** Quando webhook PagerDuty for recebido em `integrations/pagerduty/webhook.js`, o sistema **deve** gerar `.mb/runbooks/INC-<id>.md` com seções: contexto, comandos a executar, links.
- **CA-4** Quando o usuário invocar `/mb-adoption-report`, o sistema **deve** mostrar: nº squads ativos, top 10 comandos, distribuição por plugin, % squads sem nenhum retro nos últimos 30 dias.
- **CA-5** Onde houver `docs/governance/champion-certification.md`, o sistema **deve** descrever 4 níveis com critérios mensuráveis (X retros realizadas, Y plugins usados, Z talks dadas, etc).
- **CA-6** Quando `bash tests/e2e/run.sh` for executado com `MB_MOCK_JIRA=1 MB_MOCK_SLACK=1 MB_MOCK_PAGERDUTY=1`, o sistema **deve** validar todos os fluxos integrados em <2min.
- **CA-7** Quando o Slack bot for empacotado (`integrations/slack/package.json`), o sistema **deve** ter scripts `start`, `dev`, `test` funcionais e Dockerfile pronto.

## Fora de escopo

- mb-knowledge-graph (v1.5).
- mb-search semântico (v1.5).
- SIEM integration (v2.0).
- IDE extension (v3.0).
- Open-source seletivo (v3.0).

## Boundaries

- ✅ **Always:** todas as integrações suportam modo mock (`MB_MOCK_*`); credenciais nunca commitadas; logs sem PII.
- ⚠️ **Ask first:** alterar schema de runbook ou de adoção report (afeta consumers downstream).
- 🚫 **Never:** chamar APIs externas em testes; commitar `.env`; permitir comandos arbitrários via Slack.

## Clarifications

- **Q:** Slack bot — Bolt JS ou Bolt Python?
  - **R:** Bolt JS (Node 20). Já é stack frontend MB; mais fácil deploy via container.
- **Q:** Jira adapter — REST v3 ou v2?
  - **R:** REST v3 (Cloud). Para Jira on-prem MB, doc inclui flag `JIRA_LEGACY=1`.
- **Q:** Certificação — quem audita?
  - **R:** Comitê Champion + Chapter AI. Doc inclui template de application + critérios objetivos contabilizados via `mb-leaderboard` (v0.5).
- **Q:** Adoption report tem timeline?
  - **R:** Default 30 dias, flag `--period 90d|1y` opcional.
