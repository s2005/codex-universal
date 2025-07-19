#!/bin/bash

echo "============================================"
echo "Welcome to openai/codex-universal (Python)!"
echo "============================================"

/opt/codex/setup_universal.sh

echo "Python environment ready. Dropping you into a bash shell."
exec bash --login "$@"
