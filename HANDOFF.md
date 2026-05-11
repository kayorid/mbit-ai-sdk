# Handoff — MBit v1.0.0

> Documento de retomada. Lê este antes de continuar a evolução do MBit em sessão futura.

**Data deste handoff:** 2026-05-11
**Versão atual:** v1.0.0 (tag `v1.0.0` no repo)
**Estado:** ✅ Production-ready corporativo · Working tree limpo · todas as suites verdes

> 🎯 **Vai testar numa máquina nova (transferindo zip)?** Siga **[PILOT-SETUP.md](./PILOT-SETUP.md)** — passo a passo discoverable pelo Claude Code. Atalho: `bash scripts/pilot-check.sh`.

---

## 🎯 Onde estamos

### Repositório
- **GitHub:** https://github.com/kayorid/mbit-ai-sdk
- **Branch principal:** `main`
- **Último commit:** `89ab17e` — feat: MBit v1.0.0 — maturidade pedagógica
- **Tags:** `v0.3.0`, `v0.3.1`, `v0.3.2`, `v0.5.0`, `v1.0.0`
- **Releases:** todas publicadas com release notes em CHANGELOG.md

### Local
- **Path:** `/Users/kayoridolfi/Documents/vibecoding/plugin-mb-ai`
- **Remote origin:** https://github.com/kayorid/mbit-ai-sdk.git

### Estatísticas (v1.0.0)
- 9 plugins · 14+ skills · 60+ comandos · 10 hooks · 33 scripts · 16 achievements · 18+ docs
- **3 integrações reais**: Slack (Bolt JS), Jira (adapter shell), PagerDuty (webhook Node)
- **166 itens** validados pelo completeness-check
- **120 smoke tests** (execução real de hooks + integrações + comandos novos)
- **11 testes E2E** num sandbox temporário (`tests/e2e/run.sh`)
- **5 testes node:test** (4 slack + 1 pagerduty)

### Specs entregues
Todas em `docs/specs/_completed/`:
- `v0.3.2-cleanup/` — M-1 (consolidação de hooks) + suite E2E
- `v0.5-community/` — leaderboard, newsletter, AI Champions charter, AI Lab playbook
- `v1.0-maturity/` — Slack bot, Jira adapter, PagerDuty webhook, adoption report, certificação

---

## 🔄 Como retomar trabalho

### 1. Verificar saúde do projeto

```bash
cd /Users/kayoridolfi/Documents/vibecoding/plugin-mb-ai
git status
git log --oneline -5
bash tests/completeness-check.sh
bash tests/smoke/run.sh
```

Esperado: working tree limpo, ambas suites verde.

### 2. Sincronizar com remote

```bash
git fetch origin
git status  # deve mostrar "up to date"
```

### 3. Verificar última versão

```bash
bash plugins/mb-ai-core/scripts/version.sh
```

---

## 🚀 Próxima evolução planejada

### ✅ v0.3.2, v0.5.0, v1.0.0 — entregues em 2026-05-11

Specs completas em `docs/specs/_completed/`. Resumo:
- **v0.3.2** — M-1 consolidação de hooks + suite E2E + fix achievements unbound var
- **v0.5.0** — `/mb-leaderboard`, `/mb-newsletter`, charter AI Champions, AI Lab (6 trilhas), opt-in guide
- **v1.0.0** — Slack bot Bolt JS, Jira adapter, PagerDuty webhook, `/mb-adoption-report`, certificação Champion 4 níveis

### v1.5 — Inteligência operacional (próximo ciclo)

- `mb-knowledge-graph` — grafo de decisões cross-squad
- `mb-search` semântico (embeddings + sqlite-vec)
- Telemetria opt-in
- Drift detection automático

### v2.0 — Plataforma corporativa (Trim 2)

- SIEM integration
- Hackathon interno anual "MB AI Hack"
- Datadog/Grafana → observability review automatizado
- Marketplace interno com infra própria

### v3.0 — Excelência de mercado (Q4 2026)

