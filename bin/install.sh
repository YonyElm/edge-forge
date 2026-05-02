#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

########################################
# Load environment (base + optional local override)
########################################

ENV_FILE="$ROOT_DIR/config/config.env"
LOCAL_ENV_FILE="$ROOT_DIR/config/models.local.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# Optional per-machine override (gitignored)
if [[ -f "$LOCAL_ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$LOCAL_ENV_FILE"
fi

########################################
# Core utilities
########################################

source "$ROOT_DIR/lib/core.sh"

########################################
# Args
########################################

COMMAND="${1:-help}"
TARGET="${2:-}"

########################################
# Dispatch
########################################

case "$COMMAND" in
  runtime)
    [[ -z "${TARGET:-}" ]] && die "Missing runtime target (ollama|lmstudio)"
    source "$ROOT_DIR/installers/runtime/$TARGET.sh" \
      || die "Unknown runtime: $TARGET"
    run
    ;;
  coding-agent)
    [[ -z "${TARGET:-}" ]] && die "Missing coding-agent target (claude|opencode|aider)"
    source "$ROOT_DIR/installers/coding-agent/$TARGET.sh" \
      || die "Unknown coding-agent: $TARGET"
    run
    ;;
  print-config)
    echo "== Active Configuration =="
    echo "DEFAULT_RUNTIME=${DEFAULT_RUNTIME:-ollama}"
    echo "OLLAMA_MODEL=${OLLAMA_MODEL:-phi4-mini}"
    echo "LMSTUDIO_MODEL_ID=${LMSTUDIO_MODEL_ID:-nemotron-3-nano-4b}"
    echo "AIDER_MODEL=${AIDER_MODEL:-ollama/phi4-mini}"
    ;;
  *)
    echo "Usage:"
    echo "  install.sh runtime [ollama|lmstudio]"
    echo "  install.sh coding-agent [claude|opencode|aider]"
    echo "  install.sh print-config"
    exit 1
    ;;
esac