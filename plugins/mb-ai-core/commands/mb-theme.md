---
description: Configura tema visual do MBit (default | festive | compact | accessible | none)
argument-hint: [show | set <tema>]
---

# /mb-theme

Gerencia o tema visual via `.mb/config.yaml`.

```bash
SUB="${1:-show}"
case "$SUB" in
  show)
    THEME=$(grep -E '^theme:' .mb/config.yaml 2>/dev/null | sed 's/theme:[[:space:]]*//' | tr -d '"' | tr -d "'" || echo "default")
    echo "Tema atual: ${THEME:-default}"
    echo ""
    echo "Disponíveis:"
    echo "  default     — paleta MB oficial (laranja #E8550C truecolor)"
    echo "  festive     — paleta vibrante (releases, marcos)"
    echo "  compact     — cores básicas ANSI 16 (CI, terminais limitados)"
    echo "  accessible  — alto contraste + bold (acessibilidade)"
    echo "  none        — sem cores (logs, scripts)"
    ;;
  set)
    THEME="${2:-}"
    [[ -z "$THEME" ]] && { echo "Uso: /mb-theme set <tema>"; exit 1; }
    case "$THEME" in
      default|festive|compact|accessible|none) ;;
      *) echo "Tema inválido: $THEME"; exit 1 ;;
    esac
    mkdir -p .mb
    if grep -q '^theme:' .mb/config.yaml 2>/dev/null; then
      TMP=$(mktemp)
      sed "s/^theme:.*/theme: $THEME/" .mb/config.yaml > "$TMP" && mv "$TMP" .mb/config.yaml
    else
      echo "theme: $THEME" >> .mb/config.yaml
    fi
    echo "✓ Tema definido: $THEME"
    echo "Próximas mensagens MBit usarão a paleta nova."
    ;;
  *)
    echo "Uso: /mb-theme [show | set <tema>]"
    ;;
esac
```
