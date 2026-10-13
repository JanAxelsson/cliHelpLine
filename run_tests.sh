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
#   ./run_tests.sh               # Run all 3 test stages:
#                                #   1. Local host verification (Darwin/Linux)
#                                #   2. Docker full-suite verification (all 14 languages)
#                                #   3. README.md 2-line snippet verification
#   ./run_tests.sh <target...>   # Run test stages for specific script or language
#                                # Examples:
#                                #   ./run_tests.sh cliHelpLine.py
#                                #   ./run_tests.sh py
#                                #   ./run_tests.sh python
#                                #   ./run_tests.sh bash zsh fish
#   ./run_tests.sh --local, -l   # Run local test + README test only (skips Docker)
#   ./run_tests.sh --docker, -d  # Run Docker test + README test only (skips local)
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

set -uo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

IMAGE_NAME="clihelpline-tester"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE_PATH="$PROJECT_ROOT/tests/Dockerfile"

# Check if Docker daemon is running, attempt to start if not
ensure_docker_running() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: 'docker' command not found. Please install Docker first." >&2
        exit 1
    fi

    if docker info >/dev/null 2>&1; then
        return 0
    fi

    echo "Docker is not running. Attempting to start Docker automatically..."

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

    # Wait for Docker daemon to become responsive (up to 45s)
    echo -n "Waiting for Docker to start"
    local max_wait=45
    local count=0
    while ! docker info >/dev/null 2>&1; do
        sleep 2
        count=$((count + 2))
        echo -n "."
        if [ "$count" -ge "$max_wait" ]; then
            echo ""
            echo "Error: Docker did not start within $max_wait seconds." >&2
            echo "Please start Docker manually and try again." >&2
            exit 1
        fi
    done
    echo " Done!"
}

# Parse command line flags
MODE="all" # "all", "local", "docker"
REBUILD=0
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --local|-l)
            MODE="local"
            ;;
        --docker|-d)
            MODE="docker"
            ;;
        --build)
            REBUILD=1
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

pass_local=0
pass_docker=0
pass_readme=0
has_failure=0

# ============================================================
# Test 1: Local host tests
# ============================================================
if [ "$MODE" != "docker" ]; then
    echo "============================================================"
    echo "=== Test 1/3: Local host tests ($(uname -s)) ==="
    echo "============================================================"
    local_fail=0
    if [ "${#ARGS[@]}" -gt 0 ]; then
        bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh" --help-only "${ARGS[@]}" || local_fail=1
    else
        bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh" --help-only || local_fail=1
    fi
    if [ "$local_fail" -eq 0 ]; then
        pass_local=1
    else
        has_failure=1
    fi
    echo ""
fi

# ============================================================
# Test 2: Full test suite inside Docker
# ============================================================
if [ "$MODE" != "local" ]; then
    echo "============================================================"
    echo "=== Test 2/3: Full test suite inside Docker ($IMAGE_NAME) ==="
    echo "============================================================"
    ensure_docker_running

    # Build image if it doesn't exist or if --build was passed
    if [ "$REBUILD" -eq 1 ] || ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "=== Building Docker test image ($IMAGE_NAME) ==="
        docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$PROJECT_ROOT"
    fi

    # Pass terminal TTY if interactive
    INTERACTIVE_FLAG=""
    if [ -t 0 ] && [ -t 1 ]; then
        INTERACTIVE_FLAG="-it"
    fi

    docker_fail=0
    if [ "${#ARGS[@]}" -gt 0 ]; then
        docker run --rm $INTERACTIVE_FLAG \
            -v "$PROJECT_ROOT:/workspace" \
            -w /workspace \
            "$IMAGE_NAME" \
            bash tests/test_cliHelpLine.sh --help-only "${ARGS[@]}" || docker_fail=1
    else
        docker run --rm $INTERACTIVE_FLAG \
            -v "$PROJECT_ROOT:/workspace" \
            -w /workspace \
            "$IMAGE_NAME" \
            bash tests/test_cliHelpLine.sh --help-only || docker_fail=1
    fi
    if [ "$docker_fail" -eq 0 ]; then
        pass_docker=1
    else
        has_failure=1
    fi
    echo ""
fi

# ============================================================
# Test 3: README.md verification
# ============================================================
test_readme_label="Test 3/3"
[ "$MODE" = "local" ] && test_readme_label="Test 2/2"
[ "$MODE" = "docker" ] && test_readme_label="Test 2/2"

echo "============================================================"
echo "=== $test_readme_label: README.md verification ==="
echo "============================================================"
readme_fail=0
if [ "${#ARGS[@]}" -gt 0 ]; then
    bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh" --readme-only "${ARGS[@]}" || readme_fail=1
else
    bash "$PROJECT_ROOT/tests/test_cliHelpLine.sh" --readme-only || readme_fail=1
fi
if [ "$readme_fail" -eq 0 ]; then
    pass_readme=1
else
    has_failure=1
fi
echo ""

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo "                     TEST SUMMARY                           "
echo "============================================================"
if [ "$MODE" != "docker" ]; then
    if [ "$pass_local" -eq 1 ]; then
        printf "  ${GREEN}[ OK ]${RESET} Test 1: Local host ($(uname -s))\n"
    else
        printf "  ${RED}[FAIL]${RESET} Test 1: Local host ($(uname -s))\n"
    fi
fi
if [ "$MODE" != "local" ]; then
    if [ "$pass_docker" -eq 1 ]; then
        printf "  ${GREEN}[ OK ]${RESET} Test 2: Inside Docker ($IMAGE_NAME)\n"
    else
        printf "  ${RED}[FAIL]${RESET} Test 2: Inside Docker ($IMAGE_NAME)\n"
    fi
fi
if [ "$pass_readme" -eq 1 ]; then
    printf "  ${GREEN}[ OK ]${RESET} Test 3: README.md synchronization\n"
else
    printf "  ${RED}[FAIL]${RESET} Test 3: README.md synchronization\n"
fi
echo "============================================================"

if [ "$has_failure" -eq 0 ]; then
    printf "${GREEN}All tests passed!${RESET}\n"
    exit 0
else
    printf "${RED}One or more tests failed.${RESET}\n"
    exit 1
fi
