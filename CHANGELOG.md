# Changelog

Todas as mudanças notáveis no MBit (MB AI SDK) serão documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/), versionamento semântico.

## [0.3.0] — 2026-05-10

### Adicionado
- **Plugin novo `mb-evals@0.3.0`** — eval framework para features que usam IA em runtime. Datasets golden, rubricas (determinística + LLM-as-judge + custom), runners, A/B compare e modo CI. Comandos: `/mb-evals-init`, `/mb-evals-run`, `/mb-evals-compare`, `/mb-evals-ci`.
- **`/mb-init`** — wizard interativo de primeira instalação que configura `~/.claude/settings.json` com marketplace MB e 9 plugins. Backup automático do settings anterior.
- **`/mb-fast`** — modo expresso para squads maduros (3+ ciclos completos, 0 exceções, 2+ learnings promovidos, 5+ achievements). Verifica critérios e destrava automaticamente.
- **`/mb-theme set/show`** — gerência do tema visual via `.mb/config.yaml` (default, festive, compact, accessible, none).
- **`/mb-search <termo>`** — busca grep estruturada em specs ativas e arquivadas com excerpt. Versão semântica em v1.5.
- **`/mb-new-skill <slug>`** — scaffolder de skill custom em `.mb/skills/mb-<slug>/` com SKILL.md + references + scripts + templates + atualização do índice.
- **`/mb-retro-digest [N]`** — resumo curto das últimas N retrospectivas para captura rápida de tendências.
- **Auto-snapshot** — `/mb-bootstrap-rescan` agora cria snapshot automático antes de modificar `.mb/`.
- **CI próprio do repo** — `.github/workflows/sdk-ci.yml` rodando smoke tests, validação de manifestos JSON, sintaxe shell, ShellCheck e sincronização de versões em todo PR ao `mbit-ai-sdk`.
- **Governança open-source** — `CONTRIBUTING.md`, `SECURITY.md`, issue templates (bug/proposal/security), PR template.
- **`docs/MIGRATION.md`** — guia de migração entre versões.
- **`docs/PLUGIN-DEVELOPMENT.md`** — guia completo para desenvolver plugins MBit.

### Corrigido
- **M-2 statusline para terminais estreitos** — auto-detecta largura via payload e usa formato compacto se <100 cols (mínimo se <80).
- **M-8 ANSI no contexto do agente** — banner colorido vai apenas para stderr (terminal); `additionalContext` (LLM input) recebe versão plain. Economiza ~150 tokens/sessão.
- **Auto-snapshot pré-rescan** — `mb-bootstrap-rescan` invoca `/mb-snapshot create pre-rescan` antes de operação destrutiva.

### Bumpado
- Todos os 9 plugins de `0.2.0` para `0.3.0` (sincronizado em marketplace + plugin.json).

## [0.2.0] — 2026-05-10

### Adicionado
- **Identidade visual MBit** — paleta laranja MB oficial `#E8550C` (truecolor), 8 ASCII arts hexagonais (welcome, bootstrap-done, spec-start, ship, hotfix, retro, mature-squad, hexagon-logo).
- **Banner de boas-vindas** com hexágono + ANSI Shadow wordmark "MBit", manifesto rotativo (20 frases incluindo "Cripto para todos").
- **Statusline** custom sempre visível: `◆ MB │ <squad> │ boot ✓ │ specs N │ <FASE> │ 🛡 N │ <modelo>`.
- **Themes** configuráveis (`default`, `festive`, `compact`, `accessible`, `none`) via `.mb/config.yaml` ou `MB_THEME`.
- **Spinners** reutilizáveis (`lib/spinner.sh`) com pool de mensagens criativas.
- **Hooks de UX**: SessionStart (banner + status + achievements), Stop (despedida + resumo + achievements), Notification (tom MB).
- **Achievement system** — 12 conquistas (`first-bootstrap`, `defender`, `mature-squad`, `centurion`, etc), checker, notify hook plugado em Stop, comando `/mb-achievements`.
- **`/mb-doctor`** — diagnóstico colorido tipo `brew doctor` com 7 seções de health checks.
- **`/mb-snapshot`** — backup reversível de `.mb/` e specs ativas (create/list/restore).
- **`/mb-dashboard`** — painel ASCII com sparklines, maturidade, achievements, próxima ação contextual.
- **`/mb-tutorial`** — sandbox guiado (`~/.mb/tutorial-sandbox/`) com repositório fictício "MBExchangeMini" + roteiro 45-60 min.
- **`/mb-update`** — verifica e aplica atualizações com changelog, comparação semver via `sort -V` e detecção de breaking changes.
- **`/mb-banner`** + **`/mb-ascii`** — invocação manual de ASCII art.
- **Plugin novo `mb-cost@0.2.0`** — princípio MBit #9 ("custo de IA é decisão de engenharia"). Captura de tokens via PostToolUse, snapshot de preço no log, agregação por fase/feature/dia/mês, alertas de budget. 4 comandos.
- **GHA workflow** distribuído (`.github/workflows/mb-ai-checks.yml`) — secret scan, PII scan brasileira, spec coverage, validação de commit format e manifestos JSON.
- **Slack stub** (`integrations/slack/`) — manifest declarativo + arquitetura para implementação completa em onda 3.
- **Suite de smoke tests** (`tests/smoke/run.sh`) — 60+ verificações: estrutura, JSON, scripts, hooks (execução real com payloads simulados), versões sincronizadas.
- **Documentação evolutiva** — `docs/plans/2026-05-10-evolution-roadmap.md` (5 frentes, 6 ondas v0.2→v3.0, dependências, capacity, riscos).

