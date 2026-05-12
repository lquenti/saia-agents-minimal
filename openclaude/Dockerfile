# OpenClaude Coding Agent - Isolated Docker Environment
# Safe workspace for OpenClaude AI coding agent

FROM ubuntu:24.04

# Labels
LABEL maintainer="Gorbad Ironfist <gorbad@openclaw.ai>"
LABEL description="Isolated OpenClaude agent environment with pre-installed skills"
LABEL version="1.0.0"
LABEL platform="openclaude"

# Security: Run as non-root user (UID 1000 to match host user)
RUN groupadd -r agent && useradd -r -g agent -d /home/agent -m agent -u 1000

# Install system dependencies including Python and uv (as root)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    jq \
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

# Switch to non-root user
USER agent

# Set working directory (isolated workspace)
WORKDIR /home/agent/workspace

# Install OpenClaude CLI
RUN curl -fsSL https://openclaude.ai/install.sh | sh \
    && echo "OpenClaude installed successfully"

# Create config directory
RUN mkdir -p /home/agent/.openclaude

# Copy configuration files
COPY --chown=agent:agent .env.example /home/agent/.openclaude/.env.example
COPY --chown=agent:agent config.json /home/agent/.openclaude/config.json

# Set environment variables
ENV HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    OPENCLAUDE_HOME=/home/agent/.openclaude \
    UV_BIN=~/.local/bin/uv \
    PATH=/home/agent/.openclaude/bin:/home/agent/.local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command - wait for agent to start
CMD ["/bin/bash", "-c", "cd /home/agent/workspace && exec tail -f /dev/null"]
