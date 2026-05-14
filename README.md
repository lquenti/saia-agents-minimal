# Advanced Coding Agent 🦾

> An isolated, secure coding agent environment with pre-installed development skills. Built for safe, productive AI-assisted software development.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

## 🎯 Overview

The **Advanced Coding Agent** is a self-contained Docker-based environment that provides:

- **Isolated workspace** - Agent operates in a sandboxed container with restricted filesystem access
- **Pre-installed skills** - Ready-to-use tools for Git, GitHub, file operations, web fetching, and more
- **Security hardening** - Non-root user, network isolation, command restrictions, and resource limits
- **Multi-agent support** - Works with OpenClaw, OpenClaude, and OpenCode agent runtimes

Perfect for:
- AI-assisted coding tasks
- Automated code reviews
- CI/CD integration
- Safe experimentation with AI coding agents

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Host System                               │
│  /home/cloud/advanced-coding-agent/                          │
│  ├─ agents.json      (agent configuration)                  │
│  ├─ tools.md         (tool definitions)                     │
│  ├─ docker-compose.yml                                       │
│  ├─ Dockerfile                                               │
│  ├─ projects/        (writable workspace)                   │
│  └─ docs/            (read-only documentation)              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              advanced-coding-agent (Docker)                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  User: agent (non-root)                               │  │
│  │  FS: Read-only root + mounted volumes                 │  │
│  │  Network: Internal (isolated)                         │  │
│  │                                                       │  │
│  │  /home/agent/workspace/                               │  │
│  │  ├─ projects/  (RW - working directory)              │  │
│  │  ├─ docs/      (RO - documentation)                  │  │
│  │  ├─ temp/      (RW - ephemeral)                      │  │
│  │  └─ logs/      (RW - agent logs)                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Git configured (for agent operations)
- At least 4GB RAM available

### Installation

1. **Clone or navigate to the repository:**
   ```bash
   cd /home/cloud/advanced-coding-agent
   ```

2. **Build the Docker image:**
   ```bash
   docker-compose build
   ```

3. **Start the agent:**
   ```bash
   docker-compose up -d
   ```

4. **Verify it's running:**
   ```bash
   docker-compose ps
   ```

5. **Enter the container:**
   ```bash
   docker-compose exec coding-agent /bin/bash
   ```

## 📁 Project Structure

```
advanced-coding-agent/
├── agents.json              # Agent configuration & skills
├── tools.md                 # Tool definitions & security rules
├── docker-compose.yml       # Container orchestration
├── Dockerfile               # Container image definition
├── .dockerignore            # Docker build exclusions
├── .gitignore               # Git exclusions
├── LICENSE                  # MIT License
├── CONTRIBUTING.md          # Contribution guidelines
├── README.md                # This file
├── start-openclaude.sh      # OpenClaude runtime launcher
├── start-opencode.sh        # OpenCode runtime launcher
├── stop-openclaude.sh       # OpenClaude shutdown script
├── stop-opencode.sh         # OpenCode shutdown script
├── docs/                    # Documentation (read-only)
│   ├── QUICK_START_SKILLS.md
│   └── SOFTWARE_ENGINEERING_WORKFLOW.md
└── projects/                # Workspace (writable)
    └── .gitkeep             # Directory placeholder
```

## 🔧 Configuration

### Agent Configuration (`agents.json`)

```json
{
  "agent": {
    "name": "Advanced Coding Agent",
    "version": "1.0.0",
    "description": "Isolated coding agent with pre-installed skills"
  },
  "skills": {
    "enabled": ["github", "git", "fileops", "shell", "web", "diffs", "session-logs"],
    "disabled": ["voice-call", "browser-automation"]
  },
  "security": {
    "allowExternalCalls": false,
    "allowNetworkAccess": false,
    "blockedCommands": ["rm -rf /", "dd", "mkfs", "fdisk"],
    "maxFileSize": 104857600,
    "allowedDirectories": [
      "/home/agent/workspace/projects",
      "/home/agent/workspace/docs",
      "/home/agent/workspace/temp"
    ]
  }
}
```

### Resource Limits