### Corrigido
- **Sincronização de versões** — todos os 8 plugin.jsons + marketplace.json em `0.2.0`.
- **`cost-report.sh` `unbound variable: FEAT`** — variáveis inicializadas antes do `case`.
- **Regex Perl `(?:)` em `grep -E`** nos hooks de PII e chave privada — convertidos para ERE puro. Cartão Visa/Mastercard/Amex, chave Ethereum hex e BIP-39 mnemonic agora bloqueiam de fato.
- **`cost-capture` overhead** — curto-circuito antes de qualquer `jq` se payload não tem `usage`. Sai em milissegundos.
- **`set -e` adequado** — scripts CLI usam `set -euo pipefail`; scripts de display (doctor, dashboard) mantêm `-uo` propositalmente.
- **`grep` vs `ugrep`** — todas chamadas usam `grep -e -- "$PAT"` ou `grep -Eq -e` para evitar interpretação de `-----BEGIN` como flag.
- **`destructive-confirm`** — permite explicitamente `git push --force-with-lease` (preferível a `--force`).
- **`secret-scan .env`** — allowlist estendida para `.env.local`, `.env.development`, `.env.test`, `.env.sample`. Ignora placeholders `<...>`, `${VAR}`, `changeme`, `your-key-here`.
- **`session-start-banner`** — manifesto lido como array; sem divisão por zero ou linha vazia.
- **`update.sh`** — `git -C` (não muda cwd), comparação semver via `sort -V`, validação de versão remota.
- **`doctor.sh` `find -o`** — wrapped em `\( ... \) -print` para portabilidade BSD/GNU.
- **`dashboard.sh` BLOCKS_WEEK**: fallback `n/d` se `date` não suportado, evita métrica falsa de "tudo limpo".
- **Audit log race conditions** — escritas críticas com `flock` + sanitização (`tr -d '\n|'`) para evitar corrupção.
- **`achievements/notify.sh` órfão** — agora plugado em hook Stop, dispara automaticamente.
- **`RELEASE-NOTES.md` desatualizado** — substituído por aviso apontando ao CHANGELOG.

## [0.1.0] — 2026-05-10

### Adicionado
- **Marketplace `mb`** com 7 plugins.
- **`mb-ai-core@0.1.0`**: constitution corporativa MB; 4 hooks bloqueantes (secret-scan, MCP allowlist, destructive-confirm, audit-log); 4 comandos (`/mb-help`, `/mb-status`, `/mb-approve`, `/mb-exception`); skill `mb-constitution`; MCP allowlist inicial.
- **`mb-bootstrap@0.1.0`**: onboarding híbrido (análise automática + entrevista guiada + enriquecimento); skill `mb-bootstrap`; 5 comandos; templates de `.mb/CLAUDE.md`, `glossary.md`.
- **`mb-sdd@0.1.0`**: ciclo Spec-Driven rígido com 7 fases e checkpoints obrigatórios; 10 comandos (`/mb-spec`, `/mb-spec-*`, `/mb-hotfix`, `/mb-spike`); herda artefatos do plugin SDD original.
- **`mb-review@0.1.0`**: 3 agentes revisores (`mb-code-reviewer`, `mb-security-reviewer`, `mb-spec-reviewer`); 4 comandos.
- **`mb-observability@0.1.0`**: design e revisão de observabilidade stack-agnostic; 3 comandos.
- **`mb-security@0.1.0`**: threat modeling STRIDE + cripto; compliance Bacen/CVM/LGPD/Travel Rule; padrões cripto (BIP, custódia, multisig); 2 hooks bloqueantes (PII brasileira, chaves privadas); 4 comandos.
- **`mb-retro@0.1.0`**: retrospectivas estruturadas; agregação trimestral de learnings; 4 comandos.
- **Documentação**: design proposal completo, manual técnico, roteiro de apresentação, playbooks por papel, governance + RACI, FAQ.

### Próximas versões
- v0.5 → v3.0: ver `docs/plans/2026-05-10-evolution-roadmap.md`.
