ensure_node() {
  command_exists() { command -v "$1" >/dev/null 2>&1; }

  log() { echo "[node] $1"; }
  die() { echo "[node] ERROR: $1" >&2; exit 1; }

  # --- Detect working Node ---
  if command_exists node && command_exists npm; then
    if node -e "console.log('ok')" >/dev/null 2>&1; then
      NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)

      if [ "$NODE_MAJOR" -ge 18 ]; then
        log "Node OK: $(node -v)"
        return
      fi

      log "Node too old: $(node -v)"
    else
      log "Node exists but is broken (likely glibc mismatch)"
    fi
  fi

  log "Installing Node.js (safe mode)"

  # --- macOS ---
  if command_exists brew; then
    log "Using Homebrew"
    brew install node
    return
  fi

  # --- Debian/Ubuntu ---
  if command_exists apt-get; then
    log "Using apt (safe fallback strategy)"

    sudo apt-get update
    sudo apt-get install -y curl ca-certificates

    # Try NodeSource ONLY if system supports it
    if curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
      if sudo apt-get install -y nodejs; then
        if node -e "console.log('ok')" >/dev/null 2>&1; then
          log "Installed Node via NodeSource: $(node -v)"
          return
        fi
      fi
    fi

    log "NodeSource failed or incompatible. Switching to nvm..."

    # --- Install nvm ---
    if ! command_exists nvm; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    # --- Load nvm (both possible paths) ---
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command_exists nvm; then
      export NVM_DIR="$HOME/.config/nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    command_exists nvm || die "nvm not available"

    log "Installing Node 18 (2026 minimum requirements)"

    nvm install 18
    nvm use 18
    nvm alias default 18

    # --- Force PATH fix ---
    export PATH="$HOME/.nvm/versions/node/$(nvm current)/bin:$PATH"

    # --- Final verification ---
    node -e "console.log('Node working:', process.version)" || die "Node failed runtime check"
    npm -v >/dev/null 2>&1 || die "npm missing after install"

    log "Installed Node via nvm: $(node -v)"
    return
  fi

  # --- Fedora/RHEL ---
  if command_exists dnf; then
    log "Using dnf"
    sudo dnf install -y nodejs
    return
  fi

  # --- Arch ---
  if command_exists pacman; then
    log "Using pacman"
    sudo pacman -S --noconfirm nodejs npm
    return
  fi

  die "No supported package manager found"
}
