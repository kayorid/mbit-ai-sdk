---
description: Fase PLAN parte 2 — quebra design em tasks atômicas com dependências e paralelização
argument-hint: <slug-da-feature>
---

# /mb-spec-plan

Conduza a segunda parte da fase PLAN:

1. Verifique DESIGN aprovado.
2. Leia `design.md` e `requirements.md`.
3. Quebre o design em tasks atômicas (≤ 1 dia cada). Use template `assets/templates/tasks.md.tpl`.
4. Para cada task:
   - Título acionável (imperativo).
   - Critério de pronto observável.
   - Arquivos prováveis de tocar.
   - Dependências (`depends-on: T-3`).
   - Marcar `[P]` se paralelizável (sem dependência e arquivos disjuntos).
5. Numere tasks (`T-1`, `T-2`, ...).
6. Adicione seção "Plano de execução" com ordem sugerida e oportunidades de paralelização.
7. Peça `/mb-approve PLAN`.

Critério de pronto: cada task é claramente "fazível" e tem critério de pronto observável.
