---
description: Modo hotfix — pula DISCUSS/SPEC para urgências, exige hotfix-plan mínimo e post-mortem em 48h
argument-hint: <descrição-curta>
---

# /mb-hotfix

Modo expresso para urgências legítimas. **Não use para evitar disciplina** — use só quando há incidente em produção ou janela crítica de negócio.

## Comportamento

0. **Banner de hotfix:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/../mb-ai-core/lib/ascii.sh" hotfix danger
   ```
1. **Validação inicial:**
   - Pergunte: "Qual o incidente/urgência? Há ticket de incidente associado?"
   - Se a justificativa for fraca (não-urgência), oriente usar `/mb-spec` normal.
2. **Setup:**
   - Crie `docs/specs/_active/<YYYY-MM-DD>-hotfix-<slug>/`.
   - Gere `hotfix-plan.md` mínimo:
     - Problema (sintoma observado).
     - Causa raiz (suspeita ou confirmada).
     - Solução proposta (1-2 parágrafos).
     - Impacto e risco.
     - Plano de rollback.
     - Quem aprovou (TL/OnCall).
3. **Implementação:**
   - Execute o fix com commits atômicos `[hotfix:<slug>] <msg>`.
   - Threat-model ainda aplica se ativo crítico.
4. **Verify acelerado:** comprovar que o sintoma sumiu (mínimo: teste manual + observabilidade confirma).
5. **Ship:** PR com label `hotfix`, review acelerado.
6. **Post-mortem obrigatório em 48h:**
   - Crie task/lembrete persistente.
   - Conduza com `/mb-spec-retro` adaptado: causa raiz formal, ações para evitar recorrência, learnings.
   - Ações de prevenção viram tasks formais em outra spec.

## Diferenças vs `/mb-spec`

| Fase | `/mb-spec` | `/mb-hotfix` |
|------|-----------|--------------|
| DISCUSS | Obrigatória | Pulada (registrada como exceção) |
| SPEC | `requirements.md` em EARS | `hotfix-plan.md` simplificado |
| PLAN | `design.md` + `tasks.md` | Decisões inline no `hotfix-plan.md` |
| EXECUTE | Commits por task | Commits por arquivo afetado |
| VERIFY | Goal-backward completo | Sintoma + observabilidade |
| REVIEW | Code+sec+spec | Code+sec acelerado |
| SHIP | PR padrão | PR label hotfix, merge expresso |
| RETRO | Learnings | Post-mortem formal em 48h |
