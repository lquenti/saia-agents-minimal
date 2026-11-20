#!/bin/bash
set -e

IMAGE=lquenti-saia-agents-minimal

HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

pushd "$(dirname "$0")/docker" >/dev/null
docker build \
    --build-arg "HOST_UID=$HOST_UID" \
    -f Dockerfile \
    -t "$IMAGE:latest" \
    "$@" \
    .
popd >/dev/null
