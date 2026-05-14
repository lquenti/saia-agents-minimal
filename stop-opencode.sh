#!/bin/bash
# Advanced Coding Agent - Stop Script (OpenCode Runtime)

set -e

CONTAINER_NAME="advanced-coding-agent"

echo -e "🛑 Stopping Advanced Coding Agent (OpenCode)..."

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "⚠ Container '${CONTAINER_NAME}' not found"
    exit 0
fi

# Stop the container
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "Stopping container..."
    docker stop "${CONTAINER_NAME}"
fi

# Remove the container
echo -e "Removing container..."
docker rm "${CONTAINER_NAME}"

echo -e "✓ Container stopped and removed"
