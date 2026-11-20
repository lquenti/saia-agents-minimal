# Advanced Coding Agent 🦾

> An isolated, secure Docker environment for AI-assisted coding with **OpenCode**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🎯 Overview

Secure, isolated Docker environment for AI coding agents with:

- ✅ **No docker-compose** - Simple shell scripts
- ✅ **Persistent memory** - .agent-memory/

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
./build.sh
```

### 3. Add to Shell

```bash
# For Bash
echo "alias agent=\"$(pwd)/run.sh\"" >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo "alias agent=\"$(pwd)/run.sh\"" >> ~/.zshrc
source ~/.zshrc
```

### 4. Start Container

Navigate to project folder and run.

```bash
agent
```

### 5. Run Agent

```bash
opencode
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.
