#!/bin/bash
# Advanced Coding Agent - Start Script (OpenCode Runtime)
# Starts the OpenCode container with current directory mounted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CONTAINER_NAME="advanced-coding-agent-opencode"
IMAGE_NAME="advanced-coding-agent-opencode"
IMAGE_TAG="latest"

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

# Validate required environment variables
if [[ -z "${OPENCODE_API_KEY}" ]]; then
    echo -e "${RED}✗ ERROR: OPENCODE_API_KEY not set in .env${NC}"
    echo -e "${YELLOW}  Please set your API key in .env file${NC}"
    exit 1
fi

if [[ -z "${MODEL}" ]]; then
    echo -e "${RED}✗ ERROR: MODEL not set in .env${NC}"
    echo -e "${YELLOW}  Please set your model in .env file${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo -e "${RED}✗ ERROR: Docker is not running${NC}"
    exit 1
fi

# Check if image exists (handle podman's localhost/ prefix)
IMAGE_FULL_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
IMAGE_PODMAN_NAME="localhost/${IMAGE_NAME}:${IMAGE_TAG}"

if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_PODMAN_NAME}$"; then
    ACTUAL_IMAGE_NAME="${IMAGE_PODMAN_NAME}"
elif docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_FULL_NAME}$"; then
    ACTUAL_IMAGE_NAME="${IMAGE_FULL_NAME}"
else
    echo -e "${RED}✗ ERROR: Docker image not found${NC}"
    echo -e "${YELLOW}  Build the image first:${NC}"
    echo -e "${YELLOW}  ./build-opencode.sh${NC}"
    exit 1
fi

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠ Container '${CONTAINER_NAME}' already exists${NC}"
    echo -e "${YELLOW}  Removing old container...${NC}"
    docker stop "${CONTAINER_NAME}" &>/dev/null || true
    docker rm "${CONTAINER_NAME}" &>/dev/null || true
    echo -e "${GREEN}✓ Removed existing container${NC}"
fi

# Get current directory for mounting
CURRENT_DIR="$(pwd)"
PROJECT_NAME="$(basename "${CURRENT_DIR}")"

# Check and fix directory ownership for container agent user (UID 999)
echo -e "${YELLOW}Checking directory ownership...${NC}"
CURRENT_OWNER=$(stat -c '%u' "${CURRENT_DIR}")
if [[ "${CURRENT_OWNER}" != "999" ]]; then
    echo -e "${YELLOW}⚠ Directory owned by UID ${CURRENT_OWNER}, container expects UID 999${NC}"
    echo -e "${YELLOW}  Fixing ownership to allow container writes...${NC}"
    
    # Check if we have sudo access
    if [[ "$(id -u)" != "0" ]] && ! command -v sudo &>/dev/null; then
        echo -e "${RED}✗ ERROR: Not running as root and sudo not available${NC}"
        echo -e "${YELLOW}  Rootless Docker cannot map UIDs correctly${NC}"
        echo -e "${YELLOW}  Solution: Run this script with sudo:${NC}"
        echo -e "${YELLOW}    sudo ./start-opencode.sh${NC}"
        echo -e "${YELLOW}  Or manually fix ownership:${NC}"
        echo -e "${YELLOW}    sudo chown -R 999:999 ${CURRENT_DIR}${NC}"
        exit 1
    fi
    
    # Use sudo if not running as root
    if [[ "$(id -u)" != "0" ]]; then
        sudo chown -R 999:999 "${CURRENT_DIR}"
    else
        chown -R 999:999 "${CURRENT_DIR}"
    fi
    echo -e "${GREEN}✓ Ownership fixed${NC}"
else
    echo -e "${GREEN}✓ Directory ownership correct (UID 999)${NC}"
fi

# Create memory directory for persistence
MEMORY_DIR="${CURRENT_DIR}/.agent-memory"
mkdir -p "${MEMORY_DIR}"
echo -e "${GREEN}✓ Memory directory created: ${MEMORY_DIR}${NC}"

# Check if AGENTS.md exists, offer to create from template
if [[ ! -f "${CURRENT_DIR}/AGENTS.md" ]]; then
    echo -e "${YELLOW}⚠ No AGENTS.md found in project root${NC}"
    echo -e "${YELLOW}  AGENTS.md provides persistent memory across sessions${NC}"
    echo ""
    echo -e "${YELLOW}Choose template:${NC}"
    echo -e "  ${GREEN}1${NC}) Generic project template"
    echo -e "  ${GREEN}2${NC}) Python/uv project template (includes ruff, mypy, pytest)"
    echo -e "  ${GREEN}n${NC}) Skip (create later)"
    echo ""
    read -p "  Selection [1/2/n]: " -n 1 -r
    echo
    case $REPLY in
        [1])
            cp "${SCRIPT_DIR}/templates/AGENTS.md" "${CURRENT_DIR}/AGENTS.md"
            echo -e "${GREEN}✓ Created AGENTS.md (generic template)${NC}"
            echo -e "${YELLOW}  Edit AGENTS.md to customize for your project${NC}"
            ;;
        [2])
            cp "${SCRIPT_DIR}/templates/AGENTS.md-python" "${CURRENT_DIR}/AGENTS.md"
            echo -e "${GREEN}✓ Created AGENTS.md (Python/uv template)${NC}"
            echo -e "${YELLOW}  Edit AGENTS.md to customize for your project${NC}"
            ;;
        [nN]|"")
            echo -e "${YELLOW}  Skipping (you can create AGENTS.md later)${NC}"
            ;;
        *)
            echo -e "${YELLOW}  Invalid selection, skipping${NC}"
            ;;
    esac
    echo ""
fi

# Start the container
echo -e "${GREEN}🚀 Starting OpenCode container...${NC}"
echo ""

docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    --hostname coding-agent \
    --user agent \
    -v "${ENV_FILE}:/home/agent/.opencode/.env:ro" \
    -v "${SCRIPT_DIR}/agents.json:/home/agent/.opencode/agents.json:ro" \
    -v "${SCRIPT_DIR}/tools.md:/home/agent/.opencode/workspace/tools.md:ro" \
    -v "${CURRENT_DIR}:/home/agent/workspace/projects/${PROJECT_NAME}:rw" \
    -v "${SCRIPT_DIR}/docs:/home/agent/workspace/docs:ro" \
    -v "${MEMORY_DIR}:/home/agent/.opencode/memory:rw" \
    -e NODE_ENV=production \
    -e WORKSPACE=/home/agent/workspace \
    -e HOME=/home/agent/workspace/projects/${PROJECT_NAME} \
    -e OPENCODE_HOME=/home/agent/.opencode \
    -e MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}" \
    -e LOG_LEVEL="${LOG_LEVEL:-info}" \
    "${ACTUAL_IMAGE_NAME}"

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
echo -e "${GREEN}  Advanced Coding Agent - OpenCode Runtime${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Container: ${YELLOW}${CONTAINER_NAME}${NC} (auto-removes on exit)"
echo -e "  Project:   ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Workspace: ${YELLOW}/home/agent/workspace/projects/${PROJECT_NAME}${NC}"
echo -e "  Memory:    ${YELLOW}/home/agent/.opencode/memory${NC} → ${MEMORY_DIR}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo -e "  1. Start the OpenCode TUI:"
echo -e "     ${YELLOW}opencode${NC}"
echo ""
echo -e "  2. Exit (container will be removed):"
echo -e "     ${YELLOW}exit${NC} or ${YELLOW}Ctrl+D${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
