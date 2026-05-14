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
- **Pre-installed skills** - 45+ production-grade skills from Matt Pocock and Addy Osmani
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

---

## 🧠 Persistent Memory

### ⚠️ OpenCode Sessions Are Stateless by Default

Each OpenCode session starts **fresh** - it doesn't remember previous conversations unless you add memory.

### Two Approaches to Memory

#### Option 1: AGENTS.md (Universal - Recommended)

**AGENTS.md works for BOTH OpenCode and OpenClaude!** Create it in your project root.

**Bonus:** Include instructions to use `.agent-memory/` folder for persistent notes!

```markdown
# Project: Your Project

## Memory Usage
CRITICAL: Use .agent-memory/ folder for persistent notes.
- Read .agent-memory/session-notes.md at session start
- Update with progress and decisions

## Current State
- Status: In progress
- Last task: Implement feature X

## Progress
✅ Done
⏳ In progress

## Architecture Decisions
- Decision 1: Why we chose X
```

**Benefits:**
- ✅ Universal (both runtimes)
- ✅ No external dependencies
- ✅ Git-tracked and shareable
- ✅ Agent can update memory folder automatically

**See [tools.md](tools.md#memory--persistence) for complete guide.**

#### Option 2: Hindsight Plugin (Advanced)

For **vector search** and **automatic recall**, use the [Hindsight plugin](https://hindsight.vectorize.io/sdks/integrations/opencode).

```json
// opencode.json
{
  "plugin": ["@vectorize-io/opencode-hindsight"]
}
```

**Benefits:**
- ✅ Automatic recall/retain
- ✅ Vector search across conversations
- ✅ Survives context compaction

**Requires:** Hindsight server (local or cloud)

### Memory Folder

The `.agent-memory/` folder is **mounted** but **not automatically used** by OpenCode. Use it for:
- Storing `AGENTS.md` (symlink to project root)
- Custom scripts
- Project-specific persistence

---

## 🧠 Pre-Installed Skills

The agent comes with **45+ production-grade skills** from two curated collections:

### Matt Pocock's Skills (`skills/matt-pocock/`)

Engineering best practices for real software development:

| Skill | Purpose |
|-------|--------|
| `/grill-me` | Get relentlessly interviewed about plans until fully specified |
| `/grill-with-docs` | Grilling session that builds shared language + CONTEXT.md |
| `/tdd` | Test-driven development with red-green-refactor loop |
| `/diagnose` | Disciplined diagnosis loop for hard bugs |
| `/to-prd` | Turn conversation into PRD + GitHub issue |
| `/to-issues` | Break plans into independent GitHub issues |
| `/triage` | Triage issues through state machine |
| `/improve-codebase-architecture` | Find deepening opportunities in codebase |
| `/zoom-out` | Get broader context on unfamiliar code |
| `/prototype` | Build throwaway prototypes to explore designs |
| `/caveman` | Ultra-compressed communication (~75% token savings) |
| `/handoff` | Compact conversation for agent handoff |

### Addy Osmani's Agent Skills (`skills/addy-osmani/`)

Production-grade engineering workflows for AI agents:

| Skill | Purpose |
|-------|--------|
| `/spec` | Write PRD before any code |
| `/plan` | Decompose specs into small, verifiable tasks |
| `/build` | Thin vertical slices - implement, test, verify |
| `/test` | Red-green-refactor with test pyramid |
| `/review` | Five-axis code review before merge |
| `/code-simplify` | Reduce complexity while preserving behavior |
| `/ship` | Pre-launch checklists + feature flags |
| `/interview-me` | One-question-at-a-time requirement extraction |
| `/idea-refine` | Divergent/convergent thinking for vague ideas |
| `/context-engineering` | Feed agents right info at right time |
| `/source-driven-development` | Ground decisions in official docs |
| `/doubt-driven-development` | Adversarial review of non-trivial decisions |
| `/frontend-ui-engineering` | Component architecture + accessibility |
| `/api-and-interface-design` | Contract-first API design |
| `/browser-testing-with-devtools` | Chrome DevTools MCP for runtime data |
| `/debugging-and-error-recovery` | Five-step triage for broken builds |
| `/code-review-and-quality` | Five-axis review with severity labels |
| `/security-and-hardening` | OWASP Top 10 prevention |
| `/performance-optimization` | Measure-first performance work |
| `/git-workflow-and-versioning` | Trunk-based development + atomic commits |
| `/ci-cd-and-automation` | Shift Left + quality gate pipelines |
| `/documentation-and-adrs` | Architecture Decision Records |

### Using Skills

Skills are pre-installed in the container at:
- OpenCode: `/home/agent/.opencode/workspace/skills/`
- OpenClaude: `/home/agent/.openclaude/workspace/skills/`

**Reference skills in your workflow** by reading the `SKILL.md` files or using the slash commands (if your runtime supports them).

## 📁 Project Structure

```
advanced-coding-agent/
├── Dockerfile.opencode       # OpenCode runtime Dockerfile
├── Dockerfile.openclaude     # OpenClaude runtime Dockerfile
├── start-opencode.sh         # OpenCode start script
├── start-openclaude.sh       # OpenClaude start script
├── .env.example              # Environment configuration template
├── agents.json               # Agent configuration & skills
├── tools.md                  # Tool definitions & security rules
├── README.md                 # This file
├── skills/                   # Pre-installed skill collections (git submodules)
│   ├── matt-pocock/          # Matt Pocock's engineering skills
│   └── addy-osmani/          # Addy Osmani's agent skills
└── docs/                     # Documentation (read-only)
    ├── QUICK_START_SKILLS.md
    └── SOFTWARE_ENGINEERING_WORKFLOW.md
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
