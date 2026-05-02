source "$ROOT_DIR/lib/core.sh"

run() {
  log "Installing Aider"

  if command_exists brew; then
    brew install aider
  else
    pip install aider-chat
  fi

  command_exists aider || die "Aider install failed"
}
