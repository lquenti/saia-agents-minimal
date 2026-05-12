#!/bin/bash
# Start OpenCode Coding Agent Container
# Mounts current folder as working directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/opencode"

echo "🪓 OpenCode Agent Startup Script"
echo "================================"
echo ""

# Check if we're in the right directory
if [ ! -f "${PROJECT_DIR}/Dockerfile" ]; then
    echo "❌ Error: OpenCode directory not found!"
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
    echo "🔨 Building OpenCode container..."
    cd "${PROJECT_DIR}"
    docker build -t opencode-agent .
    cd "${SCRIPT_DIR}"
elif [ "$(docker images -q opencode-agent 2>/dev/null)" == "" ]; then
    echo "🔨 Building OpenCode container (not found)..."
    cd "${PROJECT_DIR}"
    docker build -t opencode-agent .
    cd "${SCRIPT_DIR}"
fi

# Stop existing container if running
if [ "$(docker ps -q -f name=^opencode-agent$)" ]; then
    echo "⏹️  Stopping existing container..."
    docker stop opencode-agent
    docker rm opencode-agent
fi

echo "🚀 Starting OpenCode Agent..."
echo ""
echo "📁 Mounting current directory as workspace:"
echo "   ${PWD} → /home/agent/workspace/projects"
echo ""

# Start container
docker run -d \
    --name opencode-agent \
    --hostname opencode-agent \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,noexec,nosuid,size=100m \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --device-cgroup-rule='b 7:* rmw' \
    -v "${PWD}:/home/agent/workspace/projects:rw" \
    -v "${PROJECT_DIR}/.env:/home/agent/.opencode/.env:ro" \
    -v "${PROJECT_DIR}/docs:/home/agent/workspace/docs:ro" \
    --network none \
    --memory 4g \
    --memory-swap 4g \
    --cpus 2.0 \
    --pids-limit 100 \
    opencode-agent

echo "✅ Container started!"
echo ""
echo "📊 Container status:"
docker ps -f name=^opencode-agent$ --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "🔧 Commands:"
echo "   Enter container:  docker exec -it opencode-agent /bin/bash"
echo "   Start agent:      docker exec -it opencode-agent opencode"
echo "   View logs:        docker logs opencode-agent"
echo "   Stop container:   ./stop-opencode.sh"
echo ""
echo "🪓 WAAAGH! Happy coding!"
