# mb-ai-core

Plugin obrigatório do MB AI SDK. Carrega constitution corporativa, hooks bloqueantes de segurança e compliance, allowlist de MCPs e comandos base.

## O que entrega

- **Constitution MB** carregada via skill `mb-constitution` em todo contexto.
- **Hooks bloqueantes** (categorias SEGURANÇA e COMPLIANCE):
  - `pre-commit-secret-scan` — bloqueia commit com segredos detectados.
  - `pre-tool-mcp-allowlist` — bloqueia uso de MCP fora da allowlist.
  - `pre-bash-destructive-confirm` — exige confirmação para comandos destrutivos.
  - `post-commit-audit-log` — anexa metadado de auditoria via git notes.
- **Comandos base:**
  - `/mb-help` — visão geral do SDK e plugins ativos.
  - `/mb-status` — diagnóstico de instalação e conformidade.
  - `/mb-approve <fase>` — registra aprovação humana de fase SDD.
  - `/mb-exception` — abre exceção formal a regra bloqueante.

## Instalação

Via marketplace MB. Ver `docs/playbooks/install-by-role.md` no repo raiz.

## Configuração

- `config/constitution.md` — princípios não-negociáveis.
- `config/mcp-allowlist.json` — MCPs aprovados.

Ambos versionados no SDK; mudanças via PR ao `mb-ai-sdk` com revisão do Chapter AI.
