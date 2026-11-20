#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Docker Helpers
# =============================================================================
# Small shared helpers for the build and start scripts.
# =============================================================================

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------
declare -gr RED='\033[0;31m'
declare -gr GREEN='\033[0;32m'
declare -gr YELLOW='\033[1;33m'
declare -gr NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Decide how to invoke docker, once, and set DOCKER for every call site
#
# Probing with `docker info` rather than checking docker group membership also
# covers rootless installs and a DOCKER_HOST pointing elsewhere, neither of
# which involves that group. No password is asked for here: sudo prompts at the
# first docker command that actually needs it.
# Usage: setup_docker_cmd   (then use "${DOCKER} build ..." etc.)
# -----------------------------------------------------------------------------
setup_docker_cmd() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}✗ ERROR: docker not found in PATH${NC}" >&2
        echo -e "${YELLOW}  Install it: https://docs.docker.com/engine/install/${NC}" >&2
        exit 1
    fi

    if [[ "$(id -u)" -eq 0 ]] || docker info &>/dev/null; then
        DOCKER="docker"
    else
        DOCKER="sudo docker"
        echo -e "${YELLOW}⚠ No access to the Docker socket, so docker will be run with sudo${NC}"
        echo -e "${YELLOW}  To avoid the prompt: sudo usermod -aG docker \$USER${NC}"
        echo -e "${YELLOW}  (then log out and back in, or run: newgrp docker)${NC}"
        echo ""
    fi
}
