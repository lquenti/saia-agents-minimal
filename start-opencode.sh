#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Start Script
# =============================================================================
# Starts the OpenCode container with:
# - Current directory mounted as workspace
# - Session state persisted in .agent-memory/share/
# - Auth config mounted from .opencode/local/auth.json
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CONTAINER_NAME="advanced-coding-agent-opencode"
IMAGE_NAME="advanced-coding-agent-opencode"
IMAGE_TAG="latest"

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
HOST_USER=$(getent passwd ${HOST_UID} | cut -d: -f1)

echo -e "${GREEN}✓ Host user: ${HOST_USER} (UID: ${HOST_UID}, GID: ${HOST_GID})${NC}"

# -----------------------------------------------------------------------------
# Check Root Privileges
# -----------------------------------------------------------------------------
if [[ "$(id -u)" != "0" ]]; then
    echo -e "${RED}✗ ERROR: This script must be run with sudo${NC}"
    echo -e "${YELLOW}  Please run: sudo ./start-opencode.sh${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Load Environment
# -----------------------------------------------------------------------------
if [[ ! -f "${ENV_FILE}" ]]; then
    echo -e "${YELLOW}⚠ No .env file found${NC}"
    echo -e "${YELLOW}  Copy .env.example to .env and configure${NC}"
    exit 1
fi

source "${ENV_FILE}"
echo -e "${GREEN}✓ Loaded .env file${NC}"

# Validate required variables
if [[ -z "${OPENCODE_API_KEY}" ]]; then
    echo -e "${RED}✗ ERROR: OPENCODE_API_KEY not set in .env${NC}"
    exit 1
fi

if [[ -z "${MODEL}" ]]; then
    echo -e "${RED}✗ ERROR: MODEL not set in .env${NC}"
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
# Check Image Exists
# -----------------------------------------------------------------------------
IMAGE_FULL_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
IMAGE_PODMAN_NAME="localhost/${IMAGE_NAME}:${IMAGE_TAG}"

if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_PODMAN_NAME}$"; then
    ACTUAL_IMAGE_NAME="${IMAGE_PODMAN_NAME}"
elif docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_FULL_NAME}$"; then
    ACTUAL_IMAGE_NAME="${IMAGE_FULL_NAME}"
else
    echo -e "${RED}✗ ERROR: Docker image not found${NC}"
    echo -e "${YELLOW}  Build first: ./build-opencode.sh${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Setup Project Structure
# -----------------------------------------------------------------------------
CURRENT_DIR="$(pwd)"
PROJECT_NAME="$(basename "${CURRENT_DIR}")"

# Create memory directory for persistence
MEMORY_DIR="${CURRENT_DIR}/.agent-memory"
MEMORY_SHARE_DIR="${MEMORY_DIR}/share"
mkdir -p "${MEMORY_SHARE_DIR}"
chown ${HOST_UID}:${HOST_GID} "${MEMORY_DIR}" "${MEMORY_SHARE_DIR}"
echo -e "${GREEN}✓ Memory directory: ${MEMORY_SHARE_DIR} (owned by ${HOST_USER})${NC}"

# -----------------------------------------------------------------------------
# Setup .gitignore
# -----------------------------------------------------------------------------
GITIGNORE_FILE="${CURRENT_DIR}/.gitignore"
if [[ ! -f "${GITIGNORE_FILE}" ]]; then
    echo -e "${YELLOW}⚠ No .gitignore found${NC}"
    echo -e "${YELLOW}  Create .gitignore with .agent-memory/ excluded?${NC}"
    read -p "  Create? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo ".agent-memory/" > "${GITIGNORE_FILE}"
        chown ${HOST_UID}:${HOST_GID} "${GITIGNORE_FILE}"
        echo -e "${GREEN}✓ Created .gitignore (owned by ${HOST_USER})${NC}"
    fi
    echo ""
