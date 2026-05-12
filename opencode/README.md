# OpenCode Coding Agent 🪓

**Isolated Docker environment for OpenCode AI coding agent**

## 🚀 Quick Start

### 1. Configure API Keys

```bash
cd ~/advanced-coding-agent/opencode

# Copy example env file
cp .env.example .env

# Edit with your keys
nano .env
```

### 2. Build & Start

```bash
# Build container
docker build -t opencode-agent .

# Run container
docker run -d \
  --name opencode-agent \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -v $(pwd)/projects:/home/agent/workspace/projects:rw \
  -v $(pwd)/docs:/home/agent/workspace/docs:ro \
  -v $(pwd)/.env:/home/agent/.opencode/.env:ro \
  opencode-agent
```

### 3. Use Agent

```bash
# Enter container
docker exec -it opencode-agent /bin/bash

# Start OpenCode
opencode

# Or run directly
docker exec -it opencode-agent opencode
```

## 📁 Directory Structure

```
opencode/
├── Dockerfile          # Container definition
├── .env.example        # Environment template
├── .env                # Your API keys (DO NOT COMMIT!)
├── config.json         # Agent configuration
├── README.md           # This file
├── projects/           # Writable workspace
└── docs/               # Read-only docs
```

## 🔐 Security Features

- ✅ Read-only root filesystem
- ✅ Non-root user (agent)
- ✅ Blocked dangerous commands
- ✅ Network isolation
- ✅ Resource limits
- ✅ API key protection

## ⚙️ Configuration

Edit `config.json` to customize:
- LLM providers and models
- Enabled/disabled skills
- Security rules
- Workspace settings

## 🧪 Testing

```bash
# Test isolation
docker exec opencode-agent ls /home/cloud
# Should fail!

# Test workspace access
docker exec opencode-agent touch /home/agent/workspace/projects/test.txt
# Should work!
```

---

**Built by Gorbad Ironfist - Safe coding, WAAAGH!** 👊🪓
