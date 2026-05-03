#!/usr/bin/env bash
set -euo pipefail

IMAGE="${DOCKER_IMAGE:-agent-sandbox:latest}"
CONTAINER_NAME="${DOCKER_CONTAINER_NAME:-agent-sandbox}"
WORKDIR_CONTAINER="/workspace"
DOCKERFILE_DIR="${DOCKERFILE_DIR:-$(dirname "$0")/../config/docker-images}"

log() { echo "[sandbox] $*"; }
die() { echo "[sandbox] ERROR: $*" >&2; exit 1; }

########################################
# Build image if not present
########################################

build_image_if_missing() {
  if ! $SUDO docker image inspect "$IMAGE" >/dev/null 2>&1; then
    log "Image not found locally. Building from Dockerfile..."
    if [[ -f "$DOCKERFILE_DIR/Dockerfile" ]]; then
      $SUDO docker build -t "$IMAGE" "$DOCKERFILE_DIR"
    else
      log "Dockerfile not found at $DOCKERFILE_DIR, pulling base image..."
      $SUDO docker pull "${DOCKER_IMAGE:-node:18-bullseye}"
    fi
  fi
}

########################################
# Resolve user-provided workspace
########################################

WORKDIR_HOST="${1:-}"

if [[ -z "$WORKDIR_HOST" ]]; then
  die "Usage: $0 /path/to/workspace"
fi

# Resolve absolute path
WORKDIR_HOST="$(realpath "$WORKDIR_HOST")"

########################################
# Guardrails (CRITICAL)
########################################

# Block dangerous mounts
case "$WORKDIR_HOST" in
  "/" )
    die "Refusing to mount root filesystem (/)"
    ;;
  "$HOME" )
    die "Refusing to mount entire home directory"
    ;;
  /etc*|/usr*|/var*|/bin*|/sbin* )
    die "Refusing to mount system directories"
    ;;
esac

# Block sensitive subpaths
if [[ "$WORKDIR_HOST" == *".ssh"* ]] || \
   [[ "$WORKDIR_HOST" == *".aws"* ]] || \
   [[ "$WORKDIR_HOST" == *".config"* ]]; then
  die "Refusing to mount sensitive configuration directories"
fi

# Ensure directory exists
mkdir -p "$WORKDIR_HOST"

########################################
# Docker access
########################################

if ! docker info >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

########################################
# Build/pull image
########################################

log "Checking image..."
build_image_if_missing

########################################
# Run container
########################################

log "Starting zero-exposure agent runtime..."
log "Workspace: $WORKDIR_HOST"

$SUDO docker run --rm -it \
  --name "$CONTAINER_NAME" \
  --security-opt no-new-privileges \
  --pids-limit 512 \
  --memory 4g \
  --cpus 4 \
  --network bridge \
  -v "$WORKDIR_HOST:$WORKDIR_CONTAINER" \
  -e HOME=/root \
  -e NODE_ENV=production \
  "$IMAGE" bash -lc "

set -e

echo '[sandbox] ZERO-EXPOSURE RUNTIME READY'
echo '-----------------------------------'
echo 'Mounted workspace: /workspace'
echo ''
echo 'Capabilities:'
echo '  - Internet access (GitHub, npm, etc.)'
echo '  - Isolated execution environment'
echo ''
echo 'NOT accessible:'
echo '  - host home directory'
echo '  - browser profiles'
echo '  - SSH keys'
echo '  - system configs'
echo ''

cd /workspace
exec bash
"
