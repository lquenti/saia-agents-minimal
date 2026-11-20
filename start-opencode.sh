#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Run
# =============================================================================
# Runs OpenCode in an isolated container with the current directory mounted at
# /home/agent/workspace. Your files stay yours; the container gets no more than
# this directory, a tmpfs, and its config.
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="lquenti-saia-agents-minimal:latest"
CONTAINER_NAME="lquenti-saia-agents-minimal"
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"

source "${SCRIPT_DIR}/scripts/docker-lib.sh"
setup_docker_cmd

# Match the host UID/GID so files created in the workspace keep your ownership
HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

# -----------------------------------------------------------------------------
# Load Environment
# -----------------------------------------------------------------------------
if [[ ! -f "${SCRIPT_DIR}/.env" ]]; then
    echo "ERROR: no .env file (copy .env.example to .env)" >&2
    exit 1
fi

set -a
source "${SCRIPT_DIR}/.env"
set +a

: "${OPENCODE_API_KEY:?OPENCODE_API_KEY not set in .env}"
: "${MODEL:?MODEL not set in .env}"

# -----------------------------------------------------------------------------
# Generate Config (discovers models from the endpoint) if missing
# -----------------------------------------------------------------------------
if [[ ! -f "${OPENCODE_DIR}/auth.json" || ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    "${SCRIPT_DIR}/generate-opencode-config.sh"
    if [[ "$(id -u)" -eq 0 ]]; then
        chown -R "${HOST_UID}:${HOST_GID}" "${OPENCODE_DIR}"
    fi
fi

# -----------------------------------------------------------------------------
# Per-project persistence
# -----------------------------------------------------------------------------
CURRENT_DIR="$(pwd)"
MEMORY_SHARE_DIR="${CURRENT_DIR}/.agent-memory/share"
mkdir -p "${MEMORY_SHARE_DIR}/opencode"
if [[ "$(id -u)" -eq 0 ]]; then
    chown -R "${HOST_UID}:${HOST_GID}" "${CURRENT_DIR}/.agent-memory"
fi
ln -sf ../../../../.opencode/auth.json "${MEMORY_SHARE_DIR}/opencode/auth.json"

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------
exec ${DOCKER} run -it --rm \
    --name "${CONTAINER_NAME}" \
    --hostname coding-agent \
    --user agent \
    --cap-drop ALL \
    --cap-add NET_BIND_SERVICE \
    --cap-add NET_RAW \
    --security-opt no-new-privileges:true \
    --tmpfs /tmp:rw,exec,nosuid,size=100m \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --memory 4g \
    --memory-swap 4g \
    --cpus 2.0 \
    -v "${OPENCODE_DIR}/opencode.json:/home/agent/.config/opencode/opencode.json:ro" \
    -v "${OPENCODE_DIR}/auth.json:/home/agent/.opencode/auth.json:ro" \
    -v "${CURRENT_DIR}:/home/agent/workspace:rw" \
    -v "${MEMORY_SHARE_DIR}:/home/agent/workspace/.agent-memory/share:rw" \
    -e NODE_ENV=production \
    -e WORKSPACE=/home/agent/workspace \
    -e OPENAI_API_KEY="${OPENCODE_API_KEY}" \
    -e OPENAI_BASE_URL="${OPENAI_BASE_URL}" \
    -e MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}" \
    -e LOG_LEVEL="${LOG_LEVEL:-info}" \
    "${IMAGE_NAME}"
