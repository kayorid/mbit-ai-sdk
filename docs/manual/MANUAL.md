# Manual Técnico — MB AI SDK

> Manual de referência completo: bases teóricas, arquitetura interna, mecânica de cada plugin, fluxos detalhados, padrões avançados e práticas state-of-the-art de desenvolvimento assistido por IA em maio de 2026.

**Versão:** 0.1.0
**Data:** 2026-05-10
**Audiência:** Chapter AI, AI Champions, Tech Leads, devs interessados em entender o SDK em profundidade.

---

## Índice

1. [Bases teóricas](#1-bases-teóricas)
2. [Arquitetura interna](#2-arquitetura-interna)
3. [Como o Claude Code carrega plugins](#3-como-o-claude-code-carrega-plugins)
4. [Anatomia de um plugin MB](#4-anatomia-de-um-plugin-mb)
5. [Plugin a plugin — internals](#5-plugin-a-plugin--internals)
6. [O ciclo SDD em detalhe](#6-o-ciclo-sdd-em-detalhe)
7. [Mecânica dos hooks](#7-mecânica-dos-hooks)
8. [Audit trail](#8-audit-trail)
9. [Padrões avançados (estado da arte 2026)](#9-padrões-avançados-estado-da-arte-2026)
10. [Glossário técnico](#10-glossário-técnico)
11. [Referências e leitura adicional](#11-referências-e-leitura-adicional)

---

## 1. Bases teóricas

### 1.1 Spec-Driven Development (SDD)

**Origem:** prática derivada de Behavior-Driven Development (BDD), Domain-Driven Design (DDD) e da tradição de specs formais (Z, TLA+). Ganhou nova relevância em 2024-2026 com o uso intensivo de LLMs em desenvolvimento, popularizada por trabalhos como o **GitHub Spec-Kit** (2025), **Kiro** e os papers da Anthropic sobre "Specifications as the new programming language" (Lattner & Karpathy, 2025).

**Intuição central:** LLMs implementam bem o que está escrito; o problema é o que **não** está escrito. SDD resolve isso fazendo da spec o ponto de verdade que o agente consulta, atualiza e respeita.

**Notação EARS (Easy Approach to Requirements Syntax):** introduzida por Mavin et al. (2009), formaliza requisitos em 5 templates:

- **Ubiquitous:** `O sistema deve <comportamento>.`
- **Event-driven:** `Quando <evento>, o sistema deve <resposta>.`
- **State-driven:** `Enquanto <estado>, o sistema deve <comportamento>.`
- **Optional:** `Onde <funcionalidade>, o sistema deve <comportamento>.`
- **Conditional:** `Se <condição>, então o sistema deve <resposta>.`

EARS resolve o problema de requisitos em prosa solta — força explicitar trigger, sistema, resposta. Resultado: requisitos testáveis e cobertura mensurável.

### 1.2 Verification-before-completion

**Origem:** prática consagrada na engenharia rigorosa (NASA, aviação) e formalizada em superpowers / TDD-strict. A intuição: agentes LLM têm forte tendência a declarar "pronto" otimisticamente. A defesa é exigir **evidência observável** antes de qualquer claim.

**Operacionalização no MB AI SDK:** a fase VERIFY do ciclo SDD exige `verification.md` mapeando cada critério EARS a uma evidência (teste rodado, observação manual, métrica). Sem PASS em todos os critérios obrigatórios, SHIP é bloqueado.

### 1.3 Defensive AI hooks

**Inspiração:** controles em fronteiras de sistema (input validation, output sanitization) aplicados ao "sistema agente". O agente é um componente potencialmente errático cuja saída precisa passar por validações automatizadas antes de virar efeito real (commit, deploy, mensagem).

**Categorização do MB AI SDK:**
- **SEGURANÇA:** sempre bloqueia, sem exceção via flag (ex: chave privada).
- **COMPLIANCE:** sempre bloqueia, exceção apenas via processo formal `/mb-exception`.
- **PROCESSO:** começa como aviso, vira bloqueio após maturidade demonstrada.
- **QUALIDADE:** sempre aviso.

Esta gradação evita "fadiga de bloqueio" que faz times desabilitar tudo.

### 1.4 Subagent-driven development

**Conceito:** decomposição de tarefas em subagentes especializados, executados em paralelo ou sequência. Reduz contexto de cada agente (foco), permite paralelização e isola riscos.

**Aplicação no MB AI SDK:** os plugins `mb-review`, `mb-security` e `mb-retro` definem subagentes especializados (`mb-code-reviewer`, `mb-threat-modeler`, `mb-retro-facilitator`) que são invocados pelo agente principal quando o domínio especializado é necessário.

**Padrão emergente em 2026:** "agent orchestration" via MCPs e tool use, com agentes coordenadores que decidem quando delegar. O MB AI SDK adota a versão minimalista: subagentes como skills com domínio claro, invocados pelo agente principal sob demanda.

### 1.5 Prompt caching estratégico

**Mecânica:** modelos como Claude permitem marcar segmentos de prompt como cacheáveis (TTL ~5min). Releituras subsequentes não cobram pelo conteúdo cacheado. Custo cai dramaticamente em sessões longas com contexto repetido.

**Aplicação no SDK:** constitution, `.mb/CLAUDE.md`, glossário e referências de skills são bons candidatos a cache (mudam pouco, são lidos muito). O Chapter AI deve orientar squads a estruturar prompts longos para maximizar hit rate.

### 1.6 Memória organizacional persistente

**Conceito:** capturar aprendizado em artefatos versionados que sobrevivem a turnover, contextos novos e mudanças de modelo. Inspirado em técnicas como `MEMORY.md` (Anthropic 2025), graphs of facts, e práticas de pós-mortem disciplinadas (Etsy, Google).

**No MB AI SDK:**
- **Específico do squad:** `.mb/CLAUDE.md`, glossário, skills custom, runbooks (mantidos por AI Champion).
- **Corporativo:** constitution, hooks, MCP allowlist (mantidos pelo Chapter AI).
- **Trimestral:** `.mb/learnings/quarterly-*.md` agregando padrões.

A memória é **versionada em git**, não em sistema externo opaco. Vantagens: auditável, diff-able, recuperável.

### 1.7 Audit-by-default

**Origem:** sistemas regulados (banking, healthcare, aviation) sempre operaram com audit trails imutáveis. Aplicado ao desenvolvimento assistido por IA: como saber, em 6 meses, **por que** uma decisão foi tomada por um agente?

**No MB AI SDK:**
- Spec é a trilha de "por quê".
- `.mb/audit/approvals.log` registra "quem aprovou o quê quando".
- `.mb/audit/exceptions.log` registra desvios conscientes.
- `.mb/audit/hook-fires.log` registra decisões de bloqueio.
- git é a fonte de verdade — append-only, assinado, diff-able.

### 1.8 MCP curation

**Conceito:** Model Context Protocol (Anthropic, 2024) permite estender agentes com servidores externos. Risco: MCP malicioso ou mal-projetado pode exfiltrar dados, executar ações inesperadas, custar caro.

**Padrão MB:** allowlist explícita auditada pelo Chapter AI. Inclusão exige análise (segurança, custo, exfiltração documentada). Inspirado em práticas corporativas de gestão de dependências (Snyk, dependabot) aplicadas a tools de agente.

---

## 2. Arquitetura interna

### 2.1 Camadas

```
┌─────────────────────────────────────────────────────────────────┐
│ CAMADA 0 — Distribuição                                          │
│ GitHub Enterprise MB → repo mb-ai-sdk → marketplace via JSON     │
└─────────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ CAMADA 1 — Plugin obrigatório                                    │
│ mb-ai-core: constitution, hooks bloqueantes, MCP allowlist       │
└─────────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ CAMADA 2 — Plugins de processo (opt-in)                          │
│ mb-bootstrap, mb-sdd, mb-review, mb-observability,               │
│ mb-security, mb-retro                                            │
└─────────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ CAMADA 3 — Contexto do squad (.mb/ no repo)                      │
│ CLAUDE.md, glossary.md, runbooks/, skills/, hooks/, audit/       │
└─────────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ CAMADA 4 — Audit trail e telemetria                              │
│ git (specs, decisões, commits) + .mb/audit/ (eventos)            │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Fluxo de carga de uma sessão

Quando um dev abre o Claude Code num repo MB:

1. **Claude Code lê `~/.claude/settings.json`**: descobre marketplace `mb` e plugins habilitados.
2. **Resolve marketplace**: clona/atualiza `mb-ai-sdk` em `~/.claude/plugins/cache/mb/`.
3. **Carrega cada plugin**: lê `.claude-plugin/plugin.json`, registra skills, comandos e hooks.
4. **Hooks ficam armados**: registrados para `PreToolUse`, `PostToolUse`, etc.
5. **Skills ficam disponíveis**: descrição rica + metadados permitem auto-trigger por contexto.
6. **Comandos ficam disponíveis**: `/mb-*` reconhecidos no input.
7. **Constitution carrega sob demanda**: skill `mb-constitution` é invocada em pontos críticos (decisão arquitetural, segurança, processo).
8. **Contexto do squad** (`.mb/CLAUDE.md`) é lido pelo Claude Code automaticamente como "project memory".

### 2.3 Interação entre plugins

Os plugins são fracamente acoplados via **convenções compartilhadas**:

- Pasta `.mb/` no repo do squad.
- Pasta `docs/specs/_active/<feature>/` para artefatos de feature.
- Audit logs em `.mb/audit/`.
- Comandos com prefixo `/mb-`.
- Hooks com payload JSON padrão.

Não há acoplamento de código — qualquer plugin pode ser desabilitado isoladamente. Mas há recomendações de combinação (ex: `mb-sdd` se beneficia de `mb-review`, `mb-security` para features críticas).

---

## 3. Como o Claude Code carrega plugins

Para entender o SDK, é útil saber como o Claude Code (versão maio/2026) processa plugins.

### 3.1 Marketplace

Um marketplace é um repositório Git com:
- `.claude-plugin/marketplace.json` no root (manifesto).
- Plugins em subpastas listadas em `marketplace.json` (`source`).

### 3.2 Plugin

Um plugin é uma pasta com:
- `.claude-plugin/plugin.json` (metadados: nome, descrição, versão, autor).
- `skills/` (opcional, define skills auto-trigger).
- `commands/` (opcional, slash commands).
- `hooks/` (opcional, hooks de eventos).
- `agents/` (opcional, subagentes nomeados).

### 3.3 Skill

Cada skill é uma pasta `skills/<name>/` com `SKILL.md` no formato:

```markdown
---
name: nome-da-skill
description: Descrição rica que descreve quando usar
---

# Conteúdo da skill (instruções para o agente)
```

A descrição é **crítica**: o agente decide se invoca a skill com base nela. Skills MB usam descrições em português com triggers explícitos ("acione quando o usuário disser X, Y, Z, ou estiver na fase ...").

### 3.4 Comando

Cada comando é um arquivo Markdown em `commands/<nome>.md`:

```markdown
---
description: Descrição curta para listagem
argument-hint: <args opcional>
---

# Conteúdo: instruções para o agente quando o comando é chamado
```

Comandos MB começam com `mb-` para namespacing.

### 3.5 Hook

Hooks são declarados em `hooks/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/meu-hook.sh"
          }
        ]
      }
    ]
  }
}
```

Eventos disponíveis: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SessionStart`, `Stop`, `SubagentStop`.

O script recebe payload JSON via stdin (com `tool_name`, `tool_input`, etc) e:
- **exit 0:** prossegue.
- **exit 2:** bloqueia, mensagem de stderr vai pro agente.
- **exit ≠ 0,2:** erro, prossegue com aviso.

`${CLAUDE_PLUGIN_ROOT}` é a raiz do plugin, expandida em runtime.

---

## 4. Anatomia de um plugin MB

Estrutura padrão de cada plugin do SDK:

```
plugins/<nome>/
├── .claude-plugin/
│   └── plugin.json
├── README.md                       # documentação humana
├── skills/                         # skills auto-trigger
│   └── <skill-name>/
│       ├── SKILL.md               # instruções principais
│       ├── references/            # docs sob demanda
│       │   └── *.md
│       ├── scripts/               # automações
│       │   └── *.sh ou *.py
│       └── assets/
│           ├── templates/         # templates de artefatos (.tpl)
│           └── examples/          # exemplos
├── commands/                       # slash commands
│   └── *.md
├── hooks/                          # hooks (se aplicável)
│   ├── hooks.json
│   └── scripts/
│       └── *.sh
├── agents/                         # subagentes nomeados (futuro)
└── config/                         # configuração estática
    └── *.json ou *.yaml
```

**Convenções MB:**
- Nomes de skill, comando e hook usam prefixo `mb-`.
- Descrições em português com triggers explícitos.
- Scripts shell têm shebang `#!/usr/bin/env bash` e são `chmod +x`.
- Templates terminam em `.tpl` (não confundir com arquivo final).
- Configuração separada do código (alterável sem mexer em scripts).

---

## 5. Plugin a plugin — internals

### 5.1 mb-ai-core

**Componentes:**
- `config/constitution.md` — texto carregado pela skill `mb-constitution`.
- `config/mcp-allowlist.json` — fonte de verdade para `mcp-allowlist.sh`.
- `skills/mb-constitution/SKILL.md` — skill com auto-trigger em decisões críticas.
- `commands/{mb-help,mb-status,mb-approve,mb-exception}.md` — comandos base.
- `hooks/hooks.json` + `hooks/scripts/{secret-scan,destructive-confirm,mcp-allowlist,audit-log}.sh`.

**Comportamento de cada hook:**

| Hook | Evento | Matcher | Bloqueia? | O que faz |
|------|--------|---------|-----------|-----------|
| `secret-scan.sh` | `PreToolUse` | `Write\|Edit` | sim | Detecta padrões de segredo (AWS, GitHub PAT, JWT, etc) |
| `destructive-confirm.sh` | `PreToolUse` | `Bash` | sim (sem flag `# MB_CONFIRMED`) | Detecta `rm -rf`, `force-push`, `DROP`, etc |
| `mcp-allowlist.sh` | `PreToolUse` | `mcp__.*` | sim (sem allowlist) | Bloqueia MCPs fora da `mcp-allowlist.json` |
| `audit-log.sh` | `PostToolUse` | `Bash` | não | Grava `.mb/audit/commands.log` para git/k8s/terraform/aws |

**Fluxo de `/mb-approve`:**
1. Detecta spec ativa, fase, aprovador (via `git config user.email`).
2. Append em `.mb/audit/approvals.log` + `docs/specs/.../approvals.log`.
3. Commit dedicado.
4. Confirma no chat com próxima fase liberada.

### 5.2 mb-bootstrap

**Componentes:**
- `skills/mb-bootstrap/SKILL.md` — orquestra fluxo de 3 passos.
- `skills/mb-bootstrap/scripts/repo-scan.sh` — análise automática (5min, sem LLM).
- `skills/mb-bootstrap/references/interview-questions.md` — 10 perguntas estruturadas.
- `skills/mb-bootstrap/assets/templates/{CLAUDE.md.tpl,glossary.md.tpl}` — templates.
- `commands/{mb-bootstrap,mb-bootstrap-rescan,mb-enrich-domain,mb-enrich-runbooks,mb-enrich-skills}.md`.

**`repo-scan.sh` detecta** (regex + heurísticas):
- Linguagens: Go (`go.mod`), Node (`package.json`), Python (`pyproject.toml`/`setup.py`/`requirements.txt`), Rust (`Cargo.toml`), Java/Kotlin (`pom.xml`/`build.gradle`), Ruby (`Gemfile`), Swift.
- Frameworks: Next.js, React, Express, NestJS, Fastify, Gin, Fiber, Echo, FastAPI, Django, Flask.
- Estrutura: monorepo (Turborepo, Nx, pnpm/lerna).
- CI: GitHub Actions, GitLab CI, CircleCI, Jenkins.
- IaC: Terraform, Pulumi, Helm, Kustomize, Docker.
- Observabilidade: OTel, Datadog, NewRelic, Sentry, Prometheus.
- Testes: Vitest, Jest, pytest, Cypress, Playwright, go test.
- Segurança: gitleaks, pre-commit, dependabot, snyk.

Saída: `.mb/bootstrap/analysis.md` markdown estruturado.

**Fluxo da entrevista:**
- Skill executa as 10 perguntas uma por mensagem.
- Resposta de cada uma é appendada em `.mb/bootstrap/interview.md`.
- Após a 10ª, gera artefatos finais usando análise + entrevista.

### 5.3 mb-sdd

**Componentes:**
- `skills/mb-sdd/SKILL.md` — herança do plugin SDD original com adaptações MB.
- `skills/mb-sdd/references/{ears-notation,phase-playbook,status-tracking,...}.md` — docs aprofundadas.
- `skills/mb-sdd/assets/templates/{requirements,design,tasks,status,...}.md.tpl`.
- `skills/mb-sdd/scripts/{init_spec.sh,update_index.py,validate_spec.py}` — automações.
- `commands/{mb-spec,mb-spec-discuss,...,mb-hotfix,mb-spike}.md` — 10 comandos.

**Estado do ciclo:** persistido em:
- `docs/specs/_active/<feature>/status.md` — fase atual, decisões.
- `docs/specs/_active/<feature>/approvals.log` — checkpoints aprovados.
- `tasks.md` — checkboxes refletem progresso.

**Integração com outros plugins:**
- `mb-spec-design` invoca `/mb-threat-model` (de `mb-security`) se ativo crítico.
- `mb-spec-design` invoca `/mb-observability-design` (de `mb-observability`) sempre.
- `mb-spec` invoca `/mb-review-pr`, `/mb-review-spec`, `/mb-review-security` na fase REVIEW.
- `mb-spec-retro` delega para `mb-retro-facilitator` (de `mb-retro`).

### 5.4 mb-review

**Componentes:**
- `skills/mb-code-reviewer/SKILL.md` — code review estruturado.
- `skills/mb-security-reviewer/SKILL.md` — OWASP + cripto.
- `skills/mb-spec-reviewer/SKILL.md` — coverage spec ↔ implementação.
- `commands/{mb-review-pr,mb-review-security,mb-review-spec,mb-review-fix}.md`.

**Saída padrão:** `docs/specs/_active/<feature>/REVIEW.md` com seções por dimensão (code, security, spec coverage), findings classificados (BLOCK/HIGH/MEDIUM/LOW/INFO) com sugestão de correção.

`/mb-review-fix` aplica correções de findings BLOCK/HIGH com commit atômico por finding e marca como RESOLVED no REVIEW.md.

### 5.5 mb-observability

**Componentes:**
- `skills/mb-observability-designer/SKILL.md` — design de logs, métricas, traces, alertas, SLOs.
- `skills/mb-observability-reviewer/SKILL.md` — auditoria de instrumentação.
- `commands/{mb-observability-design,mb-observability-review,mb-runbook-from-incident}.md`.

**Filosofia operacional:**
- RED (Request-level: Rate, Errors, Duration) para serviços HTTP/RPC.
- USE (Resource-level: Utilization, Saturation, Errors) para infraestrutura.
- Golden signals (latency, traffic, errors, saturation).
- Métricas de domínio para sinais de negócio.
- Alertas sobre **sintoma**, não causa.
- SLO definido com SLI calculável e error budget.

### 5.6 mb-security

**Componentes:**
- `skills/mb-threat-modeler/SKILL.md` — STRIDE + cripto.
- `skills/mb-compliance-advisor/SKILL.md` — Bacen, CVM, LGPD, Travel Rule, PCI.
- `skills/mb-crypto-advisor/SKILL.md` — BIP, custódia, multisig.
- `commands/{mb-threat-model,mb-security-checklist,mb-compliance-check,mb-secret-rotate}.md`.
- `hooks/hooks.json` + `hooks/scripts/{pii-scan,private-key-scan}.sh`.

**Hooks bloqueantes (categoria SEGURANÇA):**

| Hook | Detecta | Falsos-positivos comuns |
|------|---------|-------------------------|
| `pii-scan.sh` | CPF (`xxx.xxx.xxx-xx`), CNPJ (`xx.xxx.xxx/xxxx-xx`), cartão | Documentos em fixtures (mitigado por allowlist de paths `_test`, `_fixture`, `_example`) |
| `private-key-scan.sh` | PEM, BIP-32 xprv, hex 256-bit + keyword "secret/private", BIP-39 mnemonic | Hex de hash (false-positive raro pela co-ocorrência com keyword) |

Estes hooks **não aceitam exceção** via `/mb-exception` — são inegociáveis.

### 5.7 mb-retro

**Componentes:**
- `skills/mb-retro-facilitator/SKILL.md` — conduz retro de 5 dimensões.
- `skills/mb-learning-extractor/SKILL.md` — agregação trimestral.
- `commands/{mb-retro,mb-retro-promote,mb-retro-extract-skill,mb-retro-quarterly}.md`.

**Fluxo de promoção:**
- Squad gera `retro.md` por feature.
- AI Champion roda `/mb-retro-quarterly` para consolidar.
- Padrões com ≥3 ocorrências viram propostas via `/mb-retro-promote`.
- PR ao `mb-ai-sdk` com label `proposal`.
- Chapter AI + 2 Champions revisam.

---

## 6. O ciclo SDD em detalhe

### 6.1 As 8 fases

```
DISCUSS → SPEC → PLAN(design+tasks) → EXECUTE → VERIFY → REVIEW → SHIP → RETRO
```

Cada fase tem:
- **Pergunta-chave:** o que estamos respondendo?
- **Artefato(s):** o que produzimos?
- **Critério de pronto:** como sabemos que terminamos?
- **Checkpoint:** `/mb-approve <FASE>`.

### 6.2 DISCUSS — ambiguity scoring

**Pergunta:** o que estamos resolvendo e onde está a ambiguidade?
**Artefato:** `discuss.md` com tabela de dimensões e scores.
**Pronto quando:** todas as dimensões CLEAR ou explicitamente registradas como "premissa".

**Anti-pattern:** pular DISCUSS achando que "já entendemos". 80% do retrabalho vem de ambiguidade não detectada cedo.

### 6.3 SPEC — requirements em EARS

**Pergunta:** o que precisa ser construído (sem stack)?
**Artefato:** `requirements.md`.
**Pronto quando:** alguém de produto valida.

**Anti-pattern:** misturar HOW com WHAT. "O sistema deve usar Redis" não é requisito — é decisão técnica que vai para PLAN.

### 6.4 PLAN parte 1 — design.md

**Pergunta:** como construímos?
**Artefato:** `design.md` com arquitetura, dados, contratos, ADRs inline, alternativas, riscos.
**Pronto quando:** dá para quebrar em tasks.

**Validation gate (over-engineering):** após gerar, audite — "o que aqui é necessário vs. projetando para o futuro?". Remova o segundo grupo.

**Integrações automáticas:**
- Threat-model se ativo crítico.
- Observability design.

### 6.5 PLAN parte 2 — tasks.md

**Pergunta:** qual a sequência executável?
**Artefato:** `tasks.md` com tasks atômicas (≤1 dia), dependências, paralelização.
**Pronto quando:** cada task é fazível e testável.

### 6.6 EXECUTE — implementação com commits atômicos

**Pergunta:** vamos construir.
**Artefato:** commits + `execution.log`.
**Pronto quando:** todas tasks `[x]`.

**Convenção de commit:** `[spec:<slug>] T-<N>: <descrição>`.

**Anti-pattern:** mudar escopo no meio do execute sem retornar a PLAN.

### 6.7 VERIFY — verificação goal-backward

**Pergunta:** o goal foi atingido?
**Artefato:** `verification.md` mapeando cada critério EARS → evidência → status.
**Pronto quando:** todos os critérios obrigatórios PASS.

**Anti-pattern:** marcar como verificado por "fiz testes" sem mapear especificamente cada critério.

### 6.8 REVIEW — code/security/spec

**Pergunta:** está pronto para produção?
**Artefato:** `REVIEW.md` consolidado.
**Pronto quando:** sem findings BLOCK; HIGH resolvidos ou justificados.

### 6.9 SHIP — entrega com trilha

**Pergunta:** entregar com auditoria.
**Artefato:** PR mergeado + tag (se release).
**Pronto quando:** PR mergeado, audit-log fechado, comunicação feita.

### 6.10 RETRO — extração de learnings

**Pergunta:** o que aprendemos?
**Artefato:** `retro.md` + propostas.
**Pronto quando:** retrospectiva conduzida, propostas viram tasks ou PRs.

---

## 7. Mecânica dos hooks

### 7.1 Eventos suportados

| Evento | Quando dispara | Caso de uso |
|--------|---------------|-------------|
| `PreToolUse` | Antes do agente executar uma tool | Validar/bloquear (segredos, MCP, destrutivos) |
| `PostToolUse` | Após tool executar | Log, telemetria, audit |
| `UserPromptSubmit` | Quando user envia mensagem | Pré-processar, validar, bloquear |
| `SessionStart` | Início de sessão | Contexto inicial, advisories |
| `Stop` | Final de turno do agente | Cleanup, telemetria |
| `SubagentStop` | Final de subagente | Idem para subagentes |

### 7.2 Matcher

`matcher` é regex contra nome da tool. Exemplos:
- `Bash` → só Bash.
- `Write|Edit` → Write ou Edit.
- `mcp__.*` → todas as tools de MCP.
- `.*` → tudo.

### 7.3 Comportamento por exit code

- **0:** OK, prossegue.
- **2:** bloqueia. stderr vai pro agente como mensagem.
- **outro:** erro de hook, prossegue com aviso ao user.

### 7.4 Payload do hook

JSON via stdin:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push --force"
  },
  "tool_response": {  // só em PostToolUse
    "exit_code": 0,
    "stdout": "...",
    "stderr": "..."
  },
  "session_id": "...",
  "transcript_path": "..."
}
```

### 7.5 Padrão MB para hooks

```bash
#!/usr/bin/env bash
set -euo pipefail
INPUT="$(cat)"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# ... lógica ...

if [[ <bloqueio> ]]; then
  AUDIT_DIR=".mb/audit"
  mkdir -p "$AUDIT_DIR"
  echo "$(date -u +%FT%TZ) | hook=<nome> | status=BLOCKED | ..." >> "$AUDIT_DIR/hook-fires.log"
  cat <<EOF >&2
[mb-<plugin>] BLOCKED — <razão>
  <contexto>
  <orientação>
EOF
  exit 2
fi

exit 0
```

---

## 8. Audit trail

### 8.1 Estrutura

```
.mb/audit/
├── approvals.log           # /mb-approve
├── exceptions.log          # /mb-exception
├── hook-fires.log          # bloqueios
├── commands.log            # comandos shell relevantes
├── security-events.log     # eventos do mb-security
└── _archive/
    └── <YYYY-Qn>/          # arquivamento periódico
```

### 8.2 Formato

Append-only, line-per-event, ISO 8601 timestamps, pipe-delimited:

```
2026-05-10T14:32:11Z | hook=pre-commit-secret-scan | tool=Write | path=src/cfg.ts | status=BLOCKED | pattern=AWS_ACCESS_KEY
2026-05-10T14:35:22Z | feature=onboarding-v2 | phase=DESIGN | actor=joao@mb | reason="aprovado em sync"
```

### 8.3 Imutabilidade

- Logs versionados em git (cada modificação é commit).
- Hook futuro `pre-commit-audit-log-tamper` detecta deleção de linhas anteriores.
- `.mb/audit/` deve ter retention policy explícita (governança).

### 8.4 Mapeamento regulatório

| Requisito regulatório | Onde no audit |
|----------------------|--------------|
| Bacen 4.658 — rastreabilidade | git log + approvals.log |
| Bacen 4.658 — gestão de incidentes | runbooks + retros |
| LGPD — controle de acesso a PII | security-events.log |
| Travel Rule — KYC trail | depende do produto, mas SDK garante baseline de log |

---

## 9. Padrões avançados (estado da arte 2026)

### 9.1 Worktree-driven parallel work

**Mecânica:** usar `git worktree` para isolar trabalho em paralelo na mesma máquina sem sair do branch principal. Comum quando múltiplas specs/agentes operam simultaneamente.

**Quando usar no MB AI SDK:**
- Spike paralelo a feature em andamento.
- Hotfix em paralelo a feature.
- Subagentes operando em isolamento.

**Padrão emergente:** o usuário invoca skill `using-git-worktrees` antes de delegar a um subagente para evitar interferência.

### 9.2 Subagent dispatching para tarefas independentes

**Conceito:** quando há 2+ tarefas sem dependência entre si, despachar subagentes em paralelo.

**Exemplo no MB AI SDK:** durante PLAN, despachar em paralelo:
- subagente para gerar `design.md`
- subagente para gerar `OBSERVABILITY.md`
- subagente para gerar `THREAT-MODEL.md` (se aplicável)

Trade-off: paralelismo encurta tempo total mas multiplica custo. Aplique quando o ganho de tempo importa mais.

### 9.3 Plan mode + execute mode

Padrão que separa "planning" de "execution":
- **Planning** com modelo grande (Opus), foco em qualidade da decomposição.
- **Execution** com modelo eficiente (Sonnet/Haiku) por task, foco em throughput.

`mb-sdd` mapeia naturalmente: PLAN é planning-mode, EXECUTE é execution-mode.

### 9.4 Eval-driven AI features

Para features que **usam** IA em runtime (não só constroem com IA):
- Definir rubricas de avaliação **antes** da implementação.
- Construir conjunto de teste (golden dataset).
- Medir pass rate em CI a cada mudança de prompt/modelo.

Não está ainda no SDK v0.1, mas planejado para v1.0 como sub-plugin `mb-ai-evals` (quando squads começarem a construir features de IA, não apenas usar IA para construir).

### 9.5 Memory-first context strategy

Em sessões longas, ordem dos prompts importa para cache:
1. Constitution (estável, longa) — primeiro, cacheável.
2. `.mb/CLAUDE.md` (pouco mutável) — segundo, cacheável.
3. Spec ativa (muda em cada feature) — terceiro.
4. Trabalho corrente (muda a cada interação) — último, não cacheado.

Resultado: hit rate >80% em sessões típicas, redução significativa de custo.

### 9.6 Verification-by-evidence

Práticas convergentes em 2026:
- Nunca declarar pronto sem `verification.md`.
- Evidência é observável (saída de teste, screenshot, comando rodado).
- Subagentes têm "skin in the game": resultado do verifier é parte do contrato.

### 9.7 Hooks como contrato com o ambiente

Tendência: usar hooks não só para bloqueio, mas para:
- Injetar contexto (ex: hook `SessionStart` carrega resumo do dia anterior).
- Notificar (Slack quando hook bloqueia em produção).
- Coletar telemetria estruturada para evolução do SDK.

### 9.8 Gradação de bloqueio (categorização MB)

Padrão MB que tende a se popularizar:
- SEGURANÇA: sempre bloqueia.
- COMPLIANCE: bloqueia, exceção via processo.
- PROCESSO: warn → block após maturidade.
- QUALIDADE: warn-only.

Evita "fadiga de bloqueio" que faz times desabilitar hooks.

### 9.9 Constitution as code

A constitution é **versionada, testada e propagada** como código:
- `constitution.md` é a fonte de verdade.
- Hooks aplicam regras derivadas.
- Skills carregam o texto.
- Mudanças via PR, não deliberação informal.

### 9.10 Spec-as-test

Tendência emergente: cada critério EARS é também um caso de teste executável (via parsers de EARS → assertions). Ainda exploratório no MB v0.1; planejado para v1.0.

---

## 10. Glossário técnico

| Termo | Definição |
|-------|-----------|
| **EARS** | Easy Approach to Requirements Syntax — formato `When/Where/While/If <trigger> Then <response>` |
| **STRIDE** | Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation of privilege — categorias de ameaça |
| **MCP** | Model Context Protocol — protocolo de extensão de agentes via servidores externos |
| **Hook** | Script executado em evento do agente (PreToolUse, PostToolUse, etc) |
| **Skill** | Capability auto-trigger do agente, definida em SKILL.md |
| **Subagent** | Agente especializado invocado pelo agente principal |
| **Constitution** | Princípios não-negociáveis carregados em todo contexto |
| **Spec ativa** | Spec em `docs/specs/_active/` em desenvolvimento |
| **AI Champion** | Referência local de IA dentro do squad |
| **Audit trail** | Registro append-only de decisões para auditoria |
| **Allowlist** | Lista explícita de itens aprovados (alternativa a blocklist) |
| **Threat model** | Análise estruturada de ameaças e mitigações |
| **SLO** | Service Level Objective — meta de qualidade de serviço |
| **SLI** | Service Level Indicator — métrica para o SLO |
| **Error budget** | Tempo/eventos de degradação tolerados pelo SLO |
| **RED** | Rate, Errors, Duration — métricas request-level |
| **USE** | Utilization, Saturation, Errors — métricas resource-level |
| **Golden signals** | Latency, traffic, errors, saturation |
| **BIP** | Bitcoin Improvement Proposal |
| **EIP** | Ethereum Improvement Proposal |
| **HSM** | Hardware Security Module |
| **KMS** | Key Management Service |
| **Multisig** | Esquema de assinatura que exige N de M chaves |
| **Travel Rule** | FATF Recomendação 16 — transferência de info entre VASPs |
| **VASP** | Virtual Asset Service Provider |
| **PII** | Personally Identifiable Information |
| **Reorg** | Reorganização de blockchain (substituição de bloco recente) |
| **MEV** | Maximal Extractable Value (front-running e similar) |

---

## 11. Referências e leitura adicional

### 11.1 Spec-Driven Development

- Mavin, Wilkinson, Harwood, Novak. **"Easy Approach to Requirements Syntax (EARS)"**. IEEE RE 2009.
- GitHub Engineering. **"Spec-Kit: Specifications as the new programming language"**. Blog, 2025.
- Anthropic. **"Building reliable AI assistants with specifications"**. Whitepaper, 2025.

### 11.2 Plugins e harness do Claude Code

- Anthropic. **Claude Code Plugins documentation**. https://docs.claude.com/claude-code (versão maio/2026).
- Anthropic. **Skill descriptions and triggering**. Best practices.
- Anthropic. **Hook system reference**. Eventos, payloads, exit codes.
- Anthropic. **Model Context Protocol specification**. v1.x.

### 11.3 Práticas de engenharia avançada com IA

- Karpathy, A. **"Software 3.0: Specifications as the new code"**. Talk, 2025.
- Lattner, C. **"AI-assisted programming at scale"**. Modular blog, 2025.
- "Superpowers" plugin community. **TDD, debugging, brainstorming patterns**. Open source, 2025-2026.

### 11.4 Segurança e compliance

- OWASP. **Top 10 — 2025 edition**.
- NIST. **SP 800-63B — Digital Identity Guidelines**.
- Banco Central do Brasil. **Resolução BCB 4.658/2018**, **4.893/2021**, marco legal cripto.
- CVM. **Resolução 35/2021**.
- Lei Geral de Proteção de Dados (Lei 13.709/2018).
- FATF. **Recommendation 16 — Travel Rule**.
- Bitcoin Improvement Proposals (BIPs).
- Ethereum Improvement Proposals (EIPs).

### 11.5 Observabilidade

- Beyer, Jones, Petoff, Murphy (Google). **Site Reliability Engineering**. O'Reilly, 2016.
- Brendan Gregg. **USE Method**.
- Tom Wilkie (Grafana). **RED Method**.
- OpenTelemetry. **Specification and SDKs**.

### 11.6 Threat modeling

- Shostack, A. **"Threat Modeling: Designing for Security"**. Wiley, 2014.
- Microsoft. **STRIDE methodology**.
- OWASP. **Threat Modeling Process**.

### 11.7 Memória e contexto

- Anthropic. **MEMORY.md and persistent context**. Best practices, 2025.
- "Constitution as Code" patterns. Community emergent practice, 2025-2026.

---

## 12. Adendos v0.2 e v0.3

### 12.1 Plugin `mb-cost` (v0.2.0)

Captura uso de tokens via hook `PostToolUse` com curto-circuito antes de jq se payload sem `usage` (otimização B-4). Persiste em `.mb/audit/cost.log` com snapshot de preço (M-5) para auditoria contábil. Comandos: `/mb-cost`, `/mb-cost-feature`, `/mb-cost-budget`, `/mb-cost-alert`.

**Limitação conhecida:** Claude Code raramente coloca `usage` em payloads de tool individuais — tokens vêm no nível de mensagem do agente. Capture real é parcial. Em v1.0+, planejado mover para hook `Stop` ou `SessionEnd` lendo transcript.

### 12.2 Achievement system (v0.2.0)

12 conquistas catalogadas em `plugins/mb-ai-core/achievements/definitions.json`. Checker (`achievements/checker.sh`) avalia métricas do squad e atualiza `.mb/achievements.json`. Notify hook (`achievements/notify.sh`) plugado em Stop dispara banner celebrativo ao desbloquear.

### 12.3 Identidade visual MBit (v0.2.0)

- Paleta laranja MB oficial `#E8550C` em truecolor (`\033[38;2;232;85;12m`).
- 8 ASCII arts hexagonais (welcome, bootstrap-done, spec-start, ship, hotfix, retro, mature-squad, hexagon-logo) com FIGlet ANSI Shadow para "MBit".
- 4 temas configuráveis via `.mb/config.yaml` ou `MB_THEME`: `default`, `festive`, `compact`, `accessible`, `none`.
- Statusline auto-detect de largura (M-2): formato completo se ≥100 cols, compacto 80-100, mínimo <80.
- SessionStart hook envia banner colorido ao stderr (terminal) e versão plain ao `additionalContext` (LLM input — economia ~150 tokens/sessão, M-8).

### 12.4 Plugin `mb-evals` (v0.3.0)

Eval framework para features que **usam** IA em runtime. Estrutura por feature em `evals/<feature>/`:
- `dataset.jsonl` — golden examples
- `rubric.md` — critérios (determinística + LLM-as-judge + custom)
- `runner.sh` — chama sistema sob teste
- `threshold.yaml` — passing/failing scores
- `runs/` — histórico timestampado

Comandos: `/mb-evals-init`, `/mb-evals-run`, `/mb-evals-compare` (A/B), `/mb-evals-ci` (exit 0/1).

**Integração com mb-sdd:** fase VERIFY do ciclo SDD agora invoca `/mb-evals-ci` automaticamente para features AI. Score abaixo do threshold bloqueia VERIFY.

### 12.5 Comandos de produtividade (v0.2-v0.3)

- `/mb-init` — wizard de primeira instalação que configura `~/.claude/settings.json` com 9 plugins.
- `/mb-doctor` — diagnóstico estilo `brew doctor` com 7 seções de health check coloridas.
- `/mb-snapshot` — backup tar.gz reversível de `.mb/` e specs ativas; auto-snapshot em `mb-bootstrap-rescan`.
- `/mb-dashboard` — painel ASCII com sparklines de ciclos, maturidade, achievements, próxima ação contextual.
- `/mb-tutorial` — sandbox `~/.mb/tutorial-sandbox/` com repositório fictício "MBExchangeMini" + roteiro 45-60min.
- `/mb-update` — verifica e aplica atualizações via `git -C` (não muda cwd) com comparação semver via `sort -V` e validação de remote semver.
- `/mb-fast` — destrava modo expresso após critérios de maturidade (3+ ciclos, 0 exceções, 2+ promotions, 5+ achievements).
- `/mb-theme set/show` — gerência do tema visual.
- `/mb-search <termo>` — busca grep estruturada em specs com excerpt.
- `/mb-new-skill <slug>` — scaffolder rápido de skill custom.
- `/mb-retro-digest [N]` — resumo das últimas N retros.
- `/mb-version` — mostra versões instaladas dos 9 plugins.
- `/mb-list-plugins` — lista plugins ativados no settings.

### 12.6 Suite de smoke tests

`tests/smoke/run.sh` valida ~95+ itens em segundos:
- Estrutura repo + manifestos JSON
- Sincronização de versões (regressão B-1)
- Scripts shell (sintaxe + executáveis)
- Skills frontmatter, comandos
- Execução real de hooks com payloads positivos E negativos:
  - secret-scan: AWS, GitHub PAT, RSA inline (bloqueia); payload limpo (permite)
  - destructive-confirm: `rm -rf`, `--force`, `DROP` (bloqueia); `git status`, `--force-with-lease`, `MB_CONFIRMED` (permite)
  - pii-scan: CPF, CNPJ, **Visa/MC/Amex** (regressão B-3); placeholder, `_test` (permite)
  - private-key-scan: PEM, BIP-32 xprv, **Ethereum hex+keyword** (regressão B-3), BIP-39 mnemonic
- cost-report execução em day/week/month (regressão B-2)
- cost-capture overhead <200ms quando sem usage (regressão B-4)
- mb-evals scripts executam (regressão de v0.3)
- ASCII art completa, documentação completa, integrações presentes

CI próprio (`.github/workflows/sdk-ci.yml`) roda em todo PR ao `mbit-ai-sdk`.

### 12.7 Governança open-source (v0.3.0)

- `CONTRIBUTING.md` — modelo, padrão de commits, convenção de branch, plugin structure, code shell, skills, comandos, versionamento.
- `SECURITY.md` — canal privado de reporte, SLAs por severidade.
- `.github/ISSUE_TEMPLATE/{bug,proposal,security}.md` + `PULL_REQUEST_TEMPLATE.md`.
- `docs/MIGRATION.md` — guia entre versões.
- `docs/PLUGIN-DEVELOPMENT.md` — guia completo para criar plugins novos.

---

**Fim do manual. Para dúvidas, abra issue ou contate Chapter AI.**

**Versão:** 0.3.1 · **Última atualização:** 2026-05-10 · **Mantido por:** Chapter AI · Mercado Bitcoin · ⬡
