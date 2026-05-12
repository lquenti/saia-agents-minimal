# OpenClaude Coding Agent 🪓

**Isolated Docker environment for OpenClaude AI coding agent**

## 🚀 Quick Start

### 1. Configure API Keys

```bash
cd ~/advanced-coding-agent/openclaude

# Copy example env file
cp .env.example .env

# Edit with your keys
nano .env
```

### 2. Build & Start

```bash
# Build container
docker build -t openclaude-agent .

# Run container
docker run -d \
  --name openclaude-agent \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -v $(pwd)/projects:/home/agent/workspace/projects:rw \
  -v $(pwd)/docs:/home/agent/workspace/docs:ro \
  -v $(pwd)/memory:/home/agent/workspace/memory:rw \
  -v $(pwd)/.env:/home/agent/.openclaude/.env:ro \
  openclaude-agent
```

### 3. Use Agent

```bash
# Enter container
docker exec -it openclaude-agent /bin/bash

# Start OpenClaude
openclaude

# Or run directly
docker exec -it openclaude-agent openclaude
```

## 📁 Directory Structure

```
openclaude/
├── Dockerfile          # Container definition
├── .env.example        # Environment template
├── .env                # Your API keys (DO NOT COMMIT!)
├── config.json         # Agent configuration
├── README.md           # This file
├── projects/           # Writable workspace
├── docs/               # Read-only docs
└── memory/             # Agent memory (OpenClaude feature)
```

## 🧠 OpenClaude Features

- ✅ **Memory Integration** - Long-term memory storage
- ✅ **Personality Mode** - Orc Warboss persona (WAAAGH!)
- ✅ **Daily Notes** - Automatic memory logging
- ✅ **Enhanced Skills** - Obsidian, summarize, etc.
- ✅ **Thinking Mode** - Medium reasoning level

## 🔐 Security Features

- ✅ Read-only root filesystem
- ✅ Non-root user (agent)
- ✅ Blocked dangerous commands
- ✅ Network isolation
- ✅ Resource limits
- ✅ API key protection

## ⚙️ Configuration

Edit `config.json` to customize:
- LLM providers (Anthropic primary, others as fallback)
- Enabled/disabled skills
- Memory settings
- Personality mode
- Security rules

## 🧪 Testing

```bash
# Test isolation
docker exec openclaude-agent ls /home/cloud
# Should fail!

# Test workspace access
docker exec openclaude-agent touch /home/agent/workspace/projects/test.txt
# Should work!

# Test memory
docker exec openclaude-agent ls /home/agent/workspace/memory
# Should show memory directory!
```

## 🆚 OpenCode vs OpenClaude

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| **Primary LLM** | OpenAI | Anthropic (Claude) |
| **Memory** | Basic | Advanced (daily notes, long-term) |
| **Personality** | Standard | Configurable (Orc Warboss!) |
| **Skills** | Core dev | Extended (obsidian, summarize) |
| **Best For** | Fast coding | Complex reasoning |

---

**Built by Gorbad Ironfist - Safe coding, WAAAGH!** 👊🪓
