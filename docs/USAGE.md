# Usage Guide 📖

## Quick Start

### 1. Initial Setup

```bash
# Clone repository
git clone https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent.git
cd advanced-coding-agent

# ⚠️ CRITICAL: Initialize submodules!
git submodule update --init --recursive

# Configure API keys
cp .env.example .env
nano .env  # Set your API key and MODEL
```

### 2. Build Docker Image (Once)

```bash
# For OpenCode:
./build-opencode.sh

# For OpenClaude:
./build-openclaude.sh
```

### 3. Add to Shell (Optional)

```bash
# Bash
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.bashrc
echo "alias start-openclaude=\"$(pwd)/start-openclaude.sh\"" >> ~/.bashrc
source ~/.bashrc

# Zsh
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.zshrc
echo "alias start-openclaude=\"$(pwd)/start-openclaude.sh\"" >> ~/.zshrc
source ~/.zshrc
```

### 4. Start a Project

```bash
# Navigate to your project folder
cd /path/to/your/project

# Start the container
sudo /path/to/advanced-coding-agent/start-opencode.sh
# or
sudo /path/to/advanced-coding-agent/start-openclaude.sh
```

The start script will:
- ✅ Create `.agent-memory/` directory
- ✅ Set up `.gitignore` (excludes `.agent-memory/`, `.opencode/`/`.openclaude/`, `.npm/`)
- ✅ Offer to create `AGENTS.md` from template
- ✅ Display project info and next steps

### 5. Run the Agent

Inside the container:

```bash
opencode
# or
openclaude
```

### 6. Exit

```bash
exit
# or Ctrl+D
```

Container auto-removes on exit. Your workspace and memory persist!

---

## Project Structure

When you start a container, these files/directories are created in your project:

```
your-project/
├── AGENTS.md              # Agent memory (created if missing)
├── .gitignore             # Auto-generated with exclusions
├── .agent-memory/         # Persistent session data
│   ├── opencode/          # OpenCode memory
│   └── claude/            # OpenClaude memory
├── .opencode/             # OpenCode config (container-local)
├── .openclaude/           # OpenClaude data (container-local)
└── .npm/                  # npm cache (container-local)
```

---

## AGENTS.md - Persistent Memory

`AGENTS.md` provides persistent memory across sessions. The start script offers to create it from a template if missing.

### Template Structure

```markdown
# AGENTS.md - Project Memory

## Project Overview
[What are you building?]

## Current State
- Status: [In progress / Blocked / Complete]
- Last task: [What were you working on?]
- Next task: [What's next?]

## Key Decisions
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

## Open Questions
- [Question 1]
- [Question 2]

## Memory Usage
CRITICAL: Use .agent-memory/ folder for persistent notes.
- Read .agent-memory/session-notes.md at session start
- Update with progress and decisions
```

---

## Skills

### Available Commands

| Skill | Purpose |
|-------|---------|
| `/interview-me` | Extract requirements one question at a time |
| `/grill-with-docs` | Build shared language + CONTEXT.md |
| `/spec` | Write PRD before any code |
| `/plan` | Break into small, verifiable tasks |
| `/test` | TDD with 80/15/5 test pyramid |
| `/build` | Thin vertical slices |
| `/review` | Five-axis code review |
| `/code-simplify` | Reduce complexity |
| `/ship` | Pre-launch checklist |
| `/understand` | Codebase analysis & knowledge graph |

**📖 Complete list:** [SKILLS.md](SKILLS.md)

---

## Troubleshooting

### Docker not running
```bash
sudo systemctl start docker
```

### Image not found
```bash
./build-opencode.sh
# or
./build-openclaude.sh
```

### API key not set
Edit `.env` and set `OPENCODE_API_KEY` or `OPENCLAUDE_API_KEY`

### Permission denied
Scripts must be run with `sudo`:
```bash
sudo ./start-opencode.sh
```

---

## Best Practices

1. **Always initialize submodules** - Skills won't work without them
2. **Use AGENTS.md** - Keep track of decisions and state
3. **Use .agent-memory/** - Store session-specific notes
4. **Follow the workflow** - Use skills in order: spec → plan → test → build → review → ship
5. **Keep .gitignore updated** - Don't commit `.agent-memory/` or runtime data

---

## Next Steps

- 📖 [Project Structure](PROJECT_STRUCTURE.md) - Understand the layout
- 📖 [Skills Reference](SKILLS.md) - Learn all available skills
- 📖 [Software Engineering Workflow](SOFTWARE_ENGINEERING_WORKFLOW.md) - Master the process
