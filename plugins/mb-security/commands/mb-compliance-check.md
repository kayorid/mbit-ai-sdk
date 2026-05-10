---
description: Verifica conformidade da feature/sistema com regulação específica
argument-hint: <bacen|cvm|lgpd|travel-rule|pci> [feature-slug]
---

# /mb-compliance-check

Invoque a skill `mb-compliance-advisor` e conduza check para a regulação especificada:

- `bacen` — Resolução 4.658, 4.893, marco legal de cripto.
- `cvm` — Resolução 35 (criptoativos como VM).
- `lgpd` — Lei 13.709 (proteção de dados).
- `travel-rule` — FATF R.16 + IN BCB.
- `pci` — PCI-DSS (se aceita cartão).

Para cada requisito aplicável, classifique status (atende / parcial / não atende) com evidência. Lacunas críticas viram tasks BLOCK.

Documente em `docs/specs/_active/<feature>/COMPLIANCE.md` ou seção do `SECURITY.md`.

Para dúvidas de interpretação ou impacto regulatório real, sempre envolva Compliance/Jurídico MB.
