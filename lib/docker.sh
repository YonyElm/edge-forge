#!/usr/bin/env bash
set -e

IMAGE="node:18-bullseye"
WORKDIR="/workspace"

echo "[docker] Checking Docker access..."

# Ensure docker works (may require sudo on Jetson)
if ! docker info >/dev/null 2>&1; then
  echo "[docker] Docker requires sudo or user not in docker group"
  echo "[docker] Retrying with sudo..."
  SUDO="sudo"
else
  SUDO=""
fi

echo "[docker] Pulling base image..."
$SUDO docker pull $IMAGE

echo "[docker] Starting container..."

$SUDO docker run --rm -it \
  -v "$PWD:$WORKDIR" \
  -w "$WORKDIR" \
  --name opencode-container \
  $IMAGE bash -lc "

    set -e

    echo '[docker] Installing dependencies...'
    npm install -g opencode-ai

    echo ''
    echo '[docker] Ready. You are inside the container.'
    echo '[docker] Your host folder is mounted at /workspace'
    echo ''

    exec bash
"
