#!/usr/bin/env bash
# mb-retro / newsletter.sh
# Gera newsletter trimestral em Markdown + HTML a partir das retros recentes.
# Output: docs/newsletter/<YYYY-QN>.md e docs/newsletter/<YYYY-QN>.html

set -uo pipefail

# Trimestre alvo (default: trimestre atual)
QUARTER="${1:-}"
if [[ -z "$QUARTER" ]]; then
  Y=$(date +%Y)
  M=$(date +%m | sed 's/^0//')
  Q=$(( (M - 1) / 3 + 1 ))
  QUARTER="${Y}-Q${Q}"
fi

OUT_DIR="docs/newsletter"
mkdir -p "$OUT_DIR"
MD="$OUT_DIR/${QUARTER}.md"
HTML="$OUT_DIR/${QUARTER}.html"

# Coleta retros do trimestre (heurística simples por data de modificação)
case "$QUARTER" in
  *-Q1) FROM_MONTH=1; TO_MONTH=3 ;;
  *-Q2) FROM_MONTH=4; TO_MONTH=6 ;;
  *-Q3) FROM_MONTH=7; TO_MONTH=9 ;;
  *-Q4) FROM_MONTH=10; TO_MONTH=12 ;;
  *) echo "Trimestre inválido: $QUARTER (esperado YYYY-Q1..Q4)" >&2; exit 1 ;;
esac
YEAR="${QUARTER%-*}"

# Encontra retros: .mb/retros/, docs/specs/_archive/, docs/specs/_completed/
RETROS_TMP=$(mktemp)
{
  find .mb/retros -name '*.md' -type f 2>/dev/null
  find docs/specs/_archive -name 'retro.md' -type f 2>/dev/null
  find docs/specs/_completed -name 'retro*.md' -type f 2>/dev/null
} > "$RETROS_TMP"

RETRO_COUNT=$(wc -l < "$RETROS_TMP" | tr -d ' ')

# Highlights (linhas que começam com "## Highlight", "✨", "## Decis")
HIGHLIGHTS=$(while read -r f; do
  [[ -z "$f" ]] && continue
  grep -E '^(##.*[Hh]ighlight|✨|##.*[Dd]ecis)' "$f" 2>/dev/null | head -2 \
    | sed "s|^|- ($(basename "$(dirname "$f")")) |"
done < "$RETROS_TMP" | head -10)

# Blockers recorrentes (linhas com "block" ou "🚨")
BLOCKERS=$(while read -r f; do
  [[ -z "$f" ]] && continue
  grep -Ei '(block|🚨|fragilidade|impedi)' "$f" 2>/dev/null | head -1 \
    | sed "s|^|- |"
done < "$RETROS_TMP" | head -5)

# Champions: squads com mais retros no período (proxy)
CHAMPIONS=$(while read -r f; do
  [[ -z "$f" ]] && continue
  grep -m1 -E '^Squad:' "$f" 2>/dev/null | sed -E 's/.*Squad:[[:space:]]*//'
done < "$RETROS_TMP" | sort | uniq -c | sort -rn | head -3 \
  | awk '{n=$1; $1=""; sub(/^ /,""); printf "- %s (%d retros)\n", $0, n}')

rm -f "$RETROS_TMP"

# ----- Markdown -----
cat > "$MD" <<EOF
# MBit Newsletter — ${QUARTER}

> Trimestre ${QUARTER} · ${RETRO_COUNT} retrospectivas processadas · gerado em $(date -u +%FT%TZ)

## Highlights

${HIGHLIGHTS:-_(nenhum highlight estruturado encontrado no período)_}

## Blockers recorrentes

${BLOCKERS:-_(nenhum blocker recorrente detectado)_}

## Squads em destaque (proxy via retros)

${CHAMPIONS:-_(nenhum squad com retro suficiente para destacar)_}

---

**Como contribuir:** abra PR ao SDK com novos comandos, retros, conquistas ou trilhas de AI Lab.
EOF

# ----- HTML -----
HIGHLIGHTS_HTML=$(echo "$HIGHLIGHTS" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's|^- |<li>|' -e 's|$|</li>|' | tr -d '\r')
BLOCKERS_HTML=$(echo "$BLOCKERS" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's|^- |<li>|' -e 's|$|</li>|' | tr -d '\r')
CHAMPIONS_HTML=$(echo "$CHAMPIONS" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's|^- |<li>|' -e 's|$|</li>|' | tr -d '\r')

cat > "$HTML" <<EOF
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>MBit Newsletter — ${QUARTER}</title>
</head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;max-width:680px;margin:32px auto;color:#1a1a1a;line-height:1.55;padding:0 16px;">
  <header style="border-bottom:3px solid #E8550C;padding-bottom:16px;margin-bottom:24px;">
    <h1 style="margin:0;color:#E8550C;font-size:28px;">MBit Newsletter</h1>
    <p style="margin:4px 0 0;color:#666;">Trimestre <strong>${QUARTER}</strong> · ${RETRO_COUNT} retrospectivas · ${date_iso:-$(date -u +%FT%TZ)}</p>
  </header>

  <section style="margin-bottom:24px;">
    <h2 style="font-size:18px;color:#333;border-bottom:1px solid #eee;padding-bottom:4px;">Highlights</h2>
    <ul>${HIGHLIGHTS_HTML:-<li><em>nenhum highlight estruturado encontrado</em></li>}</ul>
  </section>

  <section style="margin-bottom:24px;">
    <h2 style="font-size:18px;color:#333;border-bottom:1px solid #eee;padding-bottom:4px;">Blockers recorrentes</h2>
    <ul>${BLOCKERS_HTML:-<li><em>nenhum blocker recorrente detectado</em></li>}</ul>
  </section>

  <section style="margin-bottom:24px;">
    <h2 style="font-size:18px;color:#333;border-bottom:1px solid #eee;padding-bottom:4px;">Squads em destaque</h2>
    <ul>${CHAMPIONS_HTML:-<li><em>nenhum squad com retro suficiente</em></li>}</ul>
  </section>

  <footer style="margin-top:32px;padding-top:16px;border-top:1px solid #eee;color:#888;font-size:13px;">
    Gerado por <code>plugins/mb-retro/scripts/newsletter.sh</code>. Para customizar, edite o template no script ou contribua via PR.
  </footer>
</body>
</html>
EOF

echo "✓ Newsletter gerada:"
echo "  Markdown: $MD"
echo "  HTML:     $HTML"
echo "  Retros processadas: $RETRO_COUNT"
