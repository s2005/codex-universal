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

`codex-universal` provides a comprehensive Python development environment with the latest stable Python version and essential development tools.

### Configuring Python runtime

The environment comes pre-configured with Python and essential development tools. No additional configuration is needed.

## What's included

The environment includes:

- **Python**: Latest stable version from Ubuntu 24.04 (Python 3.12+)
- **Python core tools**: `pip`, `python3-venv` for virtual environments
- **Additional tools**: Can be installed via pip (poetry, uv, ruff, black, mypy, pyright, isort)
- **Development tools**: `git`, `git-lfs`, `ripgrep`, and essential build tools
- **Base system**: Ubuntu 24.04 with development libraries

See [Dockerfile](Dockerfile) for the full details of installed packages.
