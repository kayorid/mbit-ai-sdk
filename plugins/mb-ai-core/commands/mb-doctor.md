---
description: Diagnóstico completo do MB AI SDK — verifica plugins, hooks, .mb/, audit trail, conformidade
---

# /mb-doctor

Execute o script de diagnóstico:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh"
```

A saída usa cores e símbolos (✓ / ⚠ / ✗) para sinalizar cada verificação. Ao final, mostra resumo e exit code:
- **0:** tudo OK ou apenas avisos.
- **1:** erros encontrados — siga as orientações de fix.

Use ao:
- Receber relato de "algo não está funcionando".
- Após alterar `~/.claude/settings.json`.
- Ao instalar o SDK pela primeira vez.
- Periodicamente (mensalmente) como hygiene.
