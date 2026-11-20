#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKERFILE="$SCRIPT_DIR/Dockerfile.opencode"
IMAGE=lquenti-saia-agents-minimal

HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

docker build \
    --build-arg "HOST_UID=$HOST_UID" \
    -f "$DOCKERFILE" \
    -t "$IMAGE:latest" \
    "$@" \
    "$SCRIPT_DIR"
