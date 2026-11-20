# Usage Guide 📖

## Quick Start

### 1. Initial Setup

```bash
# Clone repository
git clone https://gitlab-ce.gwdg.de/gwdg/coding-agents.git
cd advanced-coding-agent

# ⚠️ CRITICAL: Initialize submodules!
git submodule update --init --recursive

# Configure API keys
cp .env.example .env
nano .env  # Set your API key and MODEL
```

### 2. Build Docker Image (Once)

```bash
./build-opencode.sh
```

### 3. Add to Shell (Optional)

```bash
# Bash
echo "alias start-opencode=\"$(pwd)/start-opencode.sh\"" >> ~/.bashrc
source ~/.bashrc

# Zsh
echo "alias start-opencode=\"sudo $(pwd)/start-opencode.sh\"" >> ~/.zshrc
source ~/.zshrc
```

### 4. Start a Project

```bash
# Navigate to your project folder
cd /path/to/your/project

# Start the container
sudo /path/to/advanced-coding-agent/start-opencode.sh
```

The start script will:
- ✅ Create `.agent-memory/` directory
- ✅ Set up `.gitignore` (excludes `.agent-memory/`, `.opencode/`)
- ✅ Offer to create `AGENTS.md` from template
- ✅ Display project info and next steps

### 5. Run the Agent

Inside the container:

```bash
opencode
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
└── .agent-memory/         # Persistent session data
    ├── opencode/          # OpenCode memory
    └── skills/            # Custom Skills
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

Add to `.opencode/opencode.json`:

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

## Docker Extensions 🐳

Docker extensions allow you to extend the base runtime image with additional tools, packages, and configurations for specific coding environments.

### Understanding Extensions

**What are Docker extensions?**
Extensions are modular Dockerfiles that extend the base runtime image with additional functionality. Each extension is self-contained and builds on top of the OpenCode base image.

**Key Features:**
- ✅ **Automatic Discovery** - Extensions are auto-discovered from `dockerfiles/Dockerfile.*` files
- ✅ **Interactive Building** - Build scripts automatically discover and show available extensions
- ✅ **Modular Design** - Each extension is focused on a specific environment or toolset

**Current Extensions:**
- **LaTeX Support** (`dockerfiles/Dockerfile.latex`) - Complete LaTeX document preparation environment

### Extension Structure

All extensions follow the same structure pattern:

```dockerfile
ARG BASE_IMAGE=localhost/advanced-coding-agent-opencode:latest

FROM ${BASE_IMAGE}

# Your extension-specific packages and configurations here

CMD ["/bin/bash"]
```

**Required Elements:**
1. **`ARG BASE_IMAGE`** - Defines the base image to extend (build argument provided during build)
2. **`FROM ${BASE_IMAGE}`** - Uses the base image variable
3. **Your extension logic** - Packages, tools, or configurations specific to your extension

---

## Step-by-Step: Creating Your First Extension

### Step 1: Plan Your Extension

Decide what your extension will provide:
- What programming language or framework support?
- What tools or packages are needed?
- What specific coding environment will be enabled?

**Example:** We'll create a Python data science extension with Python, NumPy, pandas, and Jupyter.

### Step 2: Create the Extension File

Create a new Dockerfile in the `dockerfiles/` directory with the naming convention `Dockerfile.{extension-name}`:

```bash
# Navigate to your advanced-coding-agent directory
cd /path/to/advanced-coding-agent

# Create the extension file
nano dockerfiles/Dockerfile.python-datascience
```

### Step 3: Write the Extension Dockerfile

Add the extension content following the standard pattern:

```dockerfile
ARG BASE_IMAGE=localhost/advanced-coding-agent-opencode:latest

FROM ${BASE_IMAGE}

USER root

# Install Python and data science packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python data science libraries
RUN pip3 install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    jupyter \
    scipy \
    scikit-learn

USER agent

