# Política de Segurança — MBit

## Reportando uma vulnerabilidade

O MBit lida com hooks bloqueantes em ambiente de desenvolvimento de uma exchange cripto regulada. Vulnerabilidades têm impacto potencial sério (vazamento de segredos, bypass de proteções, falha em auditoria regulatória).

### Como reportar

**Não abra issue público.** Use um destes canais:

1. **Email:** `security@mercadobitcoin.com.br` (cópia: `chapter-ai@mercadobitcoin.com.br`)
2. **GitHub Security Advisory:** [github.com/kayorid/mbit-ai-sdk/security/advisories/new](https://github.com/kayorid/mbit-ai-sdk/security/advisories/new)

### O que incluir

- Descrição clara da vulnerabilidade.
- Passos para reproduzir.
- Impacto potencial (qual proteção é bypassada, qual dado pode vazar).
- Versão do MBit e ambiente (OS, shell, jq version).
- Sugestão de fix se tiver.

### O que esperar

- **Confirmação** em até 48h úteis.
- **Análise inicial** em até 5 dias úteis.
- **Correção** prazos por severidade:
  - Crítica (RCE, bypass total de hook bloqueante): patch em 7 dias.
  - Alta (bypass de regra específica, leak parcial): 14 dias.
  - Média/baixa: próxima minor.
- **CVE/advisory** publicado após correção, com crédito ao reportador (se desejar).

## Escopo

### Em escopo
- Bypass de hooks bloqueantes (secret-scan, pii-scan, private-key-scan, mcp-allowlist, destructive-confirm).
- Vazamento de dados via audit logs.
- Race conditions que corrompam audit trail.
- Injeção via payload de hook.
- Privilege escalation via comandos `/mb-*`.
- Vulnerabilidades em scripts shell (command injection, path traversal).

### Fora de escopo
- Vulnerabilidades no Claude Code (reporte para Anthropic).
- Vulnerabilidades em MCPs externos (reporte para o publisher).
- Vulnerabilidades em dependências de sistema (jq, bash, git) — exceto se uso pelo MBit cria nova superfície.
- DOS via consumo de tokens (não é nosso threat model).
- Ataques físicos ao desenvolvedor.

## Princípios

- **Não temos bug bounty financeiro** (este é um projeto interno corporativo MB).
- **Crédito público** ao pesquisador é dado (se desejar).
- **Transparência pós-fix** — advisory público com lições aprendidas.
- **Sem represália** — pesquisadores responsáveis nunca terão problema legal por reportar dentro deste processo.

## Versões suportadas

Apenas versão `0.x` mais recente recebe patches de segurança.

| Versão | Suporte |
|--------|:-------:|
| 0.3.x  | ✓ ativa |
| 0.2.x  | ✗ — atualize |
| 0.1.x  | ✗ — atualize |

## Hardening recomendado para usuários

1. Rode `/mb-doctor` periodicamente.
2. Mantenha SDK atualizado: `/mb-update`.
3. Não desabilite hooks de SEGURANÇA via edição manual de `.mb/config.yaml`.
4. Se hook bloquear trabalho legítimo, abra `/mb-exception` (registrado em audit-trail) — não force bypass.
5. Revise `.mb/audit/security-events.log` semanalmente.
6. Use `git push --force-with-lease` em vez de `--force`.
