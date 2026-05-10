---
description: Snapshot reversível de .mb/ e specs ativas (create / list / restore)
argument-hint: <create|list|restore> [tag-ou-nome]
---

# /mb-snapshot

Backup reversível antes de operações de risco (re-bootstrap, migração major, refator de contexto).

## Subcomandos

- `/mb-snapshot create [tag]` — cria snapshot atual.
- `/mb-snapshot list` — lista snapshots existentes.
- `/mb-snapshot restore <nome>` — restaura snapshot (faz backup do estado atual antes).

Execute via:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot.sh" $ARGUMENTS
```

Snapshots ficam em `.mb/_snapshots/`. Recomende adicionar `.mb/_snapshots/` ao `.gitignore` se squad não quiser versioná-los.
