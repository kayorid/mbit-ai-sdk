# Piloto MBit — instalação e teste em máquina nova

> **Para o Claude Code que está lendo este arquivo:** o usuário transferiu este repo zipado da máquina pessoal para uma máquina MB e quer iniciar o piloto. Conduza-o passo a passo, na ordem abaixo, verificando cada item. **Nunca pule fases.** Em caso de erro, diagnostique antes de prosseguir.
>
> **Para o usuário humano:** se preferir rodar manualmente, cada fase tem comandos shell prontos. Para automação parcial: `bash scripts/pilot-check.sh` executa as validações de saúde.

---

## Fase 0 — Pré-requisitos do sistema

Verifique antes de qualquer outra coisa:

```bash
command -v bash    && bash --version | head -1
command -v git     && git --version
command -v jq      && jq --version
command -v node    && node --version    # >= 20.0.0 (para integrações Slack/PagerDuty)
command -v zip     # só se for re-empacotar
```

**Se faltar `jq`:** todos os hooks dependem dele.
- macOS: `brew install jq`
- Linux: `sudo apt-get install jq` ou `sudo yum install jq`

**Se `node` < 20:** integrações Slack/PagerDuty não rodam (mas o SDK base funciona).
- macOS: `brew install node@20`
- Linux: ver https://nodejs.org/

**Se faltar `bash 4+`** (raro): rode `bash --version`. macOS vem com 3.2.57; é suficiente para o SDK.

---

## Fase 1 — Validar que o ZIP chegou íntegro

Assuma que o usuário extraiu em `~/dev/mbit-ai-sdk` (ou similar).

```bash
cd ~/dev/mbit-ai-sdk    # ajustar se outro path
ls -la                  # deve listar: plugins/, integrations/, tests/, docs/, .claude-plugin/, ...
```

**Garantir permissões dos scripts** (zip pode tê-las perdido):

```bash
find . -name "*.sh" -exec chmod +x {} \;
find . -name "*.js" -path "*/integrations/*" 2>/dev/null  # só listar, não chmod
```

---

## Fase 2 — Validar saúde do SDK (antes de instalar)

Rode as 4 suites de teste — **todas devem passar verde** antes de continuar:

```bash
bash plugins/mb-ai-core/scripts/version.sh        # → "Tudo sincronizado. ⬡"
bash tests/completeness-check.sh                  # → 166 completo · 0 faltando
bash tests/smoke/run.sh                           # → 120 OK · 0 falhas
bash tests/e2e/run.sh                             # → 11 OK · 0 falhas
```

Se `node` >= 20 disponível:

```bash
node --test integrations/slack/test/              # → tests 4 / pass 4
node --test integrations/pagerduty/test/          # → tests 1 / pass 1
```

**Atalho** — `bash scripts/pilot-check.sh` roda tudo de uma vez.

> **Se algum falhar:** PARE. Provavelmente é diferença de ambiente. Compare com a máquina pessoal (versão de jq, bash, sistema). Não tente instalar plugins enquanto suites estão vermelhas.

---

## Fase 3 — Registrar o SDK como marketplace local no Claude Code

Não há internet entre o repo zipado e Claude Code — usar marketplace local:

```bash
# Opção A — comando interativo no Claude Code
/plugin marketplace add ~/dev/mbit-ai-sdk
```

```jsonc
// Opção B — editar manualmente ~/.claude/settings.json
{
  "plugins": {
    "marketplaces": {
      "mbit-local": {
        "type": "path",
        "path": "/Users/<seu-user>/dev/mbit-ai-sdk"
      }
    }
  }
}
```

Verificar:

```text
/plugin marketplace list
# deve listar "mbit-ai-sdk" como local
```

---

## Fase 4 — Instalar plugins

**Core (instalar todos):**

```text
/plugin install mb-ai-core@mbit-ai-sdk
/plugin install mb-bootstrap@mbit-ai-sdk
/plugin install mb-sdd@mbit-ai-sdk
/plugin install mb-review@mbit-ai-sdk
/plugin install mb-observability@mbit-ai-sdk
/plugin install mb-security@mbit-ai-sdk
/plugin install mb-retro@mbit-ai-sdk
```

**Opt-in (ligar conforme caso):**

