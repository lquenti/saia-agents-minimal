#!/bin/bash
# Start OpenClaude Coding Agent Container
# Mounts current folder as working directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/openclaude"

echo "🪓 OpenClaude Agent Startup Script"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "${PROJECT_DIR}/Dockerfile" ]; then
    echo "❌ Error: OpenClaude directory not found!"
    echo "   Expected: ${PROJECT_DIR}"
    exit 1
fi

# Check if .env exists
if [ ! -f "${PROJECT_DIR}/.env" ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "   Copy .env.example to .env and configure your API keys"
    echo ""
    read -p "   Create .env from .env.example? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "${PROJECT_DIR}/.env.example" "${PROJECT_DIR}/.env"
        echo "✅ Created .env file. Edit it with your API keys!"
        echo ""
        echo "   nano ${PROJECT_DIR}/.env"
        exit 0
    else
        echo "❌ Please configure .env before running"
        exit 1
    fi
fi

# Build container if not exists or --build flag
if [ "$1" == "--build" ] || [ "$1" == "-b" ]; then
    echo "🔨 Building OpenClaude container..."
    cd "${PROJECT_DIR}"
    docker build -t openclaude-agent .
    cd "${SCRIPT_DIR}"
elif [ "$(docker images -q openclaude-agent 2>/dev/null)" == "" ]; then
    echo "🔨 Building OpenClaude container (not found)..."
    cd "${PROJECT_DIR}"
    docker build -t openclaude-agent .
    cd "${SCRIPT_DIR}"
fi

# Stop existing container if running
if [ "$(docker ps -q -f name=^openclaude-agent$)" ]; then
    echo "⏹️  Stopping existing container..."
    docker stop openclaude-agent
    docker rm openclaude-agent
fi

echo "🚀 Starting OpenClaude Agent..."
echo ""
echo "📁 Mounting current directory as workspace:"
echo "   ${PWD} → /home/agent/workspace/projects"
echo ""

# Fix ownership of mounted volumes to match container agent user (UID 1001)
echo "🔧 Fixing volume permissions..."
sudo chown -R 1001:1001 "${PWD}/projects" "${PWD}/docs" "${PWD}/memory" 2>/dev/null || true

# Start container
docker run -d \
    --name openclaude-agent \
    --hostname openclaude-agent \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,noexec,nosuid,size=100m \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --device-cgroup-rule='b 7:* rmw' \
    -v "${PWD}:/home/agent/workspace/projects:rw" \
    -v "${PROJECT_DIR}/.env:/home/agent/.openclaude/.env:ro" \
    -v "${PROJECT_DIR}/docs:/home/agent/workspace/docs:ro" \
    -v "${SCRIPT_DIR}/memory:/home/agent/workspace/memory:rw" \
    --network none \
    --memory 4g \
    --memory-swap 4g \
    --cpus 2.0 \
    --pids-limit 100 \
    openclaude-agent

echo "✅ Container started!"
echo ""
echo "📊 Container status:"
docker ps -f name=^openclaude-agent$ --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "🔧 Commands:"
echo "   Enter container:  docker exec -it openclaude-agent /bin/bash"
echo "   Start agent:      docker exec -it openclaude-agent openclaude"
echo "   View logs:        docker logs openclaude-agent"
echo "   Stop container:   ./stop-openclaude.sh"
echo ""
echo "🪓 WAAAGH! Happy coding!"
