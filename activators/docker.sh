#!/usr/bin/env bash
set -euo pipefail

IMAGE="${DOCKER_IMAGE:-node:18-bullseye}"
WORKDIR="/workspace"
CONTAINER_NAME="${DOCKER_CONTAINER_NAME:-opencode-container}"

log() { echo "[docker] $*"; }
die() { echo "[docker] ERROR: $*" >&2; exit 1; }

########################################
# Check Docker access
########################################

if ! docker info >/dev/null 2>&1; then
  log "Docker requires sudo or user not in docker group"
  log "Retrying with sudo..."
  SUDO="sudo"
else
  SUDO=""
fi

########################################
# Pull and run
########################################

log "Pulling base image..."
$SUDO docker pull "$IMAGE"

log "Starting container..."

$SUDO docker run --rm -it \
  -v "$PWD:$WORKDIR" \
  -w "$WORKDIR" \
  -e TERM=xterm-256color \
  -e LANG=en_US.UTF-8 \
  -e LC_ALL=en_US.UTF-8 \
  --name "$CONTAINER_NAME" \
  "$IMAGE" bash -lc "

    set -e

    echo '[docker] Installing dependencies...'

    apt-get update -qq && apt-get install -y -qq \
      bash-completion \
      locales \
      vim \
      curl \
      git \
      less > /dev/null

    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen

    npm install -g opencode-ai

    echo ''
    echo '[docker] Ready. You are inside the container.'
    echo '[docker] Your host folder is mounted at /workspace'
    echo ''

    exec bash
"