elif ! grep -q "\.agent-memory" "${GITIGNORE_FILE}"; then
    echo -e "${YELLOW}⚠ .gitignore missing .agent-memory/ exclusion${NC}"
    echo -e "${YELLOW}  Add it?${NC}"
    read -p "  Add? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "" >> "${GITIGNORE_FILE}"
        echo ".agent-memory/" >> "${GITIGNORE_FILE}"
        chown ${HOST_UID}:${HOST_GID} "${GITIGNORE_FILE}"
        echo -e "${GREEN}✓ Added .agent-memory/ to .gitignore${NC}"
    fi
    echo ""
else
    echo -e "${GREEN}✓ .gitignore already excludes .agent-memory${NC}"
fi

# -----------------------------------------------------------------------------
# Setup AGENTS.md
# -----------------------------------------------------------------------------
if [[ ! -f "${CURRENT_DIR}/AGENTS.md" ]]; then
    echo -e "${YELLOW}⚠ No AGENTS.md found${NC}"
    echo -e "${YELLOW}  AGENTS.md provides persistent memory across sessions${NC}"
    echo ""
    echo -e "${YELLOW}Choose template:${NC}"
    echo -e "  ${GREEN}1${NC}) Generic project"
    echo -e "  ${GREEN}2${NC}) Python/uv project (ruff, mypy, pytest)"
    echo -e "  ${GREEN}n${NC}) Skip"
    echo ""
    read -p "  Selection [1/2/n]: " -n 1 -r
    echo
    case $REPLY in
        [1])
            cp "${SCRIPT_DIR}/templates/AGENTS.md" "${CURRENT_DIR}/AGENTS.md"
            chown ${HOST_UID}:${HOST_GID} "${CURRENT_DIR}/AGENTS.md"
            echo -e "${GREEN}✓ Created AGENTS.md (owned by ${HOST_USER})${NC}"
            ;;
        [2])
            cp "${SCRIPT_DIR}/templates/AGENTS.md-python" "${CURRENT_DIR}/AGENTS.md"
            chown ${HOST_UID}:${HOST_GID} "${CURRENT_DIR}/AGENTS.md"
            echo -e "${GREEN}✓ Created AGENTS.md (Python template, owned by ${HOST_USER})${NC}"
            ;;
        *)
            echo -e "${YELLOW}  Skipping${NC}"
            ;;
    esac
    echo ""
else
    echo -e "${GREEN}✓ AGENTS.md exists${NC}"
fi

