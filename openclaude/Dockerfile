# OpenClaude Coding Agent - Isolated Docker Environment
# Safe workspace for OpenClaude AI coding agent

FROM node:20-bookworm-slim

# Labels
LABEL maintainer="Gorbad Ironfist <gorbad@openclaw.ai>"
LABEL description="Isolated OpenClaude agent environment with pre-installed skills"
LABEL version="1.0.0"
LABEL platform="openclaude"

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
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaude CLI
RUN curl -fsSL https://openclaude.ai/install.sh | sh \
    && echo "OpenClaude installed successfully"

# Create config directory
RUN mkdir -p /home/agent/.openclaude

# Copy configuration files
COPY --chown=agent:agent .env.example /home/agent/.openclaude/.env.example
COPY --chown=agent:agent config.json /home/agent/.openclaude/config.json

# Create workspace structure
RUN mkdir -p /home/agent/workspace/{projects,docs,temp,logs} \
    && chmod -R 755 /home/agent/workspace

# Set environment variables
ENV NODE_ENV=production \
    HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    OPENCLAUDE_HOME=/home/agent/.openclaude \
    PATH=/home/agent/.openclaude/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command - wait for agent to start
CMD ["/bin/bash", "-c", "cd /home/agent/workspace && exec tail -f /dev/null"]
