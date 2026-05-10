---
description: Guia rotação de segredo vencido ou comprometido
argument-hint: <segredo-id-ou-descrição>
---

# /mb-secret-rotate

Conduza rotação de segredo:

1. **Classifique o segredo:**
   - Tipo (chave de API, certificado, credencial DB, chave cripto operacional, etc).
   - Tier de criticidade (cold/warm/hot, prod/staging).
   - Quem usa (lista de serviços/sistemas).
   - Como está armazenado (KMS, vault, env, hardcoded).
2. **Plano de rotação:**
   - Gerar novo segredo (CSPRNG, no sistema certo).
   - Distribuir para consumidores (rolling update, dual-secret window).
   - Validar funcionamento de cada consumidor com novo segredo.
   - Revogar/invalidar segredo antigo.
   - Verificar logs por uso pós-revogação (anomalia = ataque).
3. **Se foi comprometido:**
   - Tratar como incidente (`/mb-runbook-from-incident`).
   - Investigar uso anômalo.
   - Notificar partes afetadas conforme política.
   - Considerar notificação a ANPD/Bacen se LGPD/regulado.
4. **Documentar:**
   - Registrar rotação em `.mb/audit/security-events.log`.
   - Atualizar inventário de segredos.

**Nunca substitua um segredo "no quente" sem dual-secret window** — risco de derrubar serviço.