# -----------------------------------------------------------------------------
# Generate OpenCode Config
# -----------------------------------------------------------------------------
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"
if [[ ! -f "${OPENCODE_DIR}/auth.json" ]] || [[ ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    echo -e "${YELLOW}⚠ Generating OpenCode config...${NC}"
    "${SCRIPT_DIR}/generate-opencode-config.sh" || exit 1
    echo ""
fi

# -----------------------------------------------------------------------------
# Prepare Auth Config
# -----------------------------------------------------------------------------
mkdir -p "${SCRIPT_DIR}/.opencode/local"
echo "${OPENCODE_API_KEY}" | jq -R '{"apiKey": .}' > "${SCRIPT_DIR}/.opencode/local/auth.json"
chmod 644 "${SCRIPT_DIR}/.opencode/local/auth.json"
chown ${HOST_UID}:${HOST_GID} "${SCRIPT_DIR}/.opencode/local/auth.json"
echo -e "${GREEN}✓ Auth config: ${SCRIPT_DIR}/.opencode/local/auth.json${NC}"

# Create symlink for auth.json in .agent-memory/share
mkdir -p "${MEMORY_SHARE_DIR}/opencode"
ln -sf ../../../.opencode/auth.json "${MEMORY_SHARE_DIR}/opencode/auth.json"
echo -e "${GREEN}✓ Symlink: .agent-memory/share/opencode/auth.json → .opencode/auth.json${NC}"

# Create skills directory and symlink for custom skills
SKILLS_DIR="${MEMORY_SHARE_DIR}/skills"
mkdir -p "${SKILLS_DIR}"
chown ${HOST_UID}:${HOST_GID} "${SKILLS_DIR}"
ln -sf ../../../.config/opencode/skills "${SKILLS_DIR}"
echo -e "${GREEN}✓ Symlink: .agent-memory/share/skills → .config/opencode/skills${NC}"
echo -e "${YELLOW}  Add custom skills to: ${SKILLS_DIR}${NC}"
# -----------------------------------------------------------------------------
# Display Info
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Advanced Coding Agent - OpenCode Runtime${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚙️ PROJECT:${NC}"
echo -e "  Container: ${YELLOW}${CONTAINER_NAME}${NC} (auto-removes on exit)"
echo -e "  Project:   ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Workspace: ${YELLOW}/home/agent/workspace${NC}"
echo -e "  Memory:    ${YELLOW}${MEMORY_SHARE_DIR}${NC}"
echo -e "  State:     ${YELLOW}.local/share${NC} → workspace/.agent-memory/share"
echo -e "  Auth:      ${YELLOW}/home/agent/.opencode/auth.json${NC} (container-local)"
echo ""
echo -e "${YELLOW}🎯 NEXT STEPS:${NC}"
echo ""
echo -e "  ${GREEN}1) Start the agent:${NC}"
echo -e "     ${YELLOW}opencode${NC}"
echo ""
echo -e "  ${GREEN}2) Exit (container auto-removes):${NC}"
echo -e "     ${YELLOW}exit${NC} or ${YELLOW}Ctrl+D${NC}"
echo ""
echo -e "${YELLOW}🛠️ USEFUL SKILLS:${NC}"
echo -e "  /interview-me    - Extract requirements one question at a time"
echo -e "  /grill-with-docs - Build shared language + CONTEXT.md"
echo -e "  /spec            - Write PRD before any code"
echo -e "  /plan            - Break into small, verifiable tasks"
echo -e "  /test            - TDD with 80/15/5 test pyramid"
echo -e "  /build           - Thin vertical slices"
echo -e "  /review          - Five-axis code review"
echo -e "  /code-simplify   - Reduce complexity"
echo -e "  /ship            - Pre-launch checklist"
echo -e "  /understand      - Codebase analysis & knowledge graph"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# -----------------------------------------------------------------------------
# Start Container
# -----------------------------------------------------------------------------
echo -e "${GREEN}🚀 Starting OpenCode container...${NC}"
echo ""

docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    --hostname coding-agent \
    --user agent \
    --cap-drop ALL \
    --cap-add NET_BIND_SERVICE \
    --cap-add NET_RAW \
    --security-opt no-new-privileges:true \
    --tmpfs /tmp:rw,nosuid,size=100m \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --memory 4g \
    --memory-swap 4g \
    --cpus 2.0 \
    -v "${SCRIPT_DIR}/agents.json:/home/agent/.opencode/agents.json:ro" \
    -v "${OPENCODE_DIR}/opencode.json:/home/agent/.config/opencode/opencode.json:ro" \
    -v "${SCRIPT_DIR}/.opencode/local/auth.json:/home/agent/.opencode/auth.json:ro" \
    -v "${CURRENT_DIR}:/home/agent/workspace:rw" \
    -v "${MEMORY_SHARE_DIR}:/home/agent/workspace/.agent-memory/share:rw" \
    -e NODE_ENV=production \
    -e WORKSPACE=/home/agent/workspace \
    -e OPENAI_API_KEY="${OPENCODE_API_KEY}" \
    -e OPENAI_BASE_URL="${OPENAI_BASE_URL}" \
    -e MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}" \
    -e LOG_LEVEL="${LOG_LEVEL:-info}" \
    "${ACTUAL_IMAGE_NAME}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Failed to start container${NC}"
    exit 1
fi
