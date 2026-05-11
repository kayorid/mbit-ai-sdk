# Migration Guide — MBit

Guia de migração entre versões do MBit. Atualize na ordem recomendada (não pule majors).

---

## v0.2 → v0.3

**Tipo:** minor — sem breaking changes.

### O que muda

- **Plugin novo `mb-evals@0.3.0`** — eval framework para features que usam IA em runtime. Opt-in.
- **Comandos novos no core:** `/mb-init`, `/mb-fast`, `/mb-theme`, `/mb-search`, `/mb-new-skill`.
- **`/mb-bootstrap-rescan`** agora cria snapshot automático antes de modificar.
- **`/mb-retro-digest`** — resumo das últimas N retros.
- **CI próprio do SDK** — `.github/workflows/sdk-ci.yml` rodando smoke tests em todo PR.
- **Governança open-source** — `CONTRIBUTING.md`, `SECURITY.md`, issue templates, PR template.
- **Refresh dos docs principais** (README, MANUAL, PRESENTATION) — features novas listadas.

### Como migrar

1. **Squads que já estão na v0.2:**
   ```
   /mb-update
   ```
   - Reinicie Claude Code.
   - Rode `/mb-doctor` para validar.

2. **Squads que querem mb-evals:**
   - Adicione ao `~/.claude/settings.json`:
     ```json
     "mb-evals@mb": true
     ```
   - Reinicie.
   - Para começar: `/mb-evals-init <feature-ai>`.

3. **Squads que querem destravar `/mb-fast`:**
   - Rode `/mb-fast` — vai verificar critérios de maturidade.
   - Se passar, `/mb-fast` fica disponível.

### O que NÃO muda

- Plugin.json IDs e marketplace path.
- Layout de `.mb/`.
- Convenção de commits.
- Hooks bloqueantes existentes (apenas refinados).

---

## v0.1 → v0.2

**Tipo:** minor com correções importantes.

### O que muda

- **Identidade visual MBit** — paleta laranja MB oficial, ASCII hexagonal, statusline custom, banner SessionStart.
- **Plugin novo `mb-cost@0.2.0`** — captura de tokens.
- **Comandos novos no core:** `/mb-doctor`, `/mb-snapshot`, `/mb-dashboard`, `/mb-tutorial`, `/mb-update`, `/mb-banner`, `/mb-ascii`, `/mb-achievements`.
- **Achievement system** — 12 conquistas com notify hook em Stop.
- **Hooks de UX** — SessionStart, Stop, Notification.
- **Suite de smoke tests** em `tests/smoke/run.sh`.

### Bugs críticos corrigidos (atualize)

- **B-3:** hooks de PII e chave privada agora bloqueiam de fato (regex Perl `(?:)` corrigida para ERE).
- **B-4:** cost-capture overhead — curto-circuito antes de jq.
- **B-2:** cost-report.sh `unbound variable: FEAT`.
- **`grep` vs `ugrep`:** todas chamadas usam `grep -e --` agora.
- **`gawk asorti`:** removido em favor de iteração POSIX.

### Como migrar

1. Atualize `~/.claude/settings.json` para incluir `mb-cost@mb`.
2. Rode `/mb-update` (após v0.2 estar instalada manualmente).
3. Rode `/mb-doctor`.
4. Squad já bootstrapado não precisa rerun de `/mb-bootstrap` — `.mb/CLAUDE.md` continua válido.

---

## Convenções gerais de migração

- **Sempre** rode `/mb-snapshot create` antes de upgrade major.
- **Sempre** rode `/mb-doctor` após upgrade.
- **Major bump** (X.0.0) tem janela de migração de 30 dias documentada — squads recebem aviso prévio.
- **Comandos depreciados** mostram aviso por 1 minor antes de serem removidos.

## Versões em manutenção

| Versão | Suporte | Patches de segurança | Patches de bug |
|--------|:-------:|:--------------------:|:--------------:|
| 0.3.x  | ✓ ativo | ✓                    | ✓              |
| 0.2.x  | ✗       | ✗ — atualize          | ✗              |
| 0.1.x  | ✗       | ✗ — atualize          | ✗              |

## Em caso de problema

1. **Rollback:** `/mb-snapshot list` → `/mb-snapshot restore <name>`.
2. **Diagnóstico:** `/mb-doctor`.
3. **Suporte:** `#mb-ai-sdk` no Slack ou issue no repo.
