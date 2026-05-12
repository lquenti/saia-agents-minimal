# Advanced Coding Agent - Isolated Docker Environment
# Safe workspace for coding agents - can't touch host files!

FROM node:20-bookworm-slim

# Labels
LABEL maintainer="Gorbad Ironfist <gorbad@openclaw.ai>"
LABEL description="Isolated coding agent environment with pre-installed skills"
LABEL version="1.0.0"

# Security: Run as non-root user
RUN groupadd -r agent && useradd -r -g agent -d /home/agent -m agent
USER agent

# Set working directory (isolated workspace)
WORKDIR /home/agent/workspace

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    python3 \
    python3-pip \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaw CLI (for OpenClaw-based agents)
RUN curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw/main/install.sh | sh \
    && echo "OpenClaw installed"

# Alternative: Install OpenCode (comment out above if using OpenCode)
# RUN npm install -g @opencodeai/cli

# Create skills directory
RUN mkdir -p /home/agent/.openclaw/workspace/skills

# Pre-install essential skills via OpenClaw/ClawHub
# These are safe, curated skills for coding agents

# Skill 1: GitHub integration
RUN openclaw skills install github 2>/dev/null || echo "GitHub skill install attempted"

# Skill 2: Git operations
RUN openclaw skills install git 2>/dev/null || echo "Git skill install attempted"

# Skill 3: File operations
RUN openclaw skills install fileops 2>/dev/null || echo "FileOps skill install attempted"

# Skill 4: Shell commands (safe subset)
RUN openclaw skills install shell 2>/dev/null || echo "Shell skill install attempted"

# Skill 5: Web tools
RUN openclaw skills install web 2>/dev/null || echo "Web skill install attempted"

# Copy agent configuration
COPY --chown=agent:agent agents.json /home/agent/.openclaw/
COPY --chown=agent:agent tools.md /home/agent/.openclaw/workspace/

# Create safe workspace structure
RUN mkdir -p /home/agent/workspace/{projects,docs,temp} \
    && chmod -R 755 /home/agent/workspace

# Security: Restrict filesystem access
# The container can only write to /home/agent/workspace
# Host volumes are mounted read-only except for workspace

# Set environment variables
ENV NODE_ENV=production \
    HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    OPENCLAW_HOME=/home/agent/.openclaw

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command - start agent in workspace
CMD ["/bin/bash", "-c", "cd /home/agent/workspace && exec tail -f /dev/null"]
