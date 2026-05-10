---
description: Aprofunda glossário e contexto de domínio do squad
---

# /mb-enrich-domain

Conduza missão de enriquecimento de domínio:

1. Liste conceitos atuais em `.mb/glossary.md` e identifique os mais "rasos" (apenas 1 frase, sem contexto, sem exemplos).
2. Para cada conceito raso (até 5 por sessão):
   - Pergunte ao usuário: "explique esse conceito como se eu fosse novo no squad" e capture exemplos práticos.
   - Identifique no código onde o conceito aparece (grep por termo).
   - Atualize a entrada no glossário com explicação rica + 2-3 exemplos de código + sistemas relacionados.
3. Identifique 2-3 conceitos **ausentes** mas mencionados no código (grep por termos repetidos não-óbvios) e proponha incluí-los.
4. Atualize `.mb/glossary.md` e crie commit:
   ```
   git commit -m "[mb-enrich-domain] aprofunda glossário do squad"
   ```

Tempo esperado: 30-45 min por sessão.
