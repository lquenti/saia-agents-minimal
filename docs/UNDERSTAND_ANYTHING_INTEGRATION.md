# Understand-Anything Integration Summary (2026-05-27)

**Project:** Advanced Coding Agent  
**Location:** `~/advanced-coding-agent/`  
**Status:** ✅ Successfully integrated

---

## What Was Added

### 1. New Skill: Understand-Anything

**Location:** `~/advanced-coding-agent/skills/addy-osmani/skills/understand-anything/`

**Files Created:**
- `SKILL.md` - Complete skill documentation (9.5KB)

**Purpose:**
- Turn any codebase into an interactive knowledge graph
- Multi-agent pipeline for code analysis
- Visual dashboard for exploration
- Supports 6 languages
- Incremental updates

### 2. Documentation Updates

**Updated Files:**
- `docs/SKILLS.md` - Added `/understand` to skill reference
- `README.md` - Updated skill count (46+) and added to key skills table

---

## Available Commands

### Installation (First-Time)

```bash
# In the advanced coding agent container
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash
```

### Core Commands

| Command | Description |
|---------|-------------|
| `/understand` or `/ua` | Scan project and build knowledge graph |
| `/understand-dashboard` | Open interactive web dashboard |
| `/understand-chat <question>` | Ask questions about codebase |
| `/understand-explain <file>` | Deep-dive into specific file |
| `/understand-onboard` | Generate onboarding guide |
| `/understand-domain` | Extract business domains |
| `/understand-diff` | Analyze impact of changes |
| `/understand-knowledge <wiki>` | Analyze wiki/knowledge base |

---

## Usage Examples

### Quick Onboarding

```bash
# Scan codebase
/understand

# Open dashboard
/understand-dashboard

# Ask questions
/understand-chat "How does authentication work?"
```

### Deep Analysis

```bash
# Full scan with auto-update
/understand --auto-update

# Generate onboarding docs
/understand-onboard docs/UNDERSTANDING.md

# Extract business domains
/understand-domain
```

### Impact Analysis

```bash
# Make changes
git add src/

# See impact
/understand-diff
```

---

## Features

- **Multi-agent pipeline** - 5-6 specialized agents
- **Tree-sitter parsing** - Deterministic structural analysis
- **LLM semantic analysis** - Plain-English summaries
- **Interactive dashboard** - Visual knowledge graph exploration
- **Incremental updates** - Only re-analyzes changed files
- **Multi-language** - en, zh, zh-TW, ja, ko, ru
- **Git integration** - Share graphs with teammates
- **Auto-update hook** - Post-commit incremental updates

---

## Output Structure

```
<project>/.understand-anything/
├── knowledge-graph.json      # Main graph (commit this!)
├── intermediate/              # Scratch files (ignore)
└── diff-overlay.json          # Local scratch (ignore)
```

---

## Integration with Other Skills

### With `/spec`

```bash
/spec  # Write spec first
/understand  # Then understand existing code
/understand-chat "Does current architecture support this?"
```

### With `/plan`

```bash
/understand  # Understand codebase
/plan  # Then plan implementation
```

### With `/review`

```bash
/understand-diff  # Before review
/review  # Then review
```

### With `/diagnose`

```bash
/understand-chat "What files are related to X?"
/diagnose  # Then diagnose the bug
```

---

## Resources

- **GitHub:** https://github.com/Lum1104/Understand-Anything
- **Live Demo:** https://understand-anything.com/demo/
- **Discord:** https://discord.gg/pydat66RY
- **Documentation:** https://understand-anything.com

---

## Next Steps

### Option 1: Install Outside Container (Recommended)

```bash
# On your host machine
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash

# Start container - skill is automatically available
./start-opencode.sh
```

**Benefits:**
- ✅ Install once, use in all containers
- ✅ Graph persists across container restarts
- ✅ No need to reinstall after container rebuild

### Option 2: Install Inside Container

```bash
# Start the container
./start-opencode.sh

# Inside the container
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash

# Test it
/understand --help
```

**Note:** Requires reinstalling after container rebuild.

### Option 2a: Modify Dockerfile (Persistent Install)

Add to `Dockerfile.opencode` or `Dockerfile.openclaude`:

```dockerfile
# After the existing skill installation section

# Install Understand-Anything
RUN curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash
```

Then rebuild:

```bash
./build-opencode.sh
./start-opencode.sh
```

**Benefits:**
- ✅ Pre-installed in every new container
- ✅ No manual installation needed

### Option 2b: Volume Mount (Hybrid)

Mount host installation into container by adding to start script:

```bash
-v ~/.understand-anything:/home/agent/.understand-anything
```

**Benefits:**
- ✅ Install once on host
- ✅ Available in container
- ✅ Graph persists automatically

---

**Full installation guide:** See `skills/addy-osmani/skills/understand-anything/SKILL.md`

---

**WAAAGH! Now your advanced coding agent can smash through complex codebases with knowledge graphs!** 🪓👊
