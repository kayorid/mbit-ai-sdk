# Integração Slack — `mbit-bot`

> **v1.0 — implementação funcional.** Bolt JS (Node 20), com modo mock para testes offline.

Bot Slack que expõe comandos do MBit AI SDK no workspace.

## Comandos atuais

- `@mbit-ai retro <squad>` — última retrospectiva do squad no thread
- `@mbit-ai help` — lista de comandos disponíveis

Comandos planejados (futuras versões):
- `@mbit-ai status <squad>` — saúde do squad (dashboard)
- `@mbit-ai adoption` — sumário de adoção do SDK

## Como rodar

### Modo mock (testes / dev sem Slack)

```bash
cd integrations/slack
npm install
MB_MOCK_SLACK=1 npm run dev
```

Em mock mode, o bot inicia sem conectar ao Slack e lê retros de `fixtures/`. Útil para CI e dev offline.

### Produção

```bash
cd integrations/slack
npm install --omit=dev

export SLACK_BOT_TOKEN=xoxb-...
export SLACK_SIGNING_SECRET=...
export SLACK_APP_TOKEN=xapp-...   # opcional, ativa Socket Mode
export MB_RETROS_PATH=/path/to/.mb/retros

npm start
```

### Docker

```bash
docker build -t mbit-slack .
docker run --rm \
  -e SLACK_BOT_TOKEN \
  -e SLACK_SIGNING_SECRET \
  -e MB_RETROS_PATH=/data/retros \
  -v /opt/mb/retros:/data/retros \
  -p 3000:3000 \
  mbit-slack
```

## Testes

```bash
npm test
```

Suite usa `node:test` (zero deps adicionais), exercita o mock mode + adapter.

## Configuração no Slack

Use o `manifest.yaml` na raiz desta pasta:

1. **Slack API → Apps → Create New App → From Manifest**
2. Cole o conteúdo de `manifest.yaml`
3. Instale no workspace MB
4. Copie tokens (`xoxb-`, `xapp-`, signing secret) para o cofre da Plataforma
5. Deploy do container

## Variáveis de ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `SLACK_BOT_TOKEN` | sim (prod) | `xoxb-...` |
| `SLACK_SIGNING_SECRET` | sim (prod) | secret do manifest |
| `SLACK_APP_TOKEN` | opcional | ativa Socket Mode (sem expor porta) |
| `MB_RETROS_PATH` | não | path para retros (default `.mb/retros`) |
| `MB_MOCK_SLACK` | não | `=1` ativa mock mode |
| `PORT` | não | default `3000` |

## Segurança

- Tokens **nunca** commitados (`.env*` bloqueado pelo `pre-write-guard.sh` do SDK)
- Bot responde **apenas** em threads onde foi mencionado (`@mbit-ai`)
- Não executa comandos arbitrários — só os handlers em `handlers/`
- Mock mode é seguro para CI: zero network calls
