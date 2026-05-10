# mb-review

Processo padronizado de revisão para o MB AI SDK. Code review, security review e spec coverage como agentes formais — não como atividade ad-hoc.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-review-pr <pr-or-branch>` | Code review estruturado contra spec e constitution |
| `/mb-review-security` | Security review (OWASP top 10 + cripto + segredos) |
| `/mb-review-spec` | Coverage spec ↔ implementação (todo critério EARS coberto?) |
| `/mb-review-fix` | Aplica correções de findings BLOCK/HIGH de um REVIEW.md |

## Skills (subagentes especializados)

- `mb-code-reviewer` — revisor de código (qualidade, design, padrões).
- `mb-security-reviewer` — revisor de segurança (OWASP + cripto + dados).
- `mb-spec-reviewer` — verifica coverage spec ↔ implementação.

## Saídas

`docs/specs/_active/<feature>/REVIEW.md` com findings classificados por severidade:

| Severidade | Significado | Ação requerida |
|-----------|-------------|----------------|
| BLOCK | Não pode mergear | Resolver antes de SHIP |
| HIGH | Risco real | Resolver ou justificar |
| MEDIUM | Qualidade ou manutenibilidade | Resolver na sprint |
| LOW | Nice-to-have | Backlog |
| INFO | Observação | Documentar |

## Pré-requisitos

- `mb-ai-core` ativo.
- Recomendado: `mb-sdd` (review se beneficia de spec referenciada) e `mb-security` (delegação para revisor de segurança).
