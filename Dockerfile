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

# Use the default Python 3.12 from Ubuntu 24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Note: poetry, uv, and other Python tools can be installed via pip once network connectivity is available




### SETUP SCRIPTS ###

COPY setup_universal.sh /opt/codex/setup_universal.sh
RUN chmod +x /opt/codex/setup_universal.sh

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT  ["/opt/entrypoint.sh"]
