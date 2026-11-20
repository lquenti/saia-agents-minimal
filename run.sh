#!/bin/bash
# Run OpenCode in docker with the current directory at /home/agent/workspace.
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
IMAGE=lquenti-saia-agents-minimal:latest
CONTAINER=lquenti-saia-agents-minimal
OPENCODE_DIR="$SCRIPT_DIR/.opencode"

# Checks:
# .env is required for the API key and model
[ -f "$SCRIPT_DIR/.env" ] || { echo "no .env (cp .env.example .env)" >&2; exit 1; }

set -a
. "$SCRIPT_DIR/.env"
set +a

# key and model must be set before we start anything
[ -n "$OPENCODE_API_KEY" ] || { echo "OPENCODE_API_KEY not set" >&2; exit 1; }
[ -n "$MODEL" ] || { echo "MODEL not set" >&2; exit 1; }

# write opencode.json (and discover models) if it is missing
if [ ! -f "$OPENCODE_DIR/opencode.json" ]; then
    python3 "$SCRIPT_DIR/gen-config.py"
fi

CURRENT_DIR=$(pwd)
SHARE_DIR="$CURRENT_DIR/.agent-memory/share"
mkdir -p "$SHARE_DIR/opencode"

exec docker run -it --rm \
    --name "$CONTAINER" \
    --hostname coding-agent \
    --user agent \
    --cap-drop ALL \
    --cap-add NET_BIND_SERVICE \
    --cap-add NET_RAW \
    --security-opt no-new-privileges:true \
    --tmpfs /tmp:rw,exec,nosuid,size=4g \
    --tmpfs /var/run:rw,noexec,nosuid,size=10m \
    --memory 4g --memory-swap 4g --cpus 2.0 \
    -v "$OPENCODE_DIR/opencode.json:/home/agent/.config/opencode/opencode.json:ro" \
    -v "$CURRENT_DIR:/home/agent/workspace:rw" \
    -v "$SHARE_DIR:/home/agent/workspace/.agent-memory/share:rw" \
    -e SAIA_API_KEY="$OPENCODE_API_KEY" \
    "$IMAGE"
