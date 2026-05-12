# TOOLS.md - Advanced Coding Agent Tools

## Pre-installed Skills

### Core Development
- **github** - GitHub integration (issues, PRs, repos)
- **git** - Git operations (commit, push, pull, branch)
- **fileops** - File operations (read, write, edit, search)
- **shell** - Safe shell commands (limited subset)
- **web** - Web fetching and searching

### Code Quality
- **diffs** - Generate shareable diffs
- **session-logs** - Analyze conversation history

### Disabled (Security)
- **voice-call** - Voice calls (disabled for security)
- **browser-automation** - Browser control (disabled for security)

## Security Rules

### Allowed Commands
```bash
git status, git add, git commit, git push, git pull
npm install, npm run, npm test
python3, node, npx
ls, cat, grep, find, sed (safe patterns only)
```

### Blocked Commands
```bash
rm -rf /, dd, mkfs, fdisk
chmod -R 777, chown -R root
sudo, su, passwd
Any command accessing /home/cloud outside workspace
```

### File Access Rules
- ✅ `/home/agent/workspace/projects/**` - Full access
- ✅ `/home/agent/workspace/docs/**` - Read-only
- ✅ `/home/agent/workspace/temp/**` - Full access (ephemeral)
- ❌ `/home/cloud/**` - No access (host system)
- ❌ `/etc/**` - No access (system config)
- ❌ `/root/**` - No access (root home)

## Environment

- **User:** agent (non-root)
- **Workspace:** /home/agent/workspace
- **Network:** Isolated (internal only)
- **Filesystem:** Read-only root + mounted volumes

## Usage

```bash
# Build and start
docker-compose build
docker-compose up -d

# Enter container
docker-compose exec coding-agent /bin/bash

# Run agent
docker-compose exec coding-agent openclaw agent

# Stop
docker-compose down
```

---
*Built by Gorbad Ironfist - Safe coding, WAAAGH!* 👊🪓
