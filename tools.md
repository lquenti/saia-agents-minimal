# TOOLS.md - Advanced Coding Agent Tools

## Runtime Support

This agent supports two runtimes:
- **OpenCode** - Open-source coding agent CLI
- **OpenClaude** - Claude-based coding agent CLI

Select your runtime in `.env` before starting.

## Pre-installed Skills

### Core Development
| Skill | Description |
|-------|-------------|
| **github** | GitHub integration (issues, PRs, repos) |
| **git** | Git operations (commit, push, pull, branch) |
| **fileops** | File operations (read, write, edit, search) |
| **shell** | Safe shell commands (limited subset) |
| **web** | Web fetching and searching |

### Code Quality
| Skill | Description |
|-------|-------------|
| **diffs** | Generate shareable code diffs |
| **session-logs** | Analyze conversation history |
| **python** | Python development with uv |

### Disabled (Security)
- **voice-call** - Voice calls (disabled for security)
- **browser-automation** - Browser control (disabled for security)

## Security Rules

### Allowed Commands
```bash
git status, git add, git commit, git push, git pull
npm install, npm run, npm test
uv add, uv run, uv sync
python3, node, npx
ls, cat, grep, find, sed (safe patterns only)
```

### Blocked Commands
```bash
rm -rf /, dd, mkfs, fdisk, partition
chmod -R 777, chown -R root
sudo, su, passwd
Any command accessing /home/cloud outside workspace
```

### File Access Rules
| Path | Access | Purpose |
|------|--------|---------|
| `/home/agent/workspace/projects/` | **RW** | Working directory |
| `/home/agent/workspace/docs/` | **RO** | Documentation |
| `/home/agent/workspace/temp/` | **RW** | Ephemeral workspace |
| `/home/agent/workspace/logs/` | **RW** | Agent logs |
| `/home/cloud/` | **❌** | No access (host system) |
| `/etc/` | **❌** | No access (system config) |
| `/root/` | **❌** | No access (root home) |

## Environment

| Setting | Value |
|---------|-------|
| **User** | agent (non-root) |
| **Workspace** | /home/agent/workspace |
| **Network** | Isolated (internal only) |
| **Filesystem** | Read-only root + mounted volumes |
| **Python** | uv package manager |

## Memory & Persistence

### ⚠️ Both OpenCode and OpenClaude Sessions Are Stateless by Default

Each session starts **fresh** - no built-in persistent memory.

### ✅ Universal Solution: AGENTS.md (Works for Both Runtimes)

**AGENTS.md is read by BOTH OpenCode and OpenClaude**, making it the universal choice:

| Runtime | Reads AGENTS.md? | Reads CLAUDE.md? |
|---------|------------------|------------------|
| **OpenCode** | ✅ **Primary** | ⚠️ Fallback only |
| **OpenClaude** | ✅ **Yes** | ✅ **Primary** |

**If both AGENTS.md and CLAUDE.md exist, OpenCode uses AGENTS.md only!**

**Recommendation:** Use **AGENTS.md only** - works for both runtimes, no duplication needed.

---

## Option 1: AGENTS.md (Universal - Works for Both Runtimes)

Create an `AGENTS.md` file in your project root. **Both OpenCode and OpenClaude automatically read this file** on every session start.

### What AGENTS.md Does

- **Reads on every session** - Instructions injected into system prompt
- **Universal** - Works for both OpenCode and OpenClaude
- **Project-specific** - Each project can have its own AGENTS.md
- **Git-tracked** - Committed and shared with your team
- **No external dependencies** - Works out of the box

### Example AGENTS.md with Memory Instructions

