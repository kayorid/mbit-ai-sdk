---
name: mb-sdd
description: Use sempre que o usuário estiver planejando uma fase do projeto MB, iniciando uma nova feature, no meio de uma implementação não trivial, ou finalizando uma entrega. Acione também ao mencionar "spec", "especificação", "requirements", "kickoff", "planejamento", "handover", "retrospectiva", ou pedir para "documentar o que vamos fazer/fizemos". Spec-Driven Development do MB AI SDK — fluxo rígido com checkpoints obrigatórios, audit-trail via /mb-approve e integração com mb-ai-core, mb-review, mb-security, mb-observability e mb-retro. Cobre o ciclo end-to-end (discuss → spec → plan → execute → verify → review → ship → retro). Acione mesmo quando o usuário não pedir explicitamente "spec" — qualquer trabalho não trivial multi-passo se beneficia desta skill.
---

# MB Spec-Driven Development (mb-sdd)

Esta skill é a espinha dorsal do MB AI SDK. Transforma desenvolvimento assistido por IA em um processo disciplinado por especificações vivas, com checkpoints humanos obrigatórios e audit-trail compatível com requisitos regulatórios (Bacen, CVM, LGPD).

## Integração com o ecossistema MB

- **Constitution corporativa** carregada via `mb-ai-core` (skill `mb-constitution`).
- **Checkpoints registrados** via `/mb-approve <fase>` em `.mb/audit/approvals.log`.
- **Threat-model obrigatório** (via `mb-security`) para features tocando ativos críticos.
- **Observability design** (via `mb-observability`) integrado à fase PLAN.
- **Review automático** (via `mb-review`) na fase SHIP.
- **Retro estruturada** (via `mb-retro`) com promoção de learnings ao core.

A intuição central é simples: **LLMs implementam bem o que está escrito; o problema é o que não está escrito**. Spec-Driven Development resolve isso fazendo da spec o ponto de verdade que o agente consulta, atualiza e respeita ao longo de todo o ciclo.

## Quando esta skill se aplica

- Usuário diz "vamos planejar a próxima fase", "kickoff", "novo módulo/feature"
- Usuário está no meio de uma implementação não trivial e perde-se contexto
- Entrega chegando ao fim — preciso de retrospectiva, handover, registro
- Aparecem palavras como "spec", "requirements", "design doc", "ADR", "status", "histórico do projeto"
- Trabalho com 3+ passos não óbvios, ou múltiplas pessoas/agentes envolvidos
- Bug ou refatoração com escopo amplo o suficiente para merecer um documento

Para tarefas triviais (renomear variável, fix de typo, ajuste de uma linha), **não** invoque esta skill — o overhead destrói o ganho. A pergunta é: **alguém olhando isso em 3 meses precisaria entender o porquê?** Se sim, use a skill.

## As oito fases do ciclo

```
        ┌─ constitution (1x por projeto)
        │
        ├─ specify ──→ clarify ──→ plan ──→ tasks ──→ implement ──→ validate
        │                                                                │
        └────────────────────── retrospective ←───────────────────────────┘
```

Cada fase abaixo tem um propósito, uma saída e um critério de pronto. Detalhes profundos ficam em `references/phase-playbook.md` — leia quando aplicar a fase pela primeira vez ou em casos não óbvios.

### 1. Constitution (uma vez por projeto)
**Propósito**: estabelecer princípios não negociáveis que ancoram todas as decisões posteriores (idioma, segurança, qualidade, processos).
**Saída**: `<root-de-specs>/constitution.md`.
**Pronto quando**: o time concorda e o arquivo está commitado. Revisitado apenas em mudanças estruturais.

### 2. Specify (WHAT/WHY, sem stack)
**Propósito**: capturar o que precisa ser construído e por quê, em linguagem de negócio. Evite mencionar tecnologia.
**Saída**: `requirements.md` com user stories, critérios de aceitação em **EARS notation** (ver `references/ears-notation.md`), edge cases conhecidos, fora de escopo.
**Pronto quando**: alguém de produto consegue ler e dizer "sim, é isso".

### 3. Clarify (rodada explícita de perguntas)
**Propósito**: identificar e resolver ambiguidades antes de qualquer plano técnico. Esta fase é frequentemente pulada e é a maior fonte de retrabalho.
**Saída**: lista de Q&A no final de `requirements.md` (seção "Clarifications"), e atualizações em-linha onde ambiguidades existiam.
**Pronto quando**: o agente consegue listar todas as suposições explicitamente, sem "depende".

### 4. Plan (HOW — design técnico)
**Propósito**: escolher stack, estrutura, contratos, integrações. Aqui é onde tecnologia entra.
**Saída**: `design.md` com arquitetura, modelo de dados, contratos de API, dependências, riscos, alternativas consideradas.
**Pronto quando**: dá para começar a quebrar em tasks sem precisar adivinhar.

