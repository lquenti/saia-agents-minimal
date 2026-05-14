#!/bin/bash
# Advanced Coding Agent - Stop Script (OpenClaude Runtime)
# Cleans up any leftover container (container auto-removes on exit in new version)

set -e

CONTAINER_NAME="advanced-coding-agent"

echo -e "${YELLOW}⚠ Note: Container now auto-removes when you exit${NC}"
echo -e "${YELLOW}  This script only cleans up leftover containers${NC}"
echo ""

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠ Container '${CONTAINER_NAME}' found${NC}"
    read -p "Do you want to stop and remove it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop "${CONTAINER_NAME}" &>/dev/null || true
        docker rm "${CONTAINER_NAME}" &>/dev/null || true
        echo -e "${GREEN}✓ Container removed${NC}"
    else
        echo -e "${YELLOW}✗ Aborted${NC}"
    fi
else
    echo -e "${GREEN}✓ No container '${CONTAINER_NAME}' found (already cleaned up)${NC}"
fi
