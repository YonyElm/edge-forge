source "$ROOT_DIR/lib/core.sh"
source "$ROOT_DIR/lib/node.sh"

MODEL_ID="${MODEL_ID:-nemotron-3-nano-4b}"

run() {
  log "== OpenCode CLI =="

  ensure_node

  npm install -g opencode-ai

  command_exists opencode || die "OpenCode not found"

  CONFIG_DIR="$HOME/.config/opencode"
  CONFIG_FILE="$CONFIG_DIR/config.json"

  mkdir -p "$CONFIG_DIR"

  cp "$ROOT_DIR/config/opencode-lmstudio.json" "$CONFIG_FILE"

  log "Config written: $CONFIG_FILE"
}
