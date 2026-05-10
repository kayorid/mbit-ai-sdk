# Integração Slack — `mbit-bot`

Bot Slack que expõe comandos do MBit no workspace e envia notificações de eventos relevantes.

**Status:** Scaffolding inicial (v0.5 — implementação completa em onda 3).

## Arquitetura proposta

```
┌────────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Slack workspace MB │────▶│ mbit-bot (Lambda)│────▶│ GitHub Enterprise│
│  /mb-status @squad │     │ Bolt for Python  │     │ - issues         │
│  notifs em canais  │     │                  │     │ - PR comments    │
└────────────────────┘     └──────────────────┘     └──────────────────┘
                                    │
                                    ▼
                           ┌──────────────────┐
                           │ Audit logs       │
                           │ (CloudWatch)     │
                           └──────────────────┘
```

## Comandos planejados

| Slash | Resposta |
|-------|----------|
| `/mbit help` | Visão geral do SDK |
| `/mbit status @squad` | Status do squad (specs ativas, achievements, métricas) |
| `/mbit dashboard @squad` | Painel ASCII renderizado como bloco Slack |
| `/mbit cost @squad` | Custo de IA do mês |
| `/mbit propose <texto>` | Abre proposta ao SDK |

## Notificações automáticas

| Canal | Evento |
|-------|--------|
| `#mb-ai-sdk` | Release nova do SDK |
| `#mb-ai-sdk` | Achievement de squad desbloqueado |
| `#mb-ai-security` | Hook de SEGURANÇA bloqueou em CI |
| `#mb-ai-security` | Exceção crítica aberta |
| `<canal-do-squad>` | Spec entrou em fase REVIEW |
| `<canal-do-squad>` | Custo do mês passou de 85% do budget |

## Stack proposta

- **Runtime:** AWS Lambda (Python 3.11) + API Gateway.
- **Framework:** [Slack Bolt for Python](https://slack.dev/bolt-python/).
- **Storage:** DynamoDB para mapeamento `squad ↔ canal ↔ repo`.
- **Auth:** OAuth Slack + token interno para chamar GitHub Enterprise.
- **Deploy:** Terraform no AWS account corp Chapter AI.

## Próximos passos (v1.0)

1. Setup do app Slack com manifest declarativo.
2. Webhook receiver no Lambda.
3. Implementar `/mbit status` como primeiro comando (read-only).
4. Adicionar notificação de release.
5. Iterar com squads piloto.

## Manifest stub

`integrations/slack/manifest.yaml` — manifesto declarativo a usar no Slack App config (placeholder até deploy real).

```yaml
display_information:
  name: MBit
  description: Harness de IA do MB
  background_color: "#E8550C"
features:
  bot_user:
    display_name: MBit
    always_online: true
  slash_commands:
    - command: /mbit
      url: https://mbit-bot.mercadobitcoin.com.br/slack/commands
      description: Comandos do MBit
      usage_hint: "help | status | dashboard | cost | propose"
oauth_config:
  scopes:
    bot:
      - chat:write
      - commands
      - users:read
settings:
  event_subscriptions:
    request_url: https://mbit-bot.mercadobitcoin.com.br/slack/events
    bot_events:
      - app_mention
```

## Como contribuir

Esta integração será desenvolvida na onda 3 (v1.0) do roadmap evolutivo. Veja [`docs/plans/2026-05-10-evolution-roadmap.md`](../../docs/plans/2026-05-10-evolution-roadmap.md) §C.1.
