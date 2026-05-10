---
description: Mostra o banner ASCII do MB AI SDK com frase do manifesto
---

# /mb-banner

Execute o script de banner para mostrar a identidade visual do SDK.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start-banner.sh" 2>&1 | jq -r '.hookSpecificOutput.additionalContext // .'
```

Use também ao apresentar o SDK em demos, no início de workshops ou para quebrar gelo no canal `#mb-ai-sdk`.
