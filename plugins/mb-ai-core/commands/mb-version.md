---
description: Mostra versões de todos os plugins MBit + dependências do sistema
---

# /mb-version

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/version.sh"
```

Lista cada plugin com versão local vs marketplace, status de sincronização, versão do Claude Code e dependências (jq, git, bash). Exit 1 se houver dessincronização.
