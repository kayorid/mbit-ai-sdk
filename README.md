# MBit · MB AI SDK

> **Harness corporativo de desenvolvimento assistido por IA para o Mercado Bitcoin.**
> Padroniza processo, garante auditabilidade e segurança, mantém squads alinhados sem engessar especialização técnica.

[![Versão](https://img.shields.io/badge/versão-0.3.0-E8550C?style=flat-square)]() [![Status](https://img.shields.io/badge/status-piloto-orange?style=flat-square)]() [![Licença](https://img.shields.io/badge/licença-Proprietária-red?style=flat-square)]() [![Smoke tests](https://img.shields.io/badge/smoke%20tests-90%20OK-success?style=flat-square)]()

```
       ╱▔▔▔▔▔▔▔╲
      ╱         ╲       ███╗   ███╗██████╗ ██╗████████╗
     ╱           ╲      ████╗ ████║██╔══██╗██║╚══██╔══╝
    ╱             ╲     ██╔████╔██║██████╔╝██║   ██║
    ╲             ╱     ██║╚██╔╝██║██╔══██╗██║   ██║
     ╲           ╱      ██║ ╚═╝ ██║██████╔╝██║   ██║
      ╲         ╱       ╚═╝     ╚═╝╚═════╝ ╚═╝   ╚═╝
       ╲▁▁▁▁▁▁▁╱
                        Mercado Bitcoin · AI Engineering Harness

                     Cripto para todos · Código com confiança
```

---

## O que é

O **MBit** é um conjunto de plugins Claude Code que estabelece o "como" do desenvolvimento assistido por IA no MB. Não é uma biblioteca de runtime nem um framework de código — é um **framework de processo, governança e contexto** distribuído como plugins instaláveis via marketplace interno.

### Princípios fundadores

1. **Processo > Stack** — opina sobre como se trabalha, não sobre tecnologia.
2. **Auditabilidade nativa** — toda decisão deixa trilha versionada (compliance Bacen/CVM/LGPD).
3. **Rigidez pedagógica** — força o ciclo SDD enquanto o time aprende; modos relaxados após maturidade.
4. **Segurança não-negociável** — hooks de segurança/compliance sempre bloqueiam.
5. **Contexto vivo** — `.mb/CLAUDE.md`, glossário e skills do squad evoluem continuamente.
6. **MCPs sob curadoria** — apenas allowlist aprovada pelo Chapter AI.
7. **Verificação antes de claim** — nada está "pronto" sem evidência observável.
8. **Reversibilidade preferida** — ações destrutivas exigem confirmação humana.
9. **Custo de IA é decisão de engenharia** — exposto explicitamente via `mb-cost`.
10. **Aprendizado coletivo** — learnings dos squads alimentam o core.

---

## Os 9 plugins

| Plugin | Obrigatório? | Propósito |
|--------|:-----------:|-----------|
| [`mb-ai-core`](plugins/mb-ai-core/) | ✓ | Constitution, hooks bloqueantes, MCP allowlist, comandos base, achievements, doctor, dashboard, snapshot, search, themes |
| [`mb-bootstrap`](plugins/mb-bootstrap/) | recomendado | Onboarding híbrido do squad (análise + entrevista + enriquecimento) |
| [`mb-sdd`](plugins/mb-sdd/) | recomendado | Ciclo Spec-Driven rígido com checkpoints |
| [`mb-review`](plugins/mb-review/) | opt-in | Code, security e spec review como agentes formais |
| [`mb-observability`](plugins/mb-observability/) | opt-in | Design e revisão de observabilidade (stack-agnostic) |
| [`mb-security`](plugins/mb-security/) | opt-in (obrigatório se ativo crítico) | Threat modeling, compliance, padrões cripto |
| [`mb-retro`](plugins/mb-retro/) | opt-in | Retrospectivas e memória organizacional |
| [`mb-cost`](plugins/mb-cost/) | recomendado | Captura de tokens, custo por fase/feature, alertas de budget |
| [`mb-evals`](plugins/mb-evals/) | opt-in (essencial para AI features) | Eval framework — datasets, rubricas, runners, A/B compare, CI |

---

## Início rápido

### Setup automático (recomendado)

```bash
# Após instalar marketplace `mb` no Claude Code:
/mb-init
```

O wizard configura `~/.claude/settings.json` com todos os 9 plugins, faz backup automático e dá próximos passos.

### Setup manual

Em `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "mb": {
      "source": {
        "source": "github",
        "repo": "kayorid/mbit-ai-sdk"
      }
    }
  },
  "enabledPlugins": {
    "mb-ai-core@mb": true,
    "mb-bootstrap@mb": true,
    "mb-sdd@mb": true,
    "mb-review@mb": true,
    "mb-observability@mb": true,
    "mb-security@mb": true,
    "mb-retro@mb": true,
    "mb-cost@mb": true,
    "mb-evals@mb": true
  }
}
```

Depois:
1. Reinicie o Claude Code.
2. `/mb-doctor` para validar.
3. No repo do squad: `/mb-bootstrap` (Tech Lead conduz).
4. Primeira feature: `/mb-spec <slug>`.

---

## Comandos principais

| Comando | O que faz |
|---------|-----------|
| **Setup & diagnóstico** | |
| `/mb-init` | Wizard de primeira instalação |
| `/mb-doctor` | Health check completo do SDK no ambiente |
| `/mb-status` | Diagnóstico do squad/repo atual |
| `/mb-help` | Visão geral do SDK |
| `/mb-update` | Verifica e aplica atualizações |
| **Squad** | |
| `/mb-bootstrap` | Onboarding inicial do squad |
| `/mb-bootstrap-rescan` | Reanalisa repo (com auto-snapshot) |
| `/mb-enrich-domain` | Aprofunda glossário |
| `/mb-enrich-runbooks` | Cria runbook para fluxo crítico |
| `/mb-enrich-skills` | Cria skill custom |
| `/mb-new-skill <slug>` | Scaffolder rápido de skill |
| **Ciclo SDD** | |
| `/mb-spec` | Ciclo completo (8 fases) |
| `/mb-hotfix` | Modo expresso (post-mortem em 48h) |
| `/mb-spike` | Exploração com branch descartável |
| `/mb-fast` | Modo relaxado (squads maduros) |
| `/mb-approve <fase>` | Checkpoint humano |
| `/mb-exception` | Abre exceção formal |
| **Review** | |
| `/mb-review-pr` | Code review estruturado |
| `/mb-review-security` | Security review (OWASP + cripto) |
| `/mb-review-spec` | Coverage spec ↔ implementação |
| **Observabilidade & Segurança** | |
| `/mb-observability-design` | Design de logs/métricas/traces/SLOs |
| `/mb-threat-model` | STRIDE + cripto-específicos |
| `/mb-compliance-check <reg>` | Bacen / CVM / LGPD / Travel Rule |
| **Retro & Aprendizado** | |
| `/mb-retro` | Retrospectiva estruturada |
| `/mb-retro-digest` | Resumo das últimas N retros |
| `/mb-retro-promote` | Promove learning ao core |
| `/mb-retro-quarterly` | Consolidação trimestral |
| **Custo & Avaliação** | |
| `/mb-cost` | Custo de IA agregado |
| `/mb-cost-feature <slug>` | Custo por feature |
| `/mb-cost-alert` | Verificação vs budget |
| `/mb-evals-init <feature>` | Scaffolding de eval |
| `/mb-evals-run <feature>` | Executa eval |
| `/mb-evals-ci <feature>` | Modo CI (exit 0/1) |
| **UX & Visual** | |
| `/mb-banner` | Mostra banner MBit |
| `/mb-ascii <nome>` | ASCII art para momento-chave |
| `/mb-theme set <tema>` | Configura tema visual |
| `/mb-dashboard` | Painel ASCII com métricas |
| `/mb-achievements` | Conquistas do squad |
| `/mb-snapshot create/list/restore` | Backup reversível de `.mb/` |
| `/mb-search <termo>` | Busca em specs |
| `/mb-tutorial` | Sandbox guiado (45-60min) |

---

## Documentação

- 📋 [**Documento de Design Completo**](docs/plans/2026-05-10-mb-ai-sdk-design.md) — proposta executiva + arquitetura + roadmap inicial
- 🛣 [**Roadmap Evolutivo v0.2 → v3.0**](docs/plans/2026-05-10-evolution-roadmap.md) — 5 frentes, 6 ondas, dependências, capacity, riscos
- 📚 [**Manual Técnico Detalhado**](docs/manual/MANUAL.md) — bases teóricas, arquitetura interna, fluxos
- 🎤 [**Roteiro de Apresentação**](docs/presentation/PRESENTATION.md) — slides comentados para liderança
- 🏛 [**Governança e RACI**](docs/governance/raci.md) — papéis, processos, proposta de mudança
- 📖 [**Playbook de Instalação por Papel**](docs/playbooks/install-by-role.md) — Chapter AI, TL, Champion, Dev
- 🔄 [**Migration Guide**](docs/MIGRATION.md) — entre versões
- 🛠 [**Plugin Development Guide**](docs/PLUGIN-DEVELOPMENT.md) — para criar plugins novos
- 🤝 [**Contributing**](CONTRIBUTING.md) — como contribuir
- 🔒 [**Security Policy**](SECURITY.md) — reportar vulnerabilidade
- ❓ [**FAQ**](docs/faq.md)

---

## Estrutura do repositório

```
mbit-ai-sdk/
├── README.md                          ← você está aqui
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── RELEASE-NOTES.md
├── LICENSE
├── REVIEW.md                          ← code review pré-release v0.2
├── .claude-plugin/
│   └── marketplace.json               ← lista os 9 plugins
├── .github/
│   ├── workflows/
│   │   ├── mb-ai-checks.yml          ← workflow distribuído para squads MB
│   │   └── sdk-ci.yml                ← CI próprio do SDK
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug.md
│   │   ├── proposal.md
│   │   └── security.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── plans/                         ← propostas e designs
│   ├── manual/                        ← manual técnico completo
│   ├── presentation/                  ← roteiro de apresentação
│   ├── governance/                    ← papéis, processos, RACI
│   ├── playbooks/                     ← guias práticos por papel
│   ├── MIGRATION.md
│   ├── PLUGIN-DEVELOPMENT.md
│   └── faq.md
├── integrations/
│   └── slack/                         ← bot scaffold para v1.0
├── plugins/
│   ├── mb-ai-core/
│   ├── mb-bootstrap/
│   ├── mb-sdd/
│   ├── mb-review/
│   ├── mb-observability/
│   ├── mb-security/
│   ├── mb-retro/
│   ├── mb-cost/
│   └── mb-evals/
└── tests/
    └── smoke/
        ├── README.md
        └── run.sh                     ← 90+ verificações
```

---

## Suporte e contato

- **Canal Slack:** `#mb-ai-sdk`
- **Chapter AI:** `chapter-ai@mercadobitcoin.com.br`
- **Issues:** [github.com/kayorid/mbit-ai-sdk/issues](https://github.com/kayorid/mbit-ai-sdk/issues)
- **Comunidade de AI Champions:** encontro mensal — calendário interno
- **Reportar vulnerabilidade:** ver [SECURITY.md](SECURITY.md)

---

## Roadmap

| Versão | Janela | Tema | Estado |
|--------|--------|------|--------|
| **v0.1** | Sem 1-3 | Foundation | ✓ |
| **v0.2** | Sem 4-6 | Encantamento + UX + cost | ✓ |
| **v0.3** | Sem 7-9 | Maturidade operacional + evals + governança OSS | ✓ **(atual)** |
| v0.5 | Sem 10-13 | Comunidade Champions + workshops | em desenvolvimento |
| v1.0 | Sem 14-18 | Slack bot real + Jira/Linear + dashboard adoção | planejado |
| v1.5 | Sem 19-25 | mb-knowledge-graph + drift detection + telemetria opt-in | planejado |
| v2.0 | Trim 2 | Plataforma corporativa + SIEM + hackathon interno | planejado |
| v3.0 | Q4 2026 | Open-source seletivo + IDE extension | planejado |

Detalhes em [`docs/plans/2026-05-10-evolution-roadmap.md`](docs/plans/2026-05-10-evolution-roadmap.md).

---

**Feito pelo Chapter AI do Mercado Bitcoin · 2026 · ⬡**
