#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/chezmoi_smoke.py "${1:-base}"
