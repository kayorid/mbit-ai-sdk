#!/usr/bin/env bash
# mb-retro / leaderboard.sh
# Leaderboard saudável: agrega por squad, nunca por pessoa.
# Argumento opcional: --period 30d|90d|365d (default 90d)

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/../mb-ai-core/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

PERIOD="${1:-90d}"
case "${1:-}" in
  --period) PERIOD="${2:-90d}" ;;
esac
case "$PERIOD" in
  30d|90d|365d) ;;
  *) PERIOD="90d" ;;
esac

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"
G="${C_GREEN:-\033[38;5;82m}"; A="${C_ACCENT:-\033[38;5;220m}"; I="${C_INFO:-\033[38;5;87m}"

printf "\n${P}${B}MBit · Leaderboard${R} ${D}— últimas $PERIOD, agregado por squad${R}\n"
printf "${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n\n"

# Mapeia período para argumento do git log
case "$PERIOD" in
  30d) SINCE="30 days ago" ;;
  90d) SINCE="90 days ago" ;;
  365d) SINCE="365 days ago" ;;
esac

# Top squads por diversidade de comandos (commits com [<categoria>:<slug>])
printf "${A}▸ Top 5 squads por diversidade de comandos${R}\n"
if git rev-parse --git-dir >/dev/null 2>&1; then
  git log --since="$SINCE" --pretty=format:'%s' 2>/dev/null \
    | grep -oE '\[(spec|impl|fix|review|sec|obs|cost|eval|retro|docs)' \
    | awk '{
        squad="all"
        if (match($0, /\[squad:[^]]+\]/)) squad=substr($0, RSTART+7, RLENGTH-8)
        cat=substr($0,2)
        key=squad"\t"cat
        seen[key]++
      }
      END {
        for (k in seen) {
          split(k, a, "\t")
          squad_div[a[1]]++
        }
        for (s in squad_div) print squad_div[s], s
      }' \
    | sort -rn | head -5 \
    | awk -v G="$G" -v R="$R" -v D="$D" '{printf "  %s%2d categorias%s  %s%s%s\n", G, $1, R, D, $2, R}'
else
  printf "  ${D}(repo sem git — pulado)${R}\n"
fi

# Top squads por retros realizadas
printf "\n${A}▸ Top 5 squads por retros realizadas${R}\n"
if [[ -d .mb/retros ]] || [[ -d docs/specs/_archive ]] || [[ -d docs/specs/_completed ]]; then
  {
    find .mb/retros -name '*.md' -type f 2>/dev/null
    find docs/specs/_archive -name 'retro.md' -type f 2>/dev/null
    find docs/specs/_completed -name 'retro*.md' -type f 2>/dev/null
  } | while read -r f; do
        # Heurística: tenta extrair squad do path ou do conteúdo
        squad=$(grep -m1 -E '^Squad:|^# .* — ' "$f" 2>/dev/null | sed -E 's/.*Squad:[[:space:]]*//;s/^# .* — //' | head -c 50)
        [[ -z "$squad" ]] && squad="(sem squad declarado)"
        echo "$squad"
      done | sort | uniq -c | sort -rn | head -5 \
        | awk -v G="$G" -v R="$R" -v D="$D" '{printf "  %s%2d retros%s  %s%s%s\n", G, $1, R, D, substr($0, index($0,$2)), R}'
else
  printf "  ${D}(sem retros ainda)${R}\n"
fi

# Achievements raros
printf "\n${A}▸ Conquistas mais raras desbloqueadas${R}\n"
if [[ -f .mb/achievements.json ]]; then
  jq -r '.unlocked[]? | "  ✦ \(.icon // "★") \(.name) (\(.unlocked_at | .[:10]))"' .mb/achievements.json 2>/dev/null \
    | head -5
  TOTAL=$(jq -r '.unlocked | length' .mb/achievements.json 2>/dev/null || echo 0)
  printf "  ${D}Total desbloqueado: %s${R}\n" "$TOTAL"
else
  printf "  ${D}(sem achievements registrados)${R}\n"
fi

printf "\n${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n"
printf "${D}Agregação por squad apenas. Nenhum dado pessoal é exibido.${R}\n\n"
