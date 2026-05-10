---
description: Reanalisa o repositório e propõe deltas para .mb/CLAUDE.md (uso após refator grande ou trimestralmente)
---

# /mb-bootstrap-rescan

Reanalisa o repositório sem sobrescrever o `.mb/CLAUDE.md` existente. Comportamento:

1. Rode `${CLAUDE_PLUGIN_ROOT}/skills/mb-bootstrap/scripts/repo-scan.sh` gerando nova `.mb/bootstrap/analysis.md`.
2. **Compare** a análise nova com a anterior (se existir).
3. Identifique deltas relevantes:
   - Linguagens/frameworks novos ou removidos.
   - Mudança de estrutura (monorepo ↔ multi-repo).
   - CI mudou.
   - Observabilidade adicionada/removida.
4. Gere `.mb/bootstrap/rescan-<DATA>.md` com diff e propostas de atualização ao `.mb/CLAUDE.md`.
5. **Não edite o `CLAUDE.md` automaticamente.** Apresente as propostas ao usuário e aguarde aprovação.
6. Após aprovação humana, aplique os deltas e crie commit:
   ```
   git commit -m "[mb-bootstrap-rescan] atualiza CLAUDE.md após mudanças no repo"
   ```

Use quando: refator grande, mudança de stack, novo serviço criado, ou trimestralmente como hygiene.
