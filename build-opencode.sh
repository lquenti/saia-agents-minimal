#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKERFILE="$SCRIPT_DIR/Dockerfile.opencode"
IMAGE=lquenti-saia-agents-minimal

command -v docker >/dev/null 2>&1 || { echo "docker: not found" >&2; exit 1; }

if docker info >/dev/null 2>&1; then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

$DOCKER build \
    --build-arg "HOST_UID=$HOST_UID" \
    -f "$DOCKERFILE" \
    -t "$IMAGE:latest" \
    "$@" \
    "$SCRIPT_DIR"
