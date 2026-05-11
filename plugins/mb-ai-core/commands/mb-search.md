---
description: Busca em specs ativas e arquivadas (grep estruturado com excerpt)
argument-hint: <termo-ou-frase>
---

# /mb-search

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/search-specs.sh" "$ARGUMENTS"
```

Procura termo em todos os `.md` de `docs/specs/_active/` e `_archive/`. Mostra arquivo, slug da feature e excerpt da linha que casou.

Versão semântica (embeddings) virá em v1.5 conforme roadmap evolutivo.