**Validation gate**: depois de gerar o plano, peça ao agente para auditar o próprio plano em busca de **over-engineering**. "O que aqui é necessário para a feature pedida vs. o que estou projetando para o futuro hipotético?" Remova o segundo grupo.

### 5. Tasks (DO — quebra executável)
**Propósito**: transformar o design em uma sequência ordenada de tarefas de tamanho razoável (≤ 1 dia cada).
**Saída**: `tasks.md` com checkboxes, dependências explícitas e marcador `[P]` para tarefas paralelizáveis (mesmo arquivo intocado, sem dependência).
**Pronto quando**: cada task é claramente "fazível" e tem critério de pronto observável.

### 6. Implement (executar com checkpoints)
**Propósito**: escrever código seguindo as tasks, atualizando STATUS conforme avança e parando em checkpoints definidos.
**Saída**: código + tasks marcadas + `status.md` atualizado.
**Pronto quando**: todas as tasks com checkbox marcado, todos os critérios de aceitação verificáveis.

### 7. Validate (verificação contra a spec)
**Propósito**: provar que o que foi construído satisfaz o que foi especificado, não apenas que "passa nos testes".
**Saída**: relatório de validação (no `status.md` ou seção própria) com cada critério EARS endereçado.
**Pronto quando**: cada item do `requirements.md` tem evidência (teste, screenshot, log, demo).

### 8. Retrospective (fechamento)
**Propósito**: capturar lições, mover spec de `_active/` para `_completed/`, atualizar índice e histórico do projeto.
**Saída**: `retrospective.md` na pasta da feature + entrada em `HISTORY.md` global.
**Pronto quando**: feature está arquivada e descobertas reutilizáveis viraram ADRs ou atualizaram a `constitution.md`.

## Estrutura canônica de pastas

A skill mantém uma raiz dedicada para specs (default: `docs/specs/`). Adapte ao layout existente do projeto — se há `docs/plans/` e `docs/adrs/`, **complemente sem duplicar** (ver `references/integration-guide.md`).

```
docs/specs/
├── INDEX.md                          # matriz: feature → fase → status
├── HISTORY.md                        # log cronológico de marcos
├── constitution.md                   # princípios do projeto (1x)
├── _active/
│   └── YYYY-MM-DD-<slug>/
│       ├── requirements.md           # fase 2-3
│       ├── design.md                 # fase 4
│       ├── tasks.md                  # fase 5-6
│       └── status.md                 # progresso/decisões/blockers
└── _completed/
    └── YYYY-MM-DD-<slug>/            # mesma estrutura + retrospective.md
```

Para criar a estrutura inicial de uma nova spec, use `scripts/init_spec.sh <slug>` (cria a pasta com data atual e copia templates).

## Templates

Todos os artefatos têm template canônico em `assets/templates/`. Quando criar um novo arquivo de spec, **leia o template primeiro** e copie a estrutura — não improvise. Templates atuais:

- `constitution.md.tpl` — princípios do projeto
- `requirements.md.tpl` — WHAT/WHY com EARS
- `design.md.tpl` — HOW técnico
- `tasks.md.tpl` — checklist com `[P]`
- `status.md.tpl` — snapshot de progresso
- `retrospective.md.tpl` — lições e arquivo
- `adr.md.tpl` — Architecture Decision Record
- `INDEX.md.tpl` — índice global

Um exemplo end-to-end preenchido vive em `assets/examples/example-feature/` — use como referência de "como deve parecer um spec real".

## Harness anti-drift (princípios operacionais)

Drift entre intenção e implementação é o falhanço mais comum em desenvolvimento assistido por IA. Estas práticas mitigam isso. Detalhe completo em `references/ai-harness-patterns.md`.

### Boundaries de três níveis
Toda spec contém uma seção de fronteiras explícitas:
- ✅ **Always**: comportamentos obrigatórios (ex: "toda mutation invalida cache de query X")
- ⚠️ **Ask first**: ações que exigem confirmação (ex: "qualquer migration destrutiva")
- 🚫 **Never**: comportamentos proibidos (ex: "nunca commitar segredos", "nunca usar `--no-verify`")

### Spec-anchored, não spec-once
A spec não é descartada após o kickoff. **A cada decisão de mudança de rumo, atualize a spec antes do código.** Se a realidade obrigou a divergir do plano, a spec é que vai mudar — não fica desincronizada do código. Isto é o oposto do anti-pattern "spec-once" (escreve a spec, esquece, código vive vida própria).

### Checkpoints humanos
Pontos onde o agente **para e pede revisão** antes de prosseguir, definidos no próprio `tasks.md`:
- Após `clarify`, antes de `plan`
- Após `plan`, antes de `tasks`
- Em qualquer task com tag `[CHECKPOINT]`
- Antes de operações destrutivas ou irreversíveis

