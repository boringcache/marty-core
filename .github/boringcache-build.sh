#!/usr/bin/env bash
set -euo pipefail
python3 .github/boringcache-time.py build cargo nextest run --locked --workspace --exclude marty-zkp --exclude marty-bindings --features test-fixtures
python3 .github/boringcache-time.py doctests cargo test --locked --doc --workspace --exclude marty-zkp --exclude marty-bindings --features test-fixtures
