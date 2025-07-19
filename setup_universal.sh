#!/bin/bash --login

set -euo pipefail

echo "Configuring Python runtime..."

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "# Python: ${PYTHON_VERSION} (system default)"
echo "# Basic tools available: pip, python3-venv"
echo "# Additional tools like poetry, uv, ruff, black, mypy can be installed via pip"
