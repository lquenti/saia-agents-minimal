#!/bin/bash
# Advanced Coding Agent - Cleanup Script (OpenClaude Runtime)
# ONLY needed if container got orphaned (normal use: container auto-removes on exit)

set -e

CONTAINER_NAME="advanced-coding-agent"

echo -e "${YELLOW}⚠ Normal use: Container auto-removes when you exit bash${NC}"
echo -e "${YELLOW}  Only run this if container is stuck/orphaned${NC}"
echo ""

# Check if container exists (running or stopped)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}⚠ Orphaned container '${CONTAINER_NAME}' found${NC}"
    echo -e "${RED}  This shouldn't happen - container should auto-remove${NC}"
    read -p "Clean it up? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop "${CONTAINER_NAME}" &>/dev/null || true
        docker rm "${CONTAINER_NAME}" &>/dev/null || true
        echo -e "${GREEN}✓ Orphaned container removed${NC}"
    else
        echo -e "${YELLOW}✗ Aborted${NC}"
    fi
else
    echo -e "${GREEN}✓ No orphaned containers (everything clean)${NC}"
fi
