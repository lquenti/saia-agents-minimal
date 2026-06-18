#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Build Script
# =============================================================================
# Builds the OpenCode Docker image with host UID/GID for proper file ownership
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.opencode"
IMAGE_NAME="advanced-coding-agent-opencode"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Detect Host User (before sudo elevation)
# -----------------------------------------------------------------------------
HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}

echo -e "${GREEN}✓ Building with host UID: ${HOST_UID}, GID: ${HOST_GID}${NC}"

# -----------------------------------------------------------------------------
# Check Root Privileges
# -----------------------------------------------------------------------------
if [[ "$(id -u)" != "0" ]]; then
    echo -e "${RED}✗ ERROR: This script must be run with sudo${NC}"
    echo -e "${YELLOW}  Please run: sudo ./build-opencode.sh${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Check Docker
# -----------------------------------------------------------------------------
if ! docker info &>/dev/null; then
    echo -e "${RED}✗ ERROR: Docker is not running${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Check Dockerfile
# -----------------------------------------------------------------------------
if [[ ! -f "${DOCKERFILE}" ]]; then
    echo -e "${RED}✗ ERROR: Dockerfile not found: ${DOCKERFILE}${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Build Image
# -----------------------------------------------------------------------------
echo -e "${GREEN}🔨 Building OpenCode Docker image...${NC}"
echo -e "${YELLOW}  Dockerfile: ${DOCKERFILE}${NC}"
echo -e "${YELLOW}  Image: ${IMAGE_NAME}:latest${NC}"
echo -e "${YELLOW}  Host UID/GID: ${HOST_UID}/${HOST_GID}${NC}"
echo ""

docker build \
    --build-arg HOST_UID=${HOST_UID} \
    -f "${DOCKERFILE}" \
    -t "${IMAGE_NAME}:latest" \
    "${SCRIPT_DIR}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Docker build failed${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Success
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}✓ OpenCode image built successfully${NC}"
echo -e "${GREEN}  Image: ${IMAGE_NAME}:latest${NC}"
echo ""
echo -e "${GREEN}Next: Run sudo ./start-opencode.sh to start the container${NC}"
