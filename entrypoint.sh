#!/bin/bash
# Advanced Coding Agent - Entrypoint Script
# Creates symlinks for OpenCode state storage before starting the main command

set -e

# Create the target directory for session state
mkdir -p /home/agent/workspace/.agent-memory/share

# Create symlink: .local/share -> workspace/.agent-memory/share
# This redirects all OpenCode state (sessions, databases, history) to .agent-memory
if [[ ! -L /home/agent/.local/share ]]; then
    rm -rf /home/agent/.local/share 2>/dev/null || true
    ln -s /home/agent/workspace/.agent-memory/share /home/agent/.local/share
    echo "✓ Created symlink: .local/share -> workspace/.agent-memory/share"
fi

# Create symlink: .local/share/opencode/auth.json -> .opencode/auth.json
# This redirects auth.json to the container-local location (not in .agent-memory)
if [[ ! -L /home/agent/.local/share/opencode/auth.json ]]; then
    mkdir -p /home/agent/.local/share/opencode
    ln -s /home/agent/.opencode/auth.json /home/agent/.local/share/opencode/auth.json
    echo "✓ Created symlink: .local/share/opencode/auth.json -> .opencode/auth.json"
fi

# Now execute the main command (opencode or bash)
exec "$@"
