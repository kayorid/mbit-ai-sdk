---
description: Aplica correções automáticas dos findings BLOCK/HIGH de um REVIEW.md, com commit atômico por finding
---

# /mb-review-fix

Aplique correções de findings de severidade BLOCK ou HIGH:

1. Leia `docs/specs/_active/<feature>/REVIEW.md`.
2. Filtre findings BLOCK + HIGH com sugestão acionável.
3. Para cada finding (sequencial, não em paralelo):
   - Apresente ao usuário o finding e a correção proposta.
   - Aguarde confirmação OU faça automaticamente se a correção é trivial e o usuário pediu modo automático.
   - Aplique a correção.
   - Crie commit atômico:
     ```
     git commit -m "[review:<feature>] fix <severidade>: <título-curto>"
     ```
   - Marque o finding como `RESOLVED` no `REVIEW.md` com referência ao commit.
4. Findings que requerem decisão arquitetural ou refactor maior: NÃO aplique automaticamente — abra task em `tasks.md` ou nova spec.
5. Ao final, sugira rodar `/mb-review-pr` novamente para validar.

**Não toque em findings MEDIUM/LOW automaticamente** — fica para a sprint, decisão do squad.
