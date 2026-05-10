---
description: Lista as conquistas (achievements) do squad — desbloqueadas e ainda fechadas
---

# /mb-achievements

Mostra o painel de conquistas do squad.

## Comportamento

1. Rode o checker para detectar novos desbloqueios:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/achievements/checker.sh"
   ```
2. Leia `${CLAUDE_PLUGIN_ROOT}/achievements/definitions.json` (catálogo).
3. Leia `.mb/achievements.json` (estado do squad).
4. Apresente saída assim:

```
╔════════════════════════════════════════════════════════════════════╗
║              MB AI SDK · Conquistas do Squad                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  ✓ 🌱 Primeiro voo            (desbloqueado em 2026-04-20)         ║
║  ✓ 🛡 Defensor               (desbloqueado em 2026-04-25)         ║
║  ✓ 🎯 Ciclo completo          (desbloqueado em 2026-05-08)         ║
║                                                                    ║
║  ○ 🏆 Squad maduro            (3 ciclos / 0 exceções / 2 promoções)║
║  ○ 📋 Auditável               (faltam 2 ciclos completos)          ║
║  ○ 📖 Mestre de runbooks      (faltam 4 runbooks)                  ║
║                                                                    ║
║  Progresso: 3/12 desbloqueadas (25%)                               ║
╚════════════════════════════════════════════════════════════════════╝
```

5. Se houver achievement próximo do desbloqueio (>=70% do critério), destaque.
6. Anti-pattern: nunca compare entre devs do squad (achievements são de squad, não pessoais).
