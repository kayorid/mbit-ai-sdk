# v0.3.2 — Tasks

- [ ] T1 — Criar `plugins/mb-security/hooks/scripts/pre-write-guard.sh` agregando pii + private-key + secret-scan. Critério: exit 2 quando match, exit 0 quando limpo, <200ms para 10KB. [P]
- [ ] T2 — Atualizar `plugins/mb-security/hooks/hooks.json` Write|Edit → `pre-write-guard.sh`. Critério: smoke passa. [depende T1]
- [ ] T3 — Remover Write|Edit do `plugins/mb-ai-core/hooks/hooks.json` (secret-scan duplicado), manter pré-commit. Critério: completeness check ainda passa. [depende T2]
- [ ] T4 — Adicionar `strip_ansi()` em `session-start-banner.sh` e aplicar antes do `additionalContext`. Critério: payload contém zero `\033[`. [P]
- [ ] T5 — Adicionar warn explícito em `mcp-allowlist.sh` quando `jq` retornar erro. Critério: stderr contém "allowlist file corrupto". [P]
- [ ] T6 — Adicionar `head -c 102400` + regex ancorada em `private-key-scan.sh`. Critério: fixture de 1MB completa em <500ms. [P]
- [ ] T7 — Implementar cache em `achievements/checker.sh` com `cache_get`/`cache_put`/TTL 300s + invalidação por HEAD. Critério: segunda chamada consecutiva <100ms. [P]
- [ ] T8 — Criar `tests/e2e/run.sh` + fixtures em `tests/e2e/fixtures/`. Critério: ciclo completo <60s, exit 0. [depende T1-T7]
- [ ] T9 — Adicionar testes para CA-1..CA-6 em `tests/smoke/run.sh`. Critério: 95+ verificações OK.
- [ ] T10 — `[CHECKPOINT]` Bump versões: 9 plugins + marketplace.json para 0.3.2. Atualizar CHANGELOG.md, RELEASE-NOTES.md, MIGRATION.md.
- [ ] T11 — Rodar completeness + smoke + e2e; commit `feat: MBit v0.3.2 — cleanup técnico + E2E`. Tag `v0.3.2`.
