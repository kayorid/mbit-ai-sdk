#!/usr/bin/env bash
# mb-evals / scripts / compare-eval.sh
# A/B test entre duas runs de eval.

set -euo pipefail

FEATURE="${1:-}"
RUN_A="${2:-}"
RUN_B="${3:-}"

if [[ -z "$FEATURE" || -z "$RUN_A" || -z "$RUN_B" ]]; then
  echo "Uso: compare-eval.sh <feature> <run-a> <run-b>"
  echo "Ex:  compare-eval.sh chatbot 2026-05-10T1430-claude-opus 2026-05-10T1500-claude-sonnet"
  exit 1
fi

DIR="evals/$FEATURE/runs"
A_FILE="$DIR/${RUN_A}.jsonl"
B_FILE="$DIR/${RUN_B}.jsonl"

[[ ! -f "$A_FILE" ]] && { echo "Run A não encontrada: $A_FILE"; exit 1; }
[[ ! -f "$B_FILE" ]] && { echo "Run B não encontrada: $B_FILE"; exit 1; }

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/../mb-ai-core/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"
S="${C_SUCCESS:-}"; W="${C_WARN:-}"; DG="${C_DANGER:-}"

printf "\n${P}${B}MBit Evals · A/B Compare${R} ${D}— ${FEATURE}${R}\n"
printf "${D}A:${R} %s\n${D}B:${R} %s\n\n" "$RUN_A" "$RUN_B"

printf "${B}%-12s  %8s  %8s  %8s${R}\n" "ID" "A" "B" "Δ"
printf "${D}─────────────────────────────────────────────${R}\n"

REGRESS=0; IMPROVE=0; SAME=0

# Join by id, compare scores
join -j 2 \
  <(jq -r '.id+" "+(.score|tostring)' "$A_FILE" 2>/dev/null | sort) \
  <(jq -r '.id+" "+(.score|tostring)' "$B_FILE" 2>/dev/null | sort) \
  | while read -r id score_a score_b; do
    delta=$(awk "BEGIN { printf \"%+.2f\", $score_b - $score_a }")
    sign=$(awk "BEGIN { d=$score_b-$score_a; if(d>0.01) print \"up\"; else if(d<-0.01) print \"down\"; else print \"same\" }")
    case "$sign" in
      up)   COLOR="$S" ;;
      down) COLOR="$DG" ;;
      *)    COLOR="$D" ;;
    esac
    printf "  %-12s  %8s  %8s  ${COLOR}%8s${R}\n" "$id" "$score_a" "$score_b" "$delta"
  done

printf "\n${D}Outliers (|Δ| > 0.3) merecem investigação manual.${R}\n\n"
