#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Build Script
# =============================================================================
# Builds the OpenCode Docker image with host UID/GID for proper file ownership
# Supports base image and extension builds with interactive menu
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.opencode"
RUNTIME="opencode"
BASE_IMAGE_NAME="advanced-coding-agent-opencode"

# Load shared library functions
source "${SCRIPT_DIR}/scripts/docker-lib.sh"

# -----------------------------------------------------------------------------
# Discover Extension Dockerfiles
# -----------------------------------------------------------------------------
extensions=($(discover_extensions "${RUNTIME}" "${SCRIPT_DIR}"))

# -----------------------------------------------------------------------------
# Display Menu and Get User Selection
# -----------------------------------------------------------------------------
selection=$(display_build_menu "${RUNTIME}" "${extensions[@]}")

if [[ "${selection}" == "exit" ]]; then
    echo -e "${YELLOW}Build cancelled${NC}"
    exit 0
fi

# Display what was selected
echo -e "${GREEN}✓ Selection: ${selection^}${NC}"
echo ""

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
# Check Base Dockerfile
# -----------------------------------------------------------------------------
if [[ ! -f "${DOCKERFILE}" ]]; then
    echo -e "${RED}✗ ERROR: Base Dockerfile not found: ${DOCKERFILE}${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Base Image Build Function
# -----------------------------------------------------------------------------
build_base_image() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Building Base Image${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${GREEN}🔨 Building OpenCode base Docker image...${NC}"
    echo -e "${YELLOW}  Dockerfile: ${DOCKERFILE}${NC}"
    echo -e "${YELLOW}  Image: ${BASE_IMAGE_NAME}:latest${NC}"
    echo -e "${YELLOW}  Host UID/GID: ${HOST_UID}/${HOST_GID}${NC}"
    echo ""

    docker build \
        --build-arg HOST_UID=${HOST_UID} \
        -f "${DOCKERFILE}" \
        -t "${BASE_IMAGE_NAME}:latest" \
        "${SCRIPT_DIR}"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✗ ERROR: Base image build failed${NC}"
        return 1
    fi

    echo ""
    echo -e "${GREEN}✓ Base image built successfully${NC}"
    echo -e "${GREEN}  Image: ${BASE_IMAGE_NAME}:latest${NC}"
    return 0
}

# -----------------------------------------------------------------------------
# Extension Image Build Function
# -----------------------------------------------------------------------------
build_extension_image() {
    local extension="$1"
    local ext_dockerfile="${SCRIPT_DIR}/dockerfiles/Dockerfile.${extension}"
    local ext_image_name="${BASE_IMAGE_NAME}-${extension}"
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Building Extension: ${extension^}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ ! -f "${ext_dockerfile}" ]]; then
        echo -e "${RED}✗ ERROR: Extension Dockerfile not found: ${ext_dockerfile}${NC}"
        return 1
    fi
    
    # Verify base image exists
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${BASE_IMAGE_NAME}:latest$\|^localhost/${BASE_IMAGE_NAME}:latest$"; then
        echo -e "${RED}✗ ERROR: Base image not found: ${BASE_IMAGE_NAME}:latest${NC}"
        echo -e "${YELLOW}  Building base image first...${NC}"
        if ! build_base_image; then
            return 1
        fi
    fi
    
    echo -e "${GREEN}🔨 Building ${extension^} extension Docker image...${NC}"
    echo -e "${YELLOW}  Dockerfile: ${ext_dockerfile}${NC}"
    echo -e "${YELLOW}  Image: ${ext_image_name}:latest${NC}"
    echo ""

    docker build \
        --build-arg HOST_UID=${HOST_UID} \
        --build-arg BASE_IMAGE=${BASE_IMAGE_NAME}:latest \
        -f "${ext_dockerfile}" \
        -t "${ext_image_name}:latest" \
        "${SCRIPT_DIR}"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✗ ERROR: Extension image build failed${NC}"
        return 1
    fi

    echo ""
    echo -e "${GREEN}✓ Extension image built successfully${NC}"
    echo -e "${GREEN}  Image: ${ext_image_name}:latest${NC}"
    return 0
}

# -----------------------------------------------------------------------------
# Execute Build Based on Selection
# -----------------------------------------------------------------------------
build_success=true

case "${selection}" in
    "base")
        build_base_image || build_success=false
        ;;
    "all")
        echo -e "${YELLOW}Building all images...${NC}"
        build_base_image || build_success=false
        
        for ext in "${extensions[@]}"; do
            build_extension_image "${ext}" || build_success=false
        done
        ;;
    *)
        # Selected extension
        # Always build base first, then the selected extension
        build_base_image || build_success=false
        build_extension_image "${selection}" || build_success=false
        ;;
esac

# -----------------------------------------------------------------------------
# Final Status
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
if [[ "${build_success}" == "true" ]]; then
    echo -e "${GREEN}  Build Process Completed Successfully${NC}"
    
    # Display built images (optional, doesn't fail if Docker not available)
    echo ""
    echo -e "${YELLOW}Built Images:${NC}"
    if docker images &>/dev/null; then
        docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "(^|/)advanced-coding-agent-${RUNTIME}" | sed 's/^/  /' || echo -e "${YELLOW}  No ${RUNTIME} images found yet${NC}"
    else
        echo -e "${YELLOW}  Docker not available to list images${NC}"
    fi
else
    echo -e "${RED}  Build Process Completed with Errors${NC}"
    exit 1
fi
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Next: Run sudo ./start-${RUNTIME}.sh to start the container${NC}"
