---
description: Fase VERIFY — verificação goal-backward com evidência observável de que a feature atende os critérios EARS
argument-hint: <slug-da-feature>
---

# /mb-spec-verify

Conduza verificação goal-backward — não basta marcar tasks, precisa provar que o goal foi atingido:

1. Verifique EXECUTE aprovado.
2. Leia `requirements.md` e extraia todos os critérios EARS.
3. Para cada critério:
   - Identifique como provar que está atendido (teste automatizado, manual, comportamento observável, log, métrica).
   - Execute a verificação (rode testes, faça chamada manual, observe métrica).
   - Registre evidência em `verification.md`:
     ```
     ### Critério: <texto EARS>
     - **Como verificado:** <método>
     - **Evidência:** <output, screenshot, link, comando rodado>
     - **Status:** PASS | FAIL | PARTIAL
     ```
4. Identifique edge cases conhecidos do `requirements.md` e verifique cada um.
5. Identifique riscos técnicos do `design.md` e verifique mitigações.
6. **UAT (se aplicável):** conduza com stakeholder ou simule cenário de uso real.
7. Resuma no topo do `verification.md`:
   - Critérios totais: N
   - PASS: X
   - FAIL: Y
   - PARTIAL: Z
8. Se houver FAIL/PARTIAL inaceitável, retorne a EXECUTE com nova task.
9. Se tudo PASS, peça `/mb-approve VERIFY` e oriente seguir para REVIEW.

**Não declare "pronto" sem `verification.md` com PASS em todos os critérios obrigatórios.**
