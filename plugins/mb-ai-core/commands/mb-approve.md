---
description: Registra aprovação humana de uma fase do ciclo SDD com autor, timestamp e motivo no audit-trail
argument-hint: <fase> [feature] [motivo]
---

# /mb-approve

Registra aprovação humana de uma fase do ciclo SDD. Sem essa aprovação, a próxima fase não pode iniciar.

## Comportamento

1. **Identifique fase e feature.** Se o usuário passou argumentos (`/mb-approve DESIGN onboarding-v2 "design ok"`), use-os. Caso contrário:
   - Detecte spec ativa em `docs/specs/_active/` (a mais recente, ou pergunte se houver várias).
   - Detecte fase pelo último artefato gerado.
   - Pergunte motivo curto se não fornecido.

2. **Identifique o aprovador.** Use `git config user.name` e `user.email`. Se vazio, recuse e oriente configurar.

3. **Grave em `.mb/audit/approvals.log`** (append-only):
   ```
   2026-05-10T14:32:11Z | feature=<slug> | phase=<FASE> | actor=<email> | reason="<motivo>"
   ```

4. **Atualize `docs/specs/_active/<feature>/approvals.log`** local da feature com o mesmo registro.

5. **Crie commit dedicado:**
   ```
   git add .mb/audit/approvals.log docs/specs/_active/<feature>/approvals.log
   git commit -m "[spec:<feature>] approve phase <FASE> by <actor>"
   ```

6. **Confirme ao usuário:**
   ```
   ✓ Aprovação registrada
     Feature: <feature>
     Fase: <FASE>
     Aprovador: <email>
     Próxima fase liberada: <FASE+1>
   ```

## Fases válidas

`DISCUSS`, `SPEC`, `PLAN`, `EXECUTE`, `VERIFY`, `REVIEW`, `SHIP`, `RETRO`.

## Restrições

- Não pode aprovar a mesma fase duas vezes para a mesma feature (warn e aborta).
- Não pode aprovar fase futura pulando anteriores sem `/mb-exception`.
- Aprovação requer git identity configurada (não-anônima).
