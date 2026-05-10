---
description: Mostra ASCII art para momentos-chave do SDK (welcome, ship, retro, etc)
argument-hint: [welcome|bootstrap-done|spec-start|ship|hotfix|retro|mature-squad]
---

# /mb-ascii

Exibe ASCII art celebrativo de momentos-chave. Útil em demos, workshops, comunicação informal.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/lib/ascii.sh" $ARGUMENTS
```

Banners disponíveis:
- `welcome` — boas-vindas ao SDK (default)
- `bootstrap-done` — squad concluiu bootstrap
- `spec-start` — início de novo ciclo SDD
- `ship` — feature em produção
- `hotfix` — modo expresso ativado
- `retro` — retrospectiva iniciada
- `mature-squad` — squad destravou maturidade

Cores: `primary` (default) | `accent` | `success` | `warn` | `danger` | `info`.

Exemplo: `/mb-ascii ship success`
