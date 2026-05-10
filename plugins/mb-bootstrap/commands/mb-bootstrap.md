---
description: Onboarding completo do squad ao MB AI SDK — análise automática + entrevista guiada + plano de enriquecimento
---

# /mb-bootstrap

Invoque a skill `mb-bootstrap` e conduza o fluxo completo:

1. **Análise automática:** rode `${CLAUDE_PLUGIN_ROOT}/skills/mb-bootstrap/scripts/repo-scan.sh` e apresente o resumo.
2. **Entrevista guiada:** conduza as 10 perguntas de `references/interview-questions.md`, uma por vez, registrando em `.mb/bootstrap/interview.md`.
3. **Geração:** crie `.mb/CLAUDE.md`, `.mb/glossary.md`, `.mb/runbooks/`, `.mb/skills/`, `.mb/hooks/`, `.mb/bootstrap/enrichment-plan.md`, `.mb/config.yaml` usando templates de `assets/templates/`.
4. **Commit:** sugira commit inicial.
5. **Próxima ação:** oriente rodar `/mb-spec` na primeira feature e cumprir missão da semana 1.

Pré-requisito: `mb-ai-core` ativo, repositório git, sem `.mb/CLAUDE.md` existente (caso contrário, sugira `/mb-bootstrap-rescan`).
