# MBit · Smoke Test Suite

Validação rápida do SDK como um todo. Verifica:

1. Estrutura top-level (README, LICENSE, CHANGELOG, marketplace)
2. Manifestos JSON (marketplace, plugins, hooks, configs)
3. Scripts shell (sintaxe + permissões)
4. Skills com frontmatter válido
5. Comandos descobertos
6. Execução real de hooks bloqueantes (secret, destructive, PII, private-key) com payloads simulados — verifica exit 2 quando deve bloquear, exit 0 quando deve permitir
7. ASCII art presente
8. Achievements catalog
9. MCP allowlist
10. Documentação completa
11. Integrações (GHA, Slack)

## Como rodar

```bash
bash tests/smoke/run.sh
```

Exit code:
- `0` — tudo OK ou apenas avisos
- `1` — falhas (não release)

## Quando rodar

- Antes de cada release.
- Em CI a cada PR ao SDK (workflow `.github/workflows/mb-ai-checks.yml`).
- Após mudanças estruturais (novo plugin, novo hook, refator).

## Adicionar novos testes

Edite `tests/smoke/run.sh`. Padrão:

```bash
section "Nome da sessão"
if <condicao>; then t_pass "msg"; else t_fail "msg" "como corrigir"; fi
```
