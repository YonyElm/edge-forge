#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

########################################
# Load environment
########################################

ENV_FILE="$ROOT_DIR/config/config.env"
LOCAL_ENV_FILE="$ROOT_DIR/config/models.local.env"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  source "$LOCAL_ENV_FILE"
fi

source "$ROOT_DIR/lib/core.sh"

########################################
# Args
########################################

COMMAND="${1:-help}"
shift || true

########################################
# Dispatch
########################################

case "$COMMAND" in
  docker)
    bash "$ROOT_DIR/activators/docker.sh" "$@"
    ;;
  ollama)
    bash "$ROOT_DIR/activators/ollama.sh"
    ;;
  *)
    log "== Edge-Forge Activator =="
    echo "Usage:"
    echo "  activate.sh docker <workspace>"
    echo "  activate.sh ollama"
    echo ""
    echo "Examples:"
    echo "  ./bin/activate.sh ollama"
    echo "  ./bin/activate.sh docker ."
    echo "  ./bin/activate.sh docker ~/sandbox/project"
    echo ""
    ;;
esac
