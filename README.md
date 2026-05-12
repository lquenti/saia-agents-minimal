# Advanced Coding Agent 🪓

**Isolated Docker environments for safe AI coding agent operations**

> Built by Gorbad Ironfist - Safe coding, WAAAGH! 👊

## 🎯 Purpose

Create **safe, isolated Docker containers** where AI coding agents (OpenCode, OpenClaude, etc.) can work on projects **without touching host files**. Perfect for:

- ✅ Safe AI coding experiments
- ✅ Pre-installed skills and tools
- ✅ Easy deployment via Docker
- ✅ No risk to host system
- ✅ Reproducible environments

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         HOST SYSTEM (Your Machine)      │
│  ┌─────────────────────────────────┐    │
│  │   Docker Container (Read-Only)  │    │
│  │  ┌─────────────────────────┐    │    │
│  │  │   Coding Agent          │    │    │
│  │  │   (Non-root user)       │    │    │
│  │  └─────────────────────────┘    │    │
│  └─────────────────────────────────┘    │
│         ↑ Mounted Volumes (Controlled)  │
└─────────────────────────────────────────┘

Only /home/agent/workspace is writable
Everything else is read-only or blocked
```

## 🤖 Available Agents

### OpenCode Agent

- **Primary LLM**: OpenAI (gpt-4o)
- **Best For**: Fast coding tasks
- **Image**: `opencode-agent-final`

### OpenClaude Agent

- **Primary LLM**: Anthropic (Claude 3.5)
- **Best For**: Complex reasoning, memory
- **Image**: `openclaude-agent-final`

## 🚀 Quick Start

### Prerequisites

- Docker installed
- Git installed
- API keys for your LLM provider (OpenAI, Anthropic, etc.)

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/advanced-coding-agent.git
cd advanced-coding-agent
```

### 2. Choose Your Agent

#### For OpenCode:

```bash
cd opencode
```

#### For OpenClaude:

```bash
cd openclaude
```

### 3. Configure API Keys

```bash
# Copy example environment file
cp .env.example .env

# Edit with your API keys
nano .env
```

**Required keys** (edit `.env`):

```bash
# OpenAI (for OpenCode)
OPENAI_API_KEY=sk-your-openai-key-here

# Anthropic (for OpenClaude)
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Optional: GitHub token for private repos
GITHUB_TOKEN=ghp-your-token-here
```

### 4. Build Docker Image

```bash
docker build -t coding-agent .
```

**Note**: This includes Node.js, Python, uv, and pre-installed skills (~1.2GB)

### 5. Create Startup Script

Create `start.sh` in the agent directory:

```bash
#!/bin/bash
# Start Coding Agent

docker run -d \
  --name coding-agent \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges:true \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /var/run:rw,noexec,nosuid,size=10m \
  -v "$(pwd)/projects:/home/agent/workspace/projects:rw" \
  -v "$(pwd)/.env:/home/agent/.opencode/.env:ro" \
  --network none \
  --memory 4g \
  --cpus 2.0 \
  coding-agent

echo "✅ Container started!"
echo "Enter: docker exec -it coding-agent /bin/bash"
```

Make executable:

```bash
chmod +x start.sh
```

### 6. Start Container

```bash
./start.sh
```

### 7. Use Your Agent

```bash
# Enter the container
docker exec -it coding-agent /bin/bash

# Start the agent
opencode
# or
openclaude
```

## 📚 Documentation

- **[Quick Start: Using Skills](./docs/QUICK_START_SKILLS.md)** - Get started in 5 minutes
  - First time setup
  - Your first feature workflow
  - Common patterns
  - Skill cheat sheet
  - Pro tips

- **[Software Engineering Workflow](./docs/SOFTWARE_ENGINEERING_WORKFLOW.md)** - Complete guide to proper AI-assisted development
  - Planning & Design (The Grilling)
  - Breaking Into Parts (Vertical Slices)
  - Test-Driven Development (Red-Green-Refactor)
  - Architecture & Deep Modules
  - Complete workflow examples

```
advanced-coding-agent/
├── opencode/                    # OpenCode agent
│   ├── Dockerfile              # Container definition
│   ├── .env.example            # Environment template
│   ├── config.json             # Agent configuration
│   ├── skills/                 # Pre-installed skills
│   │   ├── skills/             # Matt Pocock skills
│   │   └── agent-skills/       # Addy Osmani skills
│   ├── projects/               # Your code goes here
│   └── docs/                   # Documentation
│
├── openclaude/                 # OpenClaude agent
│   ├── Dockerfile              # Container definition
│   ├── .env.example            # Environment template
│   ├── config.json             # Agent configuration
│   ├── skills/                 # Pre-installed skills
│   │   ├── skills/             # Matt Pocock skills
│   │   └── agent-skills/       # Addy Osmani skills
│   ├── projects/               # Your code goes here
│   └── docs/                   # Documentation
│
└── README.md                   # This file
```

