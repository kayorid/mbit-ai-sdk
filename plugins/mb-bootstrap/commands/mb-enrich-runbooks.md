---
description: Documenta runbook operacional para um fluxo crítico ou incidente recente
argument-hint: <fluxo-ou-incidente>
---

# /mb-enrich-runbooks

Conduza criação de runbook para um fluxo crítico do squad:

1. Identifique o fluxo (passe como argumento ou pergunte ao usuário, sugerindo da lista de "fluxos críticos" em `.mb/CLAUDE.md`).
2. Conduza entrevista estruturada:
   - **Sintomas observáveis:** como o time descobre que esse fluxo está quebrado? (alertas, métricas, reclamações)
   - **Diagnóstico inicial:** primeiros 3 lugares para olhar (logs, dashboards, comandos).
   - **Causas comuns:** top 3 causas raiz históricas.
   - **Ações de mitigação:** o que fazer para reduzir impacto enquanto se investiga.
   - **Ações de resolução:** comandos/passos para resolver as causas comuns.
   - **Escalação:** quando e para quem escalar.
   - **Pós-incidente:** o que registrar e onde.
3. Gere `.mb/runbooks/<slug-do-fluxo>.md` estruturado.
4. Atualize `.mb/runbooks/README.md` com link.
5. Crie commit:
   ```
   git commit -m "[mb-enrich-runbooks] runbook para <fluxo>"
   ```

Tempo esperado: 30-60 min por runbook.
