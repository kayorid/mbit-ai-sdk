# v0.3.2 — Design técnico

## Arquitetura

Sem mudança estrutural. Apenas:
1. Consolidação de hooks Write|Edit num único `pre-write-guard.sh` em `mb-security`.
2. Banner SessionStart com função `strip_ansi()` antes de emitir `additionalContext`.
3. Cache de achievements em `.mb/achievements.json` com `last_evaluated_at` (epoch).
4. Input cap em `private-key-scan.sh` via `head -c 102400`.
5. Warn explícito em `mcp-allowlist.sh` quando `jq` falha.
6. Suite E2E nova em `tests/e2e/run.sh`.

## Mudanças por arquivo

| Arquivo | Mudança |
|---|---|
| `plugins/mb-security/hooks/scripts/pre-write-guard.sh` | **novo** — agrega pii + private-key + secret-scan |
| `plugins/mb-security/hooks/hooks.json` | Write\|Edit aponta para `pre-write-guard.sh` |
| `plugins/mb-ai-core/hooks/hooks.json` | remove Write\|Edit (secret-scan), mantém pré-commit |
| `plugins/mb-ai-core/hooks/scripts/session-start-banner.sh` | adiciona `strip_ansi` antes do `additionalContext` |
| `plugins/mb-ai-core/hooks/scripts/mcp-allowlist.sh` | log warn se `jq` falhar |
| `plugins/mb-security/hooks/scripts/private-key-scan.sh` | `head -c 102400` no input + regex ancorada |
| `plugins/mb-ai-core/achievements/checker.sh` | função `cache_get/cache_put` com TTL 300s |
| `tests/e2e/run.sh` | **novo** — ciclo end-to-end |
| `tests/e2e/fixtures/dummy-repo/` | **novo** — repo mock |
| `tests/smoke/run.sh` | novos testes para cada CA |
| `tests/completeness-check.sh` | atualiza contadores se necessário |
| `CHANGELOG.md` | seção v0.3.2 |
| `plugins/*/plugin.json` + `.claude-plugin/marketplace.json` | bump 0.3.1 → 0.3.2 |

## Contratos

### `pre-write-guard.sh`
- **Input:** JSON via stdin (PreToolUse payload).
- **Output:** exit 0 (allow) ou exit 2 + stderr (block) com motivo.
- **Latência alvo:** <200ms para 10KB payload.

### Cache de achievements
- **Path:** `.mb/achievements.json`
- **Schema:** `{"last_evaluated_at": <epoch>, "ttl_seconds": 300, "metrics": {...}, "unlocked": [...]}`
- **Invalidação:** se `now - last_evaluated_at > ttl_seconds` OU se `git log -1 --format=%H` mudou desde último cache.

### E2E suite
- **Diretório temporário:** `mktemp -d` no início, `trap rm -rf $TMP EXIT`.
- **Etapas:**
  1. Init: copia plugins para `$TMP/.claude/plugins/`
  2. Bootstrap: invoca `scripts/bootstrap.sh` simulando squad
  3. Spec: cria stub `docs/specs/_active/teste/requirements.md`
  4. Implement: roda hook PreToolUse com payload válido
  5. Retro: invoca `retro.sh` e checa `.mb/retros/*.md` criado
  6. Validate: `bash tests/smoke/run.sh` dentro do dummy
- **Limpeza:** cleanup garantido via trap.

## Riscos

- Mudar `hooks.json` de mb-ai-core pode quebrar usuários já instalados em v0.3.1. **Mitigação:** documentar em CHANGELOG + MIGRATION.md, manter comportamento equivalente.
- Cache mal invalidado pode esconder novos achievements. **Mitigação:** TTL curto (5min) + checksum de HEAD.
- ReDoS fix pode falsos-negativos em payloads legítimos. **Mitigação:** smoke test com fixture de chave privada real (test fixture, não real).

## Alternativas consideradas

- Reescrever hooks em Go/Rust → over-engineering para v0.3.2.
- Mover cache para Redis local → complica deploy, descartado.
