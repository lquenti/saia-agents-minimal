# Architecture Guide

Deep dive into the Advanced Coding Agent architecture.

---

## Overview

The Advanced Coding Agent uses a **single-container Docker architecture** with path-based separation between host and container.

```
┌─────────────────────────────────────────────────────────────┐
│                      HOST SYSTEM                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   .env       │  │  start-*.sh  │  │ Dockerfile.* │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │             │
│         │                  │ docker run       │             │
│         │                  ▼                  │             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              CONTAINER (Docker)                     │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  /home/agent/workspace/projects/  (RW)       │  │   │
│  │  │         ↑ Mounted from host                  │  │   │
│  │  ├──────────────────────────────────────────────┤  │   │
│  │  │  /home/agent/.opencode/ or .openclaude/ (RO) │  │   │
│  │  │         Runtime configuration                │  │   │
│  │  ├──────────────────────────────────────────────┤  │   │
│  │  │  /usr/local/bin/opencode or openclaude       │  │   │
│  │  │         Agent CLI                            │  │   │
│  │  ├──────────────────────────────────────────────┤  │   │
│  │  │  /home/agent/.cache/                         │  │   │
│  │  │         Skills, npm packages, Python deps    │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Container Architecture

### Filesystem Layout

```
Container Root (/)
├── /home/agent/                    # Agent user home
│   ├── workspace/                  # Workspace root
│   │   └── projects/               # Mounted project directory (RW)
│   │       └── (your code)         # Read/write access
│   ├── .opencode/ or .openclaude/  # Runtime config (RO)
│   │   ├── AGENTS.md              # Agent rules
│   │   ├── skills/                # Pre-installed skills
│   │   └── config.json            # Runtime config
│   └── .cache/                     # Cached dependencies
│       ├── npm/                   # npm packages
│       └── uv/                    # Python packages
├── /usr/local/bin/
│   ├── opencode or openclaude     # Agent CLI
│   ├── node                       # Node.js
│   ├── python3                    # Python
│   └── uv                         # uv package manager
└── /etc/
    └── agents.json                # Agent configuration
```

### Mount Points

| Host Path | Container Path | Mode | Purpose |
|-----------|----------------|------|---------|
| `$(pwd)` | `/home/agent/workspace/projects/` | RW | Your project code |
| Internal | `/home/agent/.opencode/` | RO | Runtime config |
| Internal | `/home/agent/.cache/` | RO | Cached dependencies |

---

## Security Architecture

### Non-Root User

```bash
# Container runs as 'agent' user, not root
USER agent
```

**Benefits:**
- Limited filesystem access
- No privilege escalation
- Safer code execution

### Read-Only Filesystem

```bash
# Container root filesystem is read-only
--read-only
```

**Benefits:**
- Prevents malware persistence
- Limits attack surface
- Easier debugging

### Network Isolation

```bash
# Network disabled by default
--network=none
```

**Benefits:**
- No outbound data exfiltration
- No inbound attacks
- Controlled API access only

### Resource Limits

```bash
# Memory and CPU limits
--memory=4g --cpus=2
```

**Benefits:**
- Prevents resource exhaustion
- Fair sharing on multi-project systems
- Predictable performance

---

## Runtime Architecture

### OpenCode Runtime

```
Container Start
    │
    ├─→ Load .env
    ├─→ Mount workspace
    ├─→ Start opencode CLI
    │       │
    │       ├─→ Load AGENTS.md
    │       ├─→ Load skills from .opencode/skills/
    │       └─→ Connect to API
    │
    └─→ Agent ready
```

### OpenClaude Runtime

```
Container Start
    │
    ├─→ Load .env
    ├─→ Mount workspace
    ├─→ Start openclaude CLI
    │       │
    │       ├─→ Load AGENTS.md
    │       ├─→ Load .claude/AGENTS.md
    │       ├─→ Load skills from .openclaude/skills/
    │       └─→ Connect to API
    │
    └─→ Agent ready
```

---

## Build Architecture

### Dockerfile.opencode

```dockerfile
FROM ubuntu:24.04

# Install system packages
RUN apt-get update && apt-get install -y \
    nodejs npm python3 git curl build-essential

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create agent user
RUN useradd -m agent

# Copy configuration
COPY agents.json tools.md /home/agent/

# Install skills (git submodules)
COPY skills/ /home/agent/.opencode/skills/

# Set working directory
WORKDIR /home/agent/workspace/projects/

# Run as non-root
USER agent
```

### Dockerfile.openclaude

```dockerfile
FROM ubuntu:24.04

# Install system packages
RUN apt-get update && apt-get install -y \
    nodejs npm python3 git curl build-essential

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create agent user
RUN useradd -m agent

# Copy configuration
COPY agents.json tools.md /home/agent/

# Install skills (git submodules)
COPY skills/ /home/agent/.openclaude/skills/

# Set working directory
WORKDIR /home/agent/workspace/projects/

