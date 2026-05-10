---
description: Conduz o ciclo SDD completo (discuss → spec → plan → execute → verify → review → ship → retro) com checkpoints obrigatórios
argument-hint: <slug-da-feature>
---

# /mb-spec

Conduza o ciclo SDD completo invocando a skill `mb-sdd`. Comportamento:

0. **Banner de início:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/../mb-ai-core/lib/ascii.sh" spec-start accent
   ```
1. **Setup:** crie `docs/specs/_active/<YYYY-MM-DD>-<slug>/` com `status.md`.
2. **Para cada fase** (DISCUSS, SPEC, PLAN, EXECUTE, VERIFY, REVIEW, SHIP, RETRO):
   - Conduza a fase conforme `references/phase-playbook.md`.
   - Gere o(s) artefato(s) da fase.
   - **PAUSE** e peça ao usuário para executar `/mb-approve <FASE>` antes de prosseguir.
   - Após aprovação, prossiga para próxima fase.
3. **Integrações automáticas:**
   - Em PLAN: se a feature toca ativo crítico (ver `.mb/CLAUDE.md`, fluxos críticos, regulação), invoque `/mb-threat-model` antes de `design.md`. Sempre invoque `/mb-observability-design`.
   - Em REVIEW: invoque `/mb-review-pr` (code), `/mb-review-spec` (coverage), e `/mb-review-security` se ativo crítico.
   - Em SHIP: garanta PR aberto referenciando spec; tag com versão se aplicável.
   - Em RETRO: invoque `/mb-retro` ao fim.

**Importante:**
- Pular fases requer `/mb-exception` com justificativa.
- Tasks em EXECUTE devem gerar commits atômicos com `[spec:<slug>] <msg>`.
- Não declare "pronto" sem `verification.md` aprovado.
