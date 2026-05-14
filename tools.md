# TOOLS.md - Advanced Coding Agent Tools

## Runtime Support

This agent supports two runtimes:
- **OpenCode** - Open-source coding agent CLI
- **OpenClaude** - Claude-based coding agent CLI

Select your runtime in `.env` before starting.

## Pre-installed Skills

### Core Development
| Skill | Description |
|-------|-------------|
| **github** | GitHub integration (issues, PRs, repos) |
| **git** | Git operations (commit, push, pull, branch) |
| **fileops** | File operations (read, write, edit, search) |
| **shell** | Safe shell commands (limited subset) |
| **web** | Web fetching and searching |

### Code Quality
| Skill | Description |
|-------|-------------|
| **diffs** | Generate shareable code diffs |
| **session-logs** | Analyze conversation history |
| **python** | Python development with uv |

### Disabled (Security)
- **voice-call** - Voice calls (disabled for security)
- **browser-automation** - Browser control (disabled for security)

## Security Rules

### Allowed Commands
```bash
git status, git add, git commit, git push, git pull
npm install, npm run, npm test
uv add, uv run, uv sync
python3, node, npx
ls, cat, grep, find, sed (safe patterns only)
```

### Blocked Commands
```bash
rm -rf /, dd, mkfs, fdisk, partition
chmod -R 777, chown -R root
sudo, su, passwd
Any command accessing /home/cloud outside workspace
```

### File Access Rules
| Path | Access | Purpose |
|------|--------|---------|
| `/home/agent/workspace/projects/` | **RW** | Working directory |
| `/home/agent/workspace/docs/` | **RO** | Documentation |
| `/home/agent/workspace/temp/` | **RW** | Ephemeral workspace |
| `/home/agent/workspace/logs/` | **RW** | Agent logs |
| `/home/cloud/` | **❌** | No access (host system) |
| `/etc/` | **❌** | No access (system config) |
| `/root/` | **❌** | No access (root home) |

## Environment

| Setting | Value |
|---------|-------|
| **User** | agent (non-root) |
| **Workspace** | /home/agent/workspace |
| **Network** | Isolated (internal only) |
| **Filesystem** | Read-only root + mounted volumes |
| **Python** | uv package manager |

## Python Development

Python is available via `uv` (fast Python package manager):

```bash
# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate

# Add dependencies
uv add pytest black ruff

# Run Python
uv run python script.py

# Run tests
uv run pytest
```

## Usage

### Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Configure runtime:**
   ```bash
   # Edit .env and set:
   RUNTIME=opencode    # or RUNTIME=openclaude
   ```

3. **Start the container:**
   ```bash
   # For OpenCode:
   ./start-opencode.sh

   # For OpenClaude:
   ./start-openclaude.sh
   ```

4. **Enter the container:**
   ```bash
   docker exec -it advanced-coding-agent /bin/bash
   ```

5. **Start the agent TUI:**
   ```bash
   # For OpenCode:
   opencode

   # For OpenClaude:
   openclaude
   ```

### Stop the Container

```bash
# For OpenCode:
./stop-opencode.sh

# For OpenClaude:
./stop-openclaude.sh
```

## Configuration

### .env File Options

| Variable | Description | Default |
|----------|-------------|---------|
| `RUNTIME` | Choose runtime: `opencode` or `openclaude` | `opencode` |
| `CONTAINER_NAME` | Docker container name | `advanced-coding-agent` |
| `MAX_FILE_SIZE` | Max file size in bytes | `104857600` (100MB) |
| `LOG_LEVEL` | Logging level | `info` |
| `ALLOW_NETWORK` | Allow network access | `false` |
| `MODEL` | LLM model to use | (depends on runtime) |

### agents.json

The `agents.json` file configures:
- Enabled/disabled skills
- Security restrictions
- Workspace settings
- Python packages

## Troubleshooting

### Container won't start
```bash
# Check Docker is running
docker info

# Check for existing containers
docker ps -a | grep advanced-coding-agent

# Remove old container
./stop-opencode.sh  # or ./stop-openclaude.sh
```

### Permission denied
```bash
# Ensure scripts are executable
chmod +x start-*.sh stop-*.sh
```

### Build fails
```bash
# Check Dockerfile syntax
docker build -f Dockerfile.opencode --no-cache .
```

---
*Built by Gorbad Ironfist - Safe coding, WAAAGH!* 👊🪓
