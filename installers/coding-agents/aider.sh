source "$ROOT_DIR/lib/core.sh"

run() {
  log "Installing Aider"

  if command_exists aider; then
    log "Aider already installed"
    return
  fi

  if command_exists brew; then
    log "Using Homebrew"
    brew install aider
  elif command_exists apt-get; then
    log "Using apt (Debian/Ubuntu)"
    sudo apt-get update
    sudo apt-get install -y aider-chat
  elif command_exists dnf; then
    log "Using dnf (Fedora/RHEL)"
    sudo dnf install -y aider-chat
  else
    die "Aider installation failed: no supported package manager found (brew, apt-get, or dnf)"
  fi

  command_exists aider || die "Aider installation failed"
}