CMD ["/bin/bash"]
```

**Key Points:**
- Always use `USER root` before installing system packages
- Clean up apt cache to keep images small
- Return to `USER agent` after installations
- Use `--no-cache-dir` with pip for smaller layers

### Step 4: Build Your Extension

Run the build script - your extension will be automatically discovered:

```bash
sudo ./build-opencode.sh
```

**Interactive Menu Options:**
- **Option 1:** Base image only
- **Option 2:** Base + your extension
- **Option 3:** Build all images
- **Option 4:** Exit

Select option 2 to build base image + your extension.

### Step 5: Test Your Extension

Start a container with your extension:

```bash
sudo ./start-opencode.sh
```

Select your extension image from the menu, then test inside the container:

```bash
# Test Python installation
python3 --version

# Test packages
python3 -c "import numpy; import pandas; print('Packages working!')"

# Check Jupyter
jupyter --version
```

### Step 6: Use Your Extension

Now you can work in your specialized coding environment:

```bash
opencode

# Ask the agent to help with your data science tasks
"I need to analyze a CSV file using pandas"
```

---

## Extension Templates and Examples

### Example 1: Node.js Extension

**dockerfiles/Dockerfile.nodejs**
```dockerfile
ARG BASE_IMAGE=localhost/advanced-coding-agent-opencode:latest

FROM ${BASE_IMAGE}

USER root

# Install Node.js and npm
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install commonly used Node.js tools globally
RUN npm install -g \
    typescript \
    nodemon \
    eslint \
    prettier \
    @vue/cli \
    create-react-app

USER agent

CMD ["/bin/bash"]
```

### Example 2: Rust Development Extension

**dockerfiles/Dockerfile.rust**
```dockerfile
ARG BASE_IMAGE=localhost/advanced-coding-agent-opencode:latest

FROM ${BASE_IMAGE}

USER root

# Install Rust toolchain
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Rust to PATH for current and future sessions
ENV PATH="/root/.cargo/bin:${PATH}"

# Install commonly used Rust tools
RUN cargo install cargo-edit cargo-watch

USER agent

CMD ["/bin/bash"]
```

### Example 3: Go Development Extension

**dockerfiles/Dockerfile.golang**
```dockerfile
ARG BASE_IMAGE=localhost/advanced-coding-agent-opencode:latest

FROM ${BASE_IMAGE}

USER root

# Install Go
RUN apt-get update && apt-get install -y --no-install-recommends \
    golang-go \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install golang.org/x/tools/gopls@latest

# Set Go environment
ENV GOPATH=/home/agent/go
ENV PATH="${PATH}:${GOPATH}/bin"

USER agent

CMD ["/bin/bash"]
```

---

## Best Practices for Extensions

### 1. Keep Extensions Focused
- Each extension should have a single, clear purpose
- Avoid combining unrelated tools in one extension
- Make extensions composable - use multiple specific extensions rather than one monolithic one

### 2. Optimize Docker Layers
- Combine related RUN commands to reduce layers
- Clean up package caches in the same RUN command
- Order commands by frequency of change (stable packages first)

**Good:**
```dockerfile
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

**Bad:**
```dockerfile
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
RUN apt-get clean
```

### 3. Security Considerations
- Always specify exact package versions when possible
- Avoid installing unnecessary packages
- Keep extensions updated with security patches
- Use official package repositories

### 4. User Management
- Always switch to `USER root` for system-level operations
- Return to `USER agent` after installations for proper file permissions
- Never run applications as root inside the container

### 5. Naming Conventions
- Use lowercase, hyphenated names: `python-datascience`, `nodejs-webdev`
- Be descriptive but concise: `rust` vs `rust-development-tools`
- Avoid generic names: `tools` (too vague) vs `python-testing` (clear)

### 6. File Size Optimization
- Use `--no-install-recommends` with apt-get
- Use `--no-cache-dir` with pip
- Remove temporary files and caches
- Prefer Alpine-based images when possible (though base is Ubuntu)

### 7. Documentation and Comments
- Document why specific packages are needed
- Explain any non-obvious configurations
- Include usage examples in comments if helpful

---

## Building and Managing Extensions

### Building Options

```bash
sudo ./build-opencode.sh
```

**Interactive Menu:**
1. **Base Image Only** - Build just the base runtime
2. **Base + {Extension Name}** - Build base and specific extension
3. **Build All Images** - Build base + all discovered extensions
4. **Exit** - Cancel build

### Starting with Extensions

```bash
sudo ./start-opencode.sh
```

