# Configuration Guide

Complete configuration reference for the Advanced Coding Agent.

## Environment Variables (.env)

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
nano .env
```

### Required Settings (Top of File)

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENCODE_API_KEY` | API key for OpenAI-compatible providers | `sk-proj-xxx...` |
| `OPENCLAUDE_API_KEY` | API key for Anthropic (OpenClaude) | `sk-ant-xxx...` |
| `OPENAI_BASE_URL` | Base URL for API | `https://api.openai.com/v1` |
| `MODEL` | Model name to use | `gpt-4o` |

### Optional Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `CONTAINER_NAME` | Docker container name | `advanced-coding-agent` |
| `MAX_FILE_SIZE` | Max file size (bytes) | `104857600` (100MB) |
| `LOG_LEVEL` | Logging level | `info` |
| `ALLOW_NETWORK` | Allow network access | `false` |
| `ALLOW_EXTERNAL_CALLS` | Allow external API calls | `false` |
| `OPENAI_API_VERSION` | API version (Azure) | - |
| `OPENAI_ORG_ID` | Organization ID (OpenAI) | - |
| `OPENAI_PROJECT_ID` | Project ID (OpenAI) | - |
| `MODEL_TEMPERATURE` | Response temperature (0.0-2.0) | `0.7` |
| `MODEL_MAX_TOKENS` | Max tokens for response | `4096` |
| `API_TIMEOUT` | API call timeout (seconds) | `120` |
| `GIT_USER_NAME` | Git user name | - |
| `GIT_USER_EMAIL` | Git user email | - |

### Provider Examples

**OpenAI:**
```bash
OPENCODE_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_BASE_URL=https://api.openai.com/v1
MODEL=gpt-4o
```

**Azure OpenAI:**
```bash
OPENCODE_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_BASE_URL=https://<your-resource>.openai.azure.com/openai/deployments/<your-deployment>
OPENAI_API_VERSION=2024-02-01
MODEL=gpt-4o
```

**Ollama (local):**
```bash
OPENCODE_API_KEY=ollama  # Can be anything for local
OPENAI_BASE_URL=http://host.docker.internal:11434/v1
MODEL=llama3.1:8b
```

**LM Studio (local):**
```bash
OPENCODE_API_KEY=lm-studio  # Can be anything for local
OPENAI_BASE_URL=http://localhost:1234/v1
MODEL=local-model-name
```

**vLLM (local/remote):**
```bash
OPENCODE_API_KEY=vllm  # Can be anything
OPENAI_BASE_URL=http://localhost:8000/v1
MODEL=meta-llama/Llama-3.1-8B-Instruct
```

**DeepSeek:**
```bash
OPENCODE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_BASE_URL=https://api.deepseek.com/v1
MODEL=deepseek-chat
```

**Groq:**
```bash
OPENCODE_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_BASE_URL=https://api.groq.com/openai/v1
MODEL=llama-3.1-70b-versatile
```

**Anthropic Claude (use start-openclaude.sh):**
```bash
OPENCLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx
MODEL=claude-3-5-sonnet-latest
```

---

## agents.json Configuration

Configures agent behavior, enabled/disabled skills, and security rules.

```json
{
  "agent": {
    "name": "Advanced Coding Agent",
    "version": "2.0.0"
  },
  "skills": {
    "enabled": [
      "github",
      "git",
      "fileops",
      "shell",
      "web",
      "diffs",
      "session-logs",
      "python"
    ],
    "disabled": [
      "voice-call",
      "browser-automation"
    ]
  },
  "security": {
    "allowExternalCalls": false,
    "allowNetworkAccess": false,
    "blockedCommands": [
      "rm -rf /",
      "dd",
      "mkfs",
      "fdisk",
      "partition",
      "chmod -R 777",
      "chown -R root",
      "sudo",
      "su",
      "passwd"
    ]
  }
}
```

### Available Skills

