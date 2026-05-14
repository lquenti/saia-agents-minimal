#!/bin/bash
# Advanced Coding Agent - Start Script (OpenClaude Runtime)
# Builds and starts the OpenClaude container with current directory mounted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CONTAINER_NAME="advanced-coding-agent"
DOCKERFILE="Dockerfile.openclaude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment file
if [[ -f "${ENV_FILE}" ]]; then
    source "${ENV_FILE}"
    echo -e "${GREEN}✓ Loaded .env file${NC}"
else
    echo -e "${YELLOW}⚠ No .env file found. Copy .env.example to .env and configure.${NC}"
    echo -e "${YELLOW}  cp .env.example .env${NC}"
    echo -e "${YELLOW}  nano .env${NC}"
    exit 1
fi

# Validate runtime
if [[ "${RUNTIME}" != "openclaude" ]]; then
    echo -e "${RED}✗ ERROR: RUNTIME must be 'openclaude' for this script${NC}"
    echo -e "${RED}   Current: ${RUNTIME}${NC}"
    echo -e "${RED}   Use ./start-opencode.sh for OpenCode runtime${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo -e "${RED}✗ ERROR: Docker is not running${NC}"
    exit 1
fi

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠ Container '${CONTAINER_NAME}' already exists${NC}"
    echo -e "${YELLOW}  Removing old container (it won't persist after stop)${NC}"
    docker stop "${CONTAINER_NAME}" &>/dev/null || true
    docker rm "${CONTAINER_NAME}" &>/dev/null || true
    echo -e "${GREEN}✓ Removed existing container${NC}"
fi

# Build the image
echo -e "${GREEN}🔨 Building Docker image...${NC}"
docker build -f "${DOCKERFILE}" -t "${CONTAINER_NAME}:latest" "${SCRIPT_DIR}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Image built successfully${NC}"

# Get current directory for mounting
CURRENT_DIR="$(pwd)"
PROJECT_NAME="$(basename "${CURRENT_DIR}")"

# Create memory directory for persistence
MEMORY_DIR="${CURRENT_DIR}/.agent-memory"
mkdir -p "${MEMORY_DIR}"
echo -e "${GREEN}✓ Memory directory created: ${MEMORY_DIR}${NC}"

# Start the container
echo -e "${GREEN}🚀 Starting container...${NC}"
docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    --hostname coding-agent \
    --user agent \
    --read-only \
    --cap-drop ALL \
    --security-opt no-new-privileges:true \
    --tmpfs /tmp:rw,noexec,nosuid,size=100m \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --memory 4g \
    --memory-swap 4g \
    --cpus 2.0 \
    --network none \
    -v "${SCRIPT_DIR}/agents.json:/home/agent/.openclaude/agents.json:ro" \
    -v "${SCRIPT_DIR}/tools.md:/home/agent/.openclaude/workspace/tools.md:ro" \
    -v "${CURRENT_DIR}:/home/agent/workspace/projects/${PROJECT_NAME}:rw" \
    -v "${SCRIPT_DIR}/docs:/home/agent/workspace/docs:ro" \
    -v "${MEMORY_DIR}:/home/agent/.openclaude/memory:rw" \
    -e NODE_ENV=production \
    -e WORKSPACE=/home/agent/workspace \
    -e HOME=/home/agent/workspace/projects/${PROJECT_NAME} \
    -e OPENCLAUDE_HOME=/home/agent/.openclaude \
    -e MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}" \
    -e LOG_LEVEL="${LOG_LEVEL:-info}" \
    "${CONTAINER_NAME}:latest"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Failed to start container${NC}"
    exit 1
fi

# Container runs interactively, will exit when user exits bash
echo -e "${GREEN}✓ Container running (interactive mode)${NC}"
echo -e "${GREEN}  Container will be removed when you exit${NC}"
echo ""
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Advanced Coding Agent - OpenClaude Runtime${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Container: ${YELLOW}${CONTAINER_NAME}${NC} (auto-removes on exit)"
echo -e "  Project:   ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Workspace: ${YELLOW}/home/agent/workspace/projects/${PROJECT_NAME}${NC}"
echo -e "  Memory:    ${YELLOW}/home/agent/.openclaude/memory${NC} → ${MEMORY_DIR}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo -e "  1. Start the OpenClaude TUI:"
echo -e "     ${YELLOW}openclaude${NC}"
echo ""
echo -e "  2. Exit (container will be removed):"
echo -e "     ${YELLOW}exit${NC} or ${YELLOW}Ctrl+D${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
