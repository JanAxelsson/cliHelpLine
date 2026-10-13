#!/usr/bin/env bash
#
# run_tests.sh - Multi-language test runner for cliHelpLine
# =========================================================
# 
# Runs the full cliHelpLine test suite inside a multi-language Docker container.
# Automatically detects if Docker is running and attempts to start it if needed.
# The Docker test image is automatically built on the first run if not present.
#
# Usage:
#
#   ./run_tests.sh               # Run all tests inside Docker (auto-builds image if needed)
#   ./run_tests.sh <target...>   # Run test for specific script, extension, or language name
#                                # Examples:
#                                #   ./run_tests.sh cliHelpLine.py
#                                #   ./run_tests.sh py
#                                #   ./run_tests.sh python
#                                #   ./run_tests.sh bash zsh fish
#   ./run_tests.sh --local, -l   # Run tests locally on host system (skips missing interpreters)
#   ./run_tests.sh --build       # Force rebuild the Docker test image, then run tests
#   ./run_tests.sh --help        # Show this help text
#   ./run_tests.sh -h            # Show this help text
#   ./run_tests.sh /?            # Show this help text
#
# Requirements & Docker:
#
#   - Full test suite runs in Docker (all 14 runtimes pre-configured).
#   - Running with '--local' or '-l' executes directly on the host machine without Docker.
#   - If Docker is not currently running, this script will attempt to start it
#     automatically (macOS, Linux, WSL, Windows).
#   - You do NOT need to build the Docker image beforehand; it is automatically
#     built on the first run. Use '--build' to force a rebuild after modifying tests.

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi

set -euo pipefail

IMAGE_NAME="clihelpline-tester"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE_PATH="$PROJECT_ROOT/tests/Dockerfile"

# Check if Docker daemon is running, attempt to start if not
ensure_docker_running() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Fel: 'docker' hittades inte. Installera Docker först." >&2
        exit 1
    fi

    if docker info >/dev/null 2>&1; then
        return 0
    fi

    echo "Docker körs inte. Försöker starta Docker automatiskt..."

    local os
    os="$(uname -s)"
    case "$os" in
        Darwin)
            if [ -d "/Applications/Docker.app" ]; then
                open -a Docker
            elif command -v orb >/dev/null 2>&1; then
                open -a OrbStack 2>/dev/null || orb start 2>/dev/null
            elif command -v colima >/dev/null 2>&1; then
                colima start
            else
                open -a Docker 2>/dev/null || true
            fi
            ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                # WSL
                if [ -x "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe" ]; then
                    "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe" &
                else
                    sudo service docker start 2>/dev/null || true
                fi
            elif command -v systemctl >/dev/null 2>&1; then
                sudo systemctl start docker 2>/dev/null || systemctl --user start docker-desktop 2>/dev/null || true
            elif command -v service >/dev/null 2>&1; then
                sudo service docker start 2>/dev/null || true
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            if [ -f "/c/Program Files/Docker/Docker/Docker Desktop.exe" ]; then
                "/c/Program Files/Docker/Docker/Docker Desktop.exe" &
            fi
            ;;
        *)
            ;;
    esac

    # Vänta på att Docker daemon ska svara (max 45s)
    echo -n "Väntar på att Docker ska starta"
    local max_wait=45
    local count=0
    while ! docker info >/dev/null 2>&1; do
        sleep 2
        count=$((count + 2))
        echo -n "."
        if [ "$count" -ge "$max_wait" ]; then
            echo ""
            echo "Fel: Docker startade inte inom $max_wait sekunder." >&2
            echo "Starta Docker manuellt och försök igen." >&2
            exit 1
        fi
    done
    echo " Klart!"
}

# Parse command line flags
RUN_LOCAL=0
REBUILD=0
ARGS=()
for arg in "$@"; do
    if [ "$arg" = "--local" ] || [ "$arg" = "-l" ]; then
        RUN_LOCAL=1
    elif [ "$arg" = "--build" ]; then
        REBUILD=1
    else
        ARGS+=("$arg")
    fi
done

# If --local is requested, run directly on host without Docker
if [ "$RUN_LOCAL" -eq 1 ]; then
    echo "=== Kör tester lokalt på värdsystemet ($(uname -s)) ==="
    if [ "${#ARGS[@]}" -gt 0 ]; then
        bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh" "${ARGS[@]}"
    else
        bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh"
    fi
    exit $?
fi

ensure_docker_running

# Build image if it doesn't exist or if --build was passed
if [ "$REBUILD" -eq 1 ] || ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "=== Bygger Docker-avbild ($IMAGE_NAME) ==="
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$PROJECT_ROOT"
fi

# Pass terminal TTY if interactive
INTERACTIVE_FLAG=""
if [ -t 0 ] && [ -t 1 ]; then
    INTERACTIVE_FLAG="-it"
fi

echo "=== Kör tester inuti Docker ($IMAGE_NAME) ==="
if [ "${#ARGS[@]}" -gt 0 ]; then
    docker run --rm $INTERACTIVE_FLAG \
        -v "$PROJECT_ROOT:/workspace" \
        -w /workspace \
        "$IMAGE_NAME" \
        bash tests/test_cliHelpLine.sh "${ARGS[@]}"
else
    docker run --rm $INTERACTIVE_FLAG \
        -v "$PROJECT_ROOT:/workspace" \
        -w /workspace \
        "$IMAGE_NAME" \
        bash tests/test_cliHelpLine.sh
fi
