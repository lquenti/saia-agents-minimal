#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Build Script
# =============================================================================
# Builds the OpenCode base image, matching the host UID/GID for file ownership.
# Extra arguments are passed through to `docker build` (e.g. --no-cache).
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.opencode"
IMAGE_NAME="lquenti-saia-agents-minimal"

source "${SCRIPT_DIR}/scripts/docker-lib.sh"
setup_docker_cmd

HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
echo -e "${GREEN}🔨 Building ${IMAGE_NAME}:latest${NC}"
echo -e "${YELLOW}  Dockerfile: ${DOCKERFILE}${NC}"
echo -e "${YELLOW}  Host UID/GID: ${HOST_UID}/${HOST_GID}${NC}"
echo ""

${DOCKER} build \
    --build-arg HOST_UID=${HOST_UID} \
    -f "${DOCKERFILE}" \
    -t "${IMAGE_NAME}:latest" \
    "$@" \
    "${SCRIPT_DIR}"

echo ""
echo -e "${GREEN}✓ Built ${IMAGE_NAME}:latest${NC}"
echo -e "${GREEN}Next: ./start-opencode.sh${NC}"
