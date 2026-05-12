# OpenCode Agent 🤖

**Isolated Docker environment for OpenCode AI coding agent**

## Quick Start

### 1. Configure API Keys

```bash
# Copy example env file
cp .env.example .env

# Edit with your keys
nano .env
```

**Required:**
- `OPENAI_API_KEY` - Your OpenAI API key
- `ANTHROPIC_API_KEY` - Your Anthropic API key (optional fallback)

### 2. Build Container

```bash
docker build -t opencode-agent .
```

### 3. Create Startup Script

Create `start.sh`:

```bash
#!/bin/bash
docker run -d \
  --name opencode-agent \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges:true \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -v "$(pwd)/projects:/home/agent/workspace/projects:rw" \
  -v "$(pwd)/.env:/home/agent/.opencode/.env:ro" \
  --network none \
  --memory 4g \
  --cpus 2.0 \
  opencode-agent
```

Make executable:

```bash
chmod +x start.sh
```

### 4. Start Agent

```bash
./start.sh
```

### 5. Use Agent

```bash
# Enter container
docker exec -it opencode-agent /bin/bash

# Start OpenCode
opencode
```

## 📁 Directory Structure

```
opencode/
├── Dockerfile          # Container definition
├── .env.example        # Environment template
├── .env                # Your API keys (DO NOT COMMIT!)
├── config.json         # Agent configuration
├── skills/             # Pre-installed skills
│   ├── skills/         # Matt Pocock skills
│   └── agent-skills/   # Addy Osmani skills
├── projects/           # Your code goes here
└── docs/               # Read-only documentation
```

## 🔧 Available Tools

- **Node.js**: v18.19.1
- **npm**: 9.2.0
- **Python**: 3.12.3
- **uv**: 0.11.14 (fast Python package manager)
- **git**: Latest
- **curl**: Latest

## 📚 Pre-installed Skills

### Matt Pocock Skills

Located at: `~/.opencode/skills-mattpocock/`

Key commands:
- `/grill-me` - Plan validation
- `/tdd` - Test-driven development
- `/diagnose` - Bug diagnosis
- `/improve-codebase-architecture` - Refactoring

### Addy Osmani Agent Skills

Located at: `~/.opencode/skills-addyosmani/`

Collection of agent patterns and best practices.

## 🛡️ Security Features

- ✅ Read-only root filesystem
- ✅ Non-root user (UID 999)
- ✅ No network access
- ✅ Resource limits (4GB RAM, 2 CPU)
- ✅ Blocked dangerous commands

## 🧪 Testing

```bash
# Test isolation
docker exec opencode-agent ls /home/cloud
# Should fail!

# Test workspace
docker exec opencode-agent touch /home/agent/workspace/projects/test.txt
# Should work!

# Test tools
docker exec opencode-agent node --version
docker exec opencode-agent python3 --version
```

## 📊 Image Info

- **Size**: ~1.2GB
- **Base**: Ubuntu 24.04
- **User**: agent (UID 999)
- **Network**: Isolated

## 🐛 Troubleshooting

### Permission Issues

```bash
sudo chown -R 999:999 ./projects ./docs
```

### Container Won't Start

```bash
docker logs opencode-agent
docker build --no-cache -t opencode-agent .
```

## 📝 License

MIT License

---

**Built by Gorbad Ironfist - Safe coding, WAAAGH!** 👊🪓
