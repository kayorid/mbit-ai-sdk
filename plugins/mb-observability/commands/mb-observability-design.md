---
description: Design de observabilidade para a feature corrente — logs, métricas, traces, alertas, SLOs
argument-hint: [feature-slug]
---

# /mb-observability-design

Invoque a skill `mb-observability-designer`:

1. Identifique a feature (argumento ou spec ativa mais recente).
2. Conduza o design seguindo as 4 etapas da skill.
3. Gere `docs/specs/_active/<feature>/OBSERVABILITY.md`.
4. Atualize `design.md` com referência.
5. Crie tasks em `tasks.md` para instrumentação não trivial.
6. Sugira commits:
   ```
   git commit -m "[spec:<feature>] observability design"
   ```
