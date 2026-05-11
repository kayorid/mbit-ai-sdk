---
description: Lista plugins MBit ativados em ~/.claude/settings.json
---

# /mb-list-plugins

```bash
SETTINGS="${HOME}/.claude/settings.json"
if [[ ! -f "$SETTINGS" ]]; then
  echo "✗ ~/.claude/settings.json não existe. Rode /mb-init primeiro."
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  echo "Plugins MBit ativados em $SETTINGS:"
  echo ""
  jq -r '.enabledPlugins // {} | to_entries | map(select(.key | startswith("mb-")))[] | "  \(.value | if . == true then "✓" else "✗" end) \(.key)"' "$SETTINGS"
else
  echo "jq não instalado — não é possível listar."
  exit 1
fi
```

Use para confirmar quais plugins MBit estão habilitados antes de rodar comandos. Plugin desabilitado não responde a `/mb-*` correspondente.
