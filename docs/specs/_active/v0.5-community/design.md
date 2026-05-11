# v0.5 — Design técnico

## Arquitetura

Sem novo plugin. Estende `mb-retro` com 2 comandos e adiciona docs de governança/playbook.

```
plugins/mb-retro/
├── commands/
│   ├── mb-leaderboard.md       (novo)
│   └── mb-retro-quarterly.md   (novo)
└── scripts/
    ├── leaderboard.sh          (novo)
    ├── retro-quarterly.sh      (novo)
    └── lib/
        ├── retro-reader.sh     (novo — shared)
        └── newsletter-html.sh  (novo)
docs/
├── governance/
│   └── ai-champions.md         (novo)
├── playbooks/
│   └── ai-lab.md               (novo)
├── plugins/
│   └── opt-in-guide.md         (novo)
└── newsletter/                 (target — gerado por retro-quarterly)
    └── .gitkeep
```

## Contratos

### `/mb-leaderboard`
- **Args:** `--period <30d|90d|365d>` (default 90d)
- **Output:** terminal table com 3 seções: squads por diversidade, squads por retros, conquistas raras.
- **Dados:** lê `git log --since=$PERIOD` para `[squad:X]` commits; lê `.mb/retros/*.md` para contagem; lê `.mb/achievements.json` para raridade.

### `/mb-retro-quarterly`
- **Args:** `--quarter <YYYY-QN>` (default: trimestre atual)
- **Output:** escreve `docs/newsletter/<YYYY-QN>.md` + `.html`.
- **Geração HTML:** template embedded em `newsletter-html.sh` com placeholders `{{title}}`, `{{highlights}}`, `{{champions}}`.

### `retro-reader.sh` (lib)
- `read_retros_since <epoch>` → lista de paths de retros
- `extract_highlights <path>` → linhas que começam com "## Highlight" ou "✨"

## Mudanças por arquivo

| Arquivo | Mudança |
|---|---|
| `plugins/mb-retro/commands/mb-leaderboard.md` | **novo** |
| `plugins/mb-retro/commands/mb-retro-quarterly.md` | **novo** |
| `plugins/mb-retro/scripts/leaderboard.sh` | **novo**, executável |
| `plugins/mb-retro/scripts/retro-quarterly.sh` | **novo**, executável |
| `plugins/mb-retro/scripts/lib/retro-reader.sh` | **novo** |
| `plugins/mb-retro/scripts/lib/newsletter-html.sh` | **novo** |
| `docs/governance/ai-champions.md` | **novo** |
| `docs/playbooks/ai-lab.md` | **novo** |
| `docs/plugins/opt-in-guide.md` | **novo** |
| `docs/newsletter/.gitkeep` | **novo** |
| `plugins/mb-ai-core/commands/mb-help.md` | adiciona refs aos 2 novos comandos |
| `tests/smoke/run.sh` | testes para CA-1..CA-6 |
| `tests/completeness-check.sh` | +2 comandos, +3 docs, +4 scripts |
| `CHANGELOG.md`, `RELEASE-NOTES.md` | seção v0.5.0 |
| `plugins/*/plugin.json` + marketplace | bump 0.3.2 → 0.5.0 |

## Riscos

- Leaderboard agregando dados pode expor padrões individuais por dedução. **Mitigação:** mínimo 3 commits por squad para aparecer; squads <3 commits agrupados como "outros".
- Newsletter automática vira spam se rodada com frequência demais. **Mitigação:** doc explícita "rodar 1x por trimestre", sem cron automático.
- Charter da comunidade pode ficar desatualizado. **Mitigação:** seção "Revisão semestral" no próprio doc.

## Alternativas consideradas

- Plugin separado `mb-community` → over-engineering; comandos pertencem ao domínio de retro.
- Newsletter via MJML → dependência extra; HTML manual basta para v0.5.
