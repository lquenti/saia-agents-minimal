# Build & Start Scripts

This document explains the difference between build and start scripts.

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `build-opencode.sh` | Build OpenCode Docker image | First time, or when Dockerfile changes |
| `build-openclaude.sh` | Build OpenClaude Docker image | First time, or when Dockerfile changes |
| `start-opencode.sh` | Start OpenCode container | Every time you want to use the agent |
| `start-openclaude.sh` | Start OpenClaude container | Every time you want to use the agent |

---

## Workflow

### First Time Setup

```bash
# 1. Clone repository
git clone https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent.git
cd advanced-coding-agent

# 2. Configure environment
cp .env.example .env
nano .env  # Set API keys and model

# 3. Build Docker image (takes 2-5 minutes)
./build-opencode.sh

# 4. Start container
./start-opencode.sh

# 5. Use agent
opencode
```

### Subsequent Use

```bash
# Just start the container (no rebuild needed!)
./start-opencode.sh

# Use agent
opencode

# Exit (container auto-removes)
exit
```

### Rebuild (When Dockerfile Changes)

```bash
# Rebuild image
./build-opencode.sh

# Start container
./start-opencode.sh
```

---

## Build Scripts

### build-opencode.sh

Builds the OpenCode Docker image.

**What it does:**
- Reads `Dockerfile.opencode`
- Creates image: `advanced-coding-agent:latest`
- Installs all dependencies (Node.js, Python, uv, skills)

**When to run:**
- First time setup
- After modifying `Dockerfile.opencode`
- To update base packages

**Output:**
```
🔨 Building OpenCode Docker image...
  Dockerfile: /path/to/Dockerfile.opencode
  Image: advanced-coding-agent:latest

✓ OpenCode image built successfully
  Image: advanced-coding-agent:latest

Next: Run ./start-opencode.sh to start the container
```

---

### build-openclaude.sh

Builds the OpenClaude Docker image.

**What it does:**
- Reads `Dockerfile.openclaude`
- Creates image: `advanced-coding-agent:openclaude`
- Installs all dependencies (Node.js, Python, uv, skills)

**When to run:**
- First time setup
- After modifying `Dockerfile.openclaude`
- To update base packages

**Output:**
```
🔨 Building OpenClaude Docker image...
  Dockerfile: /path/to/Dockerfile.openclaude
  Image: advanced-coding-agent:openclaude

✓ OpenClaude image built successfully
  Image: advanced-coding-agent:openclaude

Next: Run ./start-openclaude.sh to start the container
```

---

## Start Scripts

### start-opencode.sh

Starts the OpenCode container with your project mounted.

**What it does:**
- Checks if Docker image exists
- Creates `.agent-memory/` directory in current project
- Starts container with all volumes mounted
- Runs interactive bash shell

**Container configuration:**
- User: `agent` (non-root)
- Filesystem: Read-only (except mounted volumes)
- Memory: 4GB max
- CPU: 2 cores max
- Network: Isolated (disabled)
- Auto-remove: Yes (--rm flag)

**Volumes mounted:**
- Your current directory → `/home/agent/workspace/projects/<project>`
- `agents.json` → `/home/agent/.opencode/agents.json` (read-only)
- `tools.md` → `/home/agent/.opencode/workspace/tools.md` (read-only)
- `docs/` → `/home/agent/workspace/docs` (read-only)
- `.agent-memory/` → `/home/agent/.opencode/memory` (read-write)

**Output:**
```
✓ Loaded .env file
✓ Memory directory created: /path/to/project/.agent-memory

🚀 Starting OpenCode container...

═══════════════════════════════════════════════════════════
  Advanced Coding Agent - OpenCode Runtime
═══════════════════════════════════════════════════════════

  Container: advanced-coding-agent (auto-removes on exit)
  Project:   my-project
  Workspace: /home/agent/workspace/projects/my-project
  Memory:    /home/agent/.opencode/memory → /path/to/project/.agent-memory

Next steps:

  1. Start the OpenCode TUI:
     opencode

  2. Exit (container will be removed):
     exit or Ctrl+D

═══════════════════════════════════════════════════════════
```

---

### start-openclaude.sh

Starts the OpenClaude container with your project mounted.

**What it does:**
- Checks if Docker image exists
- Creates `.agent-memory/` directory in current project
- Starts container with all volumes mounted
- Runs interactive bash shell

**Container configuration:**
- User: `agent` (non-root)
- Filesystem: Read-only (except mounted volumes)
- Memory: 4GB max
- CPU: 2 cores max
- Network: Isolated (disabled)
- Auto-remove: Yes (--rm flag)

**Volumes mounted:**
- Your current directory → `/home/agent/workspace/projects/<project>`
- `agents.json` → `/home/agent/.openclaude/agents.json` (read-only)
- `tools.md` → `/home/agent/.openclaude/workspace/tools.md` (read-only)
- `docs/` → `/home/agent/workspace/docs` (read-only)
- `.agent-memory/` → `/home/agent/.openclaude/memory` (read-write)

**Output:**
```
✓ Loaded .env file
✓ Memory directory created: /path/to/project/.agent-memory

🚀 Starting OpenClaude container...

═══════════════════════════════════════════════════════════
  Advanced Coding Agent - OpenClaude Runtime
═══════════════════════════════════════════════════════════

  Container: advanced-coding-agent (auto-removes on exit)
  Project:   my-project
  Workspace: /home/agent/workspace/projects/my-project
  Memory:    /home/agent/.openclaude/memory → /path/to/project/.agent-memory

Next steps:

  1. Start the OpenClaude TUI:
     openclaude

  2. Exit (container will be removed):
     exit or Ctrl+D

═══════════════════════════════════════════════════════════
```

---

## Troubleshooting

### "Docker image not found"

```bash
# Build the image first
./build-opencode.sh
# or
./build-openclaude.sh
```

### "Docker is not running"

```bash
# Start Docker daemon
# On Linux:
sudo systemctl start docker

# On macOS:
# Open Docker Desktop

# On Windows:
# Open Docker Desktop
```

### "Container already exists"

The start script automatically removes existing containers. If you see this warning:

```
⚠ Container 'advanced-coding-agent' already exists
  Removing old container...
✓ Removed existing container
```

This is normal and handled automatically.

### Rebuild Needed

If you modified `Dockerfile.*` but changes aren't reflected:

```bash
# Rebuild the image
./build-opencode.sh
# or
./build-openclaude.sh
```

---

## Advanced Usage

### Build Without Output

```bash
./build-opencode.sh 2>&1 | tail -5
```

### Check Image Exists

```bash
docker images | grep advanced-coding-agent
```

### Manual Docker Commands

```bash
# List images
docker images

# Remove old image
docker rmi advanced-coding-agent:latest

# Run without script
docker run -it --rm advanced-coding-agent:latest /bin/bash
```

---

## Best Practices

1. **Build once, start many times** - Don't rebuild unless Dockerfile changes
2. **Use .agent-memory/** - Store session notes for persistence
3. **Exit properly** - Use `exit` or `Ctrl+D` to clean up
4. **Check Docker first** - Ensure Docker is running before building
5. **Keep .env secure** - Never commit `.env` to git

---

**Related:**
- [Configuration Guide](CONFIGURATION.md)
- [Quick Start](../README.md#-quick-start)
- [Security](SECURITY.md)
