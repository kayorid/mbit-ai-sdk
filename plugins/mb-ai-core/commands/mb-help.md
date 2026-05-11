---
description: Visão geral do MBit — 9 plugins, comandos por categoria, links
---

# /mb-help

Apresente visão geral concisa do MBit.

## 1. Identidade

> **MBit (MB AI SDK) v0.3.1** — harness corporativo de desenvolvimento assistido por IA do Mercado Bitcoin. Padroniza processo, garante auditabilidade e segurança, mantém squads alinhados sem engessar especialização.

## 2. Os 9 plugins

| Plugin | Propósito |
|--------|-----------|
| `mb-ai-core` | Constitution, hooks bloqueantes, MCP allowlist, achievements, doctor, dashboard, snapshot, search, themes |
| `mb-bootstrap` | Onboarding híbrido do squad |
| `mb-sdd` | Ciclo Spec-Driven rígido com checkpoints |
| `mb-review` | Code/security/spec review formais |
| `mb-observability` | Design e revisão de observabilidade |
| `mb-security` | Threat modeling, compliance, hooks PII/cripto |
| `mb-retro` | Retrospectivas e memória organizacional |
| `mb-cost` | Captura de tokens, custo por fase/feature, alertas |
| `mb-evals` | Eval framework para features que usam IA em runtime |

## 3. Comandos por categoria

**Setup & diagnóstico**
- `/mb-init` — wizard de primeira instalação
- `/mb-doctor` — health check completo
- `/mb-status` — diagnóstico do squad
- `/mb-version` — versões instaladas
- `/mb-update` — atualiza SDK

**Squad & contexto**
- `/mb-bootstrap` — onboarding inicial
- `/mb-bootstrap-rescan` — reanálise (com auto-snapshot)
- `/mb-enrich-domain | -runbooks | -skills` — missões de enriquecimento
- `/mb-new-skill <slug>` — scaffolder rápido

**Ciclo SDD**
- `/mb-spec` — ciclo completo (8 fases)
- `/mb-spec-discuss | -requirements | -design | -plan | -execute | -verify | -retro` — fases isoladas
- `/mb-hotfix` — modo expresso (post-mortem 48h)
- `/mb-spike` — exploração descartável
- `/mb-fast` — modo relaxado (squads maduros)
- `/mb-approve <fase>` — checkpoint humano
- `/mb-exception` — exceção formal

**Review**
- `/mb-review-pr | -security | -spec | -fix`

**Observabilidade & segurança**
- `/mb-observability-design | -review`
- `/mb-runbook-from-incident <descrição>`
- `/mb-threat-model`
- `/mb-security-checklist`
- `/mb-compliance-check <bacen|cvm|lgpd|travel-rule|pci>`
- `/mb-secret-rotate`

**Retro & aprendizado**
- `/mb-retro` — retrospectiva
- `/mb-retro-digest` — resumo das últimas N retros
- `/mb-retro-promote` — promove ao core
- `/mb-retro-extract-skill` — extrai skill custom
- `/mb-retro-quarterly` — consolidação trimestral (análise narrativa)
- `/mb-newsletter` — newsletter trimestral (Markdown + HTML) ⬢ v0.5
- `/mb-leaderboard` — leaderboard saudável agregado por squad ⬢ v0.5
- `/mb-adoption-report` — relatório corporativo de adoção ⬢ v1.0
- `/mb-spec-from-ticket <KEY>` — gera spec a partir de ticket Jira/Linear ⬢ v1.0

**Custo & avaliação**
- `/mb-cost | -feature | -budget | -alert`
- `/mb-evals-init | -run | -compare | -ci`

**UX & visual**
- `/mb-banner` — banner MBit
- `/mb-ascii <nome>` — ASCII de momento-chave
- `/mb-theme set/show` — tema visual
- `/mb-dashboard` — painel ASCII
- `/mb-achievements` — conquistas
- `/mb-snapshot create/list/restore`
- `/mb-search <termo>` — busca em specs
- `/mb-tutorial init/roteiro/reset` — sandbox guiado

## 4. Por onde começar

| Situação | Comando |
|----------|---------|
| Primeira vez no SDK | `/mb-init` |
| Squad novo no MBit | `/mb-bootstrap` (TL conduz) |
| Nova feature | `/mb-spec <slug>` |
| Verificar instalação | `/mb-doctor` |
| Algo travou | `/mb-exception` |
| Tutorial passo a passo | `/mb-tutorial init` |

## 5. Documentação e suporte

- **Docs:** [`README.md`](https://github.com/kayorid/mbit-ai-sdk), `docs/manual/MANUAL.md`, `docs/MIGRATION.md`, `docs/PLUGIN-DEVELOPMENT.md`
- **Slack:** `#mb-ai-sdk`
- **Chapter AI:** `chapter-ai@mercadobitcoin.com.br`
- **Issues:** [github.com/kayorid/mbit-ai-sdk/issues](https://github.com/kayorid/mbit-ai-sdk/issues)
- **Vulnerabilidade:** ver [`SECURITY.md`](https://github.com/kayorid/mbit-ai-sdk/blob/main/SECURITY.md)

Mantenha resposta concisa em uma tela. ⬡
