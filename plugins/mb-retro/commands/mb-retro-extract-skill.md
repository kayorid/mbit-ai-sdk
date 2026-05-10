---
description: Identifica padrão repetido e propõe scaffolding de skill custom
argument-hint: [tema]
---

# /mb-retro-extract-skill

Identifique e crie skill custom do squad a partir de padrão recorrente:

1. Analise retros recentes do squad (`docs/specs/_archive/*/retro.md`) e identifique 3-5 atividades repetidas que poderiam virar skill.
2. Apresente os candidatos com evidência (quantas vezes apareceu, em quais features).
3. Usuário escolhe um para criar.
4. Para a skill escolhida:
   - Defina nome (`mb-<squad>-<skill>`).
   - Description rica para auto-trigger.
   - Identifique referências (docs, padrões, exemplos).
   - Identifique scripts auxiliares se houver automação.
5. Gere estrutura em `.mb/skills/<nome>/`:
   ```
   SKILL.md
   references/
   scripts/  (se aplicável)
   assets/templates/  (se aplicável)
   ```
6. Adicione ao `.mb/skills/README.md`.
7. Commit:
   ```
   git commit -m "[skills] cria skill custom <nome>"
   ```