- IDE extension (VS Code / JetBrains)
- Open-source seletivo de componentes não-confidenciais

---

## 🧪 Como testar

### Suite completa

```bash
bash tests/smoke/run.sh
```

Esperado: `90 OK · 0 falhas`. Roda em ~3s. Cobre:
- Estrutura repo + manifestos JSON
- Sincronização de versões
- Scripts (sintaxe + executáveis)
- Skills + comandos
- Execução real de hooks bloqueantes (positivo + negativo)
- ASCII art + documentação completa
- cost-report execução
- cost-capture overhead

### Completeness check

```bash
bash tests/completeness-check.sh
```

Esperado: `154 completo · 0 faltando`. Loop iterativo — repita até zerar.

### CI no GitHub

PR ao repo dispara `.github/workflows/sdk-ci.yml` que roda:
- Smoke test suite
- Validação JSON
- Sintaxe shell
- ShellCheck (severity error)
- Version sync

---

## 📝 Como adicionar features novas

### Comando novo

1. `plugins/<plugin>/commands/<nome>.md` com frontmatter:
   ```yaml
   ---
   description: <curta>
   argument-hint: <args opcional>
   ---
   ```
2. Adicione ao `tests/completeness-check.sh` array `EXPECTED_CMDS`.
3. Atualize `/mb-help` se for command relevante.
4. Rode `bash tests/completeness-check.sh` — deve passar.
5. Rode `bash tests/smoke/run.sh` — deve passar.

### Plugin novo

Veja [`docs/PLUGIN-DEVELOPMENT.md`](docs/PLUGIN-DEVELOPMENT.md) — guia completo.

Checklist:
- [ ] `plugin.json` com versão sincronizada
- [ ] README.md
- [ ] Pelo menos 1 SKILL.md com description rica
- [ ] Comandos com frontmatter
- [ ] Hooks (se aplicável) com `hooks.json` + scripts executáveis
- [ ] Adicionar ao `marketplace.json` (mesma versão)
- [ ] Adicionar ao `tests/completeness-check.sh`
- [ ] Atualizar `/mb-help`, `/mb-init`, `doctor.sh` `EXPECTED` list
- [ ] CHANGELOG.md
- [ ] PR template preenchido

### Achievement novo

1. Adicionar em `plugins/mb-ai-core/achievements/definitions.json`
2. Adicionar critério em `achievements/checker.sh` (`metric()` + `check_criteria()`)
3. Bumpar `ACH_TOTAL` em `dashboard.sh` se necessário
4. Atualizar `tests/completeness-check.sh` se mudar contagem esperada

---

## 🐛 Como reportar/corrigir bugs

1. Issue no GitHub usando template `bug.md`
2. Branch: `fix/<slug>`
3. Commit: `[fix:<slug>] <msg>`
4. PR usando template — checklist obrigatório
5. CI deve passar (smoke + completeness + manifests + ShellCheck)
6. Adicionar regression test em `tests/smoke/run.sh` se aplicável

---

## 🔒 Vulnerabilidade?

**Não abra issue público.** Veja [`SECURITY.md`](SECURITY.md):
- Email: `security@mercadobitcoin.com.br`
- GitHub Security Advisory: https://github.com/kayorid/mbit-ai-sdk/security/advisories/new

---

## 📁 Estrutura essencial

