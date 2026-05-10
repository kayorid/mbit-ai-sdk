# MB AI SDK — Design e Proposta de Implementação

**Data:** 2026-05-10
**Autor:** Kayori Dolfi (Chapter AI)
**Status:** Proposta v1.0 — pronta para revisão executiva e início de implementação
**Audiência:** Liderança de Engenharia, Tech Leads, Chapter AI, AI Champions

---

## 1. Sumário executivo

O **MB AI SDK** é um harness corporativo de desenvolvimento assistido por IA para o Mercado Bitcoin. Não é uma biblioteca de código nem um framework de runtime — é um **framework de processo, governança e contexto** que padroniza como squads do MB constroem software com Claude Code de forma:

- **Auditável** — toda decisão (spec, design, código) deixa trilha versionada compatível com requisitos regulatórios (Bacen, CVM, LGPD).
- **Segura** — hooks bloqueantes impedem vazamento de segredos, uso de MCPs não-aprovados e padrões de risco antes que cheguem a um commit.
- **Stack-agnóstica** — o SDK opina sobre **como** se trabalha, não sobre quais tecnologias usar; cada squad gera seu próprio contexto (CLAUDE.md, glossário, runbooks, skills custom) via bootstrap automatizado.
- **Pedagogicamente rígida** — força o ciclo Spec-Driven Development completo enquanto o time está aprendendo a trabalhar com IA; modos relaxados só após maturidade demonstrada.
- **Distribuída de forma modular** — um plugin obrigatório (`mb-ai-core`) carrega a baseline corporativa, e seis plugins opcionais (`mb-bootstrap`, `mb-sdd`, `mb-review`, `mb-observability`, `mb-security`, `mb-retro`) são adotados conforme necessidade do squad.

**Hipótese central:** times do MB que operam dentro do harness produzem entregas com mais qualidade auditável, menor retrabalho e onboarding mais rápido para novos integrantes — sem sacrificar velocidade significativamente.

**Entregável da v1.0:** marketplace interno com sete plugins funcionais, documentação por papel (Chapter AI, Tech Lead, AI Champion, Dev), processo de bootstrap end-to-end testável, e roadmap evolutivo até v2.0.

---

## 2. Contexto e motivação

### 2.1 Por que agora

O Mercado Bitcoin está iniciando o uso intensivo de IA generativa em desenvolvimento. A janela atual é crítica: os primeiros padrões adotados se tornarão a cultura. Sem um harness corporativo:

- Cada squad reinventa seu próprio fluxo, gerando inconsistência entre times.
- Práticas inseguras (commit de segredos via prompt, uso de MCPs não-auditados, exposição de dados regulados a APIs externas) podem se normalizar antes de serem detectadas.
- Decisões importantes ficam apenas no chat efêmero do dev com o agente, sem trilha que sobreviva à rotação de pessoas ou auditoria externa.
- O aprendizado coletivo de "o que funciona" não se consolida — cada time aprende sozinho.

### 2.2 Restrições reais do MB

- **Regulação financeira:** Bacen, CVM, Receita Federal exigem rastreabilidade de mudanças em sistemas críticos (matching engine, custódia, KYC, liquidação). Decisões automatizadas precisam ser explicáveis e auditáveis.
- **Cripto-específicos:** integração com blockchains, custódia de chaves, antifraude e Travel Rule criam superfície de ataque única que ferramentas genéricas não cobrem.
- **Heterogeneidade de stack:** times usam Go, Node, Python, Rust, Java, Next.js, React Native, Swift/Kotlin nativo. Um SDK que dite stack não seria adotado.
- **Maturidade variável em IA:** alguns devs já operam Claude Code diariamente; outros nunca usaram. O harness precisa servir a ambos.
- **Cultura de squad autônomo:** o MB valoriza autonomia de squads. O SDK precisa garantir baseline mas não engessar especialização.

### 2.3 O que já existe

A base deste SDK é o plugin **Spec-Driven Development (SDD)** já desenvolvido como prova de conceito. Ele entrega o ciclo `constitution → specify → clarify → plan → tasks → implement → validate → retrospective` com artefatos versionados em `docs/specs/`. O MB AI SDK absorve, refatora e expande esse plugin como `mb-sdd`, mantendo seu DNA mas adicionando integração com os demais plugins do ecossistema MB.

---

## 3. Princípios fundadores

Estes princípios são **não-negociáveis** e governam todas as decisões de design do SDK e dos plugins. Eles serão materializados como `constitution.md` no `mb-ai-core`.

| # | Princípio | Implicação prática |
|---|-----------|-------------------|
| 1 | **Processo > Stack** | Nenhum plugin do SDK pode forçar uma linguagem ou framework. Templates e exemplos são ilustrativos, nunca obrigatórios. |
| 2 | **Auditabilidade nativa** | Toda decisão relevante (spec, design, aprovação de fase, exceção a regra) gera artefato em git. Conversa com IA é efêmera; spec é eterna. |
| 3 | **Rigidez pedagógica** | Enquanto o time não tem maturidade demonstrada (definida por métricas em §13), o ciclo SDD completo é obrigatório. Modos relaxados destravam após critérios objetivos. |
| 4 | **Segurança não-negociável** | Hooks de segurança e compliance **sempre** bloqueiam — em squad piloto, em produção, em desenvolvimento local, em hotfix. Sem exceção via flag. |
| 5 | **Contexto vivo, não congelado** | CLAUDE.md, glossário e skills do squad são atualizados continuamente via `mb-retro`. Documentação que não evolui morre. |
| 6 | **MCPs sob curadoria** | Apenas MCPs auditados pelo Chapter AI estão na allowlist. MCP novo passa por processo formal de avaliação (segurança, custo, risco de exfiltração de dados). |
| 7 | **Verificação antes de claim** | Nenhum agente pode declarar "pronto" sem evidência. O ciclo termina em `verification.md` com prova observável de que o goal foi atingido — não apenas tasks marcadas. |
| 8 | **Reversibilidade preferida** | Ações destrutivas (force-push, delete branch, drop table) sempre exigem confirmação humana explícita, mesmo em modo autônomo. |
| 9 | **Custo de IA é decisão de engenharia** | Chamadas a modelos grandes, contextos massivos, agentes paralelos agressivos têm custo. O SDK expõe esse custo (estimativa por fase) para decisões conscientes. |
| 10 | **Aprendizado coletivo** | Learnings extraídos por `mb-retro` são propostos para promoção à constitution corporativa via PR ao `mb-ai-core`. |

