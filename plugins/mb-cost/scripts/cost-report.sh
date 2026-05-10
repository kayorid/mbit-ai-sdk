#!/usr/bin/env bash
# mb-cost / cost-report
# Gera relatório de custo agregado.
# Uso: cost-report.sh [day|week|month|feature <slug>]

set -euo pipefail

# Inicializa todas as vars que awk pode receber, evitando "unbound variable" (B-2)
FEAT=""
SINCE=""
LABEL=""

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/../mb-ai-core/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

LOG=".mb/audit/cost.log"

if [[ ! -f "$LOG" ]]; then
  echo "Sem dados de custo capturados ainda. Hook captura automaticamente conforme uso."
  exit 0
fi

# Estimativa de preço (USD/MTok) — ajustar para preços vigentes
# Fonte de verdade: time financeiro MB
PRICE_IN_PER_MTOK="${MB_PRICE_IN:-3.00}"   # USD por 1M input tokens (Opus padrão)
PRICE_OUT_PER_MTOK="${MB_PRICE_OUT:-15.00}" # USD por 1M output tokens
USD_BRL="${MB_USD_BRL:-5.30}"               # cotação aproximada

MODE="${1:-week}"
case "$MODE" in
  day)
    SINCE=$(date -u +%Y-%m-%d)
    LABEL="hoje"
    ;;
  week)
    SINCE=$(date -u -v-7d +%Y-%m-%d 2>/dev/null || date -u -d "7 days ago" +%Y-%m-%d 2>/dev/null)
    LABEL="últimos 7 dias"
    ;;
  month)
    SINCE=$(date -u -v-30d +%Y-%m-%d 2>/dev/null || date -u -d "30 days ago" +%Y-%m-%d 2>/dev/null)
    LABEL="últimos 30 dias"
    ;;
  feature)
    FEAT="${2:-}"
    [[ -z "$FEAT" ]] && { echo "Uso: cost-report.sh feature <slug>"; exit 1; }
    SINCE="0000-00-00"
    LABEL="feature ${FEAT}"
    ;;
  *)
    echo "Uso: cost-report.sh [day|week|month|feature <slug>]"
    exit 1
    ;;
esac

# Filtragem
FILTER_AWK='$1 >= since'
[[ "$MODE" == "feature" ]] && FILTER_AWK='$0 ~ ("feature=" feat)'

# Agregação por fase
P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"; I="${C_INFO:-}"
echo ""
echo -e "${P}${B}MBit · Custo de IA · ${LABEL}${R}"
echo -e "${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
printf "%-12s %12s %12s %10s %10s\n" "Fase" "In tokens" "Out tokens" "USD" "BRL"
echo -e "${D}─────────────────────────────────────────────────────────────${R}"

awk -F'|' -v since="$SINCE" -v feat="$FEAT" -v pin="$PRICE_IN_PER_MTOK" -v pout="$PRICE_OUT_PER_MTOK" -v rate="$USD_BRL" '
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
  function getfield(line, key) {
    n = split(line, parts, "|")
    for (i=1; i<=n; i++) {
      kv = trim(parts[i])
      if (substr(kv, 1, length(key)+1) == key"=") {
        return substr(kv, length(key)+2)
      }
    }
    return ""
  }
  {
    ts = trim($1)
    if (ts < since) next
    if (feat != "" && getfield($0, "feature") != feat) next

    phase = getfield($0, "phase")
    in_t = getfield($0, "in_tokens") + 0
    out_t = getfield($0, "out_tokens") + 0

    in_sum[phase] += in_t
    out_sum[phase] += out_t
    total_in += in_t
    total_out += out_t
  }
  END {
    # Sem asorti (gawk-only) — itera direto e conta entradas
    n = 0
    for (p in in_sum) {
      n++
      usd = (in_sum[p] / 1000000.0) * pin + (out_sum[p] / 1000000.0) * pout
      brl = usd * rate
      printf "  %-10s %12d %12d  $%8.2f R$%8.2f\n", p, in_sum[p], out_sum[p], usd, brl
    }
    if (n > 0) {
      total_usd = (total_in / 1000000.0) * pin + (total_out / 1000000.0) * pout
      printf "  ─────────────────────────────────────────────────────────\n"
      printf "  %-10s %12d %12d  $%8.2f R$%8.2f\n", "TOTAL", total_in, total_out, total_usd, total_usd * rate
    } else {
      print "  Nenhum evento encontrado para o período/feature."
    }
  }
' "$LOG"

echo ""
echo -e "${D}Preços: input \$$PRICE_IN_PER_MTOK/MTok · output \$$PRICE_OUT_PER_MTOK/MTok · USD→BRL R$$USD_BRL${R}"
echo -e "${D}Ajuste via env: MB_PRICE_IN, MB_PRICE_OUT, MB_USD_BRL${R}"
echo ""
