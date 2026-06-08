#!/bin/bash
# Advanced Coding Agent - Build Script (OpenCode Runtime)
# Builds the OpenCode Docker image

set -e

# Check if running as root (sudo required)
if [[ "$(id -u)" != "0" ]]; then
    echo -e "\033[0;31m✗ ERROR: This script must be run with sudo\033[0m"
    echo -e "\033[1;33m  Please run: sudo ./build-opencode.sh\033[0m"
    echo -e "\033[1;33m  Docker build requires elevated permissions\033[0m"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.opencode"
IMAGE_NAME="advanced-coding-agent-opencode"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo -e "${RED}✗ ERROR: Docker is not running${NC}"
    exit 1
fi

# Check if Dockerfile exists
if [[ ! -f "${DOCKERFILE}" ]]; then
    echo -e "${RED}✗ ERROR: Dockerfile not found: ${DOCKERFILE}${NC}"
    exit 1
fi

# Build the image
echo -e "${GREEN}🔨 Building OpenCode Docker image...${NC}"
echo -e "${YELLOW}  Dockerfile: ${DOCKERFILE}${NC}"
echo -e "${YELLOW}  Image: ${IMAGE_NAME}:latest${NC}"
echo ""

docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}:latest" "${SCRIPT_DIR}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Docker build failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ OpenCode image built successfully${NC}"
echo -e "${GREEN}  Image: ${IMAGE_NAME}:latest${NC}"
echo ""
echo -e "${GREEN}Next: Run ./start-opencode.sh to start the container${NC}"
