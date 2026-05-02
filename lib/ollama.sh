ensure_ollama() {
  if command_exists ollama; then return; fi

  log "Installing Ollama"
  curl -fsSL https://ollama.com/install.sh | sh
}

ensure_ollama_running() {
  if ! pgrep -f "ollama serve" >/dev/null; then
    log "Starting Ollama"

    # Build environment variables based on OS
    local env_vars="OLLAMA_NUM_PARALLEL=1 OLLAMA_FLASH_ATTENTION=true"

    # MLX (Metal Performance Shaders) is macOS-specific
    if [[ "$OSTYPE" == "darwin"* ]]; then
      env_vars="$env_vars OLLAMA_MLX=1"
    fi

    # Start ollama serve in the background
    eval "$env_vars ollama serve" >/dev/null 2>&1 &
  fi
}
