# Runtime Comparison

Detailed comparison of OpenCode and OpenClaude runtimes.

---

## Overview

The Advanced Coding Agent supports two runtimes:

| Runtime | Description | Best For |
|---------|-------------|----------|
| **OpenCode** | Open-source coding agent | General development, experimentation |
| **OpenClaude** | Claude-based coding agent | Complex reasoning, enterprise tasks |

---

## Quick Comparison

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| **Runtime Type** | Open-source | Anthropic Claude |
| **API Provider** | OpenAI-compatible | Anthropic |
| **Base Model** | gpt-4o, o1, etc. | claude-3.5-sonnet, etc. |
| **Start Script** | `start-opencode.sh` | `start-openclaude.sh` |
| **Image Tag** | `advanced-coding-agent:latest` | `advanced-coding-agent:openclaude` |
| **Config File** | `.opencode/AGENTS.md` | `.openclaude/AGENTS.md` |
| **Skills Path** | `.opencode/skills/` | `.openclaude/skills/` |
| **Best For** | General coding, experimentation | Complex tasks, reasoning |
| **Cost** | Varies by provider | Anthropic pricing |
| **Setup Complexity** | Medium | Medium |

---

## OpenCode Runtime

### Overview

OpenCode is an open-source coding agent runtime that works with OpenAI-compatible APIs.

### API Configuration

```bash
# .env
OPENAI_API_KEY=sk-...
BASE_URL=https://api.openai.com/v1
MODEL=gpt-4o
```

### Supported Providers

| Provider | BASE_URL | Notes |
|----------|----------|-------|
| OpenAI | `https://api.openai.com/v1` | Official |
| Azure | `https://<resource>.openai.azure.com` | Azure OpenAI |
| Ollama | `http://localhost:11434/v1` | Local models |
| LM Studio | `http://localhost:1234/v1` | Local models |
| vLLM | `http://localhost:8000/v1` | Local inference |
| DeepSeek | `https://api.deepseek.com/v1` | DeepSeek API |
| Groq | `https://api.groq.com/openai/v1` | Fast inference |

### Pros

- ✅ Open-source runtime
- ✅ Multiple provider options
- ✅ Local model support (Ollama, LM Studio)
- ✅ Flexible pricing
- ✅ Good for experimentation

### Cons

- ❌ Requires OpenAI-compatible API
- ❌ Setup varies by provider
- ❌ May need provider-specific config

### Best Use Cases

- General coding tasks
- Learning and experimentation
- Local model testing
- Multi-provider setups
- Cost-sensitive projects

---

## OpenClaude Runtime

### Overview

OpenClaude is a Claude-based coding agent runtime using Anthropic's API.

### API Configuration

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
BASE_URL=https://api.anthropic.com
MODEL=claude-3-5-sonnet-20241022
```

### Supported Models

| Model | Description | Best For |
|-------|-------------|----------|
| `claude-3-5-sonnet-20241022` | Latest Sonnet | Complex tasks |
| `claude-3-opus-20240229` | Most capable | Heavy reasoning |
| `claude-3-haiku-20240307` | Fast & cheap | Simple tasks |

### Pros

- ✅ Excellent reasoning capabilities
- ✅ Strong code understanding
- ✅ Good at complex tasks
- ✅ Enterprise-grade reliability
- ✅ Consistent performance

### Cons

- ❌ Anthropic API only
- ❌ Higher cost than some options
- ❌ No local model support
- ❌ Rate limits on free tier

### Best Use Cases

- Complex code refactoring
- Architecture design
- Code review and analysis
- Documentation generation
- Enterprise development

---

## Feature Comparison

### Code Understanding

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Large context | ✅ 128K+ | ✅ 200K |
| Code comprehension | ✅ Good | ✅ Excellent |
| Multi-file awareness | ✅ Yes | ✅ Yes |
| Cross-file navigation | ✅ Yes | ✅ Yes |

### Performance

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Response speed | Varies by provider | Fast |
| Token limits | Provider-dependent | 200K context |
| Concurrent requests | Provider-dependent | Rate limited |

### Skills Support

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Skill loading | ✅ Yes | ✅ Yes |
| Skill count | 45+ | 45+ |
| Custom skills | ✅ Yes | ✅ Yes |
| Skill isolation | ✅ Per runtime | ✅ Per runtime |

### Memory & Persistence

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| AGENTS.md | ✅ Priority | ✅ Supported |
| .agent-memory/ | ✅ Supported | ✅ Supported |
| Session state | ❌ Stateless | ❌ Stateless |
| Cross-session | ✅ Via files | ✅ Via files |

---

## Configuration Comparison

### OpenCode Configuration

```bash
# .env for OpenCode
OPENAI_API_KEY=sk-...
BASE_URL=https://api.openai.com/v1
MODEL=gpt-4o

