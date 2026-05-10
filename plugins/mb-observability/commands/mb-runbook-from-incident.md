---
description: Gera runbook estruturado a partir de descrição de incidente recente
argument-hint: <descrição-do-incidente>
---

# /mb-runbook-from-incident

Conduza criação de runbook:

1. Capture do usuário:
   - Sintoma observado (o que avisou que algo estava errado?).
   - Causa raiz (se já identificada).
   - Como foi diagnosticado (que comandos, dashboards, logs ajudaram?).
   - Como foi mitigado (ações temporárias).
   - Como foi resolvido (correção definitiva).
   - Como evitar (mudança preventiva).
2. Estruture em `.mb/runbooks/<slug>.md`:
   ```
   # Runbook: <título>

   ## Sintomas
   - ...

   ## Diagnóstico inicial
   1. ...
   2. ...

   ## Causas comuns
   | Causa | Como confirmar | Como mitigar |
   |-------|---------------|--------------|

   ## Resolução
   - ...

   ## Escalação
   - Quando: ...
   - Para quem: ...

   ## Prevenção
   - ...
   ```
3. Atualize `.mb/runbooks/README.md` com índice.
4. Commit:
   ```
   git commit -m "[runbook] <título>"
   ```
