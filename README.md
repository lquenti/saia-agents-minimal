# Advanced Coding Agent 🦾

> An isolated, secure coding agent environment. Choose your runtime: **OpenCode** or **OpenClaude**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2.0.0-green.svg)

## 🎯 Overview

The **Advanced Coding Agent** provides a secure, isolated Docker environment for AI-assisted coding. Unlike previous versions, this iteration:

- **Supports multiple runtimes** - Choose between OpenCode or OpenClaude
- **No docker-compose** - Simple `docker build` and `docker run` via shell scripts
- **Mounts your project** - Current directory is automatically mounted as workspace
- **Pre-configured tools** - Python via `uv`, Git, and essential development skills
- **Security-first** - Non-root user, read-only filesystem, network isolation

Perfect for:
- AI-assisted coding tasks
- Safe experimentation with coding agents
- CI/CD integration
- Isolated development environments

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent.git
cd advanced-coding-agent
```

### 2. Configure Your Runtime

Copy the environment file:

```bash
cp .env.example .env
nano .env  # or vim, code, etc.
```

**Edit `.env` and configure your API keys and model:**

```bash
# Set your API key and model
OPENCODE_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxx
MODEL=gpt-4o
```

> **📖 Detailed Configuration Guide:** See [.env.example](.env.example) for **complete documentation** with examples for:
> - OpenAI, Azure, Ollama, LM Studio, vLLM
> - Anthropic, DeepSeek, Groq, and more
> - Custom self-hosted providers
> - Advanced settings (temperature, timeouts, etc.)

> **💡 Note:** The runtime is determined by which start script you use:
> - `./start-opencode.sh` → OpenCode runtime
> - `./start-openclaude.sh` → OpenClaude runtime

### 3. Build and Start

```bash
# For OpenCode runtime:
./start-opencode.sh

# For OpenClaude runtime:
./start-openclaude.sh
```

This will:
- Build the Docker image (first time only)
- Create `.agent-memory/` folder in your current directory (for persistent memory)
- Start an **interactive bash shell** in the container

> **💡 Pro Tip:** Add an alias to your `.bashrc` or `.zshrc` to start the agent from anywhere! See [Install Shell Alias](#-install-shell-alias-optional-but-recommended) below.

### 4. Start the Agent TUI

Once inside the container:

```bash
# For OpenCode:
opencode

# For OpenClaude:
openclaude
```

### 5. Exit (Container Auto-Removes)

```bash
exit  # or Ctrl+D
```

**The container automatically removes itself when you exit!** No stop script needed for normal use.

---

## 🎯 Install Shell Alias (Optional but Recommended)

Want to start your agent from **anywhere** on your system? Add a shell function to your `.bashrc` or `.zshrc`:

### 1. Add to Your Shell Config

```bash
# For OpenCode:
alias start-agent='/path/to/advanced-coding-agent/start-opencode.sh'

# For OpenClaude:
alias start-agent='/path/to/advanced-coding-agent/start-openclaude.sh'
```

**Example** (add to `~/.bashrc` or `~/.zshrc`):

```bash
# Advanced Coding Agent
alias start-agent='/home/cloud/advanced-coding-agent/start-opencode.sh'
```

### 2. Reload Your Shell

```bash
source ~/.bashrc   # or source ~/.zshrc
```

### 3. Use from Anywhere!

```bash
# Navigate to your project
cd /path/to/your-project

# Start agent (one command!)
start-agent

# You're in! Start the agent
opencode

