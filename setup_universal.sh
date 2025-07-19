#!/bin/bash --login

set -euo pipefail

CODEX_ENV_PYTHON_VERSION=${CODEX_ENV_PYTHON_VERSION:-}
CODEX_ENV_NODE_VERSION=${CODEX_ENV_NODE_VERSION:-}
CODEX_ENV_RUST_VERSION=${CODEX_ENV_RUST_VERSION:-}
CODEX_ENV_GO_VERSION=${CODEX_ENV_GO_VERSION:-}
CODEX_ENV_SWIFT_VERSION=${CODEX_ENV_SWIFT_VERSION:-}

# Ensure PYENV_ROOT and NVM_DIR are set
export PYENV_ROOT=${PYENV_ROOT:-$HOME/.pyenv}
export PATH="$PYENV_ROOT/bin:$PATH"
export NVM_DIR=${NVM_DIR:-$HOME/.nvm}

echo "Configuring language runtimes..."

# Install global Python tools if not already installed
if ! command -v poetry &> /dev/null; then
    echo "Installing global Python tools (poetry, uv)..."
    pipx install poetry uv || true  # Allow to fail and continue
fi

# For Python and Node, always run the install commands so we can install
# global libraries for linting and formatting. This just switches the version.

# For others (e.g. rust), to save some time on bootup we only install other language toolchains
# if the versions differ.

if [ -n "${CODEX_ENV_PYTHON_VERSION}" ]; then
    echo "# Python: ${CODEX_ENV_PYTHON_VERSION}"
    # Check if this version is already installed
    if ! pyenv versions --bare | grep -q "^${CODEX_ENV_PYTHON_VERSION}$"; then
        echo "Installing Python ${CODEX_ENV_PYTHON_VERSION}..."
        pyenv install "${CODEX_ENV_PYTHON_VERSION}"
        # Install common packages for this version
        "${PYENV_ROOT}/versions/${CODEX_ENV_PYTHON_VERSION}/bin/pip" install --upgrade pip ruff black mypy pyright isort
    fi
    pyenv global "${CODEX_ENV_PYTHON_VERSION}"
else
    # Install default Python versions if none specified
    echo "# Python: Installing default versions (3.10, 3.11.12, 3.12, 3.13)"
    for version in 3.10 3.11.12 3.12 3.13; do
        if ! pyenv versions --bare | grep -q "^${version}$"; then
            echo "Installing Python ${version}..."
            pyenv install "${version}"
            # Install common packages for this version
            "${PYENV_ROOT}/versions/${version}/bin/pip" install --upgrade pip ruff black mypy pyright isort
        fi
    done
    pyenv global 3.11.12
fi

if [ -n "${CODEX_ENV_NODE_VERSION}" ]; then
    echo "# Node.js: ${CODEX_ENV_NODE_VERSION}"
    # Source nvm and check if version is installed
    . "$NVM_DIR/nvm.sh"
    if ! nvm list | grep -q "v${CODEX_ENV_NODE_VERSION}"; then
        echo "Installing Node.js ${CODEX_ENV_NODE_VERSION}..."
        nvm install "${CODEX_ENV_NODE_VERSION}"
    fi
    nvm alias default "${CODEX_ENV_NODE_VERSION}"
    nvm use "${CODEX_ENV_NODE_VERSION}"
    corepack enable
    corepack install -g yarn pnpm npm
else
    # Install default Node versions if none specified
    echo "# Node.js: Installing default versions (18, 20, 22)"
    . "$NVM_DIR/nvm.sh"
    for version in 18 20 22; do
        if ! nvm list | grep -q "v${version}"; then
            echo "Installing Node.js ${version}..."
            nvm install "${version}"
        fi
    done
    nvm alias default 22
    nvm use 22
    corepack enable
    corepack install -g yarn pnpm npm
fi

if [ -n "${CODEX_ENV_RUST_VERSION}" ]; then
    echo "# Rust: ${CODEX_ENV_RUST_VERSION}"
    # Install Rust if not present
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl -k --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
        . "$HOME/.cargo/env"
    fi
    # Check current version and install if needed
    current=$(rustc --version | awk '{print $2}')
    if [ "${current}" != "${CODEX_ENV_RUST_VERSION}" ]; then
        rustup toolchain install --no-self-update "${CODEX_ENV_RUST_VERSION}"
        rustup default "${CODEX_ENV_RUST_VERSION}"
        # Pre-install common linters/formatters
        # clippy is already installed
    fi
