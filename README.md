# Advanced Coding Agent 🦾

> An isolated, secure Docker environment for AI-assisted coding with **OpenCode**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🎯 Overview

Secure, isolated Docker environment for AI coding agents with:

- ✅ **No docker-compose** - Simple shell scripts
- ✅ **Persistent memory** - AGENTS.md + .agent-memory/

---

## 🚀 Quick Start

### 1. Clone & Configure

```bash
git clone https://gitlab-ce.gwdg.de/gwdg/coding-agents.git
cd coding-agents

cp .env.example .env
nano .env  # Set API key and MODEL
```

### 2. Build Image (Once)

```bash
./build-opencode.sh
```

### 3. Add to Shell

```bash
# For Bash
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.zshrc
source ~/.zshrc
```

### 4. Start Container

Navigate to project folder and run.

```bash
start-opencode
```

> If no `AGENTS.md` exists in your project, the start script will offer to create one from a template.

### 5. Run Agent

```bash
opencode
```

---

## 🧠 Persistent Memory

Sessions are persistent per project via .agent-memory and **AGENTS.md**

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

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.
