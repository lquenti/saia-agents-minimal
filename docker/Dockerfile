# Advanced Coding Agent - OpenCode Runtime
# Isolated Docker Environment with OpenCode CLI

FROM ubuntu:24.04

# Labels
LABEL description="OpenCode coding agent environment"
LABEL runtime="opencode"

# Build argument for host user ID (defaults to 1000 if not provided)
# This is used to match container user UID with host user for proper file ownership
ARG HOST_UID=1000
ENV HOST_UID=${HOST_UID}

ARG OPENCODE_VERSION=2.3.2

# Security: Run as non-root user
# Ubuntu 24.04 already has 'ubuntu' user with UID 1000, which matches most Linux hosts
# We rename it to 'agent' and change home directory to /home/agent
# For non-1000 UIDs, create a new agent user
RUN if [ "${HOST_UID}" = "1000" ]; then \
        # Use existing ubuntu user (UID 1000) - just rename and change home
        usermod -u 1000 -l agent -d /home/agent -m ubuntu && \
        groupmod -g 1000 -n agent ubuntu && \
        usermod -g agent agent; \
    else \
        # Create agent user with specified UID (use unique GID 9999 to avoid conflicts)
        groupadd -r -g 9999 agent && \
        useradd -r -g agent -u ${HOST_UID} -d /home/agent -m agent; \
    fi

# Configure GWDG mirror for Ubuntu packages
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://ftp.gwdg.de/pub/linux/debian/ubuntu/ubuntu/|g' etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://ftp.gwdg.de/pub/linux/debian/ubuntu/ubuntu/|g' etc/apt/sources.list.d/ubuntu.sources


# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    python3 \
    python3-venv \
    build-essential \
    ca-certificates \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/ \
    && mv /root/.local/bin/uvx /usr/local/bin/

# Install the standalone OpenCode v2 binary (no Node/npm)
RUN set -e; \
    case "$(uname -m)" in \
        x86_64) arch=x64 ;; \
        aarch64|arm64) arch=arm64 ;; \
        *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/opencode.tar.gz \
        "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${arch}.tar.gz"; \
    tar -xzf /tmp/opencode.tar.gz -C /usr/local/bin; \
    rm /tmp/opencode.tar.gz; \
    chmod 755 /usr/local/bin/opencode

# Switch to non-root user
USER agent

# Set working directory (isolated workspace)
WORKDIR /home/agent/workspace

# Create agent configuration directory
RUN mkdir -p /home/agent/.config/opencode

# Create safe workspace structure with proper ownership
RUN mkdir -p /home/agent/workspace/.agent-memory/share

RUN mkdir -p /home/agent/.local

RUN ln -sf /home/agent/workspace/.agent-memory/share /home/agent/.local/share

# Set environment variables
ENV HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    PATH="/home/agent/.local/bin:$PATH"

# Default command - interactive bash shell
CMD ["/bin/bash"]
