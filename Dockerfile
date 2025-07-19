FROM ubuntu:24.04

ENV LANG="C.UTF-8"
ENV HOME=/root

### BASE ###

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        binutils \
        sudo \
        build-essential \
        ca-certificates \
        curl \
        git \
        git-lfs \
        gnupg2 \
        jq \
        libbz2-dev \
        libc6 \
        libc6-dev \
        libcurl4-openssl-dev \
        libffi-dev \
        libgcc-13-dev \
        libgdbm-compat-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses-dev \
        libncursesw5-dev \
        libnss3-dev \
        libpython3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libstdc++-13-dev \
        libxml2-dev \
        make \
        openssh-client \
        pkg-config \
        python3-pip \
        ripgrep \
        sqlite3 \
        tk-dev \
        tzdata \
        unzip \
        uuid-dev \
        xz-utils \
        zip \
        zlib1g \
        zlib1g-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

### PYTHON ###

ARG PYTHON_VERSION=3.12
ARG ENABLE_MULTI_PYTHON=false

# Install base Python 3.12 (always available in Ubuntu 24.04)
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        pipx \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Conditionally install additional Python versions via deadsnakes PPA
# This will work when external repositories are accessible
RUN if [ "$ENABLE_MULTI_PYTHON" = "true" ]; then \
        add-apt-repository ppa:deadsnakes/ppa && \
        apt-get update && \
        apt-get install -y \
            python3.10 \
            python3.10-dev \
            python3.10-venv \
            python3.11 \
            python3.11-dev \
            python3.11-venv \
            python3.13 \
            python3.13-dev \
            python3.13-venv && \
        rm -rf /var/lib/apt/lists/* && \
        update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 10; \
    fi

# Configure pipx environment
ENV PIPX_BIN_DIR=/root/.local/bin
ENV PATH=$PIPX_BIN_DIR:$PATH

# Create a script for easy Python version switching
RUN echo '#!/bin/bash' > /usr/local/bin/switch-python && \
    echo 'if [ $# -eq 0 ]; then' >> /usr/local/bin/switch-python && \
    echo '  echo "Usage: switch-python <version>"' >> /usr/local/bin/switch-python && \
    echo '  echo "Available versions:"' >> /usr/local/bin/switch-python && \
    echo '  for v in 3.10 3.11 3.12 3.13; do' >> /usr/local/bin/switch-python && \
    echo '    if command -v python$v &>/dev/null; then echo "  - $v"; fi' >> /usr/local/bin/switch-python && \
    echo '  done' >> /usr/local/bin/switch-python && \
    echo '  exit 1' >> /usr/local/bin/switch-python && \
    echo 'fi' >> /usr/local/bin/switch-python && \
    echo 'VERSION=$1' >> /usr/local/bin/switch-python && \
    echo 'if command -v python$VERSION &>/dev/null; then' >> /usr/local/bin/switch-python && \
    echo '  update-alternatives --install /usr/bin/python python /usr/bin/python$VERSION 10' >> /usr/local/bin/switch-python && \
    echo '  echo "Switched to Python $VERSION"' >> /usr/local/bin/switch-python && \
    echo '  python --version' >> /usr/local/bin/switch-python && \
    echo 'else' >> /usr/local/bin/switch-python && \
    echo '  echo "Python $VERSION not available"' >> /usr/local/bin/switch-python && \
    echo '  exit 1' >> /usr/local/bin/switch-python && \
    echo 'fi' >> /usr/local/bin/switch-python && \
    chmod +x /usr/local/bin/switch-python




### SETUP SCRIPTS ###

COPY setup_universal.sh /opt/codex/setup_universal.sh
RUN chmod +x /opt/codex/setup_universal.sh

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT  ["/opt/entrypoint.sh"]
