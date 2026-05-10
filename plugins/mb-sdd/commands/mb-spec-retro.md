---
description: Fase RETRO — extrai learnings da feature, propõe evoluções para constitution e arquiva
argument-hint: <slug-da-feature>
---

# /mb-spec-retro

Conduza a retrospectiva final da feature:

0. **Banner de retro:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/../mb-ai-core/lib/ascii.sh" retro accent
   ```
1. Verifique SHIP completo (PR mergeado).
2. Invoque a skill `mb-retro-facilitator` (do plugin `mb-retro`) para conduzir o fluxo. Se `mb-retro` não estiver instalado, conduza inline:
   - **O que funcionou bem?** (práticas a manter)
   - **O que falhou ou foi caro?** (a evitar)
   - **Surpresas?** (descobertas inesperadas)
   - **Decisões que viraram precedente?** (candidatas a virar regra)
   - **Propostas de evolução?** (mudanças ao processo, hooks, skills)
3. Gere `retro.md` com as 5 seções acima.
4. Identifique se há learning promovível à constitution corporativa (`mb-ai-core`):
   - Se sim, oriente abrir PR ao `mb-ai-sdk` propondo a mudança.
5. Peça `/mb-approve RETRO`.
6. Mova a pasta da feature de `_active/` para `_archive/<YYYY-Qn>/`:
   ```
   mkdir -p docs/specs/_archive/$(date +%Y)-Q$((($(date +%-m) - 1) / 3 + 1))
   git mv docs/specs/_active/<YYYY-MM-DD>-<slug> docs/specs/_archive/<YYYY-Qn>/
   ```
7. Atualize `docs/specs/INDEX.md` (rode script de regeneração).
8. Crie commit:
   ```
   git commit -m "[spec:<slug>] retro + arquivamento"
   ```

Tempo esperado: 30-45 min.
