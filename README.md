# codex-universal (Python Only)

`codex-universal` is a Python-focused Docker development environment derived from the base Docker image available in [OpenAI Codex](http://platform.openai.com/docs/codex).

This repository provides a streamlined Python development environment with essential tools and multiple Python version support through pyenv.

For more details on environment setup, see [OpenAI Codex](http://platform.openai.com/docs/codex).

## Usage

The Docker image is available at:

```
docker pull ghcr.io/openai/codex-universal:latest
```

The below script shows how you can set up the Python development environment:

```
docker run --rm -it \
    # Mount the current directory similar to how it would get cloned in.
    -v $(pwd):/workspace/$(basename $(pwd)) -w /workspace/$(basename $(pwd)) \
    ghcr.io/openai/codex-universal:latest
```

`codex-universal` provides a comprehensive Python development environment with multiple Python versions and essential development tools.

### Choosing Python Version

**Default Configuration**: Python 3.12 (Ubuntu 24.04 default)

**Multi-Version Support**: Enable multiple Python versions (3.10, 3.11, 3.12, 3.13) when building with external repository access:

```bash
# Build with multiple Python versions enabled (requires external repository access)
docker build --build-arg ENABLE_MULTI_PYTHON=true -t codex-universal:multi .

# Build with specific Python version as default when multi-version is enabled
docker build \
  --build-arg ENABLE_MULTI_PYTHON=true \
  --build-arg PYTHON_VERSION=3.11 \
  -t codex-universal:py311 .

# Default build (Python 3.12 only, works in restricted networks)
docker build -t codex-universal:py312 .
```

**Switching Python versions** (when multi-version is enabled):
```bash
# Inside the container
switch-python 3.11
switch-python 3.10
switch-python 3.13
```

Supported Python versions: `3.10`, `3.11`, `3.12`, `3.13`

### Configuring Python runtime

The environment comes with Python 3.12 by default. When built with `ENABLE_MULTI_PYTHON=true`, additional Python versions (3.10, 3.11, 3.13) are also available.

```bash
# Check current Python version
python --version

# Switch Python versions (when multi-version is enabled)
switch-python 3.11
switch-python 3.10
switch-python 3.13

# Use version-specific commands directly
python3.10 --version  # (if available)
python3.11 --version  # (if available)
python3.12 --version  # (always available)
python3.13 --version  # (if available)
```

### Installing Python Tools

The image includes `pip` and `pipx` for installing Python packages and tools:

```bash
# Install development tools globally via pipx (recommended)
pipx install poetry        # Python dependency management
pipx install uv            # Fast Python package installer
pipx install black         # Code formatter
pipx install ruff          # Fast Python linter

# Install development tools per project via pip
pip install mypy pyright isort flake8
```

## What's included

The environment includes:

- **Python**: Python 3.12 (default) with optional multi-version support (3.10, 3.11, 3.12, 3.13) via build argument
- **Python tools**: `pip`, `pipx`, `python3-venv` (additional tools like poetry, uv, ruff, black, mypy, pyright, isort can be installed via pip/pipx)
- **Development tools**: `git`, `git-lfs`, `ripgrep`, and essential build tools
- **Base system**: Ubuntu 24.04 with development libraries

See [Dockerfile](Dockerfile) for the full details of installed packages.
