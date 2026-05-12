# OpenCode Coding Agent - Isolated Docker Environment
# Safe workspace for OpenCode AI coding agent

FROM ubuntu:24.04

# Labels
LABEL maintainer="Gorbad Ironfist <gorbad@openclaw.ai>"
LABEL description="Isolated OpenCode agent environment with pre-installed skills"
LABEL version="1.0.0"
LABEL platform="opencode"

# Security: Run as non-root user
RUN groupadd -r agent && useradd -r -g agent -d /home/agent -m agent

# Install system dependencies including Python and uv (as root)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    jq \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package installer) as root
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mkdir -p /home/agent/.local && \
    cp -r /root/.local/* /home/agent/.local/ && \
    chown -R agent:agent /home/agent/.local

# Create workspace structure (as root, before switching to agent)
RUN mkdir -p /home/agent/workspace/{projects,docs,temp,logs} && \
    chown -R agent:agent /home/agent/workspace

# Create skills directory
RUN mkdir -p /home/agent/.opencode/skills

# Copy skills from build context
COPY --chown=agent:agent skills/skills /home/agent/.opencode/skills-mattpocock
COPY --chown=agent:agent skills/agent-skills /home/agent/.opencode/skills-addyosmani

# Switch to non-root user
USER agent

# Set working directory (isolated workspace)
WORKDIR /home/agent/workspace

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install.sh | sh \
    && echo "OpenCode installed successfully"

# Create config directory
RUN mkdir -p /home/agent/.opencode

# Copy configuration files
COPY --chown=agent:agent .env.example /home/agent/.opencode/.env.example
COPY --chown=agent:agent config.json /home/agent/.opencode/config.json

# Set environment variables
ENV HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    OPCODE_HOME=/home/agent/.opencode \
    UV_BIN=~/.local/bin/uv \
    PATH=/home/agent/.opencode/bin:/home/agent/.local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command - wait for agent to start
CMD ["/bin/bash", "-c", "cd /home/agent/workspace && exec tail -f /dev/null"]
