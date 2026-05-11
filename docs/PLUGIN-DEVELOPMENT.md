# Plugin Development Guide — MBit

Guia para desenvolver plugins MBit (corp ou squad-custom). Inclui anatomia, convenções, padrões testados, armadilhas e checklist de release.

---

## Quando criar plugin novo

✅ **Crie plugin** quando:
- Capacidade compartilhável entre múltiplos squads.
- Conjunto coeso de skills + comandos + hooks.
- Necessidade de namespace próprio (`/mb-<plugin>-<comando>`).

❌ **NÃO crie plugin** quando:
- Capacidade específica de um squad → use `.mb/skills/mb-<squad>-<skill>/` no repo do squad.
- Apenas 1 comando → adicione a um plugin existente.
- Experimentação curta → use `/mb-spike`.

---

## Anatomia padrão

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json                    # versão sincronizada com marketplace
├── README.md                          # documentação humana
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md                  # auto-trigger
│       ├── references/               # docs sob demanda
│       │   └── *.md
│       ├── scripts/                  # automações
│       │   └── *.sh
│       └── assets/
│           └── templates/            # templates .tpl
├── commands/                          # slash commands
│   └── *.md
├── hooks/                             # se aplicável
│   ├── hooks.json
│   └── scripts/
│       └── *.sh
├── scripts/                           # utilitários invocados por comandos
│   └── *.sh
├── lib/                               # helpers compartilhados
│   └── *.sh
└── config/                            # configuração estática
    └── *.json | *.yaml
```

---

## plugin.json mínimo

```json
{
  "name": "mb-<nome>",
  "description": "MBit — <propósito em uma frase>",
  "version": "0.3.0",
  "author": {
    "name": "Chapter AI - Mercado Bitcoin",
    "email": "chapter-ai@mercadobitcoin.com.br"
  },
  "homepage": "https://github.com/kayorid/mbit-ai-sdk",
  "repository": "https://github.com/kayorid/mbit-ai-sdk",
  "license": "Proprietary",
  "keywords": ["mbit", "<categoria>"]
}
```

**Importante:** versão deve ser **idêntica** ao listado em `.claude-plugin/marketplace.json`. CI valida sincronização (regressão B-1).

---

## Skills — boas práticas

### Frontmatter

```yaml
---
name: mb-<plugin>-<skill>
description: Use quando <gatilho A>, ao mencionar "<termos B>", ou em situações como <contexto C>. Faz <X>. Distingue de <skill similar> por <Y>.
---
```

A `description` é **crítica** — o agente decide se invoca a skill com base nela. Skills MBit usam **descrições ricas em português** com triggers explícitos.

### Conteúdo

Estrutura recomendada:

```markdown
# Nome legível

<Contexto introdutório de 1-2 parágrafos>

## Quando aplicar

- Trigger 1
- Trigger 2

## Como aplicar

### 1. <Passo>
<Descrição>

### 2. <Passo>
<Descrição>

## Princípios

- <Princípio>

## Limitações

- <O que NÃO faz>
```

### Anti-patterns

- ❌ Description vaga: "Use para qualidade de código"
- ❌ Conteúdo gigante (>500 linhas) — quebre em `references/`
- ❌ Duplicar constitution
- ❌ Hardcode de comandos do squad

---

## Comandos — boas práticas

### Frontmatter

```yaml
---
description: <Descrição curta para listagem>
argument-hint: <args opcional>
---
```

### Conteúdo

Comandos são **instruções para o agente**, não para humano. Foco em ação:

```markdown
# /mb-<comando>

Invoque a skill `mb-<plugin>` para <propósito>:

1. Faça X.
2. Verifique Y.
3. Produza Z.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/<script>.sh" $ARGUMENTS
```
```

### Path do plugin

Use `${CLAUDE_PLUGIN_ROOT}` — Claude Code expande em runtime para a raiz do plugin atual. **Nunca** hardcode paths.

---

## Hooks — categorização e padrões

### Categorias

| Categoria | Postura | Exemplos |
|-----------|---------|----------|
| **SEGURANÇA** | Sempre bloqueia, sem flag | secret-scan, private-key-scan |
| **COMPLIANCE** | Bloqueia, exceção via `/mb-exception` | mcp-allowlist, audit-log |
| **PROCESSO** | Warn → block após maturidade | spec-reference em commit |
| **QUALIDADE** | Sempre warn | observability suggestions |

Documente categoria no comentário do script.

### Estrutura padrão

