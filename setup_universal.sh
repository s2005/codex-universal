#!/bin/bash --login

set -euo pipefail

echo "Configuring Python runtime..."

CURRENT_PYTHON=$(python --version 2>&1 | cut -d' ' -f2)
echo "# Current Python: ${CURRENT_PYTHON}"

echo "# Available Python versions:"
VERSIONS_FOUND=false
for version in 3.10 3.11 3.12 3.13; do
    if command -v python${version} &> /dev/null; then
        echo "  - Python ${version} (python${version})"
        VERSIONS_FOUND=true
    fi
done

if ! $VERSIONS_FOUND; then
    echo "  - Python 3.12 (default)"
fi

echo "# Available tools: pip, pipx, python3-venv"
if command -v switch-python &> /dev/null; then
    echo "# Switch Python versions with: switch-python <version>"
fi
echo "# Install additional tools: pipx install poetry uv && pip install ruff black mypy pyright isort"

# Show multi-version status
if command -v python3.11 &> /dev/null || command -v python3.10 &> /dev/null || command -v python3.13 &> /dev/null; then
    echo "# Multi-version Python support: ENABLED"
else
    echo "# Multi-version Python support: DISABLED (use ENABLE_MULTI_PYTHON=true build arg to enable)"
fi