---

## 4. Arquitetura macro

### 4.1 Camadas

```
┌────────────────────────────────────────────────────────────────────┐
│  CAMADA 0 — Distribuição                                            │
│  GitHub Enterprise MB → marketplace interno (mb-marketplace)        │
└────────────────────────────────────────────────────────────────────┘
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│  CAMADA 1 — Plugin obrigatório (mb-ai-core)                         │
│  • Constitution MB                                                  │
│  • Hooks bloqueantes de segurança e compliance                      │
│  • MCP allowlist                                                    │
│  • Comandos /mb-help, /mb-status, /mb-approve                       │
│  • Convenções de commit, PR, branch                                 │
└────────────────────────────────────────────────────────────────────┘
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│  CAMADA 2 — Plugins de processo (opt-in por squad)                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                 │
│  │ mb-bootstrap │ │   mb-sdd     │ │  mb-review   │                 │
│  └──────────────┘ └──────────────┘ └──────────────┘                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                 │
│  │mb-observabil │ │ mb-security  │ │   mb-retro   │                 │
│  └──────────────┘ └──────────────┘ └──────────────┘                 │
└────────────────────────────────────────────────────────────────────┘
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│  CAMADA 3 — Contexto do squad (.mb/ + docs/specs/ no repo)          │
│  • CLAUDE.md customizado                                            │
│  • glossary.md (domínio + jargões internos)                         │
│  • runbooks/                                                        │
│  • skills/ custom do squad                                          │
│  • hooks/ custom do squad                                           │
│  • docs/specs/_active/, docs/specs/_archive/                        │
└────────────────────────────────────────────────────────────────────┘
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│  CAMADA 4 — Audit trail e telemetria                                │
│  • Git como fonte de verdade (specs, decisões, commits)             │
│  • Logs estruturados de hook fires (futuro: stream para SIEM)       │
│  • Métricas de adoção e qualidade (futuro: dashboard)               │
└────────────────────────────────────────────────────────────────────┘
```

### 4.2 Repositório do SDK

O SDK vive em **um único repositório** (`mercadobitcoin/mb-ai-sdk`) com estrutura multi-plugin:

```
mb-ai-sdk/
├── README.md                            # visão geral + por onde começar
├── LICENSE
├── CHANGELOG.md
├── docs/
│   ├── plans/                           # propostas e designs (este documento)
│   ├── governance/                      # papéis, processos, RACI
│   ├── playbooks/                       # como executar tarefas comuns
│   └── faq.md
├── .claude-plugin/
│   └── marketplace.json                 # lista os 7 plugins
└── plugins/
    ├── mb-ai-core/
    ├── mb-bootstrap/
    ├── mb-sdd/
    ├── mb-review/
    ├── mb-observability/
    ├── mb-security/
    └── mb-retro/
```

Cada plugin tem estrutura padrão:

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── references/
│       ├── scripts/
│       └── assets/
├── commands/                            # slash commands
│   └── *.md
├── hooks/                               # hooks declarados via hooks.json
│   ├── hooks.json
│   └── scripts/
└── agents/                              # subagents quando aplicável
    └── *.md
