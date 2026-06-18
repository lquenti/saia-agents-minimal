# Advanced Coding Agent 🦾

> An isolated, secure Docker environment for AI-assisted coding.\
> Choose your runtime: **OpenCode** or **OpenClaude**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

## 🎯 Overview

Secure, isolated Docker environment for AI coding agents with:

- ✅ **Multiple runtimes** - OpenCode or OpenClaude
- ✅ **No docker-compose** - Simple shell scripts
- ✅ **Pre-installed skills** - Matt Pocock + Addy Osmani + Understand-Anything
- ✅ **Persistent memory** - AGENTS.md + .agent-memory/

---

## 🚀 Quick Start

### 1. Clone & Configure

```bash
git clone https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent.git
cd advanced-coding-agent

# ⚠️ CRITICAL: Initialize submodules!
# This project uses Git submodules for skills (addy-osmani, matt-pocock)
# Without this step, the skills directories will be empty!

git submodule update --init --recursive

# Verify submodules are loaded:
ls -la skills/addy-osmani  # Should contain files, not just a .git file
ls -la skills/matt-pocock  # Should contain files, not just a .git file

cp .env.example .env
nano .env  # Set API key and MODEL
```

### 2. Build Image (Once)

```bash
# For OpenCode:
./build-opencode.sh

# For OpenClaude:
./build-openclaude.sh
```

### 3. Add to Shell

```bash
# For Bash
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.bashrc
echo "alias start-openclaude=\"$(pwd)/start-openclaude.sh\"" >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.zshrc
echo "alias start-openclaude=\"$(pwd)/start-openclaude.sh\"" >> ~/.zshrc
source ~/.zshrc
```

### 4. Start Container

Navigate to project folder and run.

```bash
# For OpenCode:
start-opencode

# For OpenClaude:
start-openclaude
```

> If no `AGENTS.md` exists in your project, the start script will offer to create one from a template.

### 5. Run Agent

```bash
opencode    
# or 
openclaude
```
---

## 📚 Documentation

**🌐 [View Documentation Online](https://jdecker.pages-ce.gwdg.de/advanced-coding-agent/)**

| Guide | Description |
|-------|-------------|
| [**Skills Reference**](docs/SKILLS.md) | Complete list of 46+ pre-installed skills |
| [**Software Engineering Workflow**](docs/SOFTWARE_ENGINEERING_WORKFLOW.md) | 5-phase disciplined development |

---

## 🧠 Persistent Memory

Sessions are persistent per project via .agent-memory and **AGENTS.md** (works for both runtimes)

```markdown
# AGENTS.md

## Memory Usage
CRITICAL: Use .agent-memory/ folder for persistent notes.
- Read .agent-memory/session-notes.md at session start
- Update with progress and decisions

## Current State
- Status: In progress
- Last task: Implement feature X
```

---

## 🧠 Pre-Installed Skills

**Production-grade skills** from Matt Pocock and Addy Osmani.

### Key Skills

| Skill | Command | Purpose |
|-------|---------|---------|
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

**📖 Complete list:** [docs/SKILLS.md](docs/SKILLS.md)

---

## 🏭️ Software Engineering Workflow

Follow a **5-phase disciplined workflow**:

```
1. Shared Understanding → /interview-me, /grill-with-docs, /spec
2. Module & Interface Design → /plan, /api-and-interface-design
3. Test-Driven Implementation → /test, /build
4. Review & Simplify → /review, /code-simplify
5. Ship → /ship
```

**📖 Full workflow:** [docs/SOFTWARE_ENGINEERING_WORKFLOW.md](docs/SOFTWARE_ENGINEERING_WORKFLOW.md)

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.