Nunca consolide múltiplas fases em um único turno sem checkpoint — mesmo quando o usuário diz "siga até o fim", a estrutura interna ainda separa as fases para permitir auditoria.

### Modularidade contra "curse of instructions"
Se um documento passa de ~500 linhas, divida. O agente seguinte que ler vai aplicar pior quanto mais texto houver. Prefira hierarquia + ponteiros a um monolito.

## Status tracking

Cada feature tem `status.md` com:
- **Fase atual** (uma das 8 acima)
- **Última atualização** (timestamp ISO)
- **Decisões** (tabela: data, decisão, razão, link)
- **Perguntas em aberto**
- **Blockers**
- **Próximo passo concreto**

O `INDEX.md` global é uma tabela com todas as features ativas — fonte da verdade de "onde estamos no projeto". Atualize sempre que:
- Uma feature muda de fase
- Status muda (em curso/bloqueada/aguardando)
- Feature é completada (move-se para `_completed/`)

Detalhes em `references/status-tracking.md`. Para regenerar o INDEX a partir do estado em disco, use `scripts/update_index.py`.

## Validação automática

Antes de fechar uma fase, rode `scripts/validate_spec.py <path-to-spec-dir>` para verificar:
- Arquivos obrigatórios da fase existem
- Seções mínimas estão presentes
- Critérios EARS estão bem formados
- Tasks têm critério de pronto observável
- Não há TODOs/TBDs órfãos no documento

A validação é orientativa, não bloqueante — relatório legível, não exit code rígido. Use o output para decidir se prosseguir ou voltar.

## Integração com agentes/subagentes

Esta skill é especialmente útil em fluxos com subagentes paralelos:
- **Planejamento**: dispare um subagente por domínio (backend/frontend/dados) para preencher seções específicas do `design.md` em paralelo
- **Implementação**: tasks marcadas `[P]` podem ir para subagentes em paralelo (ver `superpowers:dispatching-parallel-agents`)
- **Validação**: subagentes especializados (security, perf, a11y) podem auditar contra critérios EARS

Para projetos que já usam padrões como `superpowers:writing-plans` ou `superpowers:executing-plans`, esta skill é o nível **acima** — ela cria o contexto que aqueles seguem. Não substitua: combine.

## Integração com docs existentes

Esta skill **respeita layouts de documentação existentes**. Antes de criar `docs/specs/`, faça uma varredura:
- Existe `docs/plans/`? Specs novas vivem em `docs/specs/`, mas linkam plans relevantes.
- Existe `docs/adrs/`? Continue criando ADRs lá; specs apenas referenciam.
- Existe `docs/runbooks/`? São saída pós-implementação, não substituídos pela spec — a `retrospective.md` aponta para o runbook gerado.

Roteiro completo em `references/integration-guide.md`.

## Pegadinhas comuns (checklist mental)

Antes de avançar de fase, verifique mentalmente:

- ❌ Stack/tecnologia mencionada no `requirements.md` → mover para `design.md`
- ❌ "Should support X in the future" no design → cortar (over-engineering)
- ❌ Tasks sem critério de pronto → não dá para validar, refazer
- ❌ Critério EARS começando com "be able to" → reformular como condição/resposta
- ❌ Múltiplas fases consolidadas sem checkpoint → voltar e separar
- ❌ Spec não atualizada após mudança de rumo → drift começou
- ❌ Documento passando de 500 linhas → quebrar em sub-documentos
- ❌ "Várias coisas em paralelo" sem `[P]` → marcar explicitamente

## Idioma e estilo

Adote o idioma do projeto-alvo. Se o projeto usa pt-BR (comum em projetos brasileiros), specs **devem** estar em pt-BR com acentuação ortográfica completa — sem substituir caracteres acentuados por ASCII. Termos técnicos consagrados (API, endpoint, JWT, etc.) ficam no original.

EARS notation é mais clara em inglês historicamente, mas funciona perfeitamente em pt-BR — use as keywords traduzidas: "Quando", "Enquanto", "Onde", "Se ... então". Exemplos em `references/ears-notation.md`.

## Recursos desta skill

- `references/ears-notation.md` — os cinco padrões EARS com exemplos pt-BR
- `references/phase-playbook.md` — playbook detalhado fase a fase
- `references/ai-harness-patterns.md` — anti-drift, boundaries, checkpoints
- `references/status-tracking.md` — como manter INDEX e status
- `references/integration-guide.md` — coexistir com docs/ pré-existente
- `assets/templates/` — todos os templates canônicos
- `assets/examples/example-feature/` — exemplo completo end-to-end
- `scripts/init_spec.sh` — bootstrap de nova spec
- `scripts/validate_spec.py` — verificação de completude
- `scripts/update_index.py` — regeneração do INDEX