```

### 4.3 Marketplace interno

A v1.0 usa o próprio repositório GitHub como marketplace. Squads adicionam ao `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "mb": {
      "source": {
        "source": "github",
        "repo": "mercadobitcoin/mb-ai-sdk"
      }
    }
  },
  "enabledPlugins": {
    "mb-ai-core@mb": true,
    "mb-bootstrap@mb": true,
    "mb-sdd@mb": true
  }
}
```

A v2.0 considera infraestrutura própria (mirror interno, controle de versão centralizado, telemetria de uso) caso o MB precise de isolamento total da rede pública para distribuição.

---

## 5. Os sete plugins em detalhe

Cada subseção descreve **propósito**, **comandos**, **skills**, **hooks**, **artefatos gerados** e **dependências** entre plugins.

### 5.1 `mb-ai-core` (obrigatório)

**Propósito:** estabelecer a baseline corporativa que todo squad MB carrega ao usar IA. É a "constituição" operacional do SDK.

**Comandos:**
- `/mb-help` — exibe overview do SDK, plugins instalados, comandos disponíveis, links para docs.
- `/mb-status` — diagnóstico: quais plugins MB estão ativos, hooks carregados, MCPs aprovados em uso, presença de `.mb/` no repo, conformidade de constitution.
- `/mb-approve <fase>` — registra aprovação humana de fase do ciclo SDD com autor, timestamp e motivo, gravada em `docs/specs/_active/<feature>/approvals.log`.
- `/mb-exception` — abre processo formal de exceção a uma regra bloqueante (gera issue, exige aprovação do Chapter AI).

**Skills:**
- `mb-constitution` — carrega princípios MB no contexto sempre que ativada. Auto-invocada quando o agente está prestes a tomar decisão arquitetural, de segurança ou de processo.

**Hooks (bloqueantes — categoria SEGURANÇA/COMPLIANCE):**
- `pre-commit-secret-scan` — bloqueia commit que contenha padrões de segredo (chaves AWS/GCP, JWT, private keys, `.env` não-template, strings tipo `password=`, `secret=`, `bearer ...`). Implementação: regex + entropia em `scripts/secret-scan.sh`.
- `pre-tool-mcp-allowlist` — bloqueia uso de MCP que não esteja na allowlist `mb-ai-core/config/mcp-allowlist.json`. Mensagem orienta como propor inclusão.
- `pre-bash-destructive-confirm` — intercepta comandos destrutivos (`rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE`, `kubectl delete`) e exige confirmação explícita gravada em log.
- `post-commit-audit-log` — anexa metadado ao commit (plugins ativos, fase SDD vigente, spec referenciada) em git-notes para trilha de auditoria.

**Artefatos gerados:**
- `.mb/audit/approvals.log` — toda aprovação registrada via `/mb-approve`.
- `.mb/audit/exceptions.log` — exceções abertas via `/mb-exception`.
- `git notes` — metadados de IA por commit.

**Dependências:** nenhuma. É a base de todos os outros.

---

### 5.2 `mb-bootstrap`

**Propósito:** onboarding de squad ao SDK via fluxo híbrido (análise automática → entrevista guiada → enriquecimento contínuo).

**Comandos:**
- `/mb-bootstrap` — entra no fluxo completo de onboarding. Primeiro uso por squad.
- `/mb-bootstrap-rescan` — reanalisa o repositório para atualizar inferências (após refator grande, mudança de stack).
- `/mb-enrich-domain` — missão de enriquecimento: aprofunda glossário e contexto de domínio.
- `/mb-enrich-runbooks` — missão: documenta runbooks operacionais a partir de incidentes recentes ou conhecimento tribal.
- `/mb-enrich-skills` — missão: identifica skills custom que o squad se beneficiaria de criar e gera scaffolding.

**Skill:**
- `mb-bootstrap` — orquestra o fluxo:
  1. **Análise automática (5 min):** detecta linguagens (extensões, package files), frameworks (imports, dependencies), estrutura (monorepo vs multi-repo), CI (workflows existentes), padrões de teste, presença de IaC.
  2. **Entrevista guiada (20-30 min):** 10 perguntas estruturadas cobrindo domínio de negócio, fluxos críticos, stakeholders, dores recentes, prioridades trimestrais, estilo de revisão. Conduzida com Tech Lead + squad presente, Chapter AI acompanhando primeiras execuções.
  3. **Geração:** cria `.mb/CLAUDE.md`, `.mb/glossary.md`, `.mb/runbooks/README.md`, `.mb/hooks/` (template para hooks custom), `.mb/skills/` (template para skills custom).
  4. **Plano de enriquecimento:** sugere 3 missões para as próximas 4 semanas.

**Hooks:** nenhum próprio (consome hooks do core).

**Artefatos gerados:**
```
.mb/
├── CLAUDE.md                     # contexto principal do squad
├── glossary.md                   # jargões, abreviações, conceitos de domínio
├── runbooks/
│   ├── README.md
│   └── <runbook>.md              # criados via /mb-enrich-runbooks
├── skills/                       # skills custom do squad
├── hooks/                        # hooks custom do squad
└── bootstrap/
    ├── analysis.md               # output da fase de análise automática
    ├── interview.md              # respostas da entrevista
    └── enrichment-plan.md        # plano das missões sugeridas
