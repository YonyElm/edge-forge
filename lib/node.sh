ensure_node() {
  if command_exists node && command_exists npm; then
    return
  fi

  log "Installing Node.js"

  if command_exists brew; then
    log "Using Homebrew"
    brew install node
  elif command_exists apt-get; then
    log "Using apt (Debian/Ubuntu)"
    sudo apt-get update
    sudo apt-get install -y nodejs npm
  elif command_exists dnf; then
    log "Using dnf (Fedora/RHEL)"
    sudo dnf install -y nodejs npm
  elif command_exists pacman; then
    log "Using pacman (Arch)"
    sudo pacman -S --noconfirm nodejs npm
  else
    die "Node.js required but no supported package manager found (brew, apt, dnf, or pacman)"
  fi

  command_exists node && command_exists npm || die "Node.js installation failed"
}
