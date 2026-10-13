#!/usr/bin/env bash
#
# run_tests.sh
# Runs cliHelpLine test suite inside a multi-language Docker container.
#
set -euo pipefail

IMAGE_NAME="clihelpline-tester"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE_PATH="$PROJECT_ROOT/tests/Dockerfile"

# Verify docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "Fel: 'docker' hittades inte. Installera eller starta Docker först." >&2
    exit 1
fi

# Build image if it doesn't exist or if --build is passed
if [ "${1:-}" = "--build" ] || ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "=== Bygger Docker-avbild ($IMAGE_NAME) ==="
    [ "${1:-}" = "--build" ] && shift
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$PROJECT_ROOT"
fi

# Pass terminal TTY if interactive
INTERACTIVE_FLAG=""
if [ -t 0 ] && [ -t 1 ]; then
    INTERACTIVE_FLAG="-it"
fi

echo "=== Kör tester inuti Docker ($IMAGE_NAME) ==="
docker run --rm $INTERACTIVE_FLAG \
    -v "$PROJECT_ROOT:/workspace" \
    -w /workspace \
    "$IMAGE_NAME" \
    bash tests/test_cliHelpLine.sh "$@"
