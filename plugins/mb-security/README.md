# mb-security

Rigor de segurança específico para uma exchange cripto. Threat modeling estruturado, compliance regulatório, padrões cripto e hooks bloqueantes para PII e chaves privadas.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `/mb-threat-model` | Threat model STRIDE para a feature corrente |
| `/mb-security-checklist` | Checklist específico cripto (chaves, custódia, transações, MFA) |
| `/mb-compliance-check <regulação>` | Verifica conformidade (`bacen`, `cvm`, `lgpd`, `travel-rule`, `pci`) |
| `/mb-secret-rotate` | Guia rotação de segredos vencidos ou comprometidos |

## Skills

- `mb-threat-modeler` — conduz threat modeling STRIDE estruturado.
- `mb-compliance-advisor` — conhece exigências regulatórias brasileiras de exchange.
- `mb-crypto-advisor` — orienta sobre BIP, gestão de chaves, custódia, multisig.

## Hooks bloqueantes (categoria SEGURANÇA — sempre bloqueiam)

- `pre-tool-pii-scan` — bloqueia escrita de PII brasileira (CPF, CNPJ, RG, dados bancários) em arquivo não-marcado como teste.
- `pre-tool-private-key-scan` — bloqueia escrita de qualquer formato de chave privada.

## Saídas

- `docs/specs/_active/<feature>/THREAT-MODEL.md`
- `docs/specs/_active/<feature>/SECURITY.md`
- `.mb/audit/security-events.log`
