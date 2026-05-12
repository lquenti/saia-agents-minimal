#!/bin/bash
# Stop OpenCode Agent Container

echo "🛑 Stopping OpenCode Agent..."
echo ""

if [ "$(docker ps -q -f name=^opencode-agent$)" ]; then
    docker stop opencode-agent
    docker rm opencode-agent
    echo "✅ Container stopped and removed"
else
    echo "⚠️  Container not running"
fi

echo ""
echo "📊 Remaining containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"
