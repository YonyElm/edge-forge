ensure_node() {
  if command_exists node && command_exists npm; then
    return
  fi

  if command_exists brew; then
    log "Installing Node via Homebrew"
    brew install node
  else
    die "Node.js required but no installer available"
  fi
}
