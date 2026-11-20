# OpenCode coding agent
# Ubuntu 24.04 + standalone OpenCode binary

FROM ubuntu:24.04

LABEL description="OpenCode coding agent environment"

# -----------------------------------------------------------------------------
# PRE-SETUP: DO NOT EDIT
# -----------------------------------------------------------------------------

# Host UID to match, so files written to the mounted workspace stay yours
ARG HOST_UID=1000
ENV HOST_UID=${HOST_UID}
ARG OPENCODE_VERSION=2.3.2
# user creation
RUN if [ "${HOST_UID}" = "1000" ]; then \
        usermod -u 1000 -l agent -d /home/agent -m ubuntu && \
        groupmod -g 1000 -n agent ubuntu && \
        usermod -g agent agent; \
    else \
        groupadd -r -g 9999 agent && \
        useradd -r -g agent -u "${HOST_UID}" -d /home/agent -m agent; \
    fi
# GWDG mirror (optional)
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://ftp.gwdg.de/pub/linux/debian/ubuntu/ubuntu/|g' etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://ftp.gwdg.de/pub/linux/debian/ubuntu/ubuntu/|g' etc/apt/sources.list.d/ubuntu.sources
# Install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Setup opencode 2 (globally)
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

# =============================================================================
# YOUR TOOLS
# Runs as root. Add your own RUN commands below.
# =============================================================================
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         python3 \
#         python3-venv \
#         build-essential \
#         nano \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
#
# RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
#     && mv /root/.local/bin/uv /root/.local/bin/uvx /usr/local/bin/
# =============================================================================

# -----------------------------------------------------------------------------
# RUNTIME-SETUP: DO NOT EDIT
# -----------------------------------------------------------------------------
USER agent
WORKDIR /home/agent/workspace

RUN mkdir -p /home/agent/.config/opencode \
             /home/agent/workspace/.agent-memory/share \
             /home/agent/.local && \
    ln -sf /home/agent/workspace/.agent-memory/share /home/agent/.local/share

ENV HOME=/home/agent \
    WORKSPACE=/home/agent/workspace \
    PATH="/home/agent/.local/bin:$PATH"

CMD ["/bin/bash"]
