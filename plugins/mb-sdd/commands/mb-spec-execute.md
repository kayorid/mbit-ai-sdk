---
description: Fase EXECUTE — implementa tasks com commits atômicos referenciando a spec
argument-hint: <slug-da-feature> [task-id]
---

# /mb-spec-execute

Execute as tasks da fase PLAN com disciplina:

1. Verifique PLAN aprovado.
2. Leia `tasks.md` e identifique a próxima task pendente (ou a especificada via argumento).
3. **Para cada task:**
   - Marque `[ ]` → `[~]` (em andamento) em `tasks.md`.
   - Implemente o código.
   - Atualize testes (TDD encorajado: teste primeiro quando possível).
   - Verifique que o critério de pronto da task está atendido.
   - Marque `[~]` → `[x]` em `tasks.md`.
   - Crie commit atômico:
     ```
     git add <arquivos-da-task>
     git commit -m "[spec:<slug>] T-<N>: <descrição da task>"
     ```
   - Anexe linha em `execution.log`:
     ```
     <ISO-DATE> | T-<N> | commit=<sha> | actor=<email>
     ```
4. **Pause em batches:** após 3-5 tasks ou ao terminar todas, peça revisão humana.
5. Quando todas as tasks estiverem `[x]`, peça `/mb-approve EXECUTE` e oriente seguir para `/mb-spec-verify`.

**Regras importantes:**
- Não pule tasks sem `/mb-exception`.
- Não mude escopo no meio do execute — abra nova task ou retorne a PLAN.
- Hooks de segurança bloqueiam segredos; respeite-os.
- Commits sem referência à spec (`[spec:...]`) podem ser bloqueados.