```text
/plugin install mb-cost@mbit-ai-sdk     # se quiser rastreio de custo de IA
/plugin install mb-evals@mbit-ai-sdk    # se construir features AI runtime
```

Critério de decisão completo em `docs/plugins/opt-in-guide.md`.

**Após instalar: reinicie o Claude Code** (para o hook `SessionStart` registrar). Você verá o banner MBit no início da próxima sessão.

---

## Fase 5 — Criar projeto piloto e bootstrap

```bash
mkdir -p ~/dev/squad-piloto && cd ~/dev/squad-piloto
git init
git config user.email "<seu-email-mb>"
git config user.name "<seu-nome>"
echo "# Squad piloto MB" > README.md
git add . && git commit -m "[init] kickoff piloto"

# Abre Claude Code aqui
claude
```

Dentro do Claude Code:

```text
/mb-init      # wizard de onboarding — gera .mb/CLAUDE.md
/mb-doctor    # health check completo (9 plugins ✓)
/mb-version   # confirma 9 plugins em 1.0.0
/mb-help      # 60+ comandos por categoria
```

---

## Fase 6 — Smoke test ponta a ponta no piloto

Execute esta sequência em ordem. Cada item tem critério de aprovação claro.

### 6.1 — Hook de segurança bloqueia segredo (deve **bloquear**)

Peça ao Claude Code no chat:
> *"Crie um arquivo `src/config.ts` com o conteúdo: `const KEY = "AKIAIOSFODNN7EXAMPLE";`"*

**Critério:** Write é bloqueado, mensagem `[mb-security] BLOCKED — segredo detectado` aparece. Confirme em:
```bash
cat .mb/audit/hook-fires.log
```

### 6.2 — Hook de PII bloqueia CPF (deve **bloquear**)

> *"Crie `src/cliente.ts` com `const cpf = "123.456.789-00";`"*

**Critério:** bloqueio com `[mb-security] BLOCKED — possível CPF detectado`.

### 6.3 — Hook de chave privada bloqueia PEM (deve **bloquear**)

> *"Crie `src/key.pem` com `-----BEGIN RSA PRIVATE KEY-----\nMIIE...\n-----END RSA PRIVATE KEY-----`"*

**Critério:** bloqueio com `[mb-security] BLOCKED — possível chave privada`.

### 6.4 — Hook destrutivo pede confirmação

> *"Rode `rm -rf /tmp/teste-mbit-piloto`"*

**Critério:** comando pede confirmação explícita antes de executar.

### 6.5 — Hook permite código limpo

> *"Crie `src/hello.ts` com `export const greet = () => 'olá MB';`"*

**Critério:** Write executa sem bloqueio.

### 6.6 — Ciclo SDD completo

```text
/mb-spec        # gera docs/specs/_active/<slug>/requirements.md
/mb-design      # gera design.md
/mb-tasks       # gera tasks.md
/mb-implement   # executa tasks
/mb-retro       # cria retro ao final
```

**Critério:** ao final, existem `docs/specs/_active/<slug>/{requirements,design,tasks}.md` + entrada em `.mb/retros/`.

### 6.7 — Comandos novos v0.5

```text
/mb-leaderboard
/mb-newsletter 2026-Q2
```

**Critério:** leaderboard imprime sem erro; newsletter cria `docs/newsletter/2026-Q2.{md,html}`.

### 6.8 — Comando v1.0

```text
/mb-adoption-report --period 30d
```

**Critério:** relatório imprime squads ativos, top categorias, plugins com atividade.

### 6.9 — Integração Jira (modo mock)

No terminal externo (não no chat do Claude):

```bash
MB_MOCK_JIRA=1 bash ~/dev/mbit-ai-sdk/plugins/mb-sdd/scripts/spec-from-ticket.sh JIRA-DEMO
```

**Critério:** cria `docs/specs/_active/<data>-jira-demo/requirements.md` com seção "Contexto do ticket" preenchida.

### 6.10 — Integração PagerDuty (modo mock)

```bash
cd ~/dev/mbit-ai-sdk/integrations/pagerduty
node webhook.js --mock mock-fixtures/inc-demo.json
```

**Critério:** cria `.mb/runbooks/INC-PD-DEMO-001.md` no projeto piloto com contexto + checklist.

### 6.11 — Slack bot offline