**Available Images:**
- Base Only: `advanced-coding-agent-opencode:latest`
- Base + Extension: `advanced-coding-agent-opencode-{extension}:latest`

### Listing Available Extensions

Extensions are automatically discovered from the `dockerfiles/` directory:

```bash
# List extension files
ls dockerfiles/Dockerfile.*

# Current extensions will be shown in build menu
sudo ./build-opencode.sh  # Shows discovered extensions
```

### Image Management

```bash
# List all built images
docker images | grep advanced-coding-agent

# Rebuild specific extension after changes
sudo ./build-opencode.sh  # Select your extension option

# Remove unused extension images to save space
docker image prune
```

---

## Available Pre-Built Extensions

The following 20+ production-ready extensions are available for immediate use. Extensions are grouped by technology domain and include comprehensive tooling for serious development work.

### 🌐 Web Development Extensions

**`nodejs-dev`** - Complete JavaScript/TypeScript development environment
- **Frameworks:** React, Vue.js, Angular CLI, Next.js, Express, Svelte, Nuxt
- **Build Tools:** TypeScript, Webpack, Vite, Parcel, ESLint, Prettier, Rollup
- **Package Managers:** npm, yarn, pnpm, bun
- **Testing:** Jest, Mocha, Cypress, Playwright, Testing Library
- **Dev Tools:** nodemon, pm2, concurrent execution

**`python-web`** - Python web framework development
- **Frameworks:** Django, Flask, FastAPI, Pyramid
- **Database:** PostgreSQL, MySQL, SQLite clients + SQLAlchemy
- **Async:** AsyncPG, AIOMySQL, Redis, Celery
- **API:** GraphQL, gRPC, REST frameworks
- **Testing:** pytest, pytest-django, coverage
- **Additional:** Selenium, Playwright for web scraping

**`php-laravel`** - PHP and Laravel development
- **PHP:** PHP 8.3 with common extensions
- **Frameworks:** Laravel CLI, Vapor CLI, Laravel tools
- **Web Servers:** nginx, Apache, PHP-FPM
- **Database Clients:** MySQL, PostgreSQL, Redis
- **Tools:** Composer, PHPUnit, PHPStan, Laravel Pint
- **Testing:** PHPUnit, PestPHP, Mockery

**`ruby-rails`** - Ruby on Rails development
- **Ruby:** Ruby 3.x with standard gems
- **Frameworks:** Rails, Sinatra, Padrino
- **Web Servers:** Passenger, Puma, Unicorn
- **Database:** PostgreSQL, MySQL, SQLite, Redis, MongoDB
- **Tools:** Bundle, RSpec, Cucumber, RuboCop
- **Job Queue:** Sidekiq, Resque, Delayed Job

### 💻 Systems Programming Extensions

**`cpp-dev`** - C/C++ development environment
- **Compilers:** GCC, Clang with C++17/20 support
- **Build:** CMake, Make, Ninja build system
- **Debugging:** GDB, LLDB, Valgrind
- **Libraries:** Boost, OpenSSL, SQLite, XML, XSLT
- **Quality:** clang-format, clang-tidy, static analysis
- **Package Manager:** Conan for C++ dependencies

**`go-dev`** - Go programming environment
- **Tools:** Go compiler, gofmt, go vet
- **Language Server:** gopls for IDE support
- **Debugging:** Delve debugger, air for live reload
- **Quality:** golangci-lint, staticcheck
- **Additional:** Build tools, testing frameworks

**`rust-dev`** - Rust development environment
- **Toolchain:** Rust compiler, Cargo package manager
- **Development:** rust-analyzer, rustfmt, clippy
- **Additional Tools:** cargo-edit, cargo-watch, cargo-audit
- **Database:** diesel-cli, sqlx-cli
- **Dependencies:** Common C libraries (OpenSSL, PostgreSQL)
- **Performance:** sccache for faster builds

**`java-dev`** - Java development with Maven and Gradle
- **Java:** OpenJDK 21 LTS
- **Build Tools:** Maven, Gradle, Ant
- **Frameworks:** Spring Boot CLI
- **Libraries:** Apache Commons, SLF4J, JSON libraries
- **Testing:** JUnit, test frameworks
- **Path:** Java environment properly configured

