source "$ROOT_DIR/lib/core.sh"
source "$ROOT_DIR/lib/system.sh"

run() {
  log "== LM Studio Runtime =="

  check_os

  if [[ "$OSTYPE" == "darwin"* ]]; then
    APP_PATH="/Applications/LM Studio.app"
  else
    APP_PATH="$HOME/.local/share/LM-Studio"
  fi

  if [[ -d "$APP_PATH" ]]; then
    log "LM Studio already installed"
  else
    warn "LM Studio requires manual install:"
    echo "https://lmstudio.ai"
  fi

  MODEL_DIR="$HOME/.cache/lm-studio/models"

  if [[ -d "$MODEL_DIR" ]] && find "$MODEL_DIR" -iname "*nemotron*4b*" | grep -q .; then
    log "Model appears installed"
  else
    warn "Install model manually inside LM Studio:"
    echo "Search: nvidia/nemotron-3-nano-4b"
  fi
}
