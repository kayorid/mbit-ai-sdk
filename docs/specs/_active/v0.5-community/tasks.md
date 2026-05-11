# v0.5 — Tasks

- [ ] T1 — Criar `plugins/mb-retro/scripts/lib/retro-reader.sh`. Critério: `read_retros_since` retorna lista correta em fixture. [P]
- [ ] T2 — Criar `plugins/mb-retro/scripts/lib/newsletter-html.sh`. Critério: gera HTML válido com inline CSS. [P]
- [ ] T3 — Criar `leaderboard.sh` + `commands/mb-leaderboard.md`. Critério: roda em repo dummy, output não-vazio, sem PII. [depende T1]
- [ ] T4 — Criar `retro-quarterly.sh` + `commands/mb-retro-quarterly.md`. Critério: gera `.md` + `.html` em `docs/newsletter/`. [depende T1, T2]
- [ ] T5 — Escrever `docs/governance/ai-champions.md` com 6 seções (charter, elegibilidade, indicação, cadência, RACI, revisão). [P]
- [ ] T6 — Escrever `docs/playbooks/ai-lab.md` com 6 trilhas iniciais (SDD, observability, security, cost, eval, retro). [P]
- [ ] T7 — Escrever `docs/plugins/opt-in-guide.md` comparando mb-evals e mb-cost. [P]
- [ ] T8 — Criar `docs/newsletter/.gitkeep`. [P]
- [ ] T9 — Atualizar `/mb-help` referenciando os 2 comandos novos. [depende T3, T4]
- [ ] T10 — Adicionar testes para CA-1..CA-6 em `tests/smoke/run.sh` e atualizar completeness-check.
- [ ] T11 — `[CHECKPOINT]` Bump versões 0.3.2 → 0.5.0 em 9 plugins + marketplace. Atualizar CHANGELOG + RELEASE-NOTES.
- [ ] T12 — Rodar completeness + smoke + e2e; commit `feat: MBit v0.5.0 — comunidade & workshops`. Tag `v0.5.0`.
