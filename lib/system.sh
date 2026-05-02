check_os() {
  case "$OSTYPE" in
    linux-gnu*|darwin*) ;;
    *) die "Unsupported OS: $OSTYPE" ;;
  esac
}

check_gpu() {
  if command_exists nvidia-smi; then
    log "NVIDIA GPU detected:"
    nvidia-smi --query-gpu=name --format=csv,noheader
  else
    warn "No NVIDIA GPU detected (CPU fallback likely)"
  fi
}