else
    # Install default Rust version if none specified
    echo "# Rust: Installing default version"
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl -k --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
        . "$HOME/.cargo/env"
    fi
fi

if [ -n "${CODEX_ENV_GO_VERSION}" ]; then
    echo "# Go: go${CODEX_ENV_GO_VERSION}"
    # Install Go if not present
    if ! command -v go &> /dev/null; then
        echo "Installing Go..."
        mkdir -p /tmp/go
        cd /tmp/go
        curl -k -O https://dl.google.com/go/go1.23.8.linux-amd64.tar.gz
        echo "45b87381172a58d62c977f27c4683c8681ef36580abecd14fd124d24ca306d3f *go1.23.8.linux-amd64.tar.gz" | sha256sum --check -
        tar -C /usr/local -xzf go1.23.8.linux-amd64.tar.gz
        rm -rf /tmp/go
        # Install golangci-lint
        curl -k -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.61.0
    fi
    # Install specified version if different
    current=$(go version | awk '{print $3}')
    if [ "${current}" != "go${CODEX_ENV_GO_VERSION}" ]; then
        go install "golang.org/dl/go${CODEX_ENV_GO_VERSION}@latest"
        "go${CODEX_ENV_GO_VERSION}" download
        # Place new go first in PATH
        echo "export PATH=$("go${CODEX_ENV_GO_VERSION}" env GOROOT)/bin:\$PATH" >> /etc/profile
        # Pre-install common linters/formatters
        golangci-lint --version # Already installed in base image, save us some bootup time
    fi
else
    # Install default Go version if none specified
    echo "# Go: Installing default version (1.23.8)"
    if ! command -v go &> /dev/null; then
        echo "Installing Go..."
        mkdir -p /tmp/go
        cd /tmp/go
        curl -k -O https://dl.google.com/go/go1.23.8.linux-amd64.tar.gz
        echo "45b87381172a58d62c977f27c4683c8681ef36580abecd14fd124d24ca306d3f *go1.23.8.linux-amd64.tar.gz" | sha256sum --check -
        tar -C /usr/local -xzf go1.23.8.linux-amd64.tar.gz
        rm -rf /tmp/go
        # Install golangci-lint
        curl -k -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.61.0
    fi
fi

if [ -n "${CODEX_ENV_SWIFT_VERSION}" ]; then
    echo "# Swift: ${CODEX_ENV_SWIFT_VERSION}"
    # Install swiftly if not present
    if ! command -v swiftly &> /dev/null; then
        echo "Installing swiftly..."
        mkdir -p /tmp/swiftly
        cd /tmp/swiftly
        curl -k -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz
        tar zxf swiftly-$(uname -m).tar.gz
        ./swiftly init --quiet-shell-followup -y || true  # Allow init to fail and continue
        echo '. ~/.local/share/swiftly/env.sh' >> /etc/profile
        rm -rf /tmp/swiftly
    fi
    # Source the swiftly environment
    if [ -f ~/.local/share/swiftly/env.sh ]; then
        . ~/.local/share/swiftly/env.sh
        if ! swiftly list-installed | grep -q "${CODEX_ENV_SWIFT_VERSION}"; then
            echo "Installing Swift ${CODEX_ENV_SWIFT_VERSION}..."
            swiftly install --use "${CODEX_ENV_SWIFT_VERSION}"
        else
            swiftly use "${CODEX_ENV_SWIFT_VERSION}"
        fi
    fi
else
    # Install default Swift version if none specified
    echo "# Swift: Installing default version (6.1)"
    # Install swiftly if not present
    if ! command -v swiftly &> /dev/null; then
        echo "Installing swiftly..."
        mkdir -p /tmp/swiftly
        cd /tmp/swiftly
        curl -k -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz
        tar zxf swiftly-$(uname -m).tar.gz
        ./swiftly init --quiet-shell-followup -y || true  # Allow init to fail and continue
        echo '. ~/.local/share/swiftly/env.sh' >> /etc/profile
        rm -rf /tmp/swiftly
    fi
    # Source the swiftly environment
    if [ -f ~/.local/share/swiftly/env.sh ]; then
        . ~/.local/share/swiftly/env.sh
        if ! swiftly list-installed | grep -q "6.1"; then
            echo "Installing Swift 6.1..."
            swiftly install --use 6.1
        else
            swiftly use 6.1
        fi
    fi
fi
