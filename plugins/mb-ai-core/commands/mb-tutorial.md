---
description: Tutorial guiado do MBit num sandbox local — passa pelo ciclo SDD completo em 45-60 min
argument-hint: [init|roteiro|reset]
---

# /mb-tutorial

Onboarding hands-on para devs novos no MBit.

**Subcomandos:**

- `/mb-tutorial init` — cria sandbox em `~/.mb/tutorial-sandbox/` com repositório fictício "MBExchangeMini".
- `/mb-tutorial roteiro` — exibe o roteiro passo-a-passo.
- `/mb-tutorial reset` — remove sandbox para recomeçar.

```bash
case "${1:-init}" in
  init)
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/tutorial-init.sh"
    ;;
  roteiro)
    cat "${CLAUDE_PLUGIN_ROOT}/scripts/tutorial-roteiro.md"
    ;;
  reset)
    rm -rf "${HOME}/.mb/tutorial-sandbox"
    echo "✓ Sandbox removido. Rode /mb-tutorial init para recomeçar."
    ;;
esac
```

Após concluir, compartilhe `tutorial-completed.md` com seu AI Champion para registro.