# When done
exit  # ← Container auto-removes
```

**Benefits:**
- ✅ Start agent from **any project folder**
- ✅ Automatically mounts **current directory** as workspace
- ✅ No need to remember where you installed the repo
- ✅ Clean workflow: `cd project` → `start-agent` → `opencode`

## 📁 Project Structure

```
advanced-coding-agent/
├── .env.example              # Environment configuration template
├── Dockerfile.opencode       # OpenCode runtime Dockerfile
├── Dockerfile.openclaude     # OpenClaude runtime Dockerfile
├── agents.json               # Agent configuration & skills
├── tools.md                  # Tool definitions & security rules
├── start-opencode.sh         # OpenCode start script
├── start-openclaude.sh       # OpenClaude start script
├── docs/                     # Documentation (read-only)
│   ├── QUICK_START_SKILLS.md
│   └── SOFTWARE_ENGINEERING_WORKFLOW.md
└── README.md                 # This file
```

## 🔄 User Workflow

### Basic Usage

```bash
# 1. Go to your project directory
cd /path/to/your-project

# 2. Start the agent
/path/to/advanced-coding-agent/start-opencode.sh

# 3. You're now in an interactive bash shell
opencode

# 4. When done, exit
exit  # ← Container automatically removed!
```

### With Shell Alias (Recommended)

After adding the alias to your `.bashrc`/`.zshrc`:

```bash
# 1. Go to any project
cd /any/path/to/project

# 2. Start agent (one command!)
start-agent

# 3. Start the agent TUI
opencode

# 4. Exit
exit
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Host System                               │
│  /home/user/advanced-coding-agent/                           │
│  ├─ .env                 (your configuration)               │
│  ├─ agents.json          (agent settings)                   │
│  ├─ tools.md             (tool definitions)                 │
│  ├─ Dockerfile.opencode                                       │
│  ├─ Dockerfile.openclaude                                     │
│  └─ start-*.sh          (launch scripts)                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ docker run -v $(pwd):...
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              advanced-coding-agent (Docker)                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  User: agent (non-root)                               │  │
│  │  FS: Read-only root + mounted volumes                 │  │
│  │  Network: Isolated (no external access)               │  │
│  │                                                       │  │
│  │  /home/agent/workspace/                               │  │
│  │  ├─ projects/your-project/  (RW - your code!)        │  │
│  │  ├─ docs/                     (RO - documentation)   │  │
│  │  ├─ temp/                     (RW - ephemeral)       │  │
│  │  └─ logs/                     (RW - agent logs)      │  │
│  │                                                       │  │
│  │  Pre-installed:                                       │  │
│  │  • OpenCode or OpenClaude CLI                         │  │
│  │  • Python via uv                                      │  │
│  │  • Git, npm, essential tools                          │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Configuration

### Environment Variables (.env)

| Variable | Description | Default |
|----------|-------------|---------|
| `RUNTIME` | Choose: `opencode` or `openclaude` | `opencode` |
| `CONTAINER_NAME` | Docker container name | `advanced-coding-agent` |
| `MAX_FILE_SIZE` | Max file size (bytes) | `104857600` (100MB) |
| `LOG_LEVEL` | Logging level | `info` |
| `ALLOW_NETWORK` | Allow network access | `false` |
| `MODEL` | LLM model to use | (runtime default) |

### agents.json

Configures agent behavior:

```json
{
  "agent": {
    "name": "Advanced Coding Agent",
    "version": "2.0.0"
  },
  "skills": {
    "enabled": ["github", "git", "fileops", "shell", "web", "diffs", "python"],
    "disabled": ["voice-call", "browser-automation"]
  },
  "security": {
    "allowExternalCalls": false,
    "allowNetworkAccess": false,
    "blockedCommands": ["rm -rf /", "dd", "mkfs", "sudo", "passwd"]
  }
}
```

## 🔒 Security Features

### Container Hardening

| Feature | Description |
|---------|-------------|
| **Non-root user** | Runs as `agent` user (UID 1000) |
| **Read-only filesystem** | Root filesystem is read-only |
| **No new privileges** | `no-new-privileges:true` |
| **Dropped capabilities** | All capabilities removed except essentials |
| **Memory limits** | 4GB max, prevents runaway processes |
| **CPU limits** | 2 cores max |
| **Network isolation** | No external network access |

### Filesystem Access

