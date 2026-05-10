---
description: Abre exceção formal a uma regra bloqueante do MB AI SDK — gera issue, registra em audit-trail e aciona aprovação do Chapter AI
argument-hint: <regra> <justificativa>
---

# /mb-exception

Abre exceção formal a uma regra bloqueante do SDK. Use quando uma regra de SEGURANÇA ou COMPLIANCE precisa ser temporariamente flexibilizada por motivo legítimo (ex: pentest interno, integração com sistema legado, hotfix crítico).

## Quando usar

- Hook bloqueante está impedindo trabalho legítimo.
- Necessidade comprovada de usar MCP fora da allowlist.
- Pular fase do ciclo SDD por razão excepcional.
- Aceitar PII em arquivo de teste por motivo justificado.

## Comportamento

1. **Colete contexto:**
   - Qual regra/hook está sendo flexibilizada?
   - Justificativa de negócio (não-técnica é insuficiente).
   - Escopo (qual feature, qual arquivo, qual período).
   - Prazo de validade da exceção (data limite).
   - Plano de mitigação (como reduzir o risco enquanto a exceção vigora).

2. **Identifique o solicitante** (`git config user.email`).

3. **Grave em `.mb/audit/exceptions.log`:**
   ```
   2026-05-10T14:32:11Z | rule=<regra> | actor=<email> | scope=<escopo> | expires=<data> | status=PENDING | reason="<justificativa>"
   ```

4. **Crie issue no GitHub** (`gh issue create`):
   - Título: `[mb-exception] <regra> — <feature>`
   - Labels: `mb-exception`, `needs-chapter-ai-review`
   - Body: justificativa, escopo, prazo, plano de mitigação, link para spec relacionada.

5. **Notifique:**
   ```
   ⚠ Exceção registrada como PENDENTE
     Regra: <regra>
     Issue: <url>
     Aprovação necessária do Chapter AI antes da regra ser flexibilizada para você.
     Tempo estimado: 1-3 dias úteis.
   ```

6. **Não desabilite a regra automaticamente.** A flexibilização só ocorre após aprovação manual do Chapter AI, que então edita `.mb/config.yaml` ou allowlist do squad.

## Restrições

- Exceção sem justificativa de negócio é rejeitada.
- Exceção sem prazo de validade é rejeitada (max 90 dias).
- Exceção sem plano de mitigação é rejeitada.
- Exceções a regras de SEGURANÇA crítica (chave privada, segredo de produção) **não são aceitas em hipótese alguma** — oriente abrir incidente em vez disso.
