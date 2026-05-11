# Integração PagerDuty

Webhook que recebe incidentes do PagerDuty e gera **runbook automático** em `.mb/runbooks/INC-<id>.md`, pré-populado com contexto, comandos sugeridos e checklist de mitigação.

## Como rodar

### Mock (testes / CI)

```bash
cd integrations/pagerduty
node webhook.js --mock mock-fixtures/inc-demo.json
# → escreve .mb/runbooks/INC-PD-DEMO-001.md
```

### Produção

```bash
cd integrations/pagerduty
export PAGERDUTY_WEBHOOK_SECRET=...   # gerado no PagerDuty
export PORT=4000
node webhook.js
```

Endpoint público: `POST /webhook`. Para dev, exponha com `cloudflared tunnel --url http://localhost:4000`.

## Configuração no PagerDuty

1. **Services → Integrations → Generic Webhook V3**
2. URL: `https://<endpoint>/webhook`
3. Copie o **Webhook Secret** para o cofre da Plataforma → `PAGERDUTY_WEBHOOK_SECRET`
4. Eventos a assinar: `incident.triggered`, `incident.acknowledged`, `incident.resolved`

## Validação de assinatura

Header `X-PagerDuty-Signature` é validado via HMAC-SHA256 com `PAGERDUTY_WEBHOOK_SECRET`. Em dev, se a env não estiver setada, validação fica permissiva (warning emitido).

## Output

`.mb/runbooks/INC-<id>.md` contém:
- Contexto do incidente (importado)
- Diagnóstico inicial sugerido
- Checklist de mitigações comuns
- Próximos passos pós-mitigação (link para `/mb-retro --post-mortem`)
- Timeline (a preencher conforme evolui)

## Testes

```bash
npm test
```

## Segurança

- Sem `--mock`, exige `PAGERDUTY_WEBHOOK_SECRET` em produção.
- Validação de assinatura usa `crypto.createHmac` nativo (zero deps).
- Não executa comandos arbitrários — apenas escreve arquivos sob `.mb/runbooks/`.