```

**Dependências:** `mb-ai-core`.

---

### 5.3 `mb-sdd` (refator do plugin atual)

**Propósito:** ciclo Spec-Driven Development rígido com checkpoints obrigatórios. Espinha dorsal do trabalho não-trivial.

**Comandos:**
- `/mb-spec` — entra no fluxo completo (discuss → spec → plan → execute → verify → ship → retro).
- `/mb-spec-discuss` — fase 1 isolada (ambiguity scoring).
- `/mb-spec-requirements` — fase 2 isolada (gera `requirements.md` em EARS).
- `/mb-spec-design` — fase 3 isolada.
- `/mb-spec-plan` — fase 4 isolada (gera `tasks.md`).
- `/mb-spec-execute` — fase 5 (executa tasks com commits atômicos).
- `/mb-spec-verify` — fase 6 (verificação goal-backward).
- `/mb-spec-retro` — fase 7 (extração de learnings).
- `/mb-hotfix` — modo expresso: pula DISCUSS/SPEC, exige PLAN mínimo + post-mortem em 48h.
- `/mb-spike` — modo exploratório: gera apenas `spike.md`, código vai para branch descartável.

**Skill principal:**
- `mb-sdd` — herda integralmente do plugin atual `spec-driven-development`, com adaptações:
  - Templates referenciam constitution MB.
  - Cada fase fecha com chamada a `/mb-approve <fase>` para audit-trail.
  - Integração com `mb-review` (`mb-spec-ship` aciona review automático).
  - Integração com `mb-retro` (`mb-spec-retro` propõe learnings ao core).

**Hooks (categoria PROCESSO/QUALIDADE — começam como aviso, viram bloqueio após maturidade):**
- `pre-commit-spec-reference` — avisa/bloqueia commit que não referencie spec ativa (formato `[spec:<feature>] <msg>` ou label `chore:` para infra).
- `post-tool-checkpoint-reminder` — após geração de artefato de fase, lembra de chamar `/mb-approve`.

**Artefatos gerados:** ver `docs/specs/_active/<data>-<feature>/` na seção 6.

**Dependências:** `mb-ai-core`. Sinergia com `mb-bootstrap`, `mb-review`, `mb-retro`.

---

### 5.4 `mb-review`

**Propósito:** padronizar processo de revisão (code review, PR review, security review) como etapa formal do ciclo, não como atividade ad-hoc.

**Comandos:**
- `/mb-review-pr <pr-url-or-branch>` — code review estruturado contra a spec referenciada e contra a constitution. Gera `REVIEW.md`.
- `/mb-review-security` — security review: threat model rápido, OWASP top 10, segredos, dependências vulneráveis, cripto-específicos (custódia, KYC).
- `/mb-review-spec` — verifica se a implementação está coerente com `requirements.md` (todo critério EARS coberto?).
- `/mb-review-fix` — aplica correções dos achados de severidade alta/média de um `REVIEW.md`.

**Skills:**
- `mb-code-reviewer` — agente revisor com regras MB (stack-agnostic).
- `mb-security-reviewer` — agente especializado em segurança e cripto.
- `mb-spec-reviewer` — agente que valida coverage spec ↔ implementação.

**Hooks:**
- `pre-pr-create-review-required` (categoria PROCESSO) — avisa se PR está sendo aberto sem `REVIEW.md` no diretório da spec ativa.

**Artefatos:** `docs/specs/_active/<feature>/REVIEW.md` com findings classificados (BLOCK / FLAG / PASS) e severidade (alta/média/baixa).

**Dependências:** `mb-ai-core`. Sinergia forte com `mb-sdd` e `mb-security`.

---

### 5.5 `mb-observability`

**Propósito:** garantir que toda feature nova nasça com observabilidade adequada — sem opinar sobre stack (Datadog, Grafana, NewRelic, OTel são equivalentes para o SDK).

**Comandos:**
- `/mb-observability-design` — guia design de observabilidade para a feature corrente: o que logar, o que metricar, o que tracear, alertas, SLOs. Gera `OBSERVABILITY.md`.
- `/mb-observability-review` — audita uma implementação existente: cobertura de logs estruturados, presença de trace context propagation, métricas RED/USE adequadas, alertas acionáveis (não apenas barulhentos).
- `/mb-runbook-from-incident` — gera runbook a partir de descrição de incidente recente.

**Skills:**
- `mb-observability-designer` — entrevista o dev sobre fluxos críticos da feature, identifica pontos cegos, propõe instrumentação.
- `mb-observability-reviewer` — audita código contra checklist de observabilidade.

**Hooks:** nenhum bloqueante na v1.0 (categoria QUALIDADE — vira aviso na v1.1, bloqueio na v2.0 após maturidade).

**Artefatos:** `docs/specs/_active/<feature>/OBSERVABILITY.md` + runbooks em `.mb/runbooks/`.

**Dependências:** `mb-ai-core`. Sinergia com `mb-sdd` (fase PLAN inclui observability design).

---

### 5.6 `mb-security`

**Propósito:** trazer rigor de segurança específico para uma exchange cripto. Threat modeling, controles de compliance, padrões de cripto, custódia, KYC/AML.

**Comandos:**
- `/mb-threat-model` — gera threat model STRIDE para a feature corrente, com foco em ativos de alto valor (chaves, fundos, dados regulados).
- `/mb-security-checklist` — checklist específico cripto: gestão de chaves, assinatura de transações, custódia, autenticação multi-fator, rate limiting, proteção contra MEV/front-running quando aplicável.
- `/mb-compliance-check <regulação>` — verifica conformidade com Bacen/CVM/LGPD/Travel Rule. Aceita `bacen`, `cvm`, `lgpd`, `travel-rule`, `pci`.
- `/mb-secret-rotate` — guia rotação de segredos detectada como vencida ou comprometida.

**Skills:**
- `mb-threat-modeler` — conduz threat modeling estruturado.
- `mb-compliance-advisor` — conhece exigências regulatórias brasileiras de exchange e orienta atendimento.
- `mb-crypto-advisor` — orienta sobre padrões cripto (BIP, gestão de chaves, custódia hot/warm/cold, multisig).

**Hooks (BLOQUEANTES — categoria SEGURANÇA):**
- `pre-commit-pii-scan` — bloqueia commit com PII (CPF, RG, dados bancários) em arquivos não-marcados como dados de teste.
- `pre-commit-private-key-scan` — bloqueia commit com qualquer formato de chave privada.
- `pre-tool-prod-secret-access` — alerta + audit-log quando ferramenta tenta acessar arquivo/var marcado como `prod-secret`.

**Artefatos:** `docs/specs/_active/<feature>/THREAT-MODEL.md`, `SECURITY.md`, `.mb/audit/security-events.log`.

**Dependências:** `mb-ai-core`. Sinergia com `mb-review` e `mb-sdd` (fase DESIGN exige threat-model para features tocando ativos críticos).

---

### 5.7 `mb-retro`

**Propósito:** transformar cada ciclo SDD em aprendizado coletivo. Extrai learnings, propõe evolução de constitution e de skills, alimenta a memória organizacional.

**Comandos:**
- `/mb-retro` — conduz retrospectiva da feature/fase corrente. Gera `retro.md` estruturado: o que funcionou, o que falhou, surpresas, decisões que viraram precedente, propostas de mudança ao processo.
- `/mb-retro-promote` — promove learning do squad para proposta de PR ao `mb-ai-core` (constitution corporativa).
- `/mb-retro-extract-skill` — identifica padrões repetidos no squad e propõe scaffolding de skill custom local.
- `/mb-retro-quarterly` — agrega retros do trimestre, gera relatório executivo de tendências e propostas.

**Skills:**
- `mb-retro-facilitator` — conduz a retrospectiva como agente facilitador.
- `mb-learning-extractor` — analisa retros e identifica padrões promovíveis.

**Hooks:** nenhum.

**Artefatos:** `docs/specs/_active/<feature>/retro.md`, `.mb/learnings/quarterly-<YYYY-Qn>.md`, PRs propostos ao `mb-ai-core`.

**Dependências:** `mb-ai-core`, `mb-sdd`.

---

## 6. Ciclo de desenvolvimento rígido

O ciclo é a espinha dorsal pedagógica. Toda feature não-trivial passa pelas 7 fases. Cada fase produz artefato versionado e tem checkpoint humano.

### 6.1 Diagrama do ciclo

```
   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ DISCUSS  │───▶│   SPEC   │───▶│   PLAN   │───▶│ EXECUTE  │
   │ ambiguity│    │ EARS req │    │ tasks    │    │ batches  │
   │ scoring  │    │ + design │    │ + deps   │    │ atomic   │
   └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
        │ ✓ approve     │ ✓ approve     │ ✓ approve    │ commits
        ▼               ▼                ▼               ▼
   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
   │  RETRO   │◀───│   SHIP   │◀───│  REVIEW  │◀───│  VERIFY  │
   │ learnings│    │ PR + tag │    │ code/sec │    │ goal-back│
   │ → const. │    │ audit    │    │ /spec    │    │ + UAT    │
   └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### 6.2 Definição de cada fase