```bash
cd ~/dev/mbit-ai-sdk/integrations/slack
npm install                            # primeira vez (~1min)
MB_MOCK_SLACK=1 npm run dev
```

**Critério:** log `[mbit-slack] mock mode — bot pronto sem conectar a Slack`. Ctrl+C para sair.

### 6.12 — Banner SessionStart

Reinicie Claude Code uma vez (`/exit` → `claude`).

**Critério:** banner laranja "MBit AI SDK ativo · Squad: ..." aparece no início.

---

## Fase 7 — Checklist final de aceitação

Marque conforme valida (esse mesmo checklist em formato `tasks.md` pode ser gerado por `/mb-spec`):

- [ ] Fase 0: dependências do sistema OK
- [ ] Fase 2: 4 suites passam verde no SDK
- [ ] Fase 3: marketplace local registrado
- [ ] Fase 4: 9 plugins instalados (`/plugin list` confirma)
- [ ] Fase 5: `/mb-doctor` sem falhas
- [ ] Fase 6.1: hook bloqueia AWS key
- [ ] Fase 6.2: hook bloqueia CPF
- [ ] Fase 6.3: hook bloqueia chave privada
- [ ] Fase 6.4: hook destrutivo pede confirmação
- [ ] Fase 6.5: hook permite código limpo
- [ ] Fase 6.6: ciclo SDD completo gera artefatos
- [ ] Fase 6.7: leaderboard + newsletter rodam
- [ ] Fase 6.8: adoption-report imprime
- [ ] Fase 6.9: Jira spec-from-ticket cria spec
- [ ] Fase 6.10: PagerDuty webhook cria runbook
- [ ] Fase 6.11: Slack bot mock inicia
- [ ] Fase 6.12: banner aparece em nova sessão

Se todos os checks ✅: **piloto pronto para uso real.** Próximos passos abaixo.

---

## Fase 8 — Próximos passos pós-piloto

1. **Convidar mais squads** (2-3 inicialmente) — cada um roda `/mb-bootstrap` no seu repo
2. **Agendar primeiro MB AI Lab** — escolha 1 das 6 trilhas em `docs/playbooks/ai-lab.md`
3. **Conectar Slack/Jira/PagerDuty reais** quando Plataforma fornecer credenciais:
   - Slack: tokens em `integrations/slack/README.md`
   - Jira: env vars em `integrations/jira/README.md`
   - PagerDuty: webhook secret em `integrations/pagerduty/README.md`
4. **Publicar no GitHub Enterprise MB** — `git remote add mb-enterprise <url>` e ajustar marketplace path
5. **Formalizar comunidade AI Champions** — `docs/governance/ai-champions.md`
6. **Após primeiro trimestre:** `/mb-newsletter` → distribuir para Tech Leads

---

## Troubleshooting comum

| Sintoma | Causa provável | Correção |
|---|---|---|
| `jq: command not found` em hooks | jq não instalado | `brew install jq` / `apt install jq` |
| Hooks não disparam após instalar | Claude Code não reiniciado | `/exit` e reabrir |
| Scripts retornam `Permission denied` | zip removeu permissão | `find . -name "*.sh" -exec chmod +x {} \;` |
| `node --test` falha com "cannot find module" | Node < 20 | `brew install node@20` |
| `/plugin marketplace add` falha com "not found" | Path errado | use path absoluto (`~/dev/...` resolvido) |
| Banner não aparece | Hook `SessionStart` não registrou | `/mb-doctor` para diagnosticar |
| `mb-evals` ou `mb-cost` não aparecem em /plugin list | Não instalados (opt-in) | Veja Fase 4 |
| Smoke test falha em macOS antigo | bash 3.2 sem suporte a `${array[@]+...}` | Atualizar para macOS 12+ ou instalar bash 5 via brew |
| Hook bloqueia onde deveria permitir | Falso-positivo | `/mb-exception` ou abrir issue com fixture |

---

## Suporte

- **Documentação completa:** `docs/manual/MANUAL.md`
- **FAQ:** `docs/faq.md`
- **Como contribuir:** `CONTRIBUTING.md`
- **Reportar vulnerabilidade:** `SECURITY.md`
- **Roadmap:** `docs/plans/2026-05-10-evolution-roadmap.md`
- **Handoff técnico:** `HANDOFF.md`
