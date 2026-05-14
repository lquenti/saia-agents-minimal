# Project Structure Guide

Complete reference of the Advanced Coding Agent repository structure.

---

## Repository Layout

```
advanced-coding-agent/
├── Dockerfile.opencode          # OpenCode runtime build
├── Dockerfile.openclaude        # OpenClaude runtime build
├── start-opencode.sh            # OpenCode launcher script
├── start-openclaude.sh          # OpenClaude launcher script
├── build-opencode.sh            # OpenCode build script
├── build-openclaude.sh          # OpenClaude build script
├── .env.example                 # Configuration template
├── .gitignore                   # Git ignore rules
├── .gitlab-ci.yml               # CI/CD pipeline
├── agents.json                  # Agent configuration
├── tools.md                     # Tool definitions & security
├── README.md                    # Main documentation
├── LICENSE                      # MIT license
├── CONTRIBUTING.md              # Contribution guidelines
│
├── docs/                        # Documentation folder
│   ├── CONFIGURATION.md         # API keys, providers, env vars
│   ├── SECURITY.md              # Container hardening
│   ├── SKILLS.md                # All 45+ skills reference
│   ├── SCRIPTS.md               # Build/start workflow
│   ├── TESTING.md               # Automated tests
│   ├── USAGE.md                 # Usage patterns
│   ├── DEBUGGING.md             # Troubleshooting
│   ├── ARCHITECTURE.md          # System architecture
│   ├── PROJECT_STRUCTURE.md     # This file
│   ├── ENABLE_GITLAB_PAGES.md   # GitLab Pages setup
│   ├── SOFTWARE_ENGINEERING_WORKFLOW.md  # 5-phase workflow
│   └── QUICK_START_SKILLS.md    # Getting started with skills
│
├── tests/                       # Test suite
│   ├── run_tests.sh             # Main test runner
│   ├── test_scripts.sh          # Script tests (28 tests)
│   ├── test_docker.sh           # Docker tests (10 tests)
│   └── README.md                # Test documentation
│
├── scripts/                     # Utility scripts
│   └── generate-pages.py        # GitLab Pages HTML generator
│
├── templates/                   # AGENTS.md templates
│   ├── AGENTS.md                # Generic template
│   └── AGENTS.md-python         # Python/uv template
│
└── skills/                      # Pre-installed skills (git submodules)
    ├── addy-osmani/             # 23 agent skills
    │   ├── SKILL.md
    │   └── (skill files)
    └── matt-pocock/             # 12+ engineering skills
        ├── SKILL.md
        └── (skill files)
```

---

## Core Files

### Dockerfile.opencode

**Purpose:** Build OpenCode runtime Docker image

**Contents:**
- Base image (ubuntu:24.04)
- System packages (nodejs, python3, git)
- Python package manager (uv)
- Agent user creation
- Configuration files
- Skills installation

**Size:** ~2500 bytes

---

### Dockerfile.openclaude

**Purpose:** Build OpenClaude runtime Docker image

**Contents:**
- Base image (ubuntu:24.04)
- System packages (nodejs, python3, git)
- Python package manager (uv)
- Agent user creation
- Configuration files
- Skills installation

**Size:** ~2500 bytes

**Difference from opencode:** Different skills directory path

---

### start-opencode.sh

**Purpose:** Launch OpenCode container

**Features:**
- Check Docker is running
- Check .env exists
- Offer AGENTS.md template
- Mount workspace directory
- Run with security flags
- Auto-remove on exit

**Size:** ~6000 bytes

---

### start-openclaude.sh

**Purpose:** Launch OpenClaude container

**Features:**
- Same as start-opencode.sh
- Different image tag
- Different runtime

**Size:** ~6000 bytes

---

### build-opencode.sh

**Purpose:** Build OpenCode Docker image

**Features:**
- Check Docker is running
- Build from Dockerfile.opencode
- Tag as advanced-coding-agent:latest

**Size:** ~1100 bytes

---

### build-openclaude.sh

**Purpose:** Build OpenClaude Docker image

