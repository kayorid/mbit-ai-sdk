# Contribuindo para o MBit

Obrigado pelo interesse. O MBit é mantido pelo **Chapter AI** do Mercado Bitcoin com contribuições da comunidade de **AI Champions** dos squads.

## Modelo de governança

- **Chapter AI** é o owner do core (constitution, hooks bloqueantes, MCP allowlist).
- **AI Champions** dos squads podem propor mudanças via PR.
- **Devs** dos squads contribuem indiretamente via retros (que viram propostas via `/mb-retro-promote`).

Veja [`docs/governance/raci.md`](docs/governance/raci.md) para detalhes.

## Antes de abrir PR

1. **Identifique o tipo de mudança:**
   - 🐛 **Bug fix** — corrige comportamento documentado.
   - ✨ **Feature** — adiciona capacidade nova.
   - 📚 **Docs** — só documentação.
   - 🎨 **Polish** — refactor, perf, UX sem mudar comportamento.
   - 🔒 **Security** — fix de vulnerabilidade — leia [`SECURITY.md`](SECURITY.md) primeiro.

2. **Para features novas, abra issue antes** com label `proposal`. Discussão evita PR refeito.

3. **Rode os smoke tests local** antes de pushar:
   ```bash
   bash tests/smoke/run.sh
   ```
   Tudo deve passar em verde.

4. **Atualize CHANGELOG.md** com o que mudou (`## [próxima-versão]` se aplicável).

5. **Atualize testes** se o comportamento mudou ou se adiciona feature nova.

## Padrão de commits

Convenção MBit (validada pelo workflow `mb-ai-checks.yml`):

```
[<categoria>(:<slug>)] <mensagem imperativa curta>

<corpo opcional explicando o porquê, não o quê>
```

**Categorias válidas:**
- `[spec:<slug>]` — trabalho referenciando spec ativa
- `[hotfix:<slug>]` — modo expresso
- `[chore:<area>]` — infra, deps, build
- `[docs:<area>]` — documentação
- `[retro]` — retrospectiva
- `[runbook]` — runbook operacional
- `[review:<slug>]` — fix de finding de review
- `[skills]` — skill custom criada
- `[learnings]` — consolidação de aprendizados

## Convenção de branch

- `main` — sempre release-ready.
- `feature/<slug>` — features.
- `fix/<slug>` — bugfixes.
- `proposal/<slug>` — propostas ao core.
- `spike/<slug>` — exploração (nunca merge).

## Estrutura de plugin

Ao adicionar plugin novo, siga a estrutura padrão:

```
plugins/<plugin-name>/
├── .claude-plugin/plugin.json   # versão sincronizada com marketplace.json
├── README.md
├── skills/<skill-name>/SKILL.md
├── commands/*.md
├── hooks/hooks.json + hooks/scripts/*.sh   (se aplicável)
└── scripts/*.sh                            (se aplicável)
```

Detalhes em [`docs/PLUGIN-DEVELOPMENT.md`](docs/PLUGIN-DEVELOPMENT.md).

## Convenções de código shell

- Shebang: `#!/usr/bin/env bash`
- `set -euo pipefail` em scripts CLI; `set -uo pipefail` em scripts de display tolerantes.
- Quote variáveis sempre: `"$VAR"` não `$VAR`.
- Use `grep -e -- "$PAT"` para evitar interpretação de patterns como flags.
- Limite ReDoS: `head -c 100k` antes de regex complexa.
- Sanitize entradas: `tr -d '\n|'` antes de gravar em logs delimitados por pipe.
- Use `flock` para escritas concorrentes em audit logs.

## Convenções de skills

- Nome: prefixo `mb-` (corp) ou `mb-<squad>-` (custom de squad).
- `description` no frontmatter: rica, com **triggers explícitos** em português ("acione quando o usuário disser X, Y, Z").
- Conteúdo focado em **quando aplicar** + **como aplicar** + **princípios**. Não duplicar constitution.

## Convenções de comandos

- Nome: prefixo `mb-`.
- Frontmatter: `description` (curta, para listagem) + `argument-hint` se aceita args.
- Conteúdo: instruções para o agente, não para humano. Foco no que executar.
- Invoque scripts via `${CLAUDE_PLUGIN_ROOT}` para portabilidade.

## Versionamento

Semver estrito:
- **Major** (`X.0.0`) — breaking change. Janela de migração 30+ dias.
- **Minor** (`0.X.0`) — feature nova, hook novo, skill nova.
- **Patch** (`0.0.X`) — bugfix, docs, polish.

Ao bumpar versão:
1. Atualize **todos** os `plugin.json` E `marketplace.json` para mesma versão.
2. Adicione bloco no `CHANGELOG.md`.
3. Rode `bash tests/smoke/run.sh` — deve passar.
4. Crie tag git `v<X.Y.Z>`.

Veja [`docs/MIGRATION.md`](docs/MIGRATION.md) para mudanças entre versões.

## Code of Conduct

Este projeto adota a postura de respeito, foco técnico e disciplina pedagógica. Discordância é bem-vinda; ataque pessoal não. Mantenedores moderam quando necessário.

## Contato

- **Slack:** `#mb-ai-sdk`
- **Email Chapter AI:** `chapter-ai@mercadobitcoin.com.br`
- **Issues:** [github.com/kayorid/mbit-ai-sdk/issues](https://github.com/kayorid/mbit-ai-sdk/issues)
