# Usage Guide

Complete guide to using the Advanced Coding Agent in various scenarios.

> **Quick Start:** See [README.md](../README.md) for basic setup instructions.

---

## Quick Reference

### Basic Usage

```bash
cd /path/to/your/project
./start-opencode.sh
opencode
```

### Shell Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias start-agent='/path/to/advanced-coding-agent/start-opencode.sh'

# Then use from anywhere
cd /any/project
start-agent
```

---

## Usage Patterns

### Single Project Workflow

```bash
# 1. Navigate to project
cd /projects/my-website

# 2. Start agent
./start-opencode.sh

# 3. Create AGENTS.md if prompted (recommended)
# Select: 1 (generic) or 2 (Python/uv)

# 4. Use agent
opencode

# 5. Exit when done
exit  # Container auto-removes
```

### Multiple Projects

**Open multiple terminals/tabs:**

```bash
# Terminal 1 - Project A
cd /projects/website
./start-opencode.sh
opencode

# Terminal 2 - Project B (new terminal)
cd /projects/api
./start-opencode.sh
opencode
```

**Each container is isolated and auto-removes on exit.**

### Shell Alias for Convenience

**Setup (one-time):**

```bash
# Add to ~/.bashrc or ~/.zshrc
alias start-opencode='/path/to/advanced-coding-agent/start-opencode.sh'
alias start-openclaude='/path/to/advanced-coding-agent/start-openclaude.sh'

# Reload shell
source ~/.bashrc
```

**Usage:**

```bash
cd /projects/my-project
start-opencode
opencode
```

### Using from Any Directory

**No need to cd into the repo:**

```bash
# From anywhere
cd /projects/anything
/path/to/advanced-coding-agent/start-opencode.sh
```

**Better with alias (see above).**

---

## Runtime Selection

### OpenCode vs OpenClaude

| Use Case | Recommended Runtime |
|----------|---------------------|
| General coding | OpenCode |
| Complex reasoning | OpenClaude |
| Open-source preference | OpenCode |
| Anthropic models | OpenClaude |

### Switching Runtimes

```bash
# Stop current container
exit

# Start different runtime
./start-openclaude.sh
```

**Note:** Each runtime has its own Docker image.

---

## AGENTS.md Template Selection

**When starting a project without AGENTS.md:**

```
⚠ No AGENTS.md found in project root
  AGENTS.md provides persistent memory across sessions

Choose template:
  1) Generic project template
  2) Python/uv project template (includes ruff, mypy, pytest)
  n) Skip (create later)

Selection [1/2/n]:
```

### Template Options

| Option | Best For | Includes |
|--------|----------|----------|
| **1** | Any project | Memory instructions, progress tracking |
| **2** | Python projects | uv, ruff, mypy, pytest workflows |
| **n** | Skip | Create manually later |

### Manual Creation

```bash
# Generic template
cp /path/to/repo/templates/AGENTS.md ./AGENTS.md

# Python template
cp /path/to/repo/templates/AGENTS.md-python ./AGENTS.md
```

---

## Build Once, Start Multiple Times

### Workflow

```bash
# First time - build image
./build-opencode.sh

# Subsequent times - just start
./start-opencode.sh  # Fast! Image is cached
./start-opencode.sh  # Fast!
./start-opencode.sh  # Fast!
```

### Why This Works

- Docker images are cached locally
- `docker run` reuses the cached image
- No rebuild needed unless Dockerfile changes

### When to Rebuild

```bash
# After Dockerfile changes
./build-opencode.sh

# After adding new skills
./build-opencode.sh

# To update base packages
./build-opencode.sh
```

---

## Container Lifecycle

### Starting

```bash
./start-opencode.sh
# Container starts, mounts your project
# Agent is ready
```

### Running

```bash
opencode
# Agent works on your project
# Changes saved to your mounted directory
```

### Stopping

```bash
exit
# Container stops AND auto-removes
# No cleanup needed!
```

### Auto-Remove Behavior

```bash
# Container removes itself on exit
docker ps -a  # Container won't appear

# No need for stop scripts
# No need for cleanup
```

---

## Troubleshooting

### "Docker image not found"

**Problem:** Image not built yet

**Solution:**
```bash
./build-opencode.sh
```

### "Docker daemon not running"

**Problem:** Docker not started

**Solution:**
```bash
# Linux
sudo systemctl start docker

# macOS
# Open Docker Desktop

# Windows
# Open Docker Desktop
```

### "Permission denied"

**Problem:** Scripts not executable

**Solution:**
```bash
chmod +x *.sh
```

### "AGENTS.md already exists"

**Problem:** Template prompt doesn't appear

**Solution:**
- Edit existing AGENTS.md
- Or remove it: `rm AGENTS.md`

---

## Best Practices

### 1. Use Shell Aliases

```bash
# ~/.bashrc
alias start-agent='/path/to/repo/start-opencode.sh'
```

**Benefit:** Start from anywhere, faster workflow.

### 2. Build Once Per Runtime

```bash
# Build OpenCode once
./build-opencode.sh

# Build OpenClaude once
./build-openclaude.sh

# Start as needed (fast!)
./start-opencode.sh
./start-openclaude.sh
```

### 3. Always Use AGENTS.md

```markdown
# AGENTS.md
## Current State
- Status: In progress
- Last task: Implement feature X
```

**Benefit:** Persistent memory across sessions.

### 4. One Project Per Terminal

```bash
# Good
cd /projects/website && start-agent
cd /projects/api && start-agent  # New terminal

# Confusing (don't do this)
cd /projects/website && start-agent
cd /projects/api && start-agent  # Same terminal
```

### 5. Commit Before Switching

```bash
# In your project
git add .
git commit -m "Work in progress"

# Then switch to another project
cd ../other-project
./start-opencode.sh
```

---

## Advanced Scenarios

### Custom Workspace Location

**Default:** `/home/agent/workspace/projects/`

**Mount to custom location:**

```bash
# Edit start-opencode.sh
# Find: -v "$(pwd)":/home/agent/workspace/projects:rw
# Change to: -v "$(pwd)":/custom/path:rw
```

### Resource Limits

**Default:** 4GB RAM, 2 CPU cores

**Custom limits:** Edit `start-*.sh`

```bash
# Find: --memory=4g --cpus=2
# Change to: --memory=8g --cpus=4
```

### Network Access

**Default:** Network disabled

**Enable network:** Edit `start-*.sh`

```bash
# Remove: --network=none
```

### Read-Only Filesystem

**Default:** Container root is read-only

**Mount exceptions:** Edit `start-*.sh`

```bash
# Add: -v /tmp:/tmp:rw
```

---

## Related Documentation

- [Configuration Guide](CONFIGURATION.md) - API keys and providers
- [Security Guide](SECURITY.md) - Container hardening
- [Testing Guide](TESTING.md) - Automated tests
- [Scripts Guide](SCRIPTS.md) - Build/start workflow
- [Quick Start Skills](QUICK_START_SKILLS.md) - Getting started with skills

---

**WAAAGH! Now you know how to use the beast!** 🪓👊
