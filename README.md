# codex-python

`codex-python` is a Python-focused Docker development environment that provides a comprehensive Python development setup with multiple Python version support.

This repository is derived from the [OpenAI codex-universal](https://github.com/openai/codex-universal) base image and has been adapted to focus specifically on Python development with configurable Python versions (3.10, 3.11, 3.12, 3.13).

## Usage

The Docker image is available at:

```bash
docker pull ghcr.io/s2005/codex-python:3.12
```

You can also use version-specific tags:

```bash
# Python 3.12 (default)
docker pull ghcr.io/s2005/codex-python:3.12

# Other Python versions
docker pull ghcr.io/s2005/codex-python:3.10
docker pull ghcr.io/s2005/codex-python:3.11
docker pull ghcr.io/s2005/codex-python:3.13
```

The below script shows how you can set up the Python development environment:

```bash
# This script mounts the current directory similar to how it would get cloned in.
docker run --rm -it \
    -v $(pwd):/workspace/$(basename $(pwd)) -w /workspace/$(basename $(pwd)) \
    ghcr.io/s2005/codex-python:3.12
```

`codex-python` provides a comprehensive Python development environment with multiple Python versions and essential development tools.

### Building Different Python Versions

The workflow allows building images with different Python versions:

**Via GitHub Actions (Recommended)**:

1. Go to Actions → "Build Python Image" → "Run workflow"
2. Select your desired Python version: 3.10, 3.11, 3.12, or 3.13
3. The image will be tagged as `ghcr.io/{owner}/codex-python:{version}`

**Via Manual Build**:

```bash
# Build with specific Python version
docker build --build-arg PYTHON_VERSION=3.11 -t codex-python:3.11 .

# Build with multiple Python versions enabled (requires external repository access)
docker build --build-arg ENABLE_MULTI_PYTHON=true -t codex-python:multi .

# Default build (Python 3.12 only, works in restricted networks)
docker build -t codex-python:3.12 .
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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSES/LICENSE) file for details.

The Docker image incorporates various open source components with different licenses (MIT, Apache-2.0, BSD, GPL, etc.). For complete license information and Software Bill of Materials (SBOM), see:

- [LICENSE](LICENSES/LICENSE) - Full license text and component details
- [SBOM (Markdown)](LICENSES/codex-universal-image-sbom.md) - Human-readable component list  
- [SBOM (SPDX)](LICENSES/codex-universal-image-sbom.spdx.json) - Machine-readable SPDX format

## Acknowledgments

This project is based on the [OpenAI codex-universal](https://github.com/openai/codex-universal) Docker image. We've adapted it to focus specifically on Python development with enhanced version flexibility and streamlined workflows.
