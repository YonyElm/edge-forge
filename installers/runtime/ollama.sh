source "$ROOT_DIR/lib/ollama.sh"

MODEL="${MODEL:-phi4-mini}"

run() {
  ensure_ollama
  ensure_ollama_running

  if ollama list | grep -q "$MODEL"; then
    log "Model already present"
  else
    log "Pulling $MODEL"
    ollama pull "$MODEL"
  fi
}