# Runtime-specific config
# /home/agent/.opencode/AGENTS.md
# /home/agent/.opencode/skills/
```

### OpenClaude Configuration

```bash
# .env for OpenClaude
ANTHROPIC_API_KEY=sk-ant-...
BASE_URL=https://api.anthropic.com
MODEL=claude-3-5-sonnet-20241022

# Runtime-specific config
# /home/agent/.openclaude/AGENTS.md
# /home/agent/.openclaude/skills/
```

---

## Build Comparison

### OpenCode Build

```bash
./build-opencode.sh
```

**Output:**
- Image: `advanced-coding-agent:latest`
- Dockerfile: `Dockerfile.opencode`
- Skills: `.opencode/skills/`

### OpenClaude Build

```bash
./build-openclaude.sh
```

**Output:**
- Image: `advanced-coding-agent:openclaude`
- Dockerfile: `Dockerfile.openclaude`
- Skills: `.openclaude/skills/`

---

## Usage Comparison

### Starting OpenCode

```bash
cd /your/project
./start-opencode.sh
opencode
```

### Starting OpenClaude

```bash
cd /your/project
./start-openclaude.sh
openclaude
```

### Switching Runtimes

```bash
# Stop current
exit

# Start different runtime
./start-openclaude.sh
```

---

## Cost Comparison

### OpenCode Costs

| Provider | Input | Output | Notes |
|----------|-------|--------|-------|
| OpenAI gpt-4o | $2.50/1M | $10/1M | Standard |
| Ollama (local) | Free | Free | Self-hosted |
| Groq | Free tier | Free tier | Limited |
| Azure | Varies | Varies | Enterprise |

### OpenClaude Costs

| Model | Input | Output | Context |
|-------|-------|--------|---------|
| claude-3.5-sonnet | $3/1M | $15/1M | 200K |
| claude-3-opus | $15/1M | $75/1M | 200K |
| claude-3-haiku | $0.25/1M | $1.25/1M | 200K |

---

## Decision Guide

### Choose OpenCode When

- ✅ You want open-source runtime
- ✅ You need local model support
- ✅ You want multiple provider options
- ✅ You're experimenting/learning
- ✅ Cost is a primary concern
- ✅ You use Ollama or similar

### Choose OpenClaude When

- ✅ You need best reasoning capabilities
- ✅ You work on complex tasks
- ✅ You want enterprise reliability
- ✅ Budget is not primary concern
- ✅ You prefer Anthropic models
- ✅ You need consistent performance

### Use Both When

- ✅ You want to compare outputs
- ✅ You have different use cases
- ✅ You want redundancy
- ✅ You test across runtimes

---

## Migration Guide

### From OpenCode to OpenClaude

```bash
# 1. Build OpenClaude image
./build-openclaude.sh

# 2. Update .env
# Change API_KEY and MODEL for Anthropic

# 3. Start OpenClaude
./start-openclaude.sh

# 4. AGENTS.md works for both!
# No changes needed
```

### From OpenClaude to OpenCode

```bash
# 1. Build OpenCode image
./build-opencode.sh

# 2. Update .env
# Change API_KEY and MODEL for OpenAI-compatible

# 3. Start OpenCode
./start-opencode.sh

# 4. AGENTS.md works for both!
# No changes needed
```

---

## Troubleshooting

### OpenCode Issues

| Problem | Solution |
|---------|----------|
| "Invalid API key" | Check OPENAI_API_KEY in .env |
| "Connection refused" | Check BASE_URL |
| "Model not found" | Verify MODEL name |
| "Rate limited" | Check provider limits |

### OpenClaude Issues

| Problem | Solution |
|---------|----------|
| "Invalid API key" | Check ANTHROPIC_API_KEY |
| "Model not found" | Use valid claude-3 model |
| "Rate limited" | Check Anthropic rate limits |
| "Context too long" | Reduce context or use smaller model |

---

## Performance Benchmarks

### Typical Response Times

| Runtime | Simple Task | Complex Task |
|---------|-------------|--------------|
| OpenCode (gpt-4o) | 2-5s | 10-30s |
| OpenClaude (sonnet) | 3-6s | 15-40s |

### Token Usage

| Task Type | Typical Tokens |
|-----------|----------------|
| Code review | 5K-20K |
| Feature implementation | 10K-50K |
| Refactoring | 15K-100K |
| Documentation | 5K-30K |

---

## Related Documentation

- [Configuration Guide](CONFIGURATION.md) - API setup
- [Usage Guide](USAGE.md) - Runtime selection
- [Security Guide](SECURITY.md) - Container security
- [Skills Reference](SKILLS.md) - Available skills

---

**WAAAGH! Choose your weapon wisely!** 🪓👊
