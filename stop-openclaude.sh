#!/bin/bash
# Stop OpenClaude Agent Container

echo "🛑 Stopping OpenClaude Agent..."
echo ""

if [ "$(docker ps -q -f name=^openclaude-agent$)" ]; then
    docker stop openclaude-agent
    docker rm openclaude-agent
    echo "✅ Container stopped and removed"
else
    echo "⚠️  Container not running"
fi

echo ""
echo "📊 Remaining containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"