# Run as non-root
USER agent
```

---

## Script Architecture

### build-opencode.sh

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.opencode"

docker build -f "${DOCKERFILE}" \
    -t advanced-coding-agent:latest \
    "${SCRIPT_DIR}"
```

### start-opencode.sh

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_DIR="$(pwd)"

# Check .env exists
# Check AGENTS.md (offer template)

docker run --rm \
    --name advanced-coding-agent \
    --user agent \
    --read-only \
    --network=none \
    --memory=4g \
    --cpus=2 \
    -v "${CURRENT_DIR}":/home/agent/workspace/projects:rw \
    -v "${SCRIPT_DIR}/.env":/home/agent/.env:ro \
    advanced-coding-agent:latest \
    opencode
```

---

## Memory Architecture

### AGENTS.md (Universal)

```
Project Root
└── AGENTS.md
    ├─→ Read by OpenCode (priority)
    └─→ Read by OpenClaude (fallback)
```

### .agent-memory/ (Optional)

```
Project Root
└── .agent-memory/
    ├── session-notes.md    # Persistent session notes
    ├── context.md          # Complex task context
    └── adr/                # Architecture decision records
```

### Runtime-Specific Memory

**OpenCode:**
```
/home/agent/.opencode/
├── AGENTS.md
└── rules/
    └── *.md
```

**OpenClaude:**
```
/home/agent/.openclaude/
├── AGENTS.md
└── rules/
    └── *.md
```

---

## Skills Architecture

### Skill Locations

```
Container
├── /home/agent/.opencode/skills/    # OpenCode skills
│   ├── addy-osmani/                 # 23 skills
│   └── matt-pocock/                 # 12+ skills
└── /home/agent/.openclaude/skills/  # OpenClaude skills
    ├── addy-osmani/                 # 23 skills
    └── matt-pocock/                 # 12+ skills
```

### Skill Structure

```
skill-name/
├── SKILL.md              # Skill documentation
├── prompt.md             # Skill prompt template
└── tools/                # Skill tools (optional)
```

### Skill Loading

```bash
# OpenCode loads from .opencode/skills/
# OpenClaude loads from .openclaude/skills/
# Both read agents.json for enabled/disabled skills
```

---

## Network Architecture

### Default (Isolated)

```
┌─────────────────────┐
│    Container        │
│                     │
│  ┌───────────────┐  │
│  │   Agent CLI   │  │
│  │               │  │
│  │  No Network   │  │
│  └───────────────┘  │
└─────────────────────┘
```

### With Network Enabled

```
┌─────────────────────┐
│    Container        │
│                     │
│  ┌───────────────┐  │
│  │   Agent CLI   │  │
│  │       │       │  │
│  │       ▼       │  │
│  │   Internet    │  │
│  └───────────────┘  │
└─────────────────────┘
       │
       ▼
┌─────────────────────┐
│  API Endpoints      │
│  - OpenAI           │
│  - Anthropic        │
│  - Ollama           │
│  - Custom           │
└─────────────────────┘
```

---

## Deployment Architecture

### Single-Container Deployment

```
git clone repo
    │
    ▼
build-opencode.sh
    │
    ├─→ Docker image: advanced-coding-agent:latest
    │
    ▼
start-opencode.sh
    │
    ├─→ Container: advanced-coding-agent
    │       │
    │       ├─→ Mounts: $(pwd) → /home/agent/workspace/projects/
    │       └─→ Runs: opencode
    │
    └─→ Agent ready
```

### Multi-Project Deployment

```
Terminal 1                Terminal 2
┌─────────────────┐      ┌─────────────────┐
│ /projects/site  │      │ /projects/api   │
│                 │      │                 │
│ start-opencode  │      │ start-opencode  │
│     │           │      │     │           │
│     ▼           │      │     ▼           │
│ Container A     │      │ Container B     │
│ (auto-removes)  │      │ (auto-removes)  │
└─────────────────┘      └─────────────────┘
```

---

## Performance Architecture

### Build Time Optimization

```dockerfile
# Layer caching
FROM ubuntu:24.04           # Cached
RUN apt-get update          # Cached
RUN apt-get install ...     # Cached

# Skill installation
COPY skills/                # Invalidates cache
```

**Strategy:**
- Build once, use cached image
- Rebuild only when Dockerfile changes
- Skills are cached in image

### Runtime Optimization

```bash
# Container starts quickly
docker run --rm ...         # ~2 seconds

# Agent starts immediately
opencode                    # ~1 second
```

**Strategy:**
- Image cached locally
- No build on start
- Auto-remove on exit

---

## Related Documentation

- [Configuration Guide](CONFIGURATION.md) - API keys and models
- [Security Guide](SECURITY.md) - Container hardening
- [Usage Guide](USAGE.md) - Common usage patterns
- [Debugging Guide](DEBUGGING.md) - Troubleshooting

---

**WAAAGH! Now you know how the beast is built!** 🪓👊
