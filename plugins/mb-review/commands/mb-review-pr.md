---
description: Code review estruturado de PR ou branch contra spec ativa e constitution MB
argument-hint: <pr-url-or-branch>
---

# /mb-review-pr

Execute code review estruturado:

1. Identifique escopo (PR via `gh pr view`, branch via `git diff main...HEAD`).
2. Identifique spec ativa relacionada (`docs/specs/_active/<feature>/`).
3. Invoque a skill `mb-code-reviewer` para análise.
4. Para cada arquivo modificado, avalie correctness, design, clareza, padrões MB, testes.
5. Classifique findings (BLOCK/HIGH/MEDIUM/LOW/INFO).
6. Gere/atualize `docs/specs/_active/<feature>/REVIEW.md`.
7. Sugira ao usuário: invocar `/mb-review-security` se houver suspeita de issue de segurança, e `/mb-review-spec` para coverage.
8. Se findings BLOCK ou HIGH: oriente correção antes de SHIP.

Para findings que dá pra corrigir automaticamente, sugira `/mb-review-fix`.
