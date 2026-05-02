source "$ROOT_DIR/lib/core.sh"
source "$ROOT_DIR/lib/node.sh"

run() {
  log "Installing Claude CLI"

  ensure_node

  if npm install -g @anthropic-ai/claude-code; then
    log "Installed via official package"
  else
    log "Fallback install"
    npm install -g claude-code
  fi

  command_exists claude || die "Claude not found after install"

  log "Next: run 'claude login'"
}
