# Governança e RACI

## Papéis

| Papel | Quem | Compromisso de tempo |
|-------|------|----------------------|
| **Chapter AI** | Time corporativo dedicado | Mantém o SDK; ~20% dos seus FTEs alocados |
| **Tech Lead** | TL de cada squad | Operação no squad; ~5% do tempo do TL |
| **AI Champion** | 1 designado por squad (não precisa ser TL) | Manter contexto vivo + comunidade; ~10% |
| **Dev** | Demais membros do squad | Consumidor; usa no dia a dia |

## RACI — Atividades principais

| Atividade | Chapter AI | Tech Lead | AI Champion | Dev |
|-----------|:----------:|:---------:|:-----------:|:---:|
| Manter `mb-ai-core` (constitution, hooks, allowlist) | R/A | C | C | I |
| Avaliar e aprovar inclusão de MCP novo | R/A | I | C | I |
| Treinar AI Champions | R/A | I | I | — |
| Bootstrap inicial do squad | C | R | A | I |
| Manter `.mb/CLAUDE.md` do squad | I | A | R | C |
| Manter `.mb/glossary.md` | I | A | R | C |
| Aprovar fases SDD (`/mb-approve`) | I | R/A | C | C |
| Abrir exceção bloqueante (`/mb-exception`) | A | R | C | I |
| Conduzir retro de feature | I | C | R | A |
| Promover learning ao core (`/mb-retro-promote`) | A | C | R | I |
| Criar skill custom do squad | I | C | R | A |
| Auditar uso (relatório trimestral) | R/A | C | C | I |
| Releases do SDK | R/A | I | C | I |

**Legenda:** R = Responsible (faz), A = Accountable (responde), C = Consulted, I = Informed.

## Processo de proposta de mudança ao SDK

### 1. Origem
- Learning de retrospectiva do squad.
- Demanda repetida de múltiplos squads.
- Proposta direta do Chapter AI.

### 2. Proposta
- PR ao `mb-ai-sdk` com label `proposal`.
- Body deve incluir: justificativa, retros de origem, alternativas consideradas, squads beneficiados, plano de migração se breaking.

### 3. Review
- Chapter AI + 2 AI Champions de squads diferentes.
- Período de comentários: 5 dias úteis.

### 4. Decisão
- Maioria simples aprova.
- Chapter AI tem **veto** por motivo de segurança/compliance (com justificativa pública).

### 5. Release
- **Patch** (`0.X.Y`): bugfix, doc, melhoria não-comportamental.
- **Minor** (`0.X.0`): feature nova, hook novo, comando novo.
- **Major** (`X.0.0`): breaking change. Janela de migração de 30 dias mínimo, comunicação prévia obrigatória.

### 6. Comunicação
- Changelog atualizado.
- Anúncio em `#mb-ai-sdk` Slack.
- Comunidade mensal de Champions discute changelog.

## Processo de exceção a regra bloqueante

### Quem pode abrir
- Tech Lead (sempre).
- Dev com endosso explícito do TL.

### Quem aprova
- **Regras de PROCESSO/QUALIDADE:** Tech Lead aprova. Registrado em audit-log.
- **Regras de SEGURANÇA/COMPLIANCE:** Chapter AI aprova. Registrado em audit-log + GitHub issue.
- **Regras inegociáveis** (chave privada, segredo de produção): **não aceitam exceção**. Oriente abrir incidente.

### Prazos
- Exceção tem prazo de validade (max 90 dias).
- Renovação requer nova justificativa.
- Plano de mitigação obrigatório.

### Auditoria
- Trimestralmente, Chapter AI audita exceções vigentes e expiradas.
- Relatório vai à liderança de Engenharia + Compliance.

## Processo de incidente envolvendo o SDK

Caso o SDK cause:
- Bloqueio indevido de trabalho legítimo.
- Vazamento de informação por hook mal configurado.
- Falsa sensação de segurança (hook que deveria bloquear não bloqueou).

### Resposta
1. Tech Lead reporta no `#mb-ai-sdk` Slack.
2. Chapter AI investiga (P1: <2h; P2: <8h; P3: <24h).
3. Mitigação imediata (rollback de versão, desabilitar hook específico).
4. Post-mortem público no repo (`docs/incidents/`).
5. Mudanças preventivas viram PR ao SDK.

## Métricas de saúde do SDK

Reportadas trimestralmente pelo Chapter AI à liderança:

| Métrica | Cálculo | Meta |
|---------|---------|------|
| Adoção | Squads com `.mb/` no repo | crescente |
| Ciclos completados | Pastas em `_archive/` | crescente |
| Hook fires bloqueantes/sem | `.mb/audit/hook-fires.log` | decrescente após semana 4 do squad |
| Exceções abertas | issues `mb-exception` | <2/squad/mês |
| Tempo de bootstrap | até `.mb/CLAUDE.md` gerado | <1h |
| PRs ao core promovidos | conta no repo | crescente |
| NPS dos squads (semestral) | survey | >40 |

Detalhes em [`docs/plans/2026-05-10-mb-ai-sdk-design.md`](../plans/2026-05-10-mb-ai-sdk-design.md) §13.