**Features:**
- Check Docker is running
- Build from Dockerfile.openclaude
- Tag as advanced-coding-agent:openclaude

**Size:** ~1100 bytes

---

## Configuration Files

### .env.example

**Purpose:** Template for environment configuration

**Variables:**
```bash
# Required
OPENAI_API_KEY=sk-...
MODEL=gpt-4o

# Optional
BASE_URL=https://api.openai.com/v1
# ... many more provider options
```

**Size:** ~1000 bytes

---

### .env

**Purpose:** Your actual configuration (not committed)

**Created by:**
```bash
cp .env.example .env
nano .env
```

**Size:** Varies

---

### agents.json

**Purpose:** Agent configuration and skill management

**Structure:**
```json
{
  "agent": {
    "name": "advanced-coding-agent",
    "version": "2.0.0"
  },
  "skills": {
    "enabled": [...],
    "disabled": [...]
  },
  "security": {
    "rules": [...]
  }
}
```

**Size:** ~3000 bytes

---

### tools.md

**Purpose:** Tool definitions and security rules

**Contents:**
- Available tools
- Tool permissions
- Security constraints
- Memory configuration

**Size:** ~2000 bytes

---

### .gitignore

**Purpose:** Git ignore rules

**Ignores:**
- AGENTS.md (project-specific)
- .env (secrets)
- Test artifacts
- Python cache

**Size:** ~200 bytes

---

### .gitlab-ci.yml

**Purpose:** GitLab CI/CD pipeline

**Jobs:**
- `test` - Run test suite
- `lint` - Markdown linting (optional)
- `pages` - Generate HTML documentation
- `manual_*` - Manual trigger jobs

**Size:** ~2000 bytes

---

## Documentation Files

### docs/CONFIGURATION.md

**Purpose:** Complete API keys and provider configuration

**Contents:**
- Environment variables
- Provider setup (OpenAI, Azure, Ollama, etc.)
- Model configuration
- Authentication

**Size:** ~7KB

---

### docs/SECURITY.md

**Purpose:** Container hardening and security best practices

**Contents:**
- Non-root user
- Read-only filesystem
- Network isolation
- Resource limits
- Access control

**Size:** ~7KB

---

### docs/SKILLS.md

**Purpose:** Complete reference of all 45+ skills

**Contents:**
- Skill list
- Commands
- Usage examples
- Skill descriptions

**Size:** ~11KB

---

### docs/SCRIPTS.md

**Purpose:** Build and start script documentation

**Contents:**
- Script usage
- Workflow guide
- Troubleshooting
- Template selection

**Size:** ~9KB

---

### docs/TESTING.md

**Purpose:** Automated testing documentation

**Contents:**
- Test suite overview
- Running tests
- CI/CD integration
- Adding new tests

**Size:** ~10KB

---

### docs/USAGE.md

**Purpose:** Usage patterns and workflows

**Contents:**
- Basic usage
- Shell aliases
- Multiple projects
- Troubleshooting

**Size:** ~6KB

---

### docs/DEBUGGING.md

**Purpose:** Troubleshooting and debugging

**Contents:**
- Container inspection
- Build issues
- Runtime issues
- Common errors

**Size:** ~8KB

---

### docs/ARCHITECTURE.md

**Purpose:** System architecture deep dive

**Contents:**
- Container architecture
- Security architecture
- Runtime architecture
- Build architecture

**Size:** ~10KB

---

### docs/PROJECT_STRUCTURE.md

**Purpose:** Repository structure reference (this file)

**Contents:**
- File descriptions
- Directory structure
- Purpose of each file

**Size:** ~10KB

---

### docs/ENABLE_GITLAB_PAGES.md

**Purpose:** GitLab Pages setup guide

**Contents:**
- Enabling Pages
- CI/CD configuration
- Custom domain
- Troubleshooting

**Size:** ~3KB

---

### docs/SOFTWARE_ENGINEERING_WORKFLOW.md

**Purpose:** 5-phase disciplined development process

**Contents:**
- Phase 1: Shared Understanding
- Phase 2: Module Design
- Phase 3: TDD Implementation
- Phase 4: Review
- Phase 5: Ship

