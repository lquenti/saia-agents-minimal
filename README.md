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

> **💡 Optional:** If no `AGENTS.md` exists in your project, the start script will offer to create one from a template.

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
./tests/run_tests.sh        # Run all tests
./tests/run_tests.sh scripts  # Script tests only (28 tests)
./tests/run_tests.sh docker   # Docker tests only
```

**📖 Full guide:** [Testing Guide](docs/TESTING.md)

---

## 📚 Documentation

**🌐 [View Documentation Online](https://jdecker.pages-ce.gwdg.de/advanced-coding-agent/)**

| Guide | Description |
|-------|-------------|
| [**Configuration**](docs/CONFIGURATION.md) | API keys, models, providers, environment variables |
| [**Usage Guide**](docs/USAGE.md) | Usage patterns, workflows, shell aliases |
| [**Skills Reference**](docs/SKILLS.md) | Complete list of 45+ pre-installed skills |
| [**Security**](docs/SECURITY.md) | Container hardening, access control, best practices |
| [**Testing**](docs/TESTING.md) | Automated tests, CI/CD integration |
| [**Debugging**](docs/DEBUGGING.md) | Troubleshooting, container inspection |
| [**Architecture**](docs/ARCHITECTURE.md) | System design, security, runtime architecture |
| [**Project Structure**](docs/PROJECT_STRUCTURE.md) | Repository layout, file descriptions |
| [**Runtime Comparison**](docs/RUNTIME_COMPARISON.md) | OpenCode vs OpenClaude comparison |
| [**Software Engineering Workflow**](docs/SOFTWARE_ENGINEERING_WORKFLOW.md) | 5-phase disciplined development |
| [**Scripts**](docs/SCRIPTS.md) | Build/start workflow documentation |

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

## 🔒 Security

- ✅ **Non-root user** (agent)
- ✅ **Read-only filesystem**
- ✅ **Network isolation** (disabled by default)
- ✅ **Blocked dangerous commands**
- ✅ **Resource limits** (4GB RAM, 2 CPU cores)

**📖 Full security guide:** [docs/SECURITY.md](docs/SECURITY.md)

---

## 📁 Repository Structure

```
advanced-coding-agent/
├── Dockerfile.*          # Build configs
├── start-*.sh            # Launch scripts
├── build-*.sh            # Build scripts
├── .env.example          # Config template
├── agents.json           # Agent config
├── tools.md              # Tools & security
├── docs/                 # Documentation
├── tests/                # Test suite
├── templates/            # AGENTS.md templates
└── skills/               # Pre-installed skills
```

**📖 Full structure:** [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)

---

## 🔄 Runtime Comparison

| Feature | OpenCode | OpenClaude |
|---------|----------|------------|
| Runtime | Open-source | Claude-based |
| Best for | General coding | Complex tasks |
| API Key | OpenAI-compatible | Anthropic |
| Start Script | `start-opencode.sh` | `start-openclaude.sh` |

**📖 Detailed comparison:** [docs/RUNTIME_COMPARISON.md](docs/RUNTIME_COMPARISON.md)

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Questions?** Open an issue.  
**Security issues?** Report responsibly via the issue tracker.
