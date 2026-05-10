# MB AI SDK — Roadmap Evolutivo (v0.2 → v3.0)

> Plano detalhado de evolução do MB AI SDK após a v0.1 estar em piloto. Cobre 5 frentes (Encantamento, Inteligência Operacional, Integrações, Comunidade & Gamificação, Robustez Técnica) sequenciadas em 6 ondas (v0.2 → v3.0).

**Data:** 2026-05-10
**Autor:** Chapter AI
**Status:** Plano · pronto para priorização e início após validação do piloto v0.1
**Documentos relacionados:**
- [Design original v0.1](./2026-05-10-mb-ai-sdk-design.md)
- [Manual técnico](../manual/MANUAL.md)
- [Roteiro de apresentação](../presentation/PRESENTATION.md)

---

## Índice

1. [Visão e princípios da evolução](#1-visão-e-princípios-da-evolução)
2. [Mapa das 5 frentes](#2-mapa-das-5-frentes)
3. [Sequenciamento em ondas](#3-sequenciamento-em-ondas)
4. [Frente A — Encantamento e UX](#4-frente-a--encantamento-e-ux)
5. [Frente B — Inteligência Operacional](#5-frente-b--inteligência-operacional)
6. [Frente C — Integrações](#6-frente-c--integrações)
7. [Frente D — Comunidade e Gamificação](#7-frente-d--comunidade-e-gamificação)
8. [Frente E — Robustez Técnica](#8-frente-e--robustez-técnica)
9. [Backlog de evoluções menores](#9-backlog-de-evoluções-menores)
10. [Dependências cruzadas](#10-dependências-cruzadas)
11. [Estimativas e capacity planning](#11-estimativas-e-capacity-planning)
12. [Critérios de promoção entre ondas](#12-critérios-de-promoção-entre-ondas)
13. [Riscos e mitigações da evolução](#13-riscos-e-mitigações-da-evolução)
14. [Métricas de evolução](#14-métricas-de-evolução)

---

## 1. Visão e princípios da evolução

### 1.1 Onde queremos chegar

A v0.1 entregou o **piso** — processo padronizado, hooks bloqueantes, ciclo SDD, bootstrap híbrido. A evolução transforma o SDK de "harness funcional" em **plataforma corporativa de excelência em IA-assisted development**, comparável e superior ao estado da arte global.

**Visão para v3.0 (Q4 2026):**

> "Squad MB onboarda em IA mais rápido que squad equivalente em qualquer outra empresa cripto da América Latina. Auditoria externa do Bacen olha nosso processo e usa como referência. Devs MB se tornam referência de mercado por *como* operam IA, não só pelo produto que entregam."

### 1.2 Princípios da evolução

1. **Evolução é dirigida por uso real.** Cada feature nova nasce de necessidade observada nos retros dos squads, não de hipótese.
2. **YAGNI é regra, não exceção.** Nada entra na v0.2+ sem 3+ pedidos independentes.
3. **Compatibilidade primeiro.** Breaking changes em hooks/comandos exigem janela de migração documentada.
4. **Encantamento não é decoração.** UX bonita aumenta adoção; adoção determina sucesso.
5. **Inteligência operacional é diferencial competitivo.** Métricas, custo, evals — onde a maioria não vai.
6. **Comunidade é o maior multiplicador.** Champions ativos > qualquer ferramenta.
7. **Cada release pode ir a produção.** Sem feature flags secretas; sem código "para depois".

### 1.3 O que fica de fora propositadamente

- Marketplace público (mantemos interno).
- Plugin autoral por dev individual (apenas squad-level e core).
- Substituir Claude Code por alternativas (mantemos foco).
- Reescrever em outra linguagem (bash + markdown serve).

---

## 2. Mapa das 5 frentes

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  ╔══════════════════╗  ╔══════════════════╗  ╔════════════════╗  │
│  ║   A. ENCANTAMENTO║  ║ B. INTELIGÊNCIA  ║  ║ C. INTEGRAÇÕES ║  │
│  ║                  ║  ║   OPERACIONAL    ║  ║                ║  │
│  ║ Banner, theme,   ║  ║ Cost, evals,     ║  ║ Jira, Slack,   ║  │
│  ║ achievements,    ║  ║ knowledge graph, ║  ║ PagerDuty,     ║  │
│  ║ tutorial, sounds ║  ║ dashboard, search║  ║ Datadog, GHA   ║  │
│  ╚══════════════════╝  ╚══════════════════╝  ╚════════════════╝  │
│                                                                  │
│  ╔══════════════════════════════╗  ╔══════════════════════════╗  │
│  ║  D. COMUNIDADE & GAMIFICAÇÃO ║  ║   E. ROBUSTEZ TÉCNICA    ║  │
│  ║                              ║  ║                          ║  │
│  ║ Certification, leaderboard,  ║  ║ Doctor, snapshot, smoke, ║  │
│  ║ newsletter automática,       ║  ║ compat matrix, auto-     ║  │
│  ║ workshops mensais            ║  ║ update, telemetria       ║  │
│  ╚══════════════════════════════╝  ╚══════════════════════════╝  │
│                                                                  │
│              Tudo construído sobre a base v0.1                   │
└──────────────────────────────────────────────────────────────────┘
```

Cada frente tem **owner declarado** (Chapter AI sempre, mas com sub-owners por iniciativa) e roda **em paralelo** com as demais — exceto onde há dependência explícita (ver §10).

---

## 3. Sequenciamento em ondas

| Onda | Versão | Janela | Tema | Frentes ativas |
|------|--------|--------|------|----------------|
| **Onda 1** | v0.2 | Sem 4-5 (pós-piloto v0.1) | "Encantamento essencial" | A (parcial), E (doctor) |
| **Onda 2** | v0.5 | Sem 6-9 | "Expansão de processo + comunidade" | A (completa), D (parcial) |
| **Onda 3** | v1.0 | Sem 10-14 | "Maturidade pedagógica + integrações" | C (parcial), B (cost), D (completa) |
| **Onda 4** | v1.5 | Sem 15-20 | "Inteligência operacional" | B (completa), C (completa) |
| **Onda 5** | v2.0 | Trim 2 (Q3) | "Plataforma corporativa" | E (completa), tudo consolidado |
| **Onda 6** | v3.0 | Q4 2026 | "Excelência de mercado" | refinamento + open-source seletivo |

**Lógica do sequenciamento:**
1. Começamos pelo que aumenta **adoção** (encantamento + comunidade) — sem adoção, nada importa.
2. Adicionamos **integrações** (Slack, GHA) que expandem alcance sem mudar o core.
3. Investimos em **inteligência operacional** quando há massa crítica de dados (5+ squads ativos).
4. **Robustez técnica** progride continuamente, mas vira foco quando escalamos para >10 squads.
5. **v3.0** é polish: estabilizar APIs, considerar open-source dos componentes não-confidenciais.

---

## 4. Frente A — Encantamento e UX

### A.0 — Já entregue na v0.1.1 (banner inicial)

✓ Logo ASCII MB
✓ Manifesto rotativo (17 frases)
✓ Hook `SessionStart` com banner + status do squad
✓ Hook `Stop` com despedida e resumo do dia
✓ Status line custom
✓ Hook `Notification` com tom MB
✓ Comando `/mb-banner`

### A.1 — Theme variants (v0.2)

**Motivação:** terminais diferentes, contextos diferentes. Demo executiva (festivo), CI (compacto), dev daltônico (alto contraste).

**Escopo:**
- 4 temas: `default`, `compact`, `festive`, `accessible`.
- Configurável em `.mb/config.yaml`: `theme: default`.
- Variável de ambiente `MB_THEME` sobrescreve.
- Cada tema redefine paleta de cores e densidade de info na statusline.
- Tema `festive` usado em releases, dias especiais (data de fundação MB, marcos).

**Arquivos:**
```
plugins/mb-ai-core/themes/
├── default.sh            # paleta + funções de print
├── compact.sh
├── festive.sh
└── accessible.sh
```

**Critério de pronto:** trocar tema sem reiniciar Claude Code reflete na próxima statusline.

**Esforço:** 2 dias.

### A.2 — Achievement system (v0.2)

**Motivação:** maturidade do squad é mensurável. Celebrar marcos aumenta engajamento e cria referência social ("nosso squad já desbloqueou X").

**Escopo:**
- Achievements em `.mb/achievements.json` (squad-local) e `.mb/audit/achievements-corp.json` (futuro: corporativo).
- Cada achievement tem: `id`, `name`, `description`, `unlocked_at`, `criteria_evidence`.
- Conquistas iniciais propostas:

| ID | Nome | Critério |
|----|------|----------|
| `first-bootstrap` | 🌱 Primeiro voo | Squad rodou `/mb-bootstrap` |
| `first-cycle` | 🎯 Ciclo completo | Primeira feature do DISCUSS ao RETRO |
| `defender` | 🛡 Defensor | 1º hook bloqueante salvou um vazamento |
| `audit-ready` | 📋 Auditável | 5 ciclos completos com aprovações registradas |
| `mature-squad` | 🏆 Squad maduro | 3+ ciclos sem exceção, 2+ retros com promoção, Champion ativo 8+ semanas. Destrava `/mb-fast` |
| `core-contributor` | 🧠 Contribuidor core | Squad teve learning promovido à constitution |
| `skill-author` | ⚡ Autor de skills | Squad criou 1ª skill custom |
| `runbook-master` | 📖 Mestre de runbooks | Squad documentou 5+ runbooks |
| `threat-modeler` | 🔍 Threat modeler | Squad fez 3+ threat models completos |
| `hot-shot` | 🚒 Apagador profissional | Hotfix com post-mortem 100% completo |
| `zero-block-week` | 🌟 Semana limpa | 7 dias sem hook bloqueante |
| `centurion` | 💯 Centurião | 100 commits referenciando spec |

- **Notificação visual** ao destravar (banner especial + som opcional).
- **Comando** `/mb-achievements` lista os do squad.
- **Leaderboard** opcional via `/mb-leaderboard` (compara com média MB — sem ranking individual destrutivo).

**Arquivos:**
```
plugins/mb-ai-core/achievements/
├── definitions.json       # catálogo
├── checker.sh             # roda periódico, detecta novas conquistas
└── hooks/
    └── achievement-notify.sh   # SessionStart verifica, notifica
```

**Critério de pronto:** squad piloto destrava `first-bootstrap` no primeiro uso, com notificação visível.

**Esforço:** 4 dias.

### A.3 — Loading spinners e mensagens caprichadas (v0.2)

**Motivação:** comandos longos sem feedback parecem travados. Mensagens criativas reforçam identidade.

**Escopo:**
- Helper script `lib/spinner.sh` reutilizável.
- Mensagens contextuais por comando:
  - `/mb-bootstrap` → "✨ Mapeando o DNA do seu squad..."
  - `/mb-spec` → "📜 Construindo spec — segura como cold storage..."
  - `/mb-threat-model` → "🔍 Pensando como atacante motivado..."
  - `/mb-retro` → "🎓 Capturando aprendizado para o MB de 2027..."
- Pool de ~50 mensagens.

**Esforço:** 1 dia.

### A.4 — Sons opcionais (v0.2)

**Motivação:** sutil, opcional, mas memorável em bloqueios críticos. Devs que prestam atenção em audio capturam evento mais rápido.

**Escopo:**
- Helper que roda `osascript -e "beep"` (macOS), `paplay` (Linux), `powershell -c [console]::beep(...)` (Win).
- Configurável em `.mb/config.yaml`: `sounds: { enabled: false, on: ["security_block", "achievement"] }`.
- Default: desabilitado. Squad/dev opta in.

**Esforço:** 0.5 dia.

### A.5 — Tutorial interativo `/mb-tutorial` (v0.5)

**Motivação:** ler docs ≠ aprender fazendo. Tutorial guia o dev por um ciclo completo num sandbox.

**Escopo:**
- `/mb-tutorial` cria diretório temporário `~/.mb/tutorial-sandbox/`.
- Inicializa repo git fictício de produto cripto simples ("MBExchangeMini").
- Guia o usuário passo a passo por:
  1. `/mb-bootstrap` (bootstrap fictício, 5min).
  2. Pequena feature ("adicionar par BTC/USDC") via `/mb-spec` completo.
  3. Hotfix simulado.
  4. Threat model de exemplo.
  5. Retro final com promoção fictícia.
- Cada passo com explicação do "por quê" + dica.
- Tempo estimado: 45-60 min.
- Ao final: certificado markdown `tutorial-completed-<dev>.md` que vira menção em `/mb-status`.

**Esforço:** 5 dias (curadoria pedagógica + scaffolding).

### A.6 — Easter eggs sutis (v1.0)

**Motivação:** delight não-óbvio cria fidelidade. Devs que descobrem se sentem "in the know".

**Exemplos propostos:**
- Em datas especiais (aniversário do MB, halving do Bitcoin), banner muda sutilmente.
- Comando secreto `/mb-konami` mostra créditos animados.
- Após 100 commits referenciando spec, próximo `/mb-status` tem agradecimento personalizado.
- Mensagem do dia 21/04 (Tiradentes) referencia "independência operacional".
- Bloco genesis do Bitcoin como referência em alguma frase do manifesto.

**Esforço:** ongoing, ~0.5 dia/mês.

---

## 5. Frente B — Inteligência Operacional

### B.1 — `mb-cost` plugin (v1.0)

**Motivação:** uso de IA tem custo real. Sem visibilidade, custo escala silenciosamente. Decisões conscientes precisam de dados.

**Escopo:**
- Plugin novo `mb-cost`.
- **Mecânica:**
  - Hook `PostToolUse` captura uso de tokens reportado pela API.
  - Agrega por: comando, fase SDD, feature, dia, dev.
  - Persiste em `.mb/audit/cost.log`.
- **Comandos:**
  - `/mb-cost` — resumo da feature/dia/semana corrente.
  - `/mb-cost-feature <slug>` — custo total de uma feature por fase.
  - `/mb-cost-budget set <valor>` — define orçamento mensal/squad.
  - `/mb-cost-alert` — alerta quando consumo > X% do budget.
- **Dashboard ASCII:**
  ```
  Custo MB AI SDK — semana 19/2026

  ┌─────────────────┬────────┬────────┐
  │ Fase            │ Tokens │ R$ est │
  ├─────────────────┼────────┼────────┤
  │ DISCUSS         │ 12.4k  │  0.18  │
  │ SPEC            │ 24.1k  │  0.35  │
  │ DESIGN          │ 89.2k  │  1.30  │
  │ EXECUTE         │ 412.3k │  6.01  │
  │ VERIFY          │ 18.7k  │  0.27  │
  │ REVIEW          │ 156.4k │  2.28  │
  ├─────────────────┼────────┼────────┤
  │ TOTAL           │ 713.1k │ 10.39  │
  └─────────────────┴────────┴────────┘
  ```
- **Métricas-chave:** custo/feature, custo/dev/dia, % cache hit, % uso de modelos grandes vs pequenos.

**Esforço:** 8 dias (incluindo integração com API de billing).

### B.2 — `mb-evals` plugin (v1.5)

**Motivação:** quando squads começarem a construir features que **usam** IA em runtime (chatbot de suporte, classificação de transações, antifraude), precisamos de framework para avaliar qualidade dessas saídas — não basta unit test.

**Escopo:**
- Plugin novo `mb-evals`.
- **Arquitetura:**
  - `evals/<feature>/dataset.jsonl` — golden dataset.
  - `evals/<feature>/rubric.md` — rubrica de avaliação.
  - `evals/<feature>/runner.sh` — executa eval, gera relatório.
- **Rubricas suportadas:**
  - Determinística (regex, JSON schema, comparison).
  - Likert via LLM-as-judge (com prompt versionado).
  - Custom (script bash/python).
- **Comandos:**
  - `/mb-evals-init <feature>` — scaffolding de eval.
  - `/mb-evals-run <feature>` — roda eval, gera score.
  - `/mb-evals-compare <feature> <versao-a> <versao-b>` — A/B test de prompts/modelos.
  - `/mb-evals-ci <feature>` — modo CI (exit 0/1 conforme threshold).
- **Integração:** ciclo SDD para AI features ganha fase EVAL adicional entre VERIFY e REVIEW.

**Esforço:** 12 dias.

### B.3 — `mb-knowledge-graph` (v1.5)

**Motivação:** decisões dispersas viram silos. Grafo torna possível responder "quais squads tomaram decisão semelhante? que ADRs precedem este?".

**Escopo:**
- Plugin novo `mb-knowledge-graph`.
- **Mecânica:**
  - Parser que lê todos os `design.md`, `discuss.md`, `retro.md`, `THREAT-MODEL.md` do MB.
  - Extrai entidades (decisão, padrão, fragilidade, ferramenta) e relações (precede, contradiz, refina, motiva).
  - Persiste em `.mb/knowledge-graph/{nodes,edges}.jsonl` ou GraphML para visualização.
- **Comandos:**
  - `/mb-graph-build` — reconstrói grafo (squad-local).
  - `/mb-graph-search <consulta>` — busca semântica + estrutural.
  - `/mb-graph-related <slug>` — encontra specs relacionadas.
  - `/mb-graph-export <formato>` — exporta para Mermaid / GraphML / Neo4j Cypher.
- **Versão corporativa (v2.0):** worker centralizado agrega grafos de todos os squads.

**Esforço:** 10 dias squad-local; 20 dias corporativo.

### B.4 — `/mb-dashboard` ASCII (v1.0)

**Motivação:** painel rápido com métricas do squad sem sair do terminal.

**Escopo:**
- Comando `/mb-dashboard` produz painel multi-painel ASCII:
  ```
  ┌─ MB AI SDK · Squad <nome> · Sem 19/2026 ─────────────────────┐
  │                                                              │
  │  Specs ativas:  3        Concluídas trim:  7                 │
  │  Hotfixes:      1        Spikes:           2                 │
  │                                                              │
  │  ┌─ Ciclos completados (últ 12 sem) ─┐                       │
  │  │     ▁▂▃▃▄▅▆▆▇▇██                  │  trend: ↗            │
  │  └────────────────────────────────────┘                      │
  │                                                              │
  │  Hooks bloqueantes (sem):  3 ↘                               │
  │  Aprovações registradas:  47                                 │
  │  Exceções abertas:         0                                 │
  │                                                              │
  │  Maturidade:   ████████░░░░  68%                             │
  │  Achievements: 7/12                                          │
  │                                                              │
  │  Custo IA semana:  R$ 142,30  (budget: R$ 800/mês  17.7%)    │
  │                                                              │
  │  Próxima ação sugerida:  /mb-spec-verify onboarding-v2       │
  └──────────────────────────────────────────────────────────────┘
  ```
- Dados extraídos de `.mb/audit/*`, `docs/specs/_active`, `_archive`, `.mb/achievements.json`, `.mb/audit/cost.log`.
- Sparklines via `gnuplot -p` minimal ou aproximação ASCII.

**Esforço:** 4 dias.

### B.5 — `/mb-search` busca semântica em specs (v1.5)

**Motivação:** após dezenas de specs arquivadas, encontrar "como tratamos rate-limit antes" requer ferramenta.

**Escopo:**
- Indexação local: walk em `docs/specs/_archive`, embeddings via modelo MB-aprovado, sqlite-vec ou similar.
- `/mb-search "<query>"` retorna top-N specs com excerpts relevantes.
- Re-rank com LLM para qualidade.
- Versão corporativa (v2.0) indexa cross-squad.

**Esforço:** 6 dias squad-local.

### B.6 — Drift detection (v2.0)

**Motivação:** com muitos squads, alguns vão divergir da constitution sem que ninguém perceba. Detecção automática previne fragmentação.

**Escopo:**
- Worker periódico (Lambda/cron) varre repos MB com `.mb/`.
- Detecta:
  - Hooks bloqueantes desabilitados sem exceção formal.
  - Constituição local divergindo da corporativa.
  - Ciclos SDD pulando fases.
- Reporta para Chapter AI (não pune squad — orienta conversa).

**Esforço:** 10 dias.

---

## 6. Frente C — Integrações

### C.1 — Slack bot básico (v1.0)

**Motivação:** muito do trabalho do dev acontece no Slack. SDK precisa estar onde o time está.

**Escopo:**
- Bot `@mb-ai-sdk` no workspace MB.
- Comandos:
  - `/mb-status @squad` — status do squad em mensagem rica.
  - `/mb-help` — botão para abrir docs.
  - Notificações automáticas:
    - Novo ciclo SDD aberto em squad-relevante.
    - Hook bloqueante de SEGURANÇA disparou (canal `#mb-ai-security`).
    - Achievement destravado.
    - Exceção aberta aguardando review do Chapter.
    - Release do SDK.

**Esforço:** 8 dias (bot infra + comandos iniciais).

### C.2 — GitHub Actions checks (v1.0)

**Motivação:** hooks locais podem ser desabilitados. Mesmas verificações em CI garantem chão.

**Escopo:**
- Workflow `mb-ai-checks.yml` distribuído pelo SDK.
- Roda em todo PR:
  - Secret scan (mesmo regex dos hooks locais).
  - PII scan.
  - Spec coverage check (se PR referencia spec, valida que `verification.md` existe e PASSes).
  - Validation de mensagens de commit (formato `[spec:...]`).
- Falhas viram comentários no PR com orientação.
- Squads instalam adicionando `uses: mercadobitcoin/mb-ai-sdk/.github/workflows/mb-ai-checks.yml@v1.0`.

**Esforço:** 5 dias.

### C.3 — Jira/Linear → spec (v1.5)

**Motivação:** muitos squads geram features a partir de tickets. Pular passo manual reduz fricção.

**Escopo:**
- `/mb-spec-from-ticket <ticket-url-or-id>` — lê ticket via API, extrai descrição/critérios, gera scaffold de `discuss.md` + `requirements.md` rascunho.
- Suporta Jira (MB usa) e Linear.
- Mantém link bidirecional: comentário no ticket apontando spec; spec referencia ticket.
- Fechamento automático do ticket quando SHIP completar (configurável).

**Esforço:** 6 dias.

### C.4 — PagerDuty → runbook (v1.5)

**Motivação:** incidentes geram aprendizado precioso. Capturar enquanto fresco previne perda.

**Escopo:**
- Webhook PagerDuty → API interna → cria task no squad relevante.
- Após resolução do incidente, sugere automaticamente `/mb-runbook-from-incident` no canal Slack.
- Pré-popula com timeline do PagerDuty.

**Esforço:** 4 dias.

### C.5 — Datadog/Grafana → observabilidade review (v2.0)

**Motivação:** validar `OBSERVABILITY.md` contra realidade. Métricas declaradas existem? Alertas funcionam?

**Escopo:**
- Plugin auxiliar lê `OBSERVABILITY.md`, consulta API Datadog/Grafana.
- Reporta:
  - Métricas declaradas que não existem.
  - Alertas declarados sem runbook na ferramenta.
  - SLOs declarados sem SLI calculável.
- Findings entram em `OBSERVABILITY-REVIEW.md`.

**Esforço:** 8 dias (depende da stack que o squad usa).

### C.6 — IDE extension companion (v3.0)

**Motivação:** muitos devs vivem no editor, não no terminal. Companion mostra status, sugere comandos sem mudar contexto.

**Escopo:**
- Extension VS Code / JetBrains / Cursor.
- Sidebar mostra: spec ativa, fase, próxima ação sugerida, achievements.
- Quick actions: `/mb-spec`, `/mb-status`, abrir spec ativa.
- Inline annotations: arquivo modificado sem referência a spec ativa fica destacado.

**Esforço:** 20 dias (multi-IDE; possivelmente terceirizar parte).

---

## 7. Frente D — Comunidade e Gamificação

### D.1 — Programa formal de AI Champion certification (v1.0)

**Motivação:** champions são o multiplicador. Programa formal eleva nível, padroniza conhecimento, dá orgulho.

**Escopo:**
- **Trilha de certificação:**
  - Módulo 1 (2h): fundamentos do SDK, ciclo SDD, audit trail.
  - Módulo 2 (2h): hooks, MCPs, segurança.
  - Módulo 3 (2h): bootstrap, manutenção de contexto, skills custom.
  - Módulo 4 (2h): facilitar retros, propor learnings, integração com outros plugins.
- **Avaliação:** projeto prático (bootstrap acompanhado de um squad real + 1 ciclo SDD completo).
- **Certificado:** badge digital + reconhecimento em LinkedIn (opcional) + visibilidade interna.
- **Renovação:** anual via projeto novo (evita estagnação).

**Esforço:** 15 dias (criação do material) + 4h/mês contínuo (manutenção).

### D.2 — Comunidade mensal de Champions (v0.5)

**Motivação:** Champions isolados perdem força. Comunidade dissemina e captura.

**Escopo:**
- Encontro mensal 1h (presencial híbrido).
- Pauta padrão:
  - 10min: changelog do SDK + roadmap atualizado.
  - 20min: 1 squad apresenta um learning recente.
  - 15min: discussão de propostas de mudança ao core.
  - 15min: networking + perguntas livres.
- Ata gerada por agente, distribuída no canal `#mb-ai-sdk`.
- Próximos encontros agendados em série recorrente no calendário.

**Esforço:** ongoing, 4h/mês do Chapter AI.

### D.3 — Newsletter automática (v1.0)

**Motivação:** comunicação assíncrona alcança quem não vai aos encontros. Newsletter consolida + celebra.

**Escopo:**
- Geração automática mensal a partir de:
  - `mb-retro-quarterly` (consolidado).
  - Achievements destravados.
  - Releases do SDK.
  - Métricas agregadas anônimas (squads ativos, ciclos, etc).
  - 1 destaque editorial (escolhido pelo Chapter AI).
- Distribuição: email interno + Slack + arquivo em `docs/newsletters/`.

**Esforço:** 4 dias setup + 4h/mês.

### D.4 — Leaderboard saudável (v1.0)

**Motivação:** competição sutil entre squads engaja. Mas evitar tóxico.

**Escopo:**
- `/mb-leaderboard` mostra (sem nomes pessoais, só squad):
  - Top squads em ciclos completados.
  - Top squads em learnings promovidos.
  - Top squads em runbooks documentados.
  - Squad com melhor "0-incident streak".
- **Anti-pattern evitado:** nada que premie velocidade pura ou commits totais (incentivos perversos).

**Esforço:** 3 dias.

### D.5 — Workshop quinzenal "MB AI Lab" (v1.5)

**Motivação:** espaço dedicado para experimentação com IA além do dia a dia.

**Escopo:**
- 2h quinzenal opcional.
- Pauta:
  - Tema rotativo (prompt engineering, eval design, novas ferramentas, papers).
  - Hands-on em sandbox.
  - Compartilhamento de descobertas.
- Aberto a todos os devs MB, não só Champions.

**Esforço:** 4h quinzenal do Chapter AI + convidados.

### D.6 — Hackathon interno anual (v2.0)

**Motivação:** evento marco que cataliza inovação e visibilidade do programa.

**Escopo:**
- 24h hackathon "MB AI Hack".
- Times constroem features usando o SDK.
- Categorias:
  - Melhor uso de SDD.
  - Melhor skill custom.
  - Melhor uso de mb-evals.
  - Melhor experiência de retro.
- Premiação simbólica + apresentação para liderança.

**Esforço:** evento, ~30 dias de preparo do Chapter AI + parceiros.

### D.7 — Open-source seletivo (v3.0)

**Motivação:** componentes não-confidenciais (ciclo SDD, padrões EARS, hooks bash genéricos) podem virar referência de mercado, atraindo talento.

**Escopo:**
- Identificar componentes seguros para open-source.
- Repo público `mercadobitcoin/sdd-toolkit` ou similar.
- Branding: "Inspirado pelo MB AI SDK".
- Política clara do que fica privado (constitution, allowlist, hooks específicos cripto).

**Esforço:** 15 dias (curadoria + jurídico + setup).

---

## 8. Frente E — Robustez Técnica

### E.1 — `/mb-doctor` (v0.2)

**Motivação:** quando algo dá errado, dev precisa de diagnóstico rápido. Inspirado em `brew doctor`.

**Escopo:**
- Verifica:
  - Versão do Claude Code instalada vs requerida pelo SDK.
  - Marketplace MB resolvido corretamente.
  - Plugins MB ativados conforme `enabledPlugins`.
  - Hooks executáveis e sintaxe shell válida.
  - Permissões de escrita em `.mb/`.
  - `.mb/CLAUDE.md` presente.
  - Conformidade da constitution local.
  - Disponibilidade de MCPs aprovados.
  - Conectividade com GitHub Enterprise para updates.
- Saída colorida, com `✓`/`⚠`/`✗`, sugestão de fix em cada problema.

**Esforço:** 4 dias.

### E.2 — Snapshot/rollback de `.mb/` (v0.5)

**Motivação:** operações destrutivas em `.mb/` (re-bootstrap, migração major) podem perder contexto. Snapshot reversível mitiga.

**Escopo:**
- `/mb-snapshot create [tag]` — tar.gz de `.mb/` em `.mb/_snapshots/<timestamp>.tar.gz`.
- `/mb-snapshot list` — lista snapshots.
- `/mb-snapshot restore <timestamp>` — reverte (com confirmação).
- Snapshot automático antes de `mb-bootstrap-rescan`, migração major do SDK.

**Esforço:** 2 dias.

### E.3 — Smoke tests contra cada release do Claude Code (v1.0)

**Motivação:** Claude Code evolui rápido. Mudança em hooks/skills/comandos pode quebrar SDK silenciosamente.

**Escopo:**
- Suíte de smoke tests em `tests/smoke/`:
  - Carregar marketplace + plugins.
  - Disparar cada hook com input simulado.
  - Invocar cada comando com argumentos válidos.
  - Verificar exit codes esperados.
- CI roda contra: versão pinada, latest stable, latest beta.
- Falhas viram issues no repo.

**Esforço:** 6 dias setup + manutenção contínua.

### E.4 — Compatibility matrix documentada (v1.0)

**Motivação:** "que versão do SDK funciona com que versão do Claude Code?"

**Escopo:**
- `docs/compatibility-matrix.md` mantida.
- Atualizada a cada release.
- Smoke tests da E.3 alimentam.

**Esforço:** 1 dia setup + ongoing.

### E.5 — Auto-update mechanism (v1.0)

**Motivação:** squads ficam em versões antigas porque atualizar é manual. Auto-update opt-in resolve.

**Escopo:**
- Hook `SessionStart` (sutil, não bloqueante) detecta versão nova.
- Mostra mensagem: "Nova versão do SDK disponível: v0.2 → v0.3. Rode `/mb-update` para atualizar."
- `/mb-update` lê changelog, mostra breaking changes, pergunta confirmação, aplica.
- Squads em modo "stable" só atualizam patches; modo "edge" recebe minors automáticos.

**Esforço:** 5 dias.

### E.6 — Telemetria estruturada anônima (v1.5)

**Motivação:** Chapter AI precisa de dados para decidir. Hoje só tem Slack e impressões.

**Escopo:**
- Opt-in explícito por squad em `.mb/config.yaml`: `telemetry: { enabled: true }`.
- Eventos coletados (hash, sem PII):
  - Comando invocado (`mb-spec-design`, etc).
  - Hook fire bloqueante (sem conteúdo).
  - Achievement destravado.
  - Erro em script.
- Destino: endpoint interno MB; retenção 90d; agregação para dashboards.
- **Nunca** captura: conteúdo de prompt, código, nomes de arquivos, segredos.

**Esforço:** 10 dias (setup + endpoint + dashboard básico).

### E.7 — SIEM integration (v2.0)

**Motivação:** audit logs hoje vivem em `.mb/audit/*` no repo. Para incidentes, time de SecOps precisa correlacionar com outros sinais.

**Escopo:**
- Stream de `hook-fires.log`, `security-events.log`, `exceptions.log` para SIEM corporativo.
- Formato: structured logs (JSON) compatíveis com Splunk/ELK/Datadog.
- Alertas configurados no SIEM (não no SDK) para padrões anômalos.

**Esforço:** 8 dias (depende do SIEM escolhido pelo MB).

### E.8 — Testing framework para hooks/skills (v2.0)

**Motivação:** hoje só smoke tests. Para confiança em mudanças, precisa de unit tests.

**Escopo:**
- `tests/unit/hooks/<hook-name>.bats` — Bash Automated Testing System.
- `tests/unit/skills/<skill-name>/` — testa que skill produz artefato esperado dado input.
- CI roda em cada PR ao SDK.

**Esforço:** 10 dias setup + ongoing.

### E.9 — Plugin de release engineering (v2.0)

**Motivação:** lançar SDK manualmente é frágil. Tooling apropriado garante consistência.

**Escopo:**
- `/mb-sdk-release <version>` (uso interno do Chapter AI).
- Valida changelog, smoke tests passando, compatibility matrix atualizada.
- Cria tag, atualiza marketplace, anuncia em Slack/email.

**Esforço:** 4 dias.

---

## 9. Backlog de evoluções menores

Lista de ideias menores com valor unitário não suficiente para virar item top-level, mas valiosas em conjunto:

| # | Item | Frente | Versão alvo |
|---|------|--------|-------------|
| 1 | `--format json` em todos os comandos para scripting | E | v1.0 |
| 2 | Pluralização inteligente em mensagens (1 spec / 2 specs) | A | v0.5 |
| 3 | Suporte a internacionalização (en para audiência externa) | A | v2.0 |
| 4 | `/mb-explain <hook>` mostra por que um hook bloqueou | A | v0.5 |
| 5 | `/mb-history` linha do tempo de eventos do squad | B | v1.5 |
| 6 | `/mb-onboard <dev>` gera plano de onboarding personalizado | D | v1.5 |
| 7 | Suporte a hooks escritos em Python ou TypeScript | E | v2.0 |
| 8 | Pre-built CI templates para 5 stacks comuns no MB | C | v1.0 |
| 9 | `/mb-changelog` mostra mudanças do SDK com filtro | A | v0.5 |
| 10 | `/mb-feedback` formulário rápido para Chapter AI | D | v0.5 |
| 11 | Suporte a "modo offline" (sem GitHub) para emergências | E | v1.5 |
| 12 | `/mb-export <feature>` empacota spec completa para handover | A | v1.0 |
| 13 | Templates de spec por tipo (API, UI, batch job, ML feature) | A | v1.5 |
| 14 | `mb-ai-bootstrap` como CLI standalone (sem Claude Code) | E | v3.0 |
| 15 | Suporte a múltiplas constituições (squad pode estender corp) | A | v2.0 |
| 16 | `/mb-explain-this <arquivo>` invoca subagente especialista | A | v1.5 |
| 17 | Hot-reload de hooks sem reiniciar sessão | E | v2.0 |
| 18 | Theming por horário do dia (modo noite mais sutil) | A | v1.5 |
| 19 | `/mb-dry-run <comando>` mostra o que aconteceria | A | v1.0 |
| 20 | Métricas de "saúde" do `.mb/CLAUDE.md` (idade, completude) | E | v1.5 |

---

## 10. Dependências cruzadas

Alguns itens dependem de outros. Diagrama de dependências:

```
A.0 (banner) ──┐
               ├──> A.1 (themes)
               ├──> A.2 (achievements) ──> D.4 (leaderboard)
               └──> A.3 (spinners)

E.1 (doctor) ─────> E.5 (auto-update)
E.3 (smoke) ──────> E.4 (compat matrix)

B.1 (cost) ───────> B.4 (dashboard) ──> D.3 (newsletter)
B.3 (graph) ──────> B.5 (search)
                    B.2 (evals) ──> piloto AI feature

C.1 (slack) ──────> D.3 (newsletter)
C.2 (gha) ────────> E.6 (telemetria)

D.1 (cert) ───────> D.5 (workshop) ──> D.6 (hackathon)
D.2 (comunidade) ─> ongoing, sem deps
```

**Caminho crítico para v1.0:** A.1 → A.2 → D.1 → C.1 → C.2 → B.1 → B.4 → E.1.

**Caminho crítico para v2.0:** B.2 (evals) é o item de maior valor estratégico — destrava capacidade do MB construir features de IA com qualidade auditável.

---

## 11. Estimativas e capacity planning

### 11.1 Esforço total por frente

| Frente | Esforço total estimado | Capacity Chapter AI |
|--------|------------------------|---------------------|
| A — Encantamento | ~22 dias | 1 dev × 5 sem |
| B — Inteligência | ~50 dias | 1 dev × 10 sem |
| C — Integrações | ~51 dias | 1 dev × 11 sem |
| D — Comunidade | ~22 dias setup + ongoing | 0.3 FTE contínuo |
| E — Robustez | ~50 dias | 1 dev × 10 sem |
| **TOTAL** | **~195 dias** | ~9 meses calendário com 1 FTE; ~5 meses com 2 FTEs |

### 11.2 Cenários de capacity

| Cenário | Chapter AI FTE | Tempo até v2.0 | Risco |
|---------|:--------------:|:--------------:|-------|
| Mínimo | 1 FTE dedicado | ~9 meses | Alto — qualquer interrupção atrasa tudo |
| Recomendado | 2 FTEs (1 técnico + 1 comunidade) | ~5 meses | Médio |
| Ambicioso | 3 FTEs (técnico + comunidade + integrações) | ~3.5 meses | Baixo, custo maior |

### 11.3 Trabalho por onda

| Onda | Versão | Itens principais | Capacity necessária |
|------|--------|------------------|---------------------|
| 1 | v0.2 | A.1, A.2, A.3, A.4, E.1, E.2 | 12 dias |
| 2 | v0.5 | A.5, D.2, alguns backlog | 10 dias + ongoing |
| 3 | v1.0 | B.1, B.4, C.1, C.2, D.1, D.3, D.4, E.3-E.5 | 50 dias |
| 4 | v1.5 | B.2, B.3, B.5, C.3, C.4, D.5, E.6, backlog | 50 dias |
| 5 | v2.0 | B.6, C.5, D.6, E.7-E.9, drift detection | 60 dias |
| 6 | v3.0 | C.6, D.7, polish, refinamento | 30 dias |

---

## 12. Critérios de promoção entre ondas

Não promovemos para próxima onda só por tempo decorrido. Cada onda tem **critérios de saída** mensuráveis:

### Saída da Onda 1 (v0.2)
- Squad piloto reporta NPS ≥40 em pesquisa.
- Zero incidentes envolvendo SDK reportados.
- 1+ achievement destravado por squad piloto.
- `/mb-doctor` rodando em todos os squads sem erros não-tratados.

### Saída da Onda 2 (v0.5)
- 3+ squads ativos.
- Comunidade mensal com >70% presença média.
- 1+ tutorial completado por squad.
- Throughput de retros aumentou.

### Saída da Onda 3 (v1.0)
- 5+ squads ativos.
- 3+ AI Champions certificados.
- Slack bot adotado em 100% dos squads ativos.
- GHA checks rodando em PRs de 80%+ dos squads ativos.
- Custo IA visível e tendência sob controle.
- Squad piloto destravou modo `/mb-fast`.

### Saída da Onda 4 (v1.5)
- 1+ feature MB usando IA em runtime construída via `mb-evals`.
- Knowledge graph cobre 100% de squads ativos.
- Newsletter mensal saindo regularmente.
- 10+ Champions certificados.

### Saída da Onda 5 (v2.0)
- Hackathon interno realizado.
- SIEM integrado e alertas configurados.
- Plataforma considerada "estável" pelo time de Plataforma corporativo.
- Avaliação externa (consultoria) confirma maturidade ≥4/5.

### Saída para v3.0
- Decisão executiva sobre open-source seletivo tomada.
- Programa de Champions auto-suficiente (Chapter AI <30% do tempo).
- Métricas demonstram ROI positivo claro.

---

## 13. Riscos e mitigações da evolução

| # | Risco | Probabilidade | Impacto | Mitigação |
|---|-------|:-------------:|:-------:|-----------|
| 1 | Roadmap fica preso na v0.5 por baixa adoção | Média | Crítico | Ondas curtas; investir em D antes de B/C |
| 2 | Chapter AI satura, vira gargalo | Alta | Alto | Programa de Champions cedo; modelo de PR distribuído |
| 3 | Integração C.5 (Datadog) não evolui por mudança de stack do MB | Média | Médio | Manter B.4 (dashboard interno) como fallback |
| 4 | Open-source (D.7) gera trabalho de manutenção sem retorno | Média | Médio | Decisão tardia, só após v2.0; jurídico envolvido |
| 5 | Telemetria (E.6) gera resistência por privacidade | Média | Alto | Opt-in real, transparência total, comitê externo de revisão |
| 6 | mb-evals (B.2) é over-engineered para necessidade real | Média | Médio | Validar com squad piloto que de fato esteja construindo AI feature |
| 7 | Achievements (A.2) gera competição tóxica | Baixa | Médio | Anti-patterns evitados desde design (sem rank pessoal) |
| 8 | Compatibilidade quebra com release nova do Claude Code | Alta | Alto | Smoke tests automáticos, compat matrix, comunicação rápida |
| 9 | SDK fica pesado, devs reclamam de overhead | Média | Alto | Themes leves, opt-in granular, performance como NFR |
| 10 | Custo de manutenção excede budget aprovado | Média | Crítico | Reportes trimestrais à liderança; ajuste de escopo via roadmap |

---

## 14. Métricas de evolução

Métricas que indicam saúde da evolução em si (não só do SDK):

| Métrica | O que mede | Meta |
|---------|-----------|------|
| **Velocity de releases** | Releases por mês | ≥1 minor |
| **Time to fix** | Issue → release com fix | <14 dias mediana |
| **Adoption rate** | % squads na versão atual | >70% |
| **Champion retention** | % Champions ainda ativos após 6m | >80% |
| **Proposal acceptance** | % PRs `proposal` aceitos | >40% (alto demais = sem critério; baixo demais = desencoraja) |
| **Incident-free quarter** | Trimestres sem incidente envolvendo SDK | 100% almejado |
| **NPS dos squads** | Survey semestral | ≥40 |
| **External recognition** | Mídia/comunidade externa reconhecendo | meta v3.0: 1+ menção |

---

## 15. O que pedimos da liderança nesta fase

1. **Aprovar capacity plan recomendado** (2 FTEs no Chapter AI) ou negociar trade-offs com roadmap.
2. **Endossar princípio de evolução dirigida por uso** — não criamos features sem demanda.
3. **Garantir budget IA** para crescimento previsto (cost transparency vai ajudar a justificar).
4. **Patrocinar programa de Champion certification** com reconhecimento institucional (badge, menção em rituais).
5. **Endossar publicação seletiva (D.7) na hora certa** — open-source de componentes não-confidenciais é diferencial de marca empregadora.

---

**Fim do roadmap evolutivo. Próximos passos imediatos:**
1. Validar piloto v0.1 (semanas 1-3 a partir do go-live).
2. Iniciar Onda 1 (v0.2) imediatamente após retro do piloto.
3. Revisão trimestral deste roadmap pela comunidade de Champions + Chapter AI.
