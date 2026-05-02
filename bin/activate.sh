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

########################################
# Dispatch
########################################

case "$COMMAND" in
  docker)
    source "$ROOT_DIR/activators/docker.sh"
    ;;
  ollama)
    bash "$ROOT_DIR/activators/ollama.sh"
    ;;
  *)
    log "== Edge-Forge Activator =="
    echo "Usage:"
    echo "  activate.sh docker     Start the Docker container"
    echo "  activate.sh ollama     Ensure Ollama serve is running + model ready"
    echo ""
    echo "Examples:"
    echo "  ./bin/activate.sh ollama"
    echo "  ./bin/activate.sh docker"
    echo ""
    ;;
esac
