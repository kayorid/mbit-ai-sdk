#!/usr/bin/env bash
# mb-ai-core / lib / spinner.sh
# Spinner elegante para operações longas. Não-bloqueante; roda em background.
# Uso:
#   mb_spin_start "Carregando constitution..."
#   ... trabalho ...
#   mb_spin_stop

MB_SPIN_PID=""

# Pool de mensagens criativas (fallback quando não passada)
MB_SPIN_QUOTES=(
  "Mapeando o DNA do seu squad..."
  "Construindo spec — segura como cold storage..."
  "Pensando como atacante motivado..."
  "Capturando aprendizado para o MB de 2027..."
  "Carregando constitution MB..."
  "Verificando conformidade Bacen..."
  "Procurando padrão na desordem..."
  "Tecendo audit trail..."
  "Preparando o terreno para o próximo dev..."
  "Escutando o que o código não diz..."
)

mb_spin_quote() {
  local idx=$(( RANDOM % ${#MB_SPIN_QUOTES[@]} ))
  echo "${MB_SPIN_QUOTES[$idx]}"
}

mb_spin_start() {
  local msg="${1:-$(mb_spin_quote)}"
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  (
    local i=0
    while true; do
      local f="${frames:$((i%10)):1}"
      printf "\r\033[38;5;220m%s\033[0m %s " "$f" "$msg" >&2
      i=$((i+1))
      sleep 0.1
    done
  ) &
  MB_SPIN_PID=$!
  disown 2>/dev/null || true
}

mb_spin_stop() {
  local status="${1:-ok}"
  if [[ -n "$MB_SPIN_PID" ]]; then
    kill "$MB_SPIN_PID" 2>/dev/null || true
    wait "$MB_SPIN_PID" 2>/dev/null || true
    MB_SPIN_PID=""
  fi
  printf "\r\033[K" >&2
  case "$status" in
    ok)   printf "\033[38;5;82m✓\033[0m %s\n" "${2:-Pronto}" >&2 ;;
    warn) printf "\033[38;5;214m⚠\033[0m %s\n" "${2:-Aviso}" >&2 ;;
    fail) printf "\033[38;5;196m✗\033[0m %s\n" "${2:-Falhou}" >&2 ;;
    silent) ;;
  esac
}
