---
description: Fase DISCUSS isolada — explora ambiguidades e gera ambiguity score antes de qualquer requirement
argument-hint: <slug-da-feature>
---

# /mb-spec-discuss

Conduza apenas a fase DISCUSS:

1. Crie ou identifique `docs/specs/_active/<YYYY-MM-DD>-<slug>/`.
2. Peça ao usuário 1-2 frases sobre o problema/feature.
3. Conduza ambiguity scoring: identifique 5-10 dimensões da ideia e classifique cada uma como CLEAR / AMBIGUOUS / UNKNOWN.
4. Para cada AMBIGUOUS/UNKNOWN, faça perguntas dirigidas (uma por vez).
5. Resolva todas as ambiguidades ou explicitamente registre como "premissa assumida".
6. Gere `discuss.md` com:
   - Problema/feature em 2 frases.
   - Tabela de dimensões e scores.
   - Ambiguidades resolvidas.
   - Premissas explícitas.
   - Escopo (in/out).
7. Peça `/mb-approve DISCUSS`.

Não inicie SPEC sem aprovação.
