ensure_ollama() {
  if command_exists ollama; then return; fi

  log "Installing Ollama"
  curl -fsSL https://ollama.com/install.sh | sh
}

ensure_ollama_running() {
  if ! pgrep -f "ollama serve" >/dev/null; then
    log "Starting Ollama"
    OLLAMA_NUM_PARALLEL=1 OLLAMA_FLASH_ATTENTION=true OLLAMA_MLX=1 ollama serve >/dev/null 2>&1 &
  fi
}