**`dotnet-dev`** - .NET and C# development
- **Framework:** .NET SDK 8.0, C# compiler
- **Tools:** Entity Framework, NuGet package manager
- **IDE:** JetBrains ReSharper tools, dotnet format
- **Web:** ASP.NET Core development
- **Database:** Common database drivers
- **Mono:** Mono runtime for cross-platform compatibility

### 🤖 AI/ML & Data Science Extensions

**`python-datascience`** - Complete data science environment
- **Python:** Python 3 with Miniconda package manager
- **Core:** NumPy, pandas, SciPy, scikit-learn
- **Visualization:** Matplotlib, Seaborn, Plotly, Bokeh
- **Jupyter:** Jupyter Notebook, JupyterLab, IPython
- **Advanced:** pandas-profiling, Sweetviz, Dtale
- **Statistical:** statsmodels, networkx, sympy

**`python-ml`** - Machine learning and training
- **Core:** TensorFlow, Keras, PyTorch, XGBoost, LightGBM
- **Experiment Tracking:** MLflow, Weights & Biases, Neptune
- **Data Version Control:** DVC
- **Serving:** FastAPI, Streamlit, Gradio
- **Optimization:** ONNX, TensorRT, model optimization
- **Orchestration:** Prefect, Dagster, Airflow
- **Transformers:** Hugging Face transformers, timm

**`deep-learning`** - Advanced deep learning with GPU support
- **Frameworks:** PyTorch with CUDA, TensorFlow GPU
- **Vision:** OpenCV, Pillow, scikit-image, Albumentations
- **NLP:** Hugging Face transformers, tokenizers, datasets
- **LLM Tools:** LangChain, OpenAI, Anthropic, timm
- **Training:** PyTorch Lightning, fastai, Ray distributed
- **Monitoring:** Weights & Biases, MLflow, TensorBoard
- **Models:** EfficientNet, pretrainedmodels, reinforcement learning

**`nlp`** - Natural Language Processing environment
- **Core:** spaCy, NLTK, TextBlob, transformers
- **Models:** Multiple spaCy models (small, medium, large)
- **Fine-tuning:** TRL, PEFT, bitsandbytes
- **Framework:** LangChain ecosystem, OpenAI, Anthropic
- **Serving:** Text Generation Inference, vLLM
- **Text Analysis:** Gensim, topic modeling, sentence embeddings
- **Utilities:** Tokenization, language detection, text preprocessing

**`mlops`** - Machine Learning Operations
- **Experiment Tracking:** MLflow, Weights & Biases, Comet, Neptune
- **Orchestration:** Prefect, Dagster, Airflow, Kubeflow
- **Data:** DVC, Great Expectations, Feast feature store
- **Deployment:** KServe, Seldon Core, BentoML
- **Infrastructure:** Kubernetes, Docker, Terraform
- **Monitoring:** Prometheus, Grafana, Evidently
- **Platforms:** Azure ML, Google Vertex AI integrations

### 📱 Mobile Development Extensions

**`flutter`** - Flutter and Dart development
- **Flutter SDK:** Latest stable Flutter SDK with Dart
- **Android:** Android SDK, build tools, platform tools
- **Build:** Gradle, Android build configuration
- **Tools:** Flutter CLI, FlutterFire CLI, DevTools
- **Development:** Hot reload, debugging, testing
- **Java:** OpenJDK 17 for Flutter builds

**`react-native`** - React Native and Expo development
- **Frameworks:** React Native CLI, Expo CLI
- **Platform:** Android SDK, command-line tools
- **Build:** Gradle, Metro bundler
- **Development:** Watchman, React DevTools, Flipper
- **Testing:** Detox, React Native testing library
- **Quality:** ESLint, Prettier, TypeScript tooling
- **JavaScript:** npm, yarn, pnpm package managers

### ☁️ Cloud & DevOps Extensions

**`devops`** - Complete DevOps toolchain
- **Containers:** Docker, Docker Compose
- **Orchestration:** Kubernetes (kubectl), Helm, minikube
- **IaC:** Terraform, Ansible, Packer, Vagrant
- **Cloud:** AWS CLI, EKSctl, AWS SAM
- **Serverless:** Serverless Framework
- **CI/CD:** Jenkins, GitLab Runner, GitHub CLI
- **Monitoring:** Prometheus, Grafana, monitoring clients
- **Additional:** Consul, Vault, Nomad for service discovery

