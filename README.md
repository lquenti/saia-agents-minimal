# Advanced Coding Agent 🪓

**Isolated Docker environment for safe coding agent operations**

Built by Gorbad Ironfist - Safe coding, WAAAGH! 👊

## 🎯 Purpose

Create a **safe, isolated environment** where coding agents (OpenCode, OpenClaw, etc.) can work on projects **without touching host files**. Perfect for:

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

## 🚀 Quick Start

### 1. Clone & Build

```bash
cd ~/advanced-coding-agent
docker-compose build
```

### 2. Start Agent

```bash
docker-compose up -d
```

### 3. Enter Workspace

```bash
docker-compose exec coding-agent /bin/bash
```

### 4. Start Coding

```bash
# Inside container
openclaw agent
# or
opencode
```

## 🛡️ Security Features

### Filesystem Isolation
- ✅ Read-only root filesystem
- ✅ Only `/home/agent/workspace` is writable
- ✅ Host files completely inaccessible
- ✅ No access to `/etc`, `/root`, `/home/cloud`

### Network Isolation
- ✅ Internal-only network (no internet by default)
- ✅ No external API calls unless explicitly allowed
- ✅ Controlled DNS resolution

### Resource Limits
- ✅ CPU: 2 cores max
- ✅ Memory: 4GB max
- ✅ No privilege escalation

### Command Blocking
- ✅ Blocked: `rm -rf /`, `dd`, `mkfs`, `sudo`, etc.
- ✅ Allowed: `git`, `npm`, `node`, safe shell commands
- ✅ File size limits (100MB max)

## 📦 Pre-installed Skills

| Skill | Purpose | Status |
|-------|---------|--------|
| github | GitHub integration | ✅ Enabled |
| git | Git operations | ✅ Enabled |
| fileops | File operations | ✅ Enabled |
| shell | Safe shell commands | ✅ Enabled |
| web | Web fetching/searching | ✅ Enabled |
| diffs | Generate shareable diffs | ✅ Enabled |
| voice-call | Voice calls | ❌ Disabled |
| browser-automation | Browser control | ❌ Disabled |

## 📁 Directory Structure

```
advanced-coding-agent/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Orchestration
├── agents.json             # Agent configuration
├── tools.md                # Tool documentation
├── README.md               # This file
├── .gitignore             # Git ignore rules
├── projects/              # Writable project workspace
│   └── .gitkeep
├── docs/                  # Read-only documentation
│   └── .gitkeep
└── agents/                # Agent definitions
    └── .gitkeep
```

## 🔧 Configuration

### Edit agents.json

```json
{
  "security": {
    "blockedCommands": ["your", "blocked", "commands"],
    "allowedDirectories": ["/path/to/allow"]
  }
}
```

### Mount External Projects

Edit `docker-compose.yml`:

```yaml
volumes:
  - ./my-project:/home/agent/workspace/projects/my-project:rw
```

## 🧪 Testing

```bash
# Test filesystem isolation
docker-compose exec coding-agent ls /home/cloud
# Should fail - no access!

# Test network isolation
docker-compose exec coding-agent curl google.com
# Should fail - no internet!

# Test allowed operations
docker-compose exec coding-agent cd /home/agent/workspace/projects
docker-compose exec coding-agent touch test.txt
# Should work!
```

## 🚨 Production Hardening

Before deploying to production:

1. **Enable seccomp profile** (remove `unconfined`)
2. **Add network policies** (restrict outbound)
3. **Enable image scanning** (Trivy, Snyk)
4. **Set up logging/monitoring**
5. **Rotate credentials regularly**
6. **Enable container signing**

## 📊 Resource Usage

- **Image Size:** ~500MB
- **Memory:** 1-4GB (configurable)
- **CPU:** 0.5-2 cores (configurable)
- **Startup:** ~10 seconds

## 🐛 Troubleshooting

### Permission Denied

```bash
# Ensure files are owned by agent user
sudo chown -R 1000:1000 ./projects ./docs
```

### Container Won't Start

```bash
# Check logs
docker-compose logs coding-agent

# Rebuild
docker-compose build --no-cache
```

### Can't Access Files

```bash
# Check volume mounts
docker-compose config

# Verify permissions
ls -la ./projects
```

## 📝 License

MIT License - Free to use and modify

## 👊 Contributing

Want to add skills or improve security? Fork and PR!

**Remember:** Security first! Test thoroughly before deploying.

---

**Built with WAAAGH! energy by Gorbad Ironfist** 🪓

*Safe coding, brutal efficiency!*
