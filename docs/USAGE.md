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
echo "alias start-opencode=\"sudo $(pwd)/start-opencode.sh\"" >> ~/.zshrc
echo "alias start-openclaude=\"sudo $(pwd)/start-openclaude.sh\"" >> ~/.zshrc
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
│   ├── npm/               # OpenClaude cache
│   ├── skills/            # Custom Skills
│   ├── openclaude/        # OpenClaude memory
│   └── claude/            # OpenClaude memory
└── .openclaude/           # OpenClaude memory, symlink to .agent-memory
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

## Adding Custom Skills

You can add your own skills to extend the agent's capabilities.

### Skill Structure

Create a skill directory in your project:

```
your-project/
└── .agent-memory/
    └── skills/           # Custom skills directory
        └── my-custom-skill/
            ├── SKILL.md  # Skill definition (required)
            ├── README.md # Documentation (optional)
            └── scripts/  # Helper scripts (optional)
```

### SKILL.md Format

```markdown
# My Custom Skill

## Description
Brief description of what this skill does.

## Usage
```
my-command [arguments]
```

## Examples
```bash
my-command --option value
```

## Implementation
How the skill works internally.
```

### Registering a Skill

Add to `.agent-memory/claude/opencode.json` (or `.opencode/opencode.json`):

```json
{
  "skills": {
    "my-custom-skill": {
      "path": "/home/agent/workspace/.agent-memory/share/skills/my-custom-skill",
      "enabled": true
    }
  }
}
```

### Example: Custom Code Review Skill

```markdown
# /custom-review

## Description
Run custom review with project-specific rules.

## Usage
```
/custom-review [file]
```

## Rules
1. Check for security vulnerabilities
2. Validate against project coding standards
3. Suggest performance improvements
```

### Pre-installed Skills Location

Skills are mounted from:
- **OpenCode:** `/home/agent/.opencode/workspace/skills/`
- **OpenClaude:** `/home/agent/.openclaude/workspace/skills/`

Your custom skills in `.agent-memory/share/skills/` are symlinked to these locations.

---

## Workflow Examples

### Example 1: New Feature Development

```bash
# 1. Start container
cd my-project
sudo start-opencode.sh

# 2. Extract requirements
/interview-me

# 3. Build shared context
/grill-with-docs

# 4. Write specification
/spec

# 5. Break into tasks
/plan

# 6. Implement with tests
/test
/build

# 7. Review and simplify
/review
/code-simplify

# 8. Ship it!
/ship
```

### Example 2: Bug Fixing

```bash
# 1. Diagnose the issue
/diagnose

# 2. Understand codebase context
/zoom-out

# 3. Write failing test
/test

# 4. Fix the bug
/build

# 5. Verify fix
/test

# 6. Review changes
/review
```

### Example 3: Codebase Understanding

```bash
# 1. Generate knowledge graph
/understand

# 2. Review architecture
/improve-codebase-architecture

# 3. Create documentation
/grill-with-docs
```

---

## Session Memory

### AGENTS.md (Project-wide)
Persistent across all sessions for the project.

### .agent-memory/ (Session-specific)
```
.agent-memory/
└── session-notes.md    # session data
```

**Best Practice:**
- Start each session by reading `session-notes.md`
- Update with decisions and progress
- Keep AGENTS.md for major decisions only

---

## Troubleshooting

### Docker not running
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in
```

### Image not found
```bash
./build-opencode.sh
# or
./build-openclaude.sh
```

### API key not set
Edit `.env` and set:
- `OPENCODE_API_KEY` for OpenCode
- `OPENCLAUDE_API_KEY` for OpenClaude

### Permission denied
Scripts must be run with `sudo`:
```bash
sudo ./start-opencode.sh
```

### Skills not loading
1. Check submodules are initialized:
   ```bash
   git submodule update --init --recursive
   ```
2. Verify skills directory exists:
   ```bash
   ls skills/
   ```
3. Check `.agent-memory/share/skills/` is populated

### Container won't start
1. Check Docker is running: `docker ps`
2. Check image exists: `docker images`
3. Check `.env` has required variables
4. Check disk space: `df -h`

---

## Best Practices

1. **Always initialize submodules** - Skills won't work without them
2. **Use AGENTS.md** - Keep track of decisions and state
3. **Use .agent-memory/** - Store session-specific notes
4. **Follow the workflow** - Use skills in order: spec → plan → test → build → review → ship
5. **Keep .gitignore updated** - Don't commit `.agent-memory/` or runtime data
6. **Write custom skills** - Extend functionality for your specific needs
7. **Document decisions** - Update AGENTS.md after major changes

---

## Next Steps

- 📖 [Project Structure](PROJECT_STRUCTURE.md) - Understand the layout
- 📖 [Skills Reference](SKILLS.md) - Learn all available skills
- 📖 [Software Engineering Workflow](SOFTWARE_ENGINEERING_WORKFLOW.md) - Master the process
