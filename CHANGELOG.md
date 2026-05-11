# Changelog

Todas as mudanças notáveis no MBit (MB AI SDK) serão documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/), versionamento semântico.

## [0.3.2] — 2026-05-11

### Corrigido
- **M-1 (REVIEW)** Hooks `PreToolUse Write|Edit` consolidados em **um único** `pre-write-guard.sh` em `mb-security`, que despacha para `pii-scan`, `private-key-scan` e `secret-scan` lendo o payload uma única vez. Reduz overhead de ~3 invocações shell separadas para 1.
- **mb-ai-core/hooks.json** deixa de interceptar `Write|Edit` (dedup); `secret-scan.sh` permanece neste plugin como referência standalone para debug.
- **achievements/checker.sh** corrige `unbound variable` quando array `unlocked_now` está vazio (regressão silenciosa que falhava em primeiro uso).

### Adicionado
- **`tests/e2e/run.sh`** — suite end-to-end nova: cria sandbox temporário, valida bootstrap, hooks reais contra payloads JSON, ciclo SDD (requirements/design/tasks), achievements checker + cache, banner SessionStart sem ANSI. 11 verificações em <5s.
- **Smoke suite** +7 testes para `pre-write-guard` e validação estrutural dos hooks consolidados (97 OK total, era 90).

### Planejamento
- **Specs SDD criadas** em `docs/specs/_active/` para v0.3.2, v0.5 e v1.0 — requirements + design + tasks completos.

## [0.3.1] — 2026-05-10

### Corrigido
- **Bug #1** `doctor.sh` lista hardcoded de plugins atualizada para incluir `mb-cost` e `mb-evals` (estava reportando-os como ausentes).
- **Bug #2** `/mb-help` reescrito para listar 9 plugins (era 7) + 50+ comandos por categoria.
- **Bug #3** `constitution.md` atualizada para v0.3.1 — menciona mb-cost, mb-evals, achievements, /mb-fast, regras sobre features AI em runtime e custo de IA.
- **Bug #4** `mb-evals-compare` agora é script bash real (`compare-eval.sh`) que faz join + diff de scores entre runs, não só doc.
- **Bug #5** `mb-sdd` integra `mb-evals` na fase VERIFY — features AI exigem `/mb-evals-ci` antes de aprovação.

### Adicionado
- **`/mb-version`** — mostra versões de todos os plugins MBit + dependências do sistema (jq, git, bash) com status de sincronização.
- **`/mb-list-plugins`** — lista plugins MBit ativados em `~/.claude/settings.json`.
- **4 achievements novos para v0.3:** `first-eval-run`, `fast-mode-unlocked`, `theme-customizer`, `compliance-aware`. Total agora: **16 conquistas**.
- **`tests/completeness-check.sh`** — script de garantia que valida 154+ itens (plugins, comandos, skills, ASCII, hooks, scripts, docs, integrações, achievements, versões sincronizadas). Loop iterativo até zero falhas.
- **Dashboard upgrade** — agora mostra evals configurados, runs total, custo IA, status do modo `/mb-fast`.

### MEDIUMs do REVIEW corrigidos
- **M-1** Documentado em `mb-security/hooks/hooks.json` que Write/Edit overlap com `mb-ai-core/secret-scan` é intencional (responsabilidades distintas) — consolidação planejada para v0.5.
- **M-3** `mcp-allowlist.sh` valida JSON do allowlist antes de parsing; mensagem de WARN explícita se corrompido.
- **M-4** Truncamento de SQUAD via `jq -Rr '.[0:N]'` (UTF-8 safe) em vez de `head -c`. Funciona com nomes acentuados.
- **M-7** `achievements/checker.sh` agora cacheia `last_evaluated_at` em `.mb/achievements.json` — re-avalia apenas a cada 5 min (override via `MB_FORCE_ACHIEVEMENT_CHECK`). Evita custo em monorepos.
- **M-9** `stop-farewell.sh` emite tanto stderr (CLI) quanto `additionalContext` (Cursor/IDEs que filtram stderr).

### Atualizado
- `MANUAL.md` — adendos v0.2 e v0.3 com mb-cost, achievements, identidade visual, mb-evals, comandos novos, suite de testes, governança.
- `PRESENTATION.md` — slide 7 atualizado para 9 plugins.
- `docs/playbooks/install-by-role.md` — `/mb-init` wizard, `mb-cost`/`mb-evals` no JSON de exemplo.
- `docs/faq.md` — 11 perguntas novas sobre features v0.2/v0.3.
- `mcp-allowlist.json` — versão bumped para 0.3.1, `review_cycle` documentado.

### Bumpado
- Todos os 9 plugins de `0.3.0` para `0.3.1` (sincronizado em marketplace + plugin.json).

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
