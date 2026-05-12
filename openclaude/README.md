# OpenClaude Agent 🧠

**Isolated Docker environment for OpenClaude AI coding agent with advanced memory**

## Quick Start

### 1. Configure API Keys

```bash
# Copy example env file
cp .env.example .env

# Edit with your keys
nano .env
```

**Required:**
- `ANTHROPIC_API_KEY` - Your Anthropic API key (primary)
- `OPENAI_API_KEY` - Your OpenAI API key (fallback)

### 2. Build Container

```bash
docker build -t openclaude-agent .
```

### 3. Create Startup Script

Create `start.sh`:

```bash
#!/bin/bash
docker run -d \
  --name openclaude-agent \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges:true \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -v "$(pwd)/projects:/home/agent/workspace/projects:rw" \
  -v "$(pwd)/memory:/home/agent/workspace/memory:rw" \
  -v "$(pwd)/.env:/home/agent/.openclaude/.env:ro" \
  --network none \
  --memory 4g \
  --cpus 2.0 \
  openclaude-agent
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
docker exec -it openclaude-agent /bin/bash

# Start OpenClaude
openclaude
```

## 📁 Directory Structure

```
openclaude/
├── Dockerfile          # Container definition
├── .env.example        # Environment template
├── .env                # Your API keys (DO NOT COMMIT!)
├── config.json         # Agent configuration
├── skills/             # Pre-installed skills
│   ├── skills/         # Matt Pocock skills
│   └── agent-skills/   # Addy Osmani skills
├── projects/           # Your code goes here
├── memory/             # Agent memory storage
└── docs/               # Read-only documentation
```

## 🧠 OpenClaude Features

### Advanced Memory

- **Daily Notes**: Automatic memory logging
- **Long-term Memory**: Persistent knowledge storage
- **Context Integration**: Memory-aware responses
- **Auto-save**: Regular memory updates

Memory location: `~/.openclaude/workspace/memory/`

### Personality Mode

- **Configurable Personas**: Including Orc Warboss!
- **Voice Support**: TTS integration
- **Custom Prompts**: Tailor agent behavior

### Enhanced Skills

- **Obsidian Integration**: Vault automation
- **Summarize**: URL and file summarization
- **All Matt Pocock skills**
- **All Addy Osmani skills**

## 🔧 Available Tools

- **Node.js**: v18.19.1
- **npm**: 9.2.0
- **Python**: 3.12.3
- **uv**: 0.11.14
- **git**: Latest
- **curl**: Latest

## 📚 Pre-installed Skills

### Matt Pocock Skills

Located at: `~/.openclaude/skills-mattpocock/`

Key commands:
- `/grill-me` - Plan validation
- `/grill-with-docs` - Plan + documentation
- `/tdd` - Test-driven development
- `/diagnose` - Bug diagnosis
- `/improve-codebase-architecture` - Refactoring

### Addy Osmani Agent Skills

Located at: `~/.openclaude/skills-addyosmani/`

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
docker exec openclaude-agent ls /home/cloud
# Should fail!

# Test workspace
docker exec openclaude-agent touch /home/agent/workspace/projects/test.txt
# Should work!

# Test memory
docker exec openclaude-agent ls /home/agent/workspace/memory
# Should show memory directory!

# Test tools
docker exec openclaude-agent node --version
docker exec openclaude-agent python3 --version
```

## 📊 Image Info

- **Size**: ~1.2GB
- **Base**: Ubuntu 24.04
- **User**: agent (UID 999)
- **Network**: Isolated
- **Memory**: Enabled

## 🆚 OpenCode vs OpenClaude

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| **Primary LLM** | OpenAI | Anthropic (Claude) |
| **Memory** | Basic | Advanced |
| **Personality** | Standard | Configurable |
| **Extended Skills** | Core dev | Obsidian, summarize |
| **Best For** | Fast coding | Complex reasoning |

## 🐛 Troubleshooting

### Permission Issues

```bash
sudo chown -R 999:999 ./projects ./docs ./memory
```

### Container Won't Start

```bash
docker logs openclaude-agent
docker build --no-cache -t openclaude-agent .
```

## 📝 License

MIT License

---

**Built by Gorbad Ironfist - Safe coding, WAAAGH!** 👊🪓