| Resource | Limit | Reservation |
|----------|-------|-------------|
| CPU | 2.0 cores | 0.5 cores |
| Memory | 4GB | 1GB |

## 🔒 Security Features

### User Isolation
- **Non-root user** (`agent`) - Prevents privilege escalation
- **Read-only root filesystem** - Only mounted volumes are writable
- **No new privileges** - `no-new-privileges:true` security flag

### Network Isolation
- **Internal network** - No external internet access by default
- **Blocked external calls** - Agent cannot make arbitrary network requests

### Command Restrictions
**Blocked commands:**
```bash
rm -rf /, dd, mkfs, fdisk, partition
chmod -R 777, chown -R root
sudo, su, passwd
```

**Allowed commands:**
```bash
git status, git add, git commit, git push, git pull
npm install, npm run, npm test
python3, node, npx
ls, cat, grep, find, sed (safe patterns)
```

### Filesystem Access

| Path | Access | Purpose |
|------|--------|---------|
| `/home/agent/workspace/projects/` | **RW** | Working directory |
| `/home/agent/workspace/docs/` | **RO** | Documentation |
| `/home/agent/workspace/temp/` | **RW** | Ephemeral workspace |
| `/home/agent/workspace/logs/` | **RW** | Agent logs |
| `/home/cloud/` | **❌** | No access (host system) |
| `/etc/` | **❌** | No access (system config) |
| `/root/` | **❌** | No access (root home) |

## 🛠️ Available Tools

### Core Development
| Tool | Description |
|------|-------------|
| **github** | GitHub integration (issues, PRs, repos) |
| **git** | Git operations (commit, push, pull, branch) |
| **fileops** | File operations (read, write, edit, search) |
| **shell** | Safe shell commands (limited subset) |
| **web** | Web fetching and searching |

### Code Quality
| Tool | Description |
|------|-------------|
| **diffs** | Generate shareable code diffs |
| **session-logs** | Analyze conversation history |

### Disabled (Security)
- **voice-call** - Voice calls (disabled for security)
- **browser-automation** - Browser control (disabled for security)

## 💡 Usage Examples

### Basic Operations

```bash
# Start the agent
docker-compose up -d

# View logs
docker-compose logs -f

# Enter the container
docker-compose exec coding-agent /bin/bash

# Run a specific command
docker-compose exec coding-agent git status

# Stop the agent
docker-compose down
```

### Working with Projects

```bash
# Create a new project
docker-compose exec coding-agent mkdir -p /home/agent/workspace/projects/my-project

# Clone a repository
docker-compose exec coding-agent git clone https://github.com/user/repo.git /home/agent/workspace/projects/my-project

# View project files
docker-compose exec coding-agent ls -la /home/agent/workspace/projects/
```

### Using Skills

```bash
# Git operations
docker-compose exec coding-agent git commit -m "Your message"

# File operations
docker-compose exec coding-agent cat /home/agent/workspace/projects/file.txt

# Web fetching
docker-compose exec coding-agent curl -s https://api.example.com/data
```

## 🔄 Runtime Options

### OpenClaude Runtime

```bash
# Start with OpenClaude
./start-openclaude.sh

# Stop OpenClaude
./stop-openclaude.sh
```

### OpenCode Runtime

```bash
# Start with OpenCode
./start-opencode.sh

# Stop OpenCode
./stop-opencode.sh
```

## 📚 Documentation

- [Quick Start Skills](docs/QUICK_START_SKILLS.md) - Getting started with agent skills
- [Software Engineering Workflow](docs/SOFTWARE_ENGINEERING_WORKFLOW.md) - Best practices for AI-assisted development

## 🧪 Development

### Building from Source

```bash
# Build the image
docker-compose build --no-cache

# Run tests
docker-compose exec coding-agent npm test  # If applicable

# Run linting
docker-compose exec coding-agent npm run lint  # If applicable
```

### Debugging

```bash
# Enter container with debug shell
docker-compose exec coding-agent /bin/bash

# View agent logs
docker-compose logs -f coding-agent

# Check resource usage
docker stats coding-agent
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with ❤️ for safe, productive AI-assisted development.

---

**Questions?** Open an issue or reach out to the maintainers.

**Security Issues?** Please report responsibly via the issue tracker.
