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
    # Set Python version (optional)
    -e CODEX_ENV_PYTHON_VERSION=3.12 \
    # Mount the current directory similar to how it would get cloned in.
    -v $(pwd):/workspace/$(basename $(pwd)) -w /workspace/$(basename $(pwd)) \
    ghcr.io/openai/codex-universal:latest
```

`codex-universal` includes setup scripts that look for `CODEX_ENV_PYTHON_VERSION` environment variable and configures the Python version accordingly.

### Configuring Python runtime

The following environment variable can be set to configure Python installation:

| Environment variable       | Description                | Supported versions                               | Additional packages                                                  |
| -------------------------- | -------------------------- | ------------------------------------------------ | -------------------------------------------------------------------- |
| `CODEX_ENV_PYTHON_VERSION` | Python version to install  | `3.10`, `3.11.12`, `3.12`, `3.13`                | `pyenv`, `poetry`, `uv`, `ruff`, `black`, `mypy`, `pyright`, `isort` |

## What's included

The environment includes:

- **Python versions**: 3.10, 3.11.12, 3.12, 3.13 (managed via pyenv)
- **Python package managers**: `poetry`, `uv`, `pip`, `pipx`
- **Python linting/formatting tools**: `ruff`, `black`, `mypy`, `pyright`, `isort`
- **Development tools**: `git`, `git-lfs`, `ripgrep`, and essential build tools
- **Base system**: Ubuntu 24.04 with development libraries

See [Dockerfile](Dockerfile) for the full details of installed packages.