```
mbit-ai-sdk/
├── README.md                          ← entrada principal
├── HANDOFF.md                         ← você está aqui
├── CHANGELOG.md                       ← histórico de versões
├── CONTRIBUTING.md                    ← como contribuir
├── SECURITY.md                        ← reportar vulnerabilidade
├── REVIEW.md                          ← code review pré-release v0.2
├── .claude-plugin/marketplace.json    ← lista 9 plugins
├── plugins/
│   ├── mb-ai-core/                    ← obrigatório, contém wizard, doctor, dashboard
│   ├── mb-bootstrap/                  ← onboarding squad
│   ├── mb-sdd/                        ← ciclo Spec-Driven
│   ├── mb-review/                     ← code/security/spec review
│   ├── mb-observability/              ← logs/metrics/traces/SLOs
│   ├── mb-security/                   ← threat model + cripto + compliance
│   ├── mb-retro/                      ← retrospectivas + memória
│   ├── mb-cost/                       ← captura de tokens
│   └── mb-evals/                      ← framework de eval para AI features
├── docs/
│   ├── plans/                         ← propostas + roadmaps
│   ├── manual/MANUAL.md               ← bases teóricas + internals
│   ├── presentation/PRESENTATION.md   ← roteiro slide-a-slide
│   ├── governance/raci.md             ← papéis + processos
│   ├── playbooks/                     ← guias por papel
│   ├── MIGRATION.md                   ← entre versões
│   ├── PLUGIN-DEVELOPMENT.md          ← criar plugins
│   └── faq.md
├── integrations/slack/                ← bot stub para v1.0
├── tests/
│   ├── smoke/run.sh                   ← suite de execução real (90 verificações)
│   ├── smoke/README.md
│   └── completeness-check.sh          ← validação canônica (154 itens)
└── .github/
    ├── workflows/
    │   ├── mb-ai-checks.yml           ← distribuído para squads MB
    │   └── sdk-ci.yml                 ← CI próprio do repo
    ├── ISSUE_TEMPLATE/{bug,proposal,security}.md
    └── PULL_REQUEST_TEMPLATE.md
```

---

## 💡 Decisões de design importantes

Para evitar reabrir discussões em sessões futuras, registro aqui:

1. **Marketplace path:** `kayorid/mbit-ai-sdk` (público). Em produção MB seria espelhado em `mercadobitcoin/mbit-ai-sdk` no GitHub Enterprise.

2. **Stack-agnostic por design:** SDK não opina sobre linguagem ou framework. Cada squad gera seu contexto via `/mb-bootstrap`.

3. **Categorização de hooks:**
   - SEGURANÇA (sempre bloqueia, sem exceção)
   - COMPLIANCE (bloqueia, exceção via `/mb-exception`)
   - PROCESSO (warn → block após maturidade)
   - QUALIDADE (sempre warn)

4. **Versionamento:** semver estrito. Major = breaking + 30d migração. Minor = feature. Patch = fix.

5. **Convenção de commits:** `[<categoria>(:<slug>)] <msg>` validado por `mb-ai-checks.yml`.

6. **Idioma:** português brasileiro nos artefatos. Termos técnicos em inglês quando estabelecidos.

7. **mb-cost limitação conhecida:** Claude Code raramente coloca `usage` em payloads de tool individuais. Captura real é parcial — em v1.0+ moveremos para hook `Stop`/`SessionEnd` lendo transcript.

8. **Slack integration:** ainda é stub (manifest.yaml). Implementação real em v1.0.

9. **GitHub Pages:** não configurado. Documentação fica no repo.

10. **Testes em CI:** rodam ShellCheck com `severity: error` (não warning). Não falham por estilo, apenas por bugs reais.

---

## ✅ Checklist de retomada

Antes de continuar trabalho:

- [ ] `git status` — working tree limpo
- [ ] `git pull origin main` — sincronizar
- [ ] `bash tests/smoke/run.sh` — passa
- [ ] `bash tests/completeness-check.sh` — passa
- [ ] Ler último commit: `git log -1`
- [ ] Verificar issues abertas: `gh issue list -R kayorid/mbit-ai-sdk`
- [ ] Verificar PRs: `gh pr list -R kayorid/mbit-ai-sdk`

Pronto para continuar a evolução. Veja roadmap em [`docs/plans/2026-05-10-evolution-roadmap.md`](docs/plans/2026-05-10-evolution-roadmap.md) e priorize ondas com base em feedback dos squads piloto.

---

**Mantido por:** Chapter AI · Mercado Bitcoin
**Última atualização:** 2026-05-10
**Próxima revisão sugerida:** após 1 semana de piloto ou ao iniciar v0.5
**⬡**
