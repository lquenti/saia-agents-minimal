#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Start Script
# =============================================================================
# Starts the OpenCode container with:
# - Current directory mounted as workspace
# - Session state persisted in .agent-memory/share/
# - Auth config mounted from .opencode/auth.json
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
IMAGE_NAME="advanced-coding-agent-opencode:latest"

# Load shared library functions
source "${SCRIPT_DIR}/scripts/docker-lib.sh"

# Decide whether docker needs sudo before anything calls it
setup_docker_cmd

# -----------------------------------------------------------------------------
# Select Image
# -----------------------------------------------------------------------------
selected_image="${IMAGE_NAME}"
echo -e "${GREEN}✓ Image: ${selected_image}${NC}"
echo ""

# -----------------------------------------------------------------------------
# Detect Host User (before sudo elevation)
# -----------------------------------------------------------------------------
HOST_UID=${SUDO_UID:-$(id -u)}
HOST_GID=${SUDO_GID:-$(id -g)}
HOST_USER=$(getent passwd ${HOST_UID} | cut -d: -f1)

echo -e "${GREEN}✓ Host user: ${HOST_USER} (UID: ${HOST_UID}, GID: ${HOST_GID})${NC}"

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

# Set up container and image names based on selection
ACTUAL_IMAGE_NAME="${selected_image}"

# Docker resolves "localhost/name" as a registry at localhost, so keep the
# plain local tag (the localhost/ prefix is a Podman-ism)
ACTUAL_IMAGE_NAME="${ACTUAL_IMAGE_NAME#localhost/}"

# Determine container name from image name
IMAGE_NAME_ONLY="${selected_image%:*}"
IMAGE_NAME_ONLY="${IMAGE_NAME_ONLY#localhost/}"
CONTAINER_NAME="${IMAGE_NAME_ONLY}"

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
# Generate OpenCode Config
# -----------------------------------------------------------------------------
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"
if [[ ! -f "${OPENCODE_DIR}/auth.json" ]] || [[ ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    echo -e "${YELLOW}⚠ Generating OpenCode config...${NC}"
    "${SCRIPT_DIR}/generate-opencode-config.sh" || exit 1
    # Hand the generated config back to the invoking user if we ran under sudo,
    # otherwise it stays root-owned and needs sudo to edit or regenerate
    chown -R ${HOST_UID}:${HOST_GID} "${OPENCODE_DIR}"
    echo ""
fi

# -----------------------------------------------------------------------------
# Prepare Auth Config
# -----------------------------------------------------------------------------

# Create symlink for auth.json in .agent-memory/share
mkdir -p "${MEMORY_SHARE_DIR}/opencode"
ln -sf ../../../../.opencode/auth.json "${MEMORY_SHARE_DIR}/opencode/auth.json"
chown -R ${HOST_UID}:${HOST_GID} "${MEMORY_SHARE_DIR}"
echo -e "${GREEN}✓ Symlink: .agent-memory/share/opencode/auth.json → .opencode/auth.json${NC}"

# -----------------------------------------------------------------------------
# Display Info
# -----------------------------------------------------------------------------
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Advanced Coding Agent - OpenCode Runtime${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚙️ PROJECT:${NC}"
echo -e "  Container: ${YELLOW}${CONTAINER_NAME}${NC} (auto-removes on exit)"
echo -e "  Project:   ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Workspace: ${YELLOW}/home/agent/workspace${NC} (mounted on local directory)"
echo -e "  Memory:    ${YELLOW}/home/agent/workspace/.agent-memory${NC}"
echo -e "  Image:     ${YELLOW}${selected_image}${NC}"
echo ""
echo -e "${YELLOW}🎯 NEXT STEPS:${NC}"
echo ""
echo -e "  ${GREEN}1) Start the agent:${NC}"
echo -e "     ${YELLOW}opencode${NC}"
echo ""
echo -e "  ${GREEN}2) Exit (container auto-removes):${NC}"
echo -e "     ${YELLOW}exit${NC} or ${YELLOW}Ctrl+D${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# -----------------------------------------------------------------------------
# Start Container
# -----------------------------------------------------------------------------
echo -e "${GREEN}🚀 Starting OpenCode container...${NC}"
echo ""

${DOCKER} run -it --rm \
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
    -v "${SCRIPT_DIR}/.opencode/auth.json:/home/agent/.opencode/auth.json:ro" \
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