| Fase | Pergunta-chave | Artefato | Pronto quando |
|------|----------------|----------|---------------|
| **DISCUSS** | O que estamos resolvendo e onde está a ambiguidade? | `discuss.md` com ambiguity score | Score < limiar e premissas explícitas |
| **SPEC** | O que precisa ser construído (sem stack)? | `requirements.md` em EARS | Produto consegue ler e dizer "é isso" |
| **PLAN** | Como construímos? | `design.md` + `tasks.md` | Tasks ≤1 dia cada, deps claras, threat-model se ativo crítico |
| **EXECUTE** | Vamos construir | commits atômicos referenciando spec | Toda task com checkbox marcado e commit referenciado |
| **VERIFY** | O goal foi atingido? | `verification.md` com evidência | Critérios EARS testados, UAT aprovado |
| **REVIEW** | Está pronto para produção? | `REVIEW.md` (code+sec+spec) | Sem findings BLOCK, FLAGs documentados |
| **SHIP** | Entregar com trilha | PR + tag + audit-log | PR mergeado com referência à spec, audit-log fechado |
| **RETRO** | O que aprendemos? | `retro.md` + propostas | Learnings extraídos, propostas abertas se aplicável |

### 6.3 Checkpoints obrigatórios

Após cada fase, o agente **pausa** e exige `/mb-approve <fase>` executado por humano. Sem aprovação:

- A próxima fase **não inicia**.
- O agente não pode declarar progresso.
- Tentativa de pular checkpoint dispara hook bloqueante.

A aprovação é gravada em `.mb/audit/approvals.log` com formato:

```
2026-05-10T14:32:11Z | feature=user-onboarding-v2 | phase=DESIGN | actor=joao.silva | reason="Design aprovado em sync com TL e Chapter AI"
```

### 6.4 Modos especiais (ainda rígidos)

- **`/mb-hotfix <descrição>`** — pula DISCUSS e SPEC. Exige `hotfix-plan.md` mínimo (problema, solução, impacto, rollback). Produz commit + PR. Agenda `post-mortem.md` obrigatório em 48h via lembrete persistente.
- **`/mb-spike <pergunta>`** — exploratório. Gera apenas `spike.md` com pergunta, hipótese, experimento, resultado. Código em branch `spike/<topic>` que **não pode ser mergeado** — só usado para extrair aprendizado.

### 6.5 Estrutura de artefatos por feature

```
docs/specs/
├── INDEX.md                         # gerado por script
├── constitution.md                  # herdada do mb-ai-core + extensões do squad
├── _active/
│   └── 2026-05-10-user-onboarding-v2/
│       ├── discuss.md
│       ├── requirements.md
│       ├── design.md
│       ├── tasks.md
│       ├── execution.log
│       ├── verification.md
│       ├── REVIEW.md
│       ├── THREAT-MODEL.md          # se ativo crítico
│       ├── OBSERVABILITY.md
│       ├── approvals.log
│       └── retro.md
└── _archive/
    └── 2026-Q1/                     # arquivado após /mb-spec-ship
```

---

## 7. Modelo de bootstrap (híbrido em três passos)

### 7.1 Passo 1 — Análise automática (5 min, sem humano)

`mb-bootstrap` roda scripts que produzem `.mb/bootstrap/analysis.md`:

