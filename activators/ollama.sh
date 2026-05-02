#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

source "$ROOT_DIR/lib/core.sh"
source "$ROOT_DIR/lib/ollama.sh"

ENV_FILE="$ROOT_DIR/config/config.env"
LOCAL_ENV_FILE="$ROOT_DIR/config/models.local.env"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  source "$LOCAL_ENV_FILE"
fi

MODELS_DIR="$ROOT_DIR/config/ollama-models"
DEFAULT_MODEL="${OLLAMA_MODEL:-phi4-mini}"

########################################
# Ensure Ollama is running
########################################

log "Checking Ollama..."
ensure_ollama
ensure_ollama_running
sleep 2

HOST="${OLLAMA_HOST:-http://localhost:11434}"

for i in $(seq 1 15); do
  if curl -sf "$HOST/api/tags" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

########################################
# List existing models
########################################

echo ""
log "== Existing Models =="
echo ""

MODELS_OUTPUT=$(ollama list 2>/dev/null || true)

if [[ -z "$MODELS_OUTPUT" ]]; then
  log "No models installed yet."
else
  echo "$MODELS_OUTPUT" | tail -n +2 | while IFS= read -r line; do
    echo "  $line"
  done
fi

########################################
# Check for unbuilt Modelfiles
########################################

echo ""
log "== Available Model Configs =="
echo ""

UNBUILT=()

if [[ -d "$MODELS_DIR" ]]; then
  for modelfile in "$MODELS_DIR"/*; do
    [[ -f "$modelfile" ]] || continue
    [[ "$(basename "$modelfile")" == "README.md" ]] && continue

    name="$(basename "$modelfile")"

    if echo "$MODELS_OUTPUT" | grep -q "$name"; then
      echo "  [built]   $name"
    else
      echo "  [missing] $name"
      UNBUILT+=("$name")
    fi
  done
fi

########################################
# Offer to build missing models
########################################

if [[ ${#UNBUILT[@]} -gt 0 ]]; then
  echo ""
  read -rp "Build missing models? [y/N]: " BUILD_CHOICE

  if [[ "$BUILD_CHOICE" =~ ^[Yy] ]]; then
    for name in "${UNBUILT[@]}"; do
      echo ""
      log "Building model: $name"
      ollama create "$name" -f "$MODELS_DIR/$name"
      log "Done: $name"
    done
  fi
fi

########################################
# Select a model
########################################

echo ""
log "== Select a Model =="
echo ""

ALL_MODELS=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  model_name=$(echo "$line" | awk '{print $1}')
  [[ -z "$model_name" ]] && continue
  ALL_MODELS+=("$model_name")
  echo "  $((${#ALL_MODELS[@]})). $model_name"
done < <(ollama list 2>/dev/null | tail -n +2)

if [[ ${#ALL_MODELS[@]} -eq 0 ]]; then
  die "No models available. Install one with: ollama pull <model>"
fi

echo ""
read -rp "Choose a model [1-${#ALL_MODELS[@]}]: " MODEL_IDX

if [[ "$MODEL_IDX" -ge 1 && "$MODEL_IDX" -le ${#ALL_MODELS[@]} ]]; then
  SELECTED_MODEL="${ALL_MODELS[$((MODEL_IDX - 1))]}"
else
  log "Invalid selection, using default: $DEFAULT_MODEL"
  SELECTED_MODEL="$DEFAULT_MODEL"
fi

log "Selected: $SELECTED_MODEL"

########################################
# Select an agent
########################################

echo ""
log "== Select an Agent =="
echo ""
echo "  1. aider"
echo "  2. opencode"
echo "  3. claude"
echo ""
read -rp "Choose an agent [1-3]: " AGENT_IDX

case "$AGENT_IDX" in
  1)
    AGENT="aider"
    ;;
  2)
    AGENT="opencode"
    ;;
  3)
    AGENT="claude"
    ;;
  *)
    die "Invalid agent selection"
    ;;
esac

log "Selected: $AGENT"

########################################
# Launch the agent
########################################

echo ""
log "Launching $AGENT with model: $SELECTED_MODEL"
echo ""

case "$AGENT" in
  aider)
    if ! command_exists aider; then
      log "Aider not installed. Installing..."
      bash "$ROOT_DIR/bin/install.sh" coding-agent aider
    fi

    if [[ "$SELECTED_MODEL" =~ ^ollama/ ]]; then
      aider --model "$SELECTED_MODEL"
    else
      aider --model "ollama/$SELECTED_MODEL"
    fi
    ;;

  opencode)
    if ! command_exists opencode; then
      log "OpenCode not installed. Installing..."
      bash "$ROOT_DIR/bin/install.sh" coding-agent opencode
    fi

    ollama launch opencode --model "$SELECTED_MODEL"
    ;;

  claude)
    if ! command_exists claude; then
      log "Claude CLI not installed. Installing..."
      bash "$ROOT_DIR/bin/install.sh" coding-agent claude
    fi

    ollama launch claude --model "$SELECTED_MODEL"
    ;;
esac
