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
        bzr \
        ca-certificates \
        curl \
        default-libmysqlclient-dev \
        dnsutils \
        gettext \
        git \
        git-lfs \
        gnupg2 \
        inotify-tools \
        iputils-ping \
        jq \
        libbz2-dev \
        libc6 \
        libc6-dev \
        libcurl4-openssl-dev \
        libdb-dev \
        libedit2 \
        libffi-dev \
        libgcc-13-dev \
        libgcc1 \
        libgdbm-compat-dev \
        libgdbm-dev \
        libgdiplus \
        libgssapi-krb5-2 \
        liblzma-dev \
        libncurses-dev \
        libncursesw5-dev \
        libnss3-dev \
        libpq-dev \
        libpsl-dev \
        libpython3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libstdc++-13-dev \
        libunwind8 \
        libuuid1 \
        libxml2-dev \
        libz3-dev \
        make \
        moreutils \
        netcat-openbsd \
        openssh-client \
        pkg-config \
        protobuf-compiler \
        python3-pip \
        ripgrep \
        rsync \
        software-properties-common \
        sqlite3 \
        swig3.0 \
        tk-dev \
        tzdata \
        unixodbc-dev \
        unzip \
        uuid-dev \
        xz-utils \
        zip \
        zlib1g \
        zlib1g-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

### PYTHON ###

ARG PYENV_VERSION=v2.5.5
ARG PYTHON_VERSION=3.11.12

# Install pyenv
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN git config --global http.sslverify false \
    && git -c advice.detachedHead=0 clone --branch ${PYENV_VERSION} --depth 1 https://github.com/pyenv/pyenv.git "${PYENV_ROOT}" \
    && git config --global --unset http.sslverify \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile \
    && echo 'export PATH="$$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> /etc/profile \
    && echo 'eval "$(pyenv init - bash)"' >> /etc/profile \
    && cd ${PYENV_ROOT} && src/configure && make -C src
# Install pipx for common global package managers (e.g. poetry)
ENV PIPX_BIN_DIR=/root/.local/bin
ENV PATH=$PIPX_BIN_DIR:$PATH
RUN apt-get update && apt-get install -y pipx \
    && rm -rf /var/lib/apt/lists/*


### NODE ###

ARG NVM_VERSION=v0.40.2
ARG NODE_VERSION=22

ENV NVM_DIR=/root/.nvm
# Corepack tries to do too much - disable some of its features:
# https://github.com/nodejs/corepack/blob/main/README.md
ENV COREPACK_DEFAULT_TO_LATEST=0
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
ENV COREPACK_ENABLE_AUTO_PIN=0
ENV COREPACK_ENABLE_STRICT=0
RUN git config --global http.sslverify false \
    && git -c advice.detachedHead=0 clone --branch ${NVM_VERSION} --depth 1 https://github.com/nvm-sh/nvm.git "${NVM_DIR}" \
    && git config --global --unset http.sslverify \
    && echo 'source $NVM_DIR/nvm.sh' >> /etc/profile \
    && echo "prettier\neslint\ntypescript" > $NVM_DIR/default-packages

### BUN ###

ARG BUN_VERSION=1.2.10

ENV BUN_INSTALL=/root/.bun
ENV PATH="$BUN_INSTALL/bin:$PATH"

RUN mkdir -p "$BUN_INSTALL/bin" \
    && curl -k -L --fail "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-x64-baseline.zip" \
        -o /tmp/bun.zip \
    && unzip -q /tmp/bun.zip -d "$BUN_INSTALL/bin" \
    && mv "$BUN_INSTALL/bin/bun-linux-x64-baseline/bun" "$BUN_INSTALL/bin/bun" \
    && chmod +x "$BUN_INSTALL/bin/bun" \
    && rm -rf "$BUN_INSTALL/bin/bun-linux-x64-baseline" /tmp/bun.zip \
    && echo 'export BUN_INSTALL=/root/.bun' >> /etc/profile \
    && echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /etc/profile

### JAVA ###

ARG JAVA_VERSION=21
ARG GRADLE_VERSION=8.14
ARG GRADLE_DOWNLOAD_SHA256=61ad310d3c7d3e5da131b76bbf22b5a4c0786e9d892dae8c1658d4b484de3caa

ENV GRADLE_HOME=/opt/gradle
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-${JAVA_VERSION}-jdk \
    && rm -rf /var/lib/apt/lists/* \
    && curl -k -LO "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle-${GRADLE_VERSION}-bin.zip" | sha256sum --check - \
    && unzip gradle-${GRADLE_VERSION}-bin.zip \
    && rm gradle-${GRADLE_VERSION}-bin.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

### SWIFT ###

ARG SWIFT_VERSION=6.1

# We'll install Swift at runtime to avoid network timeouts during build

### RUBY ###

RUN apt-get update && apt-get install -y --no-install-recommends \
        ruby-full \
    && rm -rf /var/lib/apt/lists/*

### RUST ###

# We'll install Rust at runtime to avoid SSL certificate issues during build

### GO ###

ARG GO_VERSION=1.23.8
ARG GO_DOWNLOAD_SHA256=45b87381172a58d62c977f27c4683c8681ef36580abecd14fd124d24ca306d3f

# We'll install Go at runtime to avoid network issues during build
ENV PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

### BAZEL ###

RUN curl -k -L --fail https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 -o /usr/local/bin/bazelisk \
    && chmod +x /usr/local/bin/bazelisk \
    && ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

### LLVM ###
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        cmake \
        ccache \
        python3 \
        ninja-build \
        nasm \
        yasm \
        gawk \
        lsb-release \
        wget \
        software-properties-common \
        gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && (wget --no-check-certificate -O - https://apt.llvm.org/llvm.sh | bash || echo "LLVM installation skipped - not available for this OS version")

### SETUP SCRIPTS ###

COPY setup_universal.sh /opt/codex/setup_universal.sh
RUN chmod +x /opt/codex/setup_universal.sh

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT  ["/opt/entrypoint.sh"]