**`cloud-dev`** - Multi-cloud development
- **AWS:** AWS CLI, EKSctl, SAM CLI, Elastic Beanstalk
- **Azure:** Azure CLI with full feature set
- **GCP:** Google Cloud CLI, Firebase CLI
- **Infrastructure:** Terraform, Kubernetes tools
- **Serverless:** Serverless Framework, AWS CDK
- **Monitoring:** Prometheus client, Grafana tools
- **Databases:** MongoDB, Redis, PostgreSQL clients

### 🗄️ Database Development Extensions

**`database-dev`** - Comprehensive database tools
- **Databases:** PostgreSQL, MySQL, SQLite, Redis, MongoDB
- **Tools:** Flyway, Liquibase for migrations
- **GUI:** DBeaver, pgAdmin, MySQL Workbench
- **Performance:** pgbench, sysbench, monitoring tools
- **Backup:** AutoMySQLBackup, backup utilities
- **Python:** SQLAlchemy, ORMs for all major databases
- **Node.js:** Knex, TypeORM, Prisma, Express database tools
- **Airflow:** Apache Airflow for ETL workflows

### 🎮 Specialized Development Extensions

**`game-dev`** - Game development environment
- **Godot Engine:** Full Godot Engine with Mono/C# support
- **Unity:** Unity build tools (Linux support)
- **Engines:** SFML, SDL, SDL2 libraries
- **Audio:** OpenAL, Vorbis, FLAC, MP3 tools
- **Physics:** Bullet, Box2D physics engines
- **Networking:** libcurl, ENet for multiplayer
- **Assets:** ImageMagick, FFmpeg, audio processing
- **Build:** CMake, Ninja, ccache for efficient compilation

**`embedded`** - Embedded systems development
- **Arduino:** Arduino CLI, official Arduino toolchain
- **PlatformIO:** Complete PlatformIO for embedded development
- **STM32:** ARM toolchain, STM32 flash tools, OpenOCD
- **Debugging:** GDB multiarch, Valgrind for embedded
- **Communication:** Serial tools (picocom, minicom, screen)
- **Microcontrollers:** AVR toolchain, ESP32/ESP8266 tools
- **Raspberry Pi:** ARM toolchain for Pi development
- **Utilities:** Git LFS for large assets, memory analysis tools

**`web3`** - Blockchain and Web3 development
- **Solidity:** Solidity compiler (solc) with multiple versions
- **Ethereum:** Hardhat, Truffle, Ganache for local testing
- **Framework:** web3.js, ethers.js, Brownie, Ape for Python
- **Modern:** Foundry for fast Solidity development
- **Libraries:** OpenZeppelin contracts, Chainlink contracts
- **Security:** Slither, Mythril for smart contract analysis
- **Substrate:** Substrate/Polkadot development tools
- **Testing:** Solidity coverage, gas reporting
- **Infrastructure:** Geth Ethereum client, IPFS tools

**`latex`** - LaTeX document preparation (original extension)
- **Complete:** TeX Live full distribution
- **Additional:** LaTeX extra packages, Biber for bibliography
- **Purpose:** Academic and technical document preparation

---

## Recommended Extension Combinations

### For Web Development
```bash
sudo ./build-opencode.sh  # Select nodejs-dev or python-web
```

### For Systems Programming
```bash
sudo ./build-opencode.sh  # Select cpp-dev, go-dev, or rust-dev
```

### For Data Science Projects
```bash
sudo ./build-opencode.sh  # Select python-datascience
```

### For Machine Learning
```bash
sudo ./build-opencode.sh  # Select python-ml or deep-learning
```

### For Full Stack Development
```bash
sudo ./build-opencode.sh  # Build nodejs-dev and database-dev
```

### For Cloud Native Development
```bash
sudo ./build-opencode.sh  # Select devops and cloud-dev
```

---

## Building and Managing Extensions

### Building Options

```bash
sudo ./build-opencode.sh
```

**Interactive Menu:**
1. **Base Image Only** - Build just the base runtime
2. **Base + {Extension Name}** - Build base and specific extension
3. **Build All Images** - Build base + all discovered extensions
4. **Exit** - Cancel build

