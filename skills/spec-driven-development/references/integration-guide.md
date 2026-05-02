# Integration Guide — coexistir com docs/ existente

Esta skill **não substitui** documentação existente. Ela adiciona uma camada (specs comportamentais e tracking de ciclo) que tipicamente está faltando, e linka com o que já existe.

## Princípio: detectar, depois decidir

Antes de criar `docs/specs/`, faça uma varredura inicial para entender o layout do projeto. Padrões comuns que você pode encontrar:

| Estrutura existente | O que significa | Como SDD se encaixa |
|---------------------|-----------------|---------------------|
| `docs/plans/AAAA-MM-DD-titulo.md` | Design docs / implementation plans macros | Specs novas em `docs/specs/`, design.md linka o plan correspondente |
| `docs/adrs/NNN-titulo.md` | Decisions registradas | Specs **referenciam** ADRs; novas decisões grandes ainda viram ADRs próprios |
| `docs/runbooks/*.md` | Guias operacionais pós-implementação | Saída da fase retrospective; spec NÃO substitui runbook |
| `docs/architecture.md` | Visão de stack/princípios | Insumo para `constitution.md` |
| `CLAUDE.md` no root | Instruções para agentes | A `constitution.md` da spec pode ecoar/referenciar; não duplicar |
| `README.md` | Visão geral | Independente |

## Roteiro de adoção

### Em projeto novo
1. Criar `docs/specs/`
2. Criar `constitution.md` a partir do template (se ainda não há `CLAUDE.md` ou similar, este é o ponto de partida)
3. Toda feature daqui em diante segue SDD do início

### Em projeto existente com docs maduros (caso WIS)
1. **Não migrar nada retroativamente.** Plans antigos ficam onde estão.
2. Criar `docs/specs/` apenas para novas features
3. `constitution.md` resume princípios que **estavam implícitos** em `CLAUDE.md` + `architecture.md` + ADRs — não duplica, condensa
4. Cada nova spec linka:
   - ADRs relacionados (em `docs/adrs/`)
   - Plans macros relevantes (se a feature deriva de um plano de fase maior)
5. Após implement+validate, **runbook gerado vai para `docs/runbooks/`** (não para a pasta da spec) — runbooks têm vida útil maior que a feature
6. ADRs criados durante a feature continuam em `docs/adrs/` (não em `_active/`)

### Em projeto que já usa Spec Kit / Kiro
1. Aproveitar a estrutura existente — não criar paralelamente
2. Esta skill complementa com práticas de tracking (INDEX, HISTORY, status.md) que esses sistemas têm em forma mais leve
3. Adaptar templates desta skill para casar com convenções do sistema preexistente

## Mapeamento WIS específico

Para o projeto WIS-LMS especificamente (ver MEMORY.md), a integração concreta seria:

```
wis-lms/
├── docs/
│   ├── plans/                          # macros, mantém — exemplo: PRD Onboarding
│   │   └── 2026-03-07-prd-*.md
│   ├── adrs/                           # decisões técnicas, mantém
│   │   └── 002-zod-shared-package.md
│   ├── runbooks/                       # operacionais, mantém
│   │   └── handover.md
│   ├── architecture.md                 # mantém
│   ├── api-reference.md                # mantém
│   └── specs/                          # ← NOVO: behavioral specs por feature
│       ├── INDEX.md
│       ├── HISTORY.md
│       ├── constitution.md             # condensa CLAUDE.md + architecture
│       └── _active/
│           └── 2026-05-XX-<feature>/
│               ├── requirements.md
│               ├── design.md           # linka adrs/, runbooks/
│               ├── tasks.md
│               └── status.md
└── CLAUDE.md                           # mantém; complementa constitution
```

### Convenções WIS que a skill respeita
- **Idioma**: pt-BR com acentuação completa (constitution.md.tpl tem isso pré-marcado)
- **Datas**: ISO `YYYY-MM-DD` em prefixos de pasta
- **Slugs**: kebab-case
- **Verificações automáticas**: ESLint plugin local + scripts de validação

### Pontos de atenção
- `docs/plans/` continua sendo o lugar de **planejamento estratégico macro** (ex: roadmap Q2-Q5, PRD do produto). Specs em `docs/specs/` são **execução tática** de uma feature concreta.
- ADRs continuam separados — não duplicar a "decisão" no design.md; design referencia o ADR
- Retrospective.md de uma feature pode dizer "lições viraram update no `docs/runbooks/X.md`" — esse fluxo é explícito e desejável

## Convenções de link

Sempre prefira links **relativos** dentro de docs/ (mais robustos a renomes do repo):

```markdown
Para a decisão de schemas compartilhados, ver [ADR 002](../../adrs/002-zod-shared-package.md).
Plano macro: [PRD Onboarding](../../plans/2026-03-07-prd-onboarding-platform.md).
```

E sempre prefira link estável (hash + slug) a profundo (linha específica), que quebra com edição.

## Quando NÃO criar pasta docs/specs/

- Projeto pequeno (≤ 1 desenvolvedor, ≤ 5 features previstas) — pasta única `docs/` plana funciona
- Mono-arquivo já cobrindo (ex: `PROJECT.md` no root) e o time prefere assim
- Política da organização (ex: tudo em Notion/Confluence externo)

Nesses casos, esta skill ainda é útil para **estrutura interna dos documentos** — copie templates, use EARS, mantenha boundaries explícitas — só não tente impor o layout de pastas.

## Quando uma "spec" não merece pasta própria

Se a tarefa é pequena (uma task, ≤ 1 dia, sem decisão arquitetural), **não force** uma pasta `_active/...`. Em vez disso:
- Use uma single `requirements.md` + `tasks.md` no nível superior, ou
- Apenas anote em `HISTORY.md` que foi feita em modo "fast track"

A skill é flexível: o objetivo é resultado, não formulário.

## Coesão com outras skills/plugins

Esta skill **conversa bem com**:
- `superpowers:writing-plans` — pode ser invocada para gerar `tasks.md` da fase 5 com mais rigor
- `superpowers:executing-plans` — pode executar a fase 6 (implement) com checkpoints
- `superpowers:dispatching-parallel-agents` — usada na fase 4 (plan) para mapear código existente, na fase 5 (tasks) para split por domínio
- `superpowers:test-driven-development` — combina com fase 6 para implementar critérios EARS via TDD
- `superpowers:verification-before-completion` — fase 7 (validate) é a aplicação direta

Esta skill **não substitui**:
- `claude-md-management:claude-md-improver` — CLAUDE.md tem propósito diferente (instruções para agentes); pode coexistir com `constitution.md`
- ADRs (existem antes e depois desta skill)
- Runbooks (saída final, não substituídos pela spec)
