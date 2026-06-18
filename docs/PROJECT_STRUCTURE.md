# Project Structure 🏗️

```
advanced-coding-agent/
├── .env                    # API keys and configuration
├── .env.example            # Template for .env
├── .gitignore              # Git ignore rules (auto-generated)
├── AGENTS.md               # Persistent agent memory (per-project)
├── README.md               # Main documentation
├── CONTRIBUTING.md         # Contribution guidelines
├── LICENSE                 # MIT License
│
├── build-opencode.sh       # Build OpenCode Docker image
├── build-openclaude.sh     # Build OpenClaude Docker image
├── start-opencode.sh       # Start OpenCode container
├── start-openclaude.sh     # Start OpenClaude container
│
├── Dockerfile.opencode     # OpenCode runtime definition
├── Dockerfile.openclaude   # OpenClaude runtime definition
│
├── docs/                   # Documentation
│   ├── PROJECT_STRUCTURE.md    # This file
│   ├── USAGE.md                # How to use the agent
│   ├── SKILLS.md               # Pre-installed skills
│   └── SOFTWARE_ENGINEERING_WORKFLOW.md  # Workflow guide
│
├── skills/                 # Pre-installed skills (git submodules)
│   ├── addy-osmani/        # Addy Osmani's coding skills
│   ├── matt-pocock/        # Matt Pocock's productivity skills
│   └── understand-anything/ # Codebase analysis tool
│
├── templates/              # Template files
│   ├── AGENTS.md           # Generic project template
│   └── AGENTS.md-python    # Python project template
│
└── .agent-memory/          # Persistent session data (per-project)
    ├── opencode/           # OpenCode session memory
    └── claude/             # OpenClaude session memory
```

## Key Directories

### `skills/` - Pre-installed Skills
Git submodules containing production-grade coding skills. **Must initialize submodules:**
```bash
git submodule update --init --recursive
```

### `.agent-memory/` - Persistent Session Data
Session-specific memory that persists across container runs:
- `opencode/` - OpenCode runtime memory
- `claude/` - OpenClaude runtime memory

Created automatically by start scripts in your project folder.

### `templates/` - Starter Templates
Pre-written `AGENTS.md` templates for different project types.

## Files Explained

### `build-*.sh`
Build Docker images for each runtime. Run once before first use.

### `start-*.sh`
Launch containers with proper mounts and configuration. Handles:
- `.gitignore` setup
- `AGENTS.md` creation
- Environment validation
- Container startup

### `.env`
Configuration file with API keys:
- `OPENCODE_API_KEY` / `OPENCLAUDE_API_KEY`
- `MODEL` - LLM model to use
- Optional: `OPENAI_BASE_URL`, `OPENAI_MODEL`

## Runtime Differences

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Base | Claude 3.5 Sonnet | Claude 3.5 Sonnet |
| Config path | `.opencode/` | `.openclaude/` |
| Memory path | `.agent-memory/opencode/` | `.agent-memory/claude/` |
| Skills | Same | Same |

Both runtimes share the same skills and workflow!