| Skill | Description |
|-------|-------------|
| `github` | GitHub integration (issues, PRs, repos) |
| `git` | Git operations (commit, push, pull, branch) |
| `fileops` | File operations (read, write, edit, search) |
| `shell` | Safe shell commands |
| `web` | Web fetching and searching |
| `diffs` | Generate shareable code diffs |
| `session-logs` | Analyze conversation history |
| `python` | Python development tools |
| `voice-call` | Voice call functionality |
| `browser-automation` | Browser control |

---

## tools.md Configuration

Defines tool definitions and security rules. See [tools.md](../tools.md) for complete documentation.

### Key Sections

- **Memory & Persistence** - AGENTS.md and Hindsight plugin configuration
- **Security Rules** - File access restrictions, blocked commands
- **Available Tools** - Tool definitions and usage

---

## Container Configuration

### Docker Compose (Alternative)

While the project uses shell scripts, you can also use Docker Compose:

```yaml
version: '3.8'

services:
  agent:
    build:
      context: .
      dockerfile: Dockerfile.opencode
    image: advanced-coding-agent
    container_name: advanced-coding-agent
    user: agent
    volumes:
      - .:/home/agent/workspace/projects/current:rw
      - ./agents.json:/home/agent/.opencode/agents.json:ro
      - ./tools.md:/home/agent/.opencode/workspace/tools.md:ro
      - ./.agent-memory:/home/agent/.opencode/memory:rw
    environment:
      - OPENCODE_API_KEY=${OPENCODE_API_KEY}
      - MODEL=${MODEL}
    stdin_open: true
    tty: true
    network_mode: none  # Network isolation
    read_only: true
    tmpfs:
      - /tmp
      - /home/agent/workspace/temp
```

### Build Options

```bash
# OpenCode runtime
docker build -f Dockerfile.opencode -t advanced-coding-agent .

# OpenClaude runtime
docker build -f Dockerfile.openclaude -t advanced-coding-agent:openclaude .
```

### Run Options

```bash
# Interactive mode
docker run --rm -it \
  --user agent \
  -v $(pwd):/home/agent/workspace/projects/current:rw \
  advanced-coding-agent /bin/bash

# With environment variables
docker run --rm -it \
  --env-file .env \
  -v $(pwd):/home/agent/workspace/projects/current:rw \
  advanced-coding-agent /bin/bash
```

---

## Shell Alias (Recommended)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# OpenCode
alias start-agent='/path/to/advanced-coding-agent/start-opencode.sh'

# OpenClaude
alias start-agent='/path/to/advanced-coding-agent/start-openclaude.sh'
```

Then reload:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

Usage:

```bash
cd /path/to/project
start-agent
opencode
```

---

## Troubleshooting

### API Key Issues

- Verify API key format (OpenAI: `sk-...`, Anthropic: `sk-ant-...`)
- Check for trailing whitespace in `.env`
- Ensure environment variables are loaded

### Container Issues

```bash
# Check if container is running
docker ps -a | grep advanced-coding-agent

# View logs
docker logs advanced-coding-agent

# Remove stuck container
docker rm -f advanced-coding-agent
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R $(whoami) .agent-memory

# Check Docker permissions
docker run --rm -v $(pwd):/test alpine ls -la /test
```

### Network Issues

- Check `ALLOW_NETWORK` setting in `.env`
- Verify `OPENAI_BASE_URL` is correct
- Test connectivity: `curl -I https://api.openai.com`

---

## Best Practices

1. **Use shell alias** - Start agent from anywhere
2. **Configure AGENTS.md** - Enable persistent memory
3. **Set appropriate MODEL** - Match your provider
4. **Review security rules** - Ensure `tools.md` matches your needs
5. **Use `.agent-memory/`** - Store session notes for continuity

---

**Related:**
- [Quick Start](../README.md#-quick-start)
- [Software Engineering Workflow](SOFTWARE_ENGINEERING_WORKFLOW.md)
- [Tools & Security](../tools.md)