```markdown
# Project: Simple HTTP Webserver

## Memory Usage Instructions
CRITICAL: Use .agent-memory/ folder for persistent notes between sessions.

- Read .agent-memory/session-notes.md at the START of each session
- Update .agent-memory/session-notes.md with progress and decisions
- Store context in .agent-memory/context.md for complex tasks

## Current State
- Created: 2026-05-14
- Status: In progress
- Last task: Implement /api/status endpoint

## Architecture Decisions
- Using native Node.js http module (no Express)
- Port 3000 for HTTP server
- JSON responses for API endpoints

## Progress
✅ Home page at `/` - Returns "Hello, World!"
⏳ API endpoint at `/api/status` - In progress
⏳ README with instructions - Pending

## Notes
- Server should handle errors gracefully
- Use ES modules ("type": "module" in package.json)
- Keep code clean and readable
```

### How to Create AGENTS.md

```bash
# Create manually
cat > AGENTS.md << 'EOF'
# Your project instructions here
# Include memory usage instructions!
EOF

# Or use /init command (if available in your runtime)
opencode
> /init
```

### Best Practices

1. **Update after each session** - Add progress, decisions, next steps
2. **Keep it concise** - Focus on what future sessions need to know
3. **Use clear structure** - Headings, bullet points, checkboxes
4. **Track decisions** - Document WHY, not just WHAT
5. **Instruct agent to use memory folder** - Tell it to read/write .agent-memory/

---

## Option 2: Hindsight Plugin (Advanced, Vector Search)

For **true long-term memory** with vector search, use the [Hindsight plugin](https://hindsight.vectorize.io/sdks/integrations/opencode).

### What Hindsight Does

- **Persistent memory** - Stores conversations in a vector database
- **Auto-recall** - Recalls relevant context on session start
- **Auto-retain** - Saves conversations when session goes idle
- **Tools** - `hindsight_retain`, `hindsight_recall`, `hindsight_reflect`
- **Compaction hooks** - Memories survive context window trimming

### Setup Hindsight

1. **Add to opencode.json:**

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["@vectorize-io/opencode-hindsight"]
}
```

2. **Set environment variables:**

```bash
# Local Hindsight server
export HINDSIGHT_API_URL="http://localhost:8888"

# Or Hindsight Cloud
export HINDSIGHT_API_URL="https://api.hindsight.vectorize.io"
export HINDSIGHT_API_TOKEN="your-api-key"
```

3. **Configure options (optional):**

```json
{
  "plugin": [
    ["@vectorize-io/opencode-hindsight", {
      "hindsightApiUrl": "http://localhost:8888",
      "autoRecall": true,
      "autoRetain": true,
      "recallBudget": "mid"
    }]
  ]
}
```

### Hindsight Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `HINDSIGHT_API_URL` | Hindsight API URL | (required) |
| `HINDSIGHT_API_TOKEN` | API key for auth | - |
| `HINDSIGHT_BANK_ID` | Memory bank ID | `opencode` |
| `HINDSIGHT_AUTO_RECALL` | Auto-recall on start | `true` |
| `HINDSIGHT_AUTO_RETAIN` | Auto-retain on idle | `true` |
| `HINDSIGHT_RECALL_BUDGET` | low/mid/high | `mid` |

### Dynamic Bank IDs (Multi-Project)

```bash
# Isolate memory per project
export HINDSIGHT_DYNAMIC_BANK_ID=true
# Bank ID becomes: agent::project-name
```

---

## Comparison

| Feature | AGENTS.md + Memory Folder | Hindsight Plugin |
|---------|--------------------------|------------------|
| **Setup** | Manual file + instructions | Plugin + server |
| **Persistence** | Manual updates | Automatic |
| **Search** | Text only | Vector search |
| **External deps** | None | Hindsight server |
| **Best for** | Simple projects | Complex, long-term work |
| **OpenCode** | ✅ AGENTS.md | ✅ Supported |
| **OpenClaude** | ✅ AGENTS.md | ✅ Supported |

---

## Memory Folder Usage (.agent-memory/)

The `.agent-memory/` folder is **mounted** in the container and **can be used** by the agent if instructed.

### How to Make Agent Use Memory Folder

Add instructions to `AGENTS.md` telling the agent to:

```markdown
## Memory Usage Instructions
CRITICAL: Use .agent-memory/ folder for persistent notes between sessions.