| Path | Access | Purpose |
|------|--------|---------|
| `/home/agent/workspace/projects/` | **RW** | Your mounted project |
| `/home/agent/workspace/docs/` | **RO** | Documentation |
| `/home/agent/workspace/temp/` | **RW** | Ephemeral workspace |
| `/home/agent/workspace/logs/` | **RW** | Agent logs |
| `/home/cloud/` | **❌** | No access (host system) |
| `/etc/` | **❌** | No access (system config) |

### Blocked Commands

```bash
rm -rf /, dd, mkfs, fdisk, partition
chmod -R 777, chown -R root
sudo, su, passwd
```

## 🛠️ Available Tools

### Pre-installed

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | 20.x | JavaScript/TypeScript runtime |
| **Python** | 3.11 | Python runtime |
| **uv** | Latest | Fast Python package manager |
| **Git** | Latest | Version control |
| **npm** | Latest | Node package manager |

### Python Development

Python is available via `uv` (ultra-fast Python package manager):

```bash
# Create virtual environment
uv venv

# Activate
source .venv/bin/activate

# Add dependencies
uv add pytest black ruff mypy

# Run Python
uv run python script.py

# Run tests
uv run pytest

# Format code
uv run black .

# Lint code
uv run ruff check .
```

### Skills

| Skill | Description |
|-------|-------------|
| **github** | GitHub integration (issues, PRs, repos) |
| **git** | Git operations (commit, push, pull, branch) |
| **fileops** | File operations (read, write, edit, search) |
| **shell** | Safe shell commands |
| **web** | Web fetching and searching |
| **diffs** | Generate shareable code diffs |
| **session-logs** | Analyze conversation history |
| **python** | Python development tools |

## 💾 Persistent Memory

The agent stores memories in **`.agent-memory/`** folder in your project directory:

```bash
your-project/
├── .agent-memory/     ← Persistent agent memory (survives container exit)
├── your-code/
└── ...
```

**Why this matters:** Your agent remembers things between sessions! Code preferences, project context, lessons learned - all stored locally in your project.

### Start a New Project

```bash
# Create project directory
mkdir my-ai-project && cd my-ai-project

# Initialize git repo
git init

# Copy agent configuration
cp -r /path/to/advanced-coding-agent/* .

# Configure and start
cp .env.example .env
nano .env  # Set RUNTIME=opencode

./start-opencode.sh
docker exec -it advanced-coding-agent /bin/bash
opencode
```

### Work on Existing Project

```bash
cd /path/to/existing/project

# Start agent container (mounts current directory)
/path/to/advanced-coding-agent/start-opencode.sh

# Enter container
docker exec -it advanced-coding-agent /bin/bash

# Start agent
opencode
```

### View Logs

```bash
docker logs -f advanced-coding-agent
```

### Stop Container

```bash
./stop-opencode.sh      # or ./stop-openclaude.sh
```

## 🔄 Runtime Comparison

### OpenCode

- Open-source coding agent
- Community-driven
- Flexible configuration
- Good for experimentation

### OpenClaude

- Claude-based agent
- Strong reasoning capabilities
- Better for complex tasks
- May require API key

Choose based on your needs and availability.

## 📚 Documentation

- [Tools & Security](tools.md) - Complete tool reference and security rules
- [Quick Start Skills](docs/QUICK_START_SKILLS.md) - Getting started with skills
- [Software Engineering Workflow](docs/SOFTWARE_ENGINEERING_WORKFLOW.md) - Best practices

## 🧪 Development

### Build from Source

```bash
# OpenCode runtime
docker build -f Dockerfile.opencode -t advanced-coding-agent .

# OpenClaude runtime
docker build -f Dockerfile.openclaude -t advanced-coding-agent .
```

### Debug

```bash
# Enter container without starting agent
docker exec -it advanced-coding-agent /bin/bash

# Check container status
docker ps -a | grep advanced-coding-agent

# View resource usage
docker stats advanced-coding-agent
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Built with ❤️ for safe, productive AI-assisted development.

---

**Questions?** Open an issue or reach out to the maintainers.

**Security Issues?** Please report responsibly via the issue tracker.