### Starting with Extensions

```bash
sudo ./start-opencode.sh
```

**Available Images:**
- Base Only: `advanced-coding-agent-opencode:latest`
- Base + Extension: `advanced-coding-agent-opencode-{extension}:latest`

### Listing Available Extensions

Extensions are automatically discovered from the `dockerfiles/` directory:

```bash
# List extension files
ls dockerfiles/Dockerfile.*

# Current extensions will be shown in build menu
sudo ./build-opencode.sh  # Shows discovered extensions
```

### Image Management

```bash
# List all built images
docker images | grep advanced-coding-agent

# Rebuild specific extension after changes
sudo ./build-opencode.sh  # Select your extension option

# Remove unused extension images to save space
docker image prune
```

# Remove specific extension image
docker rmi advanced-coding-agent-opencode-latex:latest

# Rebuild extension after changes
sudo ./build-opencode.sh  # Select your extension option
```

---

## Extension Use Cases

### Web Development
Create extensions for different web stacks:
- `nodejs-dev` - Node.js, React, Vue, Angular, Next.js + build tools
- `python-web` - Django, Flask, FastAPI + database integration
- `php-laravel` - PHP, Composer, Laravel CLI + web servers
- `ruby-rails` - Ruby, Rails, Sinatra + testing frameworks

### Systems Programming
Establish robust environments for low-level development:
- `cpp-dev` - C/C++ with GCC, Clang, CMake, debugging tools
- `go-dev` - Go language with gopls, testing, and development tools
- `rust-dev` - Rust toolchain with cargo, rust-analyzer, and ecosystem
- `java-dev` - Java with Maven, Gradle, Spring Boot CLI
- `dotnet-dev` - .NET SDK, C#, Entity Framework + Azure tools

### Data Science & AI/ML
Build sophisticated research and development environments:
- `python-datascience` - NumPy, pandas, Jupyter, visualization tools
- `python-ml` - TensorFlow, PyTorch, scikit-learn, MLflow, ML serving
- `deep-learning` - PyTorch GPU, TensorFlow GPU, computer vision, LLM tools
- `nlp` - spaCy, transformers, Hugging Face, text generation
- `mlops` - MLflow, Kubeflow, DVC, Prefect, model deployment

### Mobile Development
Extensions for mobile app development:
- `flutter` - Flutter SDK, Dart, Android SDK, Gradle
- `react-native` - React Native CLI, Expo, mobile testing tools

### Cloud & DevOps
Tools for modern infrastructure and cloud platforms:
- `devops` - Docker, Kubernetes, Terraform, Ansible, CI/CD tools
- `cloud-dev` - AWS, Azure, GCP CLIs, serverless frameworks

### Database Engineering
Comprehensive database development and management:
- `database-dev` - PostgreSQL, MySQL, MongoDB, Redis, migration tools

### Specialized Development
Niche development environments for specific technologies:
- `game-dev` - Godot, Unity, game engines, physics, audio tools
- `embedded` - Arduino, PlatformIO, STM32, microcontroller tools
- `web3` - Solidity, Hardhat, Truffle, blockchain development
- `latex` - LaTeX document preparation (existing extension)

---

## Extension Troubleshooting

### Build Issues

**Extension not discovered:**
- Ensure file follows naming convention: `Dockerfile.{extension-name}`
- Check file is in correct directory: `advanced-coding-agent/dockerfiles/`
- Verify file has proper read permissions

**Build fails with "Base image not found":**
- Build base image first: select option 1 from build menu
- Base image is automatically built when selecting specific extension

**Permissions errors during build:**
- Always run build scripts with sudo: `sudo ./build-opencode.sh`
- Check Docker daemon is running: `sudo systemctl status docker`

### Runtime Issues

**Extension packages not available in container:**
- Verify extension image was built successfully
- Check you selected the correct image when starting container
- Test package installation: `list of commands to verify`

**Container won't start:**
- Ensure extension image exists: `docker images | grep advanced-coding-agent`
- Check for syntax errors in extension Dockerfile
- Verify extension Dockerfile follows proper structure

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
```

### API key not set
Edit `.env` and set `OPENCODE_API_KEY`.

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