- Read .agent-memory/session-notes.md at the START of each session
- Update .agent-memory/session-notes.md with progress and decisions  
- Store context in .agent-memory/context.md for complex tasks
- Store ADRs in .agent-memory/adr/ directory
```

### Memory Folder Structure

```
your-project/
├── AGENTS.md              ← ✅ Read by both runtimes
├── .agent-memory/         ← ✅ Use this for notes (if instructed in AGENTS.md)
│   ├── session-notes.md   ← Progress, decisions, next steps
│   ├── context.md         ← Complex task context
│   └── adr/               ← Architecture Decision Records
└── your-code/
```

### Example: session-notes.md

```markdown
# Session Notes - Simple HTTP Webserver

## 2026-05-14

### Completed
- Created server.js with basic HTTP server
- Added / endpoint returning "Hello, World!"

### In Progress
- /api/status endpoint - implementing now

### Decisions
- Using native http module (no Express)
- Port 3000, ES modules

### Next Steps
- Add /api/status endpoint
- Create README
- Test server
```

**The agent will only use this folder if you tell it to in AGENTS.md!**

---

## Recommended Workflow

### For Simple Projects (Recommended)

1. Create `AGENTS.md` in project root
2. **Add memory usage instructions** telling agent to use `.agent-memory/` folder
3. Update manually after each session (or let agent update it)
4. Keep it concise and structured

### For Complex Projects

1. Install Hindsight plugin
2. Set up local or cloud Hindsight server
3. Let plugin handle auto-recall/retain
4. Use `AGENTS.md` for project-specific rules + memory folder instructions
5. Use Hindsight for conversation history

## Python Development

Python is available via `uv` (fast Python package manager):

```bash
# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate

# Add dependencies
uv add pytest black ruff

# Run Python
uv run python script.py

# Run tests
uv run pytest
```

## Usage

### Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Configure runtime:**
   ```bash
   # Edit .env and set:
   RUNTIME=opencode    # or RUNTIME=openclaude
   ```

3. **Start the container:**
   ```bash
   # For OpenCode:
   ./start-opencode.sh

   # For OpenClaude:
   ./start-openclaude.sh
   ```

4. **Enter the container:**
   ```bash
   docker exec -it advanced-coding-agent /bin/bash
   ```

5. **Start the agent TUI:**
   ```bash
   # For OpenCode:
   opencode

   # For OpenClaude:
   openclaude
   ```

### Stop the Container

```bash
# For OpenCode:
./stop-opencode.sh

# For OpenClaude:
./stop-openclaude.sh
```

## Configuration

### .env File Options

| Variable | Description | Default |
|----------|-------------|---------|
| `RUNTIME` | Choose runtime: `opencode` or `openclaude` | `opencode` |
| `CONTAINER_NAME` | Docker container name | `advanced-coding-agent` |
| `MAX_FILE_SIZE` | Max file size in bytes | `104857600` (100MB) |
| `LOG_LEVEL` | Logging level | `info` |
| `ALLOW_NETWORK` | Allow network access | `false` |
| `MODEL` | LLM model to use | (depends on runtime) |

### agents.json

The `agents.json` file configures:
- Enabled/disabled skills
- Security restrictions
- Workspace settings
- Python packages

## Troubleshooting

### Container won't start
```bash
# Check Docker is running
docker info

# Check for existing containers
docker ps -a | grep advanced-coding-agent

# Remove old container
./stop-opencode.sh  # or ./stop-openclaude.sh
```

### Permission denied
```bash
# Ensure scripts are executable
chmod +x start-*.sh stop-*.sh
```

### Build fails
```bash
# Check Dockerfile syntax
docker build -f Dockerfile.opencode --no-cache .
```

---
*Built by Gorbad Ironfist - Safe coding, WAAAGH!* 👊🪓
