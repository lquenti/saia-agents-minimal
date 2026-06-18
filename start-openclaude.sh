#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Start Script (OpenClaude Runtime)
# =============================================================================
# Starts the OpenClaude container with:
# - Current directory mounted as workspace
# - Session state persisted in .agent-memory/claude/
# - OpenClaude data in .openclaude/, .npm/, .openclaude.json
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CONTAINER_NAME="advanced-coding-agent-openclaude"
IMAGE_NAME="advanced-coding-agent-openclaude"
IMAGE_TAG="latest"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
    echo -e "${YELLOW}  Please run: sudo ./start-openclaude.sh${NC}"
    echo -e "${YELLOW}  Docker requires elevated permissions for volume mounts${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Load Environment
# -----------------------------------------------------------------------------
if [[ -f "${ENV_FILE}" ]]; then
    source "${ENV_FILE}"
    echo -e "${GREEN}✓ Loaded .env file${NC}"
else
    echo -e "${YELLOW}⚠ No .env file found${NC}"
    echo -e "${YELLOW}  Copy .env.example to .env and configure${NC}"
    echo -e "${YELLOW}  cp .env.example .env${NC}"
    exit 1
fi

# Validate required environment variables
if [[ -z "${OPENCLAUDE_API_KEY}" ]]; then
    echo -e "${RED}✗ ERROR: OPENCLAUDE_API_KEY not set in .env${NC}"
    echo -e "${YELLOW}  Please set your API key in .env file${NC}"
    exit 1
fi

if [[ -z "${MODEL}" ]]; then
    echo -e "${RED}✗ ERROR: MODEL not set in .env${NC}"
    echo -e "${YELLOW}  Please set your model in .env file${NC}"
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
# Check Docker Image
# -----------------------------------------------------------------------------
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
    echo -e "${YELLOW}  ./build-openclaude.sh${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Prepare Workspace
# -----------------------------------------------------------------------------
# Get current directory for mounting
CURRENT_DIR="$(pwd)"
PROJECT_NAME="$(basename "${CURRENT_DIR}")"

# Create memory directory for persistence
MEMORY_DIR="${CURRENT_DIR}/.agent-memory"
MEMORY_OPENCLAUDE_DIR="${MEMORY_DIR}/openclaude"
MEMORY_CLAUDE_DIR="${MEMORY_DIR}/claude"
MEMORY_NPM_DIR="${MEMORY_DIR}/npm"
mkdir -p "${MEMORY_CLAUDE_DIR}"
mkdir -p "${MEMORY_OPENCLAUDE_DIR}"
mkdir -p "${MEMORY_NPM_DIR}"
chown -R ${HOST_UID}:${HOST_GID} "${CURRENT_DIR}/.agent-memory"
echo -e "${GREEN}✓ Memory directory created: ${MEMORY_DIR}${NC}"

CLAUDE_DIR="${CURRENT_DIR}/.openclaude"
CLAUDE_SKILLS_DIR="${CLAUDE_DIR}/skills"
mkdir -p "${CLAUDE_SKILLS_DIR}"
chown -R ${HOST_UID}:${HOST_GID} "${CLAUDE_DIR}"
echo -e "${GREEN}✓ Skills directory created: ${CLAUDE_SKILLS_DIR}${NC}"

# -----------------------------------------------------------------------------
# Setup .gitignore
# -----------------------------------------------------------------------------
GITIGNORE_FILE="${CURRENT_DIR}/.gitignore"
GITIGNORE_ENTRIES=(
    ".agent-memory/"
    ".openclaude/"
)

if [[ ! -f "${GITIGNORE_FILE}" ]]; then
    echo -e "${YELLOW}⚠ No .gitignore found${NC}"
    echo -e "${YELLOW}  Create .gitignore with OpenClaude exclusions?${NC}"
    read -p "  Create? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > "${GITIGNORE_FILE}"
        chown ${HOST_UID}:${HOST_GID} "${GITIGNORE_FILE}"
        echo -e "${GREEN}✓ Created .gitignore (owned by ${HOST_USER})${NC}"
        for entry in "${GITIGNORE_ENTRIES[@]}"; do
            echo -e "${GREEN}  - ${entry}${NC}"
        done
    fi
    echo ""
else
    NEEDS_UPDATE=false
    MISSING_ENTRIES=()
    
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "${entry}" "${GITIGNORE_FILE}"; then
            NEEDS_UPDATE=true
            MISSING_ENTRIES+=("${entry}")
        fi
    done
    
    if [[ "$NEEDS_UPDATE" == "true" ]]; then
        echo -e "${YELLOW}⚠ .gitignore missing OpenClaude exclusions${NC}"
        echo -e "${YELLOW}  Missing:${NC}"
        for entry in "${MISSING_ENTRIES[@]}"; do
            echo -e "${YELLOW}    - ${entry}${NC}"
        done
        echo -e "${YELLOW}  Add them?${NC}"
        read -p "  Add? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo "" >> "${GITIGNORE_FILE}"
            for entry in "${MISSING_ENTRIES[@]}"; do
                echo "${entry}" >> "${GITIGNORE_FILE}"
            done
            chown ${HOST_UID}:${HOST_GID} "${GITIGNORE_FILE}"
            echo -e "${GREEN}✓ Added missing exclusions to .gitignore${NC}"
            for entry in "${MISSING_ENTRIES[@]}"; do
                echo -e "${GREEN}  - ${entry}${NC}"
            done
        fi
        echo ""
    else
        echo -e "${GREEN}✓ .gitignore already excludes OpenClaude files${NC}"
    fi
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
# Display Info
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Advanced Coding Agent - OpenClaude Runtime${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚙️ PROJECT:${NC}"
echo -e "  Container: ${YELLOW}${CONTAINER_NAME}${NC} (auto-removes on exit)"
echo -e "  Project:   ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Workspace: ${YELLOW}/home/agent/workspace${NC} (mounted on local directory)"
echo -e "  Memory:    ${YELLOW}/home/agent/workspace/.agent-memory${NC}"
echo -e "  Skills:    ${YELLOW}/home/agent/workspace/.openclaude/skills${NC}"
echo ""
echo -e "${YELLOW}🎯 NEXT STEPS:${NC}"
echo ""
echo -e "  ${GREEN}1) Start the agent:${NC}"
echo -e "     ${YELLOW}openclaude${NC}"
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
echo -e "${GREEN}🚀 Starting OpenClaude container...${NC}"
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
    -v "${CURRENT_DIR}:/home/agent/workspace:rw" \
    -e NODE_ENV=production \
    -e WORKSPACE=/home/agent/workspace \
    -e CLAUDE_CODE_USE_OPENAI="${CLAUDE_CODE_USE_OPENAI:-1}" \
    -e OPENAI_API_KEY="${OPENAI_API_KEY}" \
    -e OPENAI_BASE_URL="${OPENAI_BASE_URL}" \
    -e OPENAI_MODEL="${OPENAI_MODEL:-${MODEL}}" \
    -e MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}" \
    -e LOG_LEVEL="${LOG_LEVEL:-info}" \
    -e CLAUDE_CODE_USE_OPENAI="${CLAUDE_CODE_USE_OPENAI:-1}" \
    -e OPENAI_API_KEY="${OPENCLAUDE_API_KEY:-${OPENAI_API_KEY:-}}" \
    -e OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.openai.com/v1}" \
    -e OPENAI_MODEL="${OPENAI_MODEL:-${MODEL}}" \
    "${ACTUAL_IMAGE_NAME}"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ ERROR: Failed to start container${NC}"
    exit 1
fi