```bash
#!/usr/bin/env bash
# mb-<plugin> / hooks / <nome>.sh
# Categoria: <SEGURANÇA|COMPLIANCE|PROCESSO|QUALIDADE>
# <Descrição em uma linha>

set -euo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"

# Curto-circuito cedo (não desperdice fork de jq)
echo "$INPUT" | grep -q 'algo-relevante' || exit 0

# Lógica
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
# ...

if <condição-de-bloqueio>; then
  AUDIT_DIR=".mb/audit"; mkdir -p "$AUDIT_DIR"
  # H-2: sanitize e flock para concorrência
  (
    flock -x 9 2>/dev/null || true
    echo "$(date -u +%FT%TZ) | hook=<nome> | status=BLOCKED | <campos>" >> "$AUDIT_DIR/hook-fires.log"
  ) 9>>.mb/audit/.lock 2>/dev/null

  cat <<EOF >&2
[mb-<plugin>] BLOCKED — <motivo>
  <contexto>
  <orientação de fix>
EOF
  exit 2
fi

exit 0
```

### Armadilhas comuns

- **`grep` interpreta `-` como flag** → use `grep -e -- "$PAT"`.
- **Regex Perl `(?:)` em `grep -E`** → não funciona, use grupos comuns `(...)`.
- **`gawk asorti`** → não existe em BSD awk. Use iteração POSIX.
- **`date -d` vs `date -v-`** → varia BSD/GNU. Tenha fallback.
- **`head -c` quebra UTF-8** → considere `cut -c` ou jq `[0:N]`.
- **ReDoS** em regex com `.{0,N}` — `head -c 100k` antes para limitar input.

---

## Scripts — padrões

```bash
#!/usr/bin/env bash
# <plugin> / scripts / <nome>.sh
# <Propósito>

set -euo pipefail   # sempre em CLI scripts; -uo apenas em display tolerantes

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

# Validações
[[ $# -lt 1 ]] && { echo "Uso: $(basename "$0") <args>"; exit 1; }

# Lógica principal
# ...

exit 0
```

---

## Templates de assets

Templates terminam em `.tpl` (não confundir com arquivo final):

```
assets/templates/
├── CLAUDE.md.tpl
├── design.md.tpl
└── runbook.md.tpl
```

Placeholders em `<MAIÚSCULAS-COM-HIFEN>`.

---

## Adicionando o plugin ao marketplace

1. Editar `.claude-plugin/marketplace.json`:

```json
{
  "name": "mb-<nome>",
  "description": "<descrição>",
  "version": "0.3.0",
  "source": "./plugins/mb-<nome>"
}
```

2. Versão deve ser idêntica ao `plugin.json` do plugin (CI valida).

3. Rode smoke tests:
```bash
bash tests/smoke/run.sh
```

---

## Cross-referenciação entre plugins

Para invocar comando de outro plugin a partir do seu:

```markdown
# Em plugins/mb-X/commands/foo.md

Invoque o comando do plugin mb-Y:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/../mb-Y/scripts/<script>.sh"
```
```

Note `${CLAUDE_PLUGIN_ROOT}/../mb-Y` — funciona porque plugins estão em pastas vizinhas.

---

## Checklist de release de plugin novo

- [ ] `plugin.json` válido (jq empty)
- [ ] Versão sincronizada entre `plugin.json` e `marketplace.json`
- [ ] README.md com tabela de comandos e propósito
- [ ] Pelo menos 1 SKILL.md com description rica
- [ ] Comandos com frontmatter `description` (+ `argument-hint` se aceita args)
- [ ] Hooks (se houver) com `hooks.json` + scripts executáveis (`chmod +x`)
- [ ] Scripts shell com `set -euo pipefail`
- [ ] Smoke tests passando: `bash tests/smoke/run.sh`
- [ ] Entrada no `CHANGELOG.md`
- [ ] PR template preenchido completo
- [ ] CI verde

---

## Perguntas frequentes

**P: Posso criar plugin que substitua `mb-ai-core`?**
R: Não. `mb-ai-core` é obrigatório e provê constitution/hooks bloqueantes inegociáveis. Estenda via novos plugins.

**P: Como testar plugin localmente antes de PR?**
R: Aponte temporariamente seu `~/.claude/settings.json` para o caminho local do repo. Rode `/mb-doctor` e teste manualmente.

**P: Plugin pode ter dependência runtime (libs, binários)?**
R: Idealmente shell + jq + git apenas. Se precisar de python/node, documente no README e detecte ausência com mensagem útil.

**P: Hooks ficam lentos em monorepos. Como otimizar?**
R: Cache de "fase atual" em `.mb/_runtime/` atualizado por hook menos frequente. Curto-circuito antes de operações caras (find, grep recursivo).
