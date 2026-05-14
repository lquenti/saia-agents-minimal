# Advanced Coding Agent 🦾

> An isolated, secure Docker environment for AI-assisted coding. Choose your runtime: **OpenCode** or **OpenClaude**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2.0.0-green.svg)

## 🎯 Overview

Secure, isolated Docker environment for AI coding agents with:

- ✅ **Multiple runtimes** - OpenCode or OpenClaude
- ✅ **No docker-compose** - Simple shell scripts
- ✅ **45+ pre-installed skills** - Matt Pocock + Addy Osmani
- ✅ **Security-first** - Non-root user, read-only filesystem
- ✅ **Persistent memory** - AGENTS.md + .agent-memory/

---

## 🚀 Quick Start

### 1. Clone & Configure

```bash
git clone https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent.git
cd advanced-coding-agent

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

### 3. Start Container

```bash
# For OpenCode:
./start-opencode.sh

# For OpenClaude:
./start-openclaude.sh
```

> **💡 Optional:** If no `AGENTS.md` exists in your project, the start script will offer to create one from a template:
> - **Generic template** - For any project type
> - **Python/uv template** - Includes uv, ruff, mypy, pytest workflows

### 4. Run Agent

```bash
opencode    # or openclaude
```

### 5. Exit

```bash
exit  # Container auto-removes!
```

> **💡 Pro Tip:** Build once, start multiple times. The image is cached, so subsequent starts are fast!

---

## ✅ Testing

Automated tests validate scripts, configuration, and Docker builds.

```bash
# Run all tests
./tests/run_tests.sh

# Script tests only (28 tests)
./tests/run_tests.sh scripts

# Docker tests only (requires Docker)
./tests/run_tests.sh docker
```

**Test Coverage:**
- ✅ Script syntax and permissions
- ✅ File existence and configuration
- ✅ Template completeness
- ✅ Documentation presence
- ✅ GitLab CI/CD configuration
- ✅ Docker builds (optional)

**CI/CD Integration:** Tests run automatically on merge requests.

See [Testing Guide](docs/TESTING.md) for complete documentation.

---

## 📚 Documentation

**🌐 [View Documentation Online](https://jdecker.pages-ce.gwdg.de/advanced-coding-agent/)**

| Guide | Description |
|-------|-------------|
| [**Configuration**](docs/CONFIGURATION.md) | API keys, models, providers, environment variables |
| [**Skills Reference**](docs/SKILLS.md) | Complete list of 45+ pre-installed skills |
| [**Security**](docs/SECURITY.md) | Container hardening, access control, best practices |
| [**Testing Guide**](docs/TESTING.md) | Automated tests, CI/CD integration, test coverage |
| [**Software Engineering Workflow**](docs/SOFTWARE_ENGINEERING_WORKFLOW.md) | 5-phase disciplined development process |
| [**Tools & Security**](tools.md) | Tool definitions, memory configuration, security rules |

---

## 🏗️ Architecture

```
Host System
├── .env (your config)
├── start-*.sh (launch scripts)
└── Dockerfile.* (build configs)
        │
        │ docker run -v $(pwd):...
        ▼
Container (agent user, read-only root)
├── /home/agent/workspace/projects/  ← Your mounted code (RW)
├── /home/agent/.opencode/ or .openclaude/  ← Runtime config (RO)
└── Pre-installed: Node.js, Python, uv, Git, 45+ skills
```

---

## 🧠 Persistent Memory

**Sessions are stateless by default.** Use **AGENTS.md** (works for both runtimes) to add memory:

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

**📖 Full guide:** [tools.md](tools.md#memory--persistence)

---

## 🧠 Pre-Installed Skills

**45+ production-grade skills** from Matt Pocock and Addy Osmani.

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

## 🔧 Advanced Usage

### Shell Alias (Recommended)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias start-agent='/path/to/advanced-coding-agent/start-opencode.sh'
```

Then use from anywhere:

```bash
cd /any/project
start-agent
opencode
```

### Build from Source

```bash
# OpenCode
docker build -f Dockerfile.opencode -t advanced-coding-agent .

# OpenClaude
docker build -f Dockerfile.openclaude -t advanced-coding-agent:openclaude .
```

### Debug

```bash
# Enter container
docker exec -it advanced-coding-agent /bin/bash

# View logs
docker logs -f advanced-coding-agent
```

---

## 🔒 Security

- ✅ **Non-root user** (agent)
- ✅ **Read-only filesystem**
- ✅ **Network isolation** (disabled by default)
- ✅ **Blocked dangerous commands**
- ✅ **Resource limits** (4GB RAM, 2 CPU cores)

**📖 Full security guide:** [docs/SECURITY.md](docs/SECURITY.md)

---

## 📁 Project Structure

```
advanced-coding-agent/
├── Dockerfile.opencode       # OpenCode runtime
├── Dockerfile.openclaude     # OpenClaude runtime
├── start-opencode.sh         # OpenCode launcher
├── start-openclaude.sh       # OpenClaude launcher
├── .env.example              # Configuration template
├── agents.json               # Agent configuration
├── tools.md                  # Tool definitions & security
├── README.md                 # This file
├── docs/                     # Documentation
│   ├── CONFIGURATION.md      # Complete config guide
│   ├── SKILLS.md             # All 45+ skills
│   ├── SECURITY.md           # Security hardening
│   ├── SOFTWARE_ENGINEERING_WORKFLOW.md  # 5-phase workflow
│   └── QUICK_START_SKILLS.md # Getting started
└── skills/                   # Pre-installed skills (git submodules)
    ├── matt-pocock/          # 12+ engineering skills
    └── addy-osmani/          # 23 agent skills
```

---

## 🔄 Runtime Comparison

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Runtime | Open-source | Claude-based |
| Best for | Experimentation | Complex tasks |
| API Key | OpenAI-compatible | Anthropic |
| Start Script | `start-opencode.sh` | `start-openclaude.sh` |

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Questions?** Open an issue.  
**Security issues?** Report responsibly via the issue tracker.
