#!/usr/bin/env bash
# mb-retro / adoption-report.sh
# Relatório de adoção corporativa do MBit AI SDK.
# Uso: adoption-report.sh [--period 30d|90d|365d] [--json]

set -uo pipefail

PERIOD="90d"
AS_JSON=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --period) PERIOD="${2:-90d}"; shift 2 ;;
    --json) AS_JSON=1; shift ;;
    *) shift ;;
  esac
done

case "$PERIOD" in
  30d) SINCE="30 days ago" ;;
  90d) SINCE="90 days ago" ;;
  365d) SINCE="365 days ago" ;;
  *) PERIOD="90d"; SINCE="90 days ago" ;;
esac

# Contagens
SQUADS_ACTIVE=0
TOP_COMMANDS=""
RETROS_RECENT=0
PLUGINS_USED=""

if git rev-parse --git-dir >/dev/null 2>&1; then
  # Squads ativos: commits únicos com [squad:X] no período
  SQUADS_ACTIVE=$(git log --since="$SINCE" --pretty=format:'%s' 2>/dev/null \
    | grep -oE '\[squad:[^]]+\]' | sort -u | wc -l | tr -d ' ')
  # Top 10 categorias de commit
  TOP_COMMANDS=$(git log --since="$SINCE" --pretty=format:'%s' 2>/dev/null \
    | grep -oE '^\[[a-z-]+(:[^]]+)?\]' \
    | sed -E 's/:.*//;s/\[|\]//g' \
    | sort | uniq -c | sort -rn | head -10)
fi

# Retros recentes
RETROS_RECENT=$({
  find .mb/retros -name '*.md' -type f -newer /tmp -mtime -90 2>/dev/null
  find docs/specs/_archive -name 'retro.md' -type f 2>/dev/null
} | wc -l | tr -d ' ')

# Plugins ativos (heurística por hooks executados em .mb/audit/hook-fires.log)
if [[ -f .mb/audit/hook-fires.log ]]; then
  PLUGINS_USED=$(grep -oE 'hook=[a-z-]+' .mb/audit/hook-fires.log 2>/dev/null \
    | sort -u | head -20)
fi

if [[ $AS_JSON -eq 1 ]]; then
  jq -n \
    --arg period "$PERIOD" \
    --arg squads "$SQUADS_ACTIVE" \
    --arg retros "$RETROS_RECENT" \
    --arg top "$TOP_COMMANDS" \
    --arg plugins "$PLUGINS_USED" \
    '{period:$period, squads_active:($squads|tonumber), retros_recent:($retros|tonumber), top_commands:$top, plugins_used:$plugins}'
  exit 0
fi

# Saída humana
if [[ -t 1 ]]; then
  P='\033[38;2;232;85;12m'; B='\033[1m'; D='\033[2m'; R='\033[0m'
  A='\033[38;5;220m'; G='\033[38;5;82m'
else
  P=''; B=''; D=''; R=''; A=''; G=''
fi

printf "\n${P}${B}MBit · Adoption Report${R} ${D}— últimas $PERIOD${R}\n"
printf "${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n\n"

printf "${A}▸ Squads ativos:${R} ${G}%s${R}\n" "$SQUADS_ACTIVE"
printf "${A}▸ Retros realizadas:${R} ${G}%s${R}\n" "$RETROS_RECENT"

printf "\n${A}▸ Top 10 categorias de commit${R}\n"
if [[ -n "$TOP_COMMANDS" ]]; then
  echo "$TOP_COMMANDS" | awk -v G="$G" -v R="$R" -v D="$D" '{printf "  %s%3d%s  %s%s%s\n", G, $1, R, D, $2, R}'
else
  printf "  ${D}(sem commits taggeados no período)${R}\n"
fi

printf "\n${A}▸ Plugins/hooks com atividade${R}\n"
if [[ -n "$PLUGINS_USED" ]]; then
  echo "$PLUGINS_USED" | sed 's/^/  /'
else
  printf "  ${D}(sem audit log de hooks)${R}\n"
fi

printf "\n${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n"
printf "${D}Para JSON consumível por dashboard, use --json${R}\n\n"