**Size:** ~26KB

---

### docs/QUICK_START_SKILLS.md

**Purpose:** Getting started with skills

**Contents:**
- Quick start
- First skill
- Common patterns
- Tips

**Size:** ~6KB

---

## Test Files

### tests/run_tests.sh

**Purpose:** Main test runner

**Features:**
- Runs all tests
- Selective test execution
- Color-coded output
- Summary

**Size:** ~3.5KB

---

### tests/test_scripts.sh

**Purpose:** Script and file tests

**Tests:** 28 total
- Script syntax (4)
- File existence (5)
- Template validation (5)
- Documentation (4)
- CI/CD (4)
- Python scripts (2)
- Permissions (4)

**Size:** ~7.5KB

---

### tests/test_docker.sh

**Purpose:** Docker build tests

**Tests:** 10 total
- Docker environment (2)
- Docker build (4)
- Container config (2)

**Size:** ~4.5KB

---

### tests/README.md

**Purpose:** Test suite documentation

**Contents:**
- Quick start
- Test suites
- CI/CD integration
- Adding tests

**Size:** ~5KB

---

## Script Files

### scripts/generate-pages.py

**Purpose:** GitLab Pages HTML generator

**Features:**
- Pure Python (no dependencies)
- Markdown to HTML
- Color themes
- Navigation

**Size:** ~2KB

---

## Template Files

### templates/AGENTS.md

**Purpose:** Generic AGENTS.md template

**Contents:**
- Memory usage instructions
- Project goal
- Tech stack
- Current state
- Progress tracking
- Next steps

**Size:** ~1.7KB (72 lines)

---

### templates/AGENTS.md-python

**Purpose:** Python/uv project template

**Contents:**
- All generic template content
- uv commands
- ruff linting
- mypy type checking
- pytest testing
- Configuration templates

**Size:** ~5.7KB (257 lines)

---

## Skills Directory

### skills/addy-osmani/

**Purpose:** Addy Osmani's agent skills (23 skills)

**Skills include:**
- Code review
- Documentation
- Testing
- Refactoring
- Security audit
- Performance optimization

**Size:** ~23 skills

---

### skills/matt-pocock/

**Purpose:** Matt Pocock's engineering skills (12+ skills)

**Skills include:**
- Interview preparation
- Requirements gathering
- Specification writing
- Planning
- TDD workflow
- Shipping checklist

**Size:** ~12+ skills

---

## File Sizes Summary

| File | Size | Lines |
|------|------|-------|
| README.md | 8KB | ~250 |
| docs/CONFIGURATION.md | 7KB | ~200 |
| docs/SECURITY.md | 7KB | ~180 |
| docs/SKILLS.md | 11KB | ~300 |
| docs/SCRIPTS.md | 9KB | ~250 |
| docs/TESTING.md | 10KB | ~280 |
| docs/USAGE.md | 6KB | ~180 |
| docs/DEBUGGING.md | 8KB | ~250 |
| docs/ARCHITECTURE.md | 10KB | ~300 |
| docs/PROJECT_STRUCTURE.md | 10KB | ~300 |
| docs/SOFTWARE_ENGINEERING_WORKFLOW.md | 26KB | ~700 |
| docs/ENABLE_GITLAB_PAGES.md | 3KB | ~80 |
| docs/QUICK_START_SKILLS.md | 6KB | ~150 |
| tests/test_scripts.sh | 7.5KB | ~200 |
| tests/test_docker.sh | 4.5KB | ~120 |
| tests/run_tests.sh | 3.5KB | ~100 |
| agents.json | 3KB | ~80 |
| tools.md | 2KB | ~60 |

---

## Related Documentation

- [Usage Guide](USAGE.md) - Common usage patterns
- [Scripts Guide](SCRIPTS.md) - Build/start workflow
- [Skills Reference](SKILLS.md) - All 45+ skills
- [Architecture Guide](ARCHITECTURE.md) - System design

---

**WAAAGH! Now you know where everything lives!** 🪓👊