- **Stack:** linguagens detectadas (por extensão e arquivos `go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `Gemfile`).
- **Frameworks:** inferidos de dependências (Next.js, FastAPI, Gin, Express, Spring Boot, etc).
- **Estrutura:** monorepo (Turborepo, Nx, workspaces) vs multi-repo, presença de `apps/`, `packages/`, `services/`.
- **CI/CD:** workflows GitHub Actions, GitLab CI, CircleCI presentes.
- **Testes:** frameworks detectados (Jest, Vitest, pytest, go test, RSpec).
- **IaC:** presença de Terraform, Pulumi, Helm charts.
- **Observabilidade:** presença de OTel, Datadog, Sentry libs.
- **Segurança:** presença de `.gitleaks`, `pre-commit-config`, `dependabot`, `snyk`.

### 7.2 Passo 2 — Entrevista guiada (20-30 min, com TL + squad + Chapter AI)

10 perguntas estruturadas. O agente conduz, registra em `.mb/bootstrap/interview.md`:

1. **Domínio:** Em uma frase, o que esse serviço/produto faz para o cliente final?
2. **Fluxos críticos:** Quais são os 3-5 fluxos que, se quebrarem, geram incidente Sev1?
3. **Stakeholders:** Quem usa o que vocês entregam? (clientes finais, B2B, times internos, reguladores)
4. **Dores recentes:** Que tipo de bug/incidente mais consumiu vocês nos últimos 90 dias?
5. **Prioridades trimestrais:** Quais são os 2-3 objetivos do squad para o próximo trimestre?
6. **Estilo de revisão:** Vocês fazem PR review síncrono, assíncrono? Há rituais (pair, mob, ensemble)?
7. **Maturidade de testes:** Cobertura ~%? E2E existe? Testes em produção (canary, shadow)?
8. **Gargalos atuais:** Onde o time gasta tempo demais? (debug, ambientes, deploy, contexto)
9. **Glossário:** Liste 5-10 jargões/abreviações que um dev novo precisa entender no primeiro dia.
10. **Relação com regulação:** Esse serviço toca algo regulado (KYC, AML, custódia, ordens, fiscal)?

### 7.3 Passo 3 — Geração e plano de enriquecimento

A partir de análise + entrevista, `mb-bootstrap` gera:

- `.mb/CLAUDE.md` — contexto principal do squad (síntese do que importa).
- `.mb/glossary.md` — jargões da entrevista.
- `.mb/runbooks/README.md` — esqueleto, runbooks reais virão por `/mb-enrich-runbooks`.
- `.mb/skills/` — pasta vazia + template para primeira skill custom.
- `.mb/hooks/` — pasta vazia + template para primeiro hook custom.
- `.mb/bootstrap/enrichment-plan.md` — 3 missões para próximas 4 semanas:
  - Semana 1: `/mb-enrich-runbooks` para fluxo crítico #1.
  - Semana 2-3: `/mb-enrich-domain` aprofundando 2 conceitos identificados como "ambíguos".
  - Semana 4: `/mb-enrich-skills` propondo primeira skill custom do squad.

### 7.4 Reanálise periódica

`/mb-bootstrap-rescan` roda trimestralmente (ou após refator grande). Atualiza `analysis.md`, propõe deltas para `.mb/CLAUDE.md`. Não sobrescreve sem aprovação.

---

## 8. Modelo de enforcement (hooks bloqueantes por categoria)

### 8.1 Categorização

| Categoria | Postura | Exemplo de hook |
|-----------|---------|-----------------|
| **SEGURANÇA** | Sempre bloqueante, sem exceção via flag | `pre-commit-secret-scan`, `pre-commit-private-key-scan` |
| **COMPLIANCE** | Sempre bloqueante, exceção apenas via `/mb-exception` (gera issue + aprovação Chapter AI) | `pre-commit-pii-scan`, `pre-tool-mcp-allowlist` |
| **PROCESSO** | Inicia como aviso (warning), vira bloqueante após 4 semanas de uso pelo squad | `pre-commit-spec-reference`, `pre-pr-create-review-required` |
| **QUALIDADE** | Sempre aviso, nunca bloqueia | `post-tool-checkpoint-reminder`, lembretes de observabilidade |

### 8.2 Mecânica de evolução

O hook `pre-commit-spec-reference` (PROCESSO) começa em modo `warn`. Após 4 semanas (configurável em `.mb/config.yaml`), vira `block`. O squad recebe lembrete automático 1 semana antes da virada. Se necessário adiar, TL abre exceção via `/mb-exception`.

### 8.3 Auditabilidade dos disparos

Todo hook fire é gravado em `.mb/audit/hook-fires.log` com:

```
2026-05-10T15:42:09Z | hook=pre-commit-secret-scan | tool=Bash | status=BLOCKED | reason="AWS access key detected in src/config.ts:42" | actor=joao.silva
```

Logs são append-only. Tentativa de remoção é detectada por `pre-commit-audit-log-tamper` (categoria COMPLIANCE).

### 8.4 Execução local vs CI

Os mesmos hooks bloqueantes do harness Claude Code rodam também como GitHub Actions checks via workflow `mb-ai-checks.yml` distribuído pelo `mb-ai-core`. Garante que mesmo dev que desabilite hook localmente seja barrado no PR.

---

## 9. Audit trail e compliance

### 9.1 O que é auditável

| Evento | Onde fica | Formato |
|--------|-----------|---------|
| Aprovação de fase SDD | `.mb/audit/approvals.log` | append-only, assinado |
| Exceção a regra | `.mb/audit/exceptions.log` + GitHub issue | log + issue |
| Hook fire | `.mb/audit/hook-fires.log` | append-only |
| Decisão de design | `docs/specs/.../design.md` | git commit |
| Spec aprovada | `docs/specs/.../requirements.md` | git commit |
| Threat model | `docs/specs/.../THREAT-MODEL.md` | git commit |
| Comando executado | git-notes no commit | metadado |

### 9.2 Mapeamento a requisitos regulatórios

- **Bacen Resolução 4.658 (segurança cibernética):** rastreabilidade de mudanças (✓ via git + audit logs), gestão de incidentes (✓ via `mb-retro` post-mortem), gestão de acessos a ferramentas (✓ via MCP allowlist).
- **CVM Resolução 35 (custódia):** segregação de ambientes e aprovações (✓ via checkpoints SDD), trilha de decisões (✓ via specs).
- **LGPD:** prevenção de exposição de PII (✓ via `pre-commit-pii-scan`), rastreio de quem acessou o quê (✓ parcial via audit logs; integração SIEM em v2.0).

### 9.3 Retenção

`.mb/audit/` é versionado em git (retenção indefinida pela política do MB). Logs antigos (>1 ano) podem ser arquivados em `.mb/audit/_archive/` para evitar crescimento excessivo do diretório ativo.

---

## 10. Governança e papéis

### 10.1 Papéis

| Papel | Responsabilidade | Treinamento |
|-------|-----------------|-------------|
| **Chapter AI** | Mantém `mb-ai-core`, governa marketplace, avalia inclusão de MCPs, treina champions, audita uso, evolui constitution | Programa interno + acompanhamento de bootstrap nos primeiros 3 squads |
| **Tech Lead do Squad** | Opera o SDK no dia a dia, conduz `/mb-bootstrap` com squad, aprova fases SDD, decide exceções menores, conecta com Chapter AI | Workshop de 4h + bootstrap acompanhado |
| **AI Champion (designado por squad)** | Mantém contexto vivo (CLAUDE.md, glossário, skills), evangeliza no squad, propõe learnings ao Chapter, é ponto de contato | Programa de 8h + comunidade interna mensal |
| **Dev** | Usa o harness no dia a dia, propõe melhorias, abre exceções quando necessário | Onboarding de 1h ao instalar plugins |

### 10.2 Processo de proposta de mudança

Mudanças no `mb-ai-core` (constitution, hooks bloqueantes, MCP allowlist) seguem fluxo:

1. **Proposta:** PR ao repo `mb-ai-sdk` com label `proposal`.
2. **Review:** Chapter AI + 2 AI Champions de squads diferentes.
3. **Período de comentário:** 5 dias úteis.
4. **Aprovação:** maioria simples + veto possível pelo Chapter AI por motivo de segurança/compliance.
5. **Release:** versão minor (`0.X.0`) ou patch (`0.X.Y`); breaking change exige major (`X.0.0`) e janela de migração de 30 dias.

### 10.3 RACI resumido

| Atividade | Chapter AI | Tech Lead | AI Champion | Dev |
|-----------|:----------:|:---------:|:-----------:|:---:|
| Manter constitution corporativa | R/A | C | C | I |
| Aprovar inclusão de MCP | R/A | C | C | I |
| Bootstrap do squad | C | R | A | I |
| Manter `.mb/CLAUDE.md` do squad | I | A | R | C |
| Aprovar fases SDD | I | R/A | C | C |
| Abrir exceção bloqueante | A | R | C | I |
| Propor learning ao core | C | C | R | I |

---

## 11. Roadmap faseado

### v0.1 — Foundation (Semana 1-3)

- `mb-ai-core` funcional com constitution, 4 hooks bloqueantes, comandos `/mb-help`, `/mb-status`, `/mb-approve`.
- `mb-bootstrap` funcional end-to-end.
- `mb-sdd` refatorado a partir do plugin atual.
- Marketplace interno publicado.
- Documentação por papel (Chapter AI, TL, Champion, Dev).
- 1 squad piloto operando.

### v0.5 — Expansão de processo (Semana 4-8)

- `mb-review` com 3 modos (code, security, spec).
- `mb-observability` com design + review.
- `mb-security` com threat-model + checklist cripto + 3 hooks bloqueantes específicos.
- `mb-retro` com extração de learnings + promoção a constitution.
- 3-5 squads operando.
- Primeira retrospectiva trimestral consolidada.

### v1.0 — Maturidade pedagógica (Semana 9-13)

- Squads piloto destravam modos relaxados após critérios objetivos atingidos.
- Hooks de PROCESSO migram de aviso para bloqueio nos squads maduros.
- CI integrado: hooks rodando como GitHub Actions checks.
- Programa formal de AI Champions com comunidade ativa.
- Dashboard básico de adoção (squads ativos, ciclos completados, exceções abertas).

### v1.5 — Inteligência e otimização (Semana 14-20)

- Análise de retros agregada via skill dedicada.
- Sugestões automáticas de skills custom baseadas em padrões repetidos.
- Detecção de drift de constitution (squads divergindo demais).
- Integração com Jira/Linear para abrir specs a partir de tickets.

### v2.0 — Plataforma corporativa (Trimestre 2)

- Marketplace interno com infraestrutura própria (mirror, controle de versão, telemetria).
- Audit logs streaming para SIEM corporativo.
- Dashboard executivo de qualidade e custo de IA por squad.
- API formal para integração com ferramentas internas (TPM, SRE, Compliance).
- Programa de certificação interno para AI Champions e TLs.

---

## 12. Riscos e mitigações

| # | Risco | Probabilidade | Impacto | Mitigação |
|---|-------|:-------------:|:-------:|-----------|
| 1 | Adoção baixa por percepção de overhead | Alta | Alto | Squad piloto com TL engajado, retro semanal, métricas de "tempo economizado em onboarding" |
| 2 | Hooks bloqueantes geram fricção excessiva | Média | Alto | Categoria QUALIDADE/PROCESSO inicia como aviso; canal direto com Chapter AI para feedback |
| 3 | Vazamento de dados regulados via prompt para modelos externos | Média | Crítico | MCP allowlist, hooks de PII, treinamento obrigatório, monitoramento |
| 4 | Squads driftarem da constitution corporativa | Média | Médio | Comunidade de Champions mensal, dashboard de drift na v1.0 |
| 5 | Manutenção do SDK virar gargalo no Chapter AI | Média | Alto | Modelo de proposta via PR distribui carga; rotação de revisores entre Champions |
| 6 | Excesso de plugins gera complexidade cognitiva | Baixa | Médio | Plugin obrigatório é mínimo; opt-in granular; `/mb-help` orienta o que cada um faz |
| 7 | Custo de IA explode sem controle | Média | Alto | Princípio #9 (custo é decisão); `mb-ai-core` expõe estimativa por fase; alertas de uso anômalo |
| 8 | Compliance regulatório identifica lacuna | Baixa | Crítico | Engajar Compliance/Jurídico em revisão formal antes de v1.0 |
| 9 | Chave de modelo IA exposta por dev | Baixa | Crítico | Hooks bloqueantes + rotação automática + secret manager corporativo |
| 10 | SDK fica desatualizado vs evolução do Claude Code | Alta | Médio | Versionamento independente, changelog disciplinado, smoke tests em cada release do Claude Code |

---

## 13. Critérios de sucesso e métricas

### 13.1 Critérios qualitativos para v1.0

- 5+ squads ativos com `mb-ai-core` + ao menos 2 plugins opcionais.
- 80%+ das features não-triviais nesses squads passando pelo ciclo SDD completo.
- Zero incidentes de vazamento de segredo via Claude Code nos squads piloto.
- Chapter AI consegue manter o SDK com ≤20% de seu tempo.
- Comunidade de AI Champions ativa (encontro mensal com >70% de presença).

### 13.2 Métricas quantitativas (capturadas via audit logs e git)

| Métrica | Como mede | Meta v1.0 |
|---------|-----------|-----------|
| Adoção | Squads com `.mb/` no repo | ≥5 |
| Ciclos completados | Pastas em `_archive/` por trimestre | ≥3 por squad ativo |
| Hook fires bloqueantes | Eventos em `hook-fires.log` por semana | Decrescente após semana 4 |
| Exceções abertas | Issues label `mb-exception` | ≤2 por squad por mês |
| Tempo de bootstrap | Início → `.mb/CLAUDE.md` gerado | ≤1h |
| Tempo de onboarding novo dev | Junção do dev → primeiro PR mergeado | -30% vs baseline pré-SDK |
| Cobertura de threat-model | Features tocando ativos críticos com `THREAT-MODEL.md` | 100% |

### 13.3 Critérios para destravar modo relaxado

Squad demonstra maturidade quando:
- 3+ ciclos SDD completos sem exceção a hook bloqueante.
- 2+ retros consecutivas com proposta promovida ao core.
- Champion ativo no programa há ≥8 semanas.

Destravado: pode usar `/mb-fast` para tarefas pequenas (commit direto com hooks de qualidade), mantendo ciclo completo para features.

---

## 14. Apêndices

### A. Estrutura de pastas — exemplo completo

```
mb-ai-sdk/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .claude-plugin/
│   └── marketplace.json
├── docs/
│   ├── plans/2026-05-10-mb-ai-sdk-design.md
│   ├── governance/raci.md
│   ├── governance/proposal-process.md
│   ├── playbooks/install-by-role.md
│   ├── playbooks/run-bootstrap.md
│   ├── playbooks/handle-exception.md
│   └── faq.md
└── plugins/
    ├── mb-ai-core/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/mb-constitution/SKILL.md
    │   ├── commands/{mb-help,mb-status,mb-approve,mb-exception}.md
    │   ├── hooks/hooks.json
    │   ├── hooks/scripts/{secret-scan,destructive-confirm,audit-log,mcp-allowlist}.sh
    │   ├── config/mcp-allowlist.json
    │   └── config/constitution.md
    ├── mb-bootstrap/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/mb-bootstrap/SKILL.md
    │   ├── skills/mb-bootstrap/scripts/repo-scan.sh
    │   ├── skills/mb-bootstrap/assets/templates/{CLAUDE.md.tpl,glossary.md.tpl,runbook.md.tpl}
    │   └── commands/{mb-bootstrap,mb-bootstrap-rescan,mb-enrich-domain,mb-enrich-runbooks,mb-enrich-skills}.md
    ├── mb-sdd/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/mb-sdd/  (refator do plugin atual)
    │   └── commands/{mb-spec,mb-spec-discuss,mb-spec-requirements,mb-spec-design,mb-spec-plan,mb-spec-execute,mb-spec-verify,mb-spec-retro,mb-hotfix,mb-spike}.md
    ├── mb-review/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/{mb-code-reviewer,mb-security-reviewer,mb-spec-reviewer}/SKILL.md
    │   └── commands/{mb-review-pr,mb-review-security,mb-review-spec,mb-review-fix}.md
    ├── mb-observability/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/{mb-observability-designer,mb-observability-reviewer}/SKILL.md
    │   └── commands/{mb-observability-design,mb-observability-review,mb-runbook-from-incident}.md
    ├── mb-security/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── skills/{mb-threat-modeler,mb-compliance-advisor,mb-crypto-advisor}/SKILL.md
    │   ├── hooks/hooks.json
    │   ├── hooks/scripts/{pii-scan,private-key-scan,prod-secret-access}.sh
    │   └── commands/{mb-threat-model,mb-security-checklist,mb-compliance-check,mb-secret-rotate}.md
    └── mb-retro/
        ├── .claude-plugin/plugin.json
        ├── README.md
        ├── skills/{mb-retro-facilitator,mb-learning-extractor}/SKILL.md
        └── commands/{mb-retro,mb-retro-promote,mb-retro-extract-skill,mb-retro-quarterly}.md
```

### B. Glossário rápido

- **EARS:** Easy Approach to Requirements Syntax — formato `When/Where/While/If <trigger> Then <system response>`.
- **STRIDE:** Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation of privilege — modelo de threat modeling.
- **Spec ativa:** spec em `docs/specs/_active/` — em desenvolvimento.
- **Constitution:** princípios não-negociáveis carregados em todo contexto.
- **Hook bloqueante:** intercepta ação e impede sua execução até critério ser atendido.
- **MCP allowlist:** lista de Model Context Protocol servers aprovados pelo Chapter AI.
- **AI Champion:** referência de IA dentro do squad, ponto de contato com Chapter AI.

### C. FAQ

**P: Sou dev solo num squad pequeno, preciso de tudo isso?**
R: Não. Comece com `mb-ai-core` + `mb-sdd`. Adicione outros conforme necessidade.

**P: Posso desabilitar um hook que está atrapalhando?**
R: Hooks de SEGURANÇA/COMPLIANCE não. Hooks de PROCESSO/QUALIDADE sim, via `.mb/config.yaml`. Mudança fica registrada.

**P: Meu squad usa stack X, vocês não documentaram nada para X.**
R: Por design — o SDK é stack-agnostic. `/mb-bootstrap` gera contexto específico para sua stack.

**P: Como reportar bug no SDK?**
R: Issue no repo `mb-ai-sdk` com label `bug`. Para problemas urgentes, contato direto com Chapter AI.

**P: O SDK envia dados para fora do MB?**
R: O SDK em si não envia nada. As ferramentas que ele orquestra (Claude Code, MCPs aprovados) seguem suas próprias políticas. MCPs externos passam por avaliação de exfiltração.

---

**Fim do documento. Próximos passos:** publicar este documento, conduzir kick-off com Chapter AI e TLs piloto, iniciar implementação conforme roadmap §11.
