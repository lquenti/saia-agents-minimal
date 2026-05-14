#!/bin/bash
# Advanced Coding Agent - Build Script (OpenClaude Runtime)
# Builds the OpenClaude Docker image

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.openclaude"
CONTAINER_NAME="advanced-coding-agent"

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
echo -e "${GREEN}🔨 Building OpenClaude Docker image...${NC}"
echo -e "${YELLOW}  Dockerfile: ${DOCKERFILE}${NC}"
echo -e "${YELLOW}  Image: ${CONTAINER_NAME}:openclaude${NC}"
echo ""

docker build -f "${DOCKERFILE}" -t "${CONTAINER_NAME}:openclaude" "${SCRIPT_DIR}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Docker build failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ OpenClaude image built successfully${NC}"
echo -e "${GREEN}  Image: ${CONTAINER_NAME}:openclaude${NC}"
echo ""
echo -e "${GREEN}Next: Run ./start-openclaude.sh to start the container${NC}"