## 🛡️ Security Features

| Feature | Protection |
|---------|-----------|
| **Read-only root** | Can't modify system files |
| **Non-root user** | No privilege escalation |
| **Network isolation** | No external access by default |
| **Command blocking** | Blocks dangerous commands |
| **Resource limits** | 2 CPU, 4GB RAM max |
| **Volume control** | Only workspace is writable |

### Blocked Commands

```bash
rm -rf /, dd, mkfs, fdisk, sudo, su, passwd
shutdown, reboot, mount, umount
```

### Allowed Directories

```bash
✅ /home/agent/workspace/projects  (your code)
✅ /home/agent/workspace/docs      (read-only docs)
✅ /home/agent/workspace/temp      (ephemeral)
❌ /home/cloud                     (host - blocked)
❌ /etc                            (system - blocked)
❌ /root                           (root - blocked)
```

## 📚 Pre-installed Skills

### Matt Pocock Skills

Engineering skills for real coding work:

- `/grill-me` - Get interviewed about plans/designs
- `/grill-with-docs` - Grilling + shared language docs
- `/tdd` - Test-driven development loop
- `/diagnose` - Bug diagnosis workflow
- `/triage` - Issue triage state machine
- `/improve-codebase-architecture` - Architecture refactoring
- `/to-issues` - Break plans into GitHub issues
- `/to-prd` - Turn conversation into PRD
- `/zoom-out` - System-level code context
- `/prototype` - Build throwaway prototypes
- `/caveman` - Ultra-compressed communication
- `/handoff` - Compact conversation for handoff
- `/write-a-skill` - Create new skills

### Addy Osmani Agent Skills

Collection of agent skills and patterns for better AI-assisted development.

## 🔧 Configuration

### Edit config.json

```json
{
  "llm": {
    "providers": {
      "openai": {
        "enabled": true,
        "default": true,
        "model": "gpt-4o"
      }
    }
  },
  "security": {
    "blockedCommands": ["your", "blocked", "commands"],
    "allowedDirectories": ["/path/to/allow"]
  }
}
```

### Mount External Projects

Edit your `start.sh`:

```bash
-v "$(pwd)/my-project:/home/agent/workspace/projects/my-project:rw"
```

## 🧪 Testing

### Test Isolation

```bash
# Try to access host - should FAIL!
docker exec coding-agent ls /home/cloud
# Permission denied! ✅

# Try to work in workspace - should WORK!
docker exec coding-agent touch /home/agent/workspace/projects/test.txt
# Success! ✅
```

### Test Tools

```bash
docker exec coding-agent node --version   # v18.19.1
docker exec coding-agent npm --version    # 9.2.0
docker exec coding-agent python3 --version  # Python 3.12.3
docker exec coding-agent uv --version     # uv 0.11.14
```

## 📊 Resource Usage

- **Image Size**: ~1.2GB
- **Memory**: 1-4GB (configurable)
- **CPU**: 0.5-2 cores (configurable)
- **Startup**: ~10 seconds

## 🆚 OpenCode vs OpenClaude

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| **Primary LLM** | OpenAI | Anthropic (Claude) |
| **Memory** | Basic | Advanced (daily notes) |
| **Personality** | Standard | Configurable |
| **Skills** | Core dev | Extended (obsidian, summarize) |
| **Best For** | Fast coding | Complex reasoning |

## 🐛 Troubleshooting

### Permission Denied

```bash
# Ensure files are owned by correct user
sudo chown -R 999:999 ./projects ./docs
```

### Container Won't Start

```bash
# Check logs
docker logs coding-agent

# Rebuild
docker build -t coding-agent .
```

### Can't Access Files

```bash
# Check volume mounts
docker inspect coding-agent

# Verify permissions
ls -la ./projects
```

## 📝 License

MIT License - Free to use and modify

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- **Matt Pocock** - Engineering skills for coding agents
- **Addy Osmani** - Agent skills collection
- **OpenClaw** - Agent framework
- **Astral** - uv package manager

---

**Built with WAAAGH! energy by Gorbad Ironfist** 🪓

*Safe coding, brutal efficiency!*
