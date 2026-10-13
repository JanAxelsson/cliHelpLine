#!/usr/bin/env bash
# ==============================================================================
# release.sh - Automated release script for cliHelpLine
# ==============================================================================
# Usage:
#   ./.agents/skills/release-clihelpline/scripts/release.sh <version> [summary]
# Example:
#   ./.agents/skills/release-clihelpline/scripts/release.sh 0.3 "Add support for 17 languages"
# ==============================================================================

set -euo pipefail

VERSION="${1:-}"
SUMMARY="${2:-}"

# Locate repository root (directory containing .git)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$REPO_ROOT"

# Validate version argument
if [ -z "$VERSION" ]; then
    echo "Error: Version argument required (e.g. 0.3 or 1.0.0)" >&2
    echo "Usage: $0 <version> [release-summary]" >&2
    exit 1
fi

# Clean up version string if prefixed with 'v'
VERSION="${VERSION#v}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Invalid version format '$VERSION'. Expected X.Y or X.Y.Z" >&2
    exit 1
fi

TAG="v$VERSION"
if [ -z "$SUMMARY" ]; then
    SUMMARY="Release version $VERSION"
fi

echo "=================================================================="
echo " Preparing release $TAG for cliHelpLine"
echo " Summary: $SUMMARY"
echo "=================================================================="

# 1. Ensure we are on develop branch
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "Error: Releases must be started from the 'develop' branch (current: $CURRENT_BRANCH)" >&2
    exit 1
fi

# 2. Ensure working directory is clean
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: Working directory has uncommitted changes. Please stash or commit first." >&2
    git status --short
    exit 1
fi

# 3. Ensure tag doesn't already exist
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    echo "Error: Tag '$TAG' already exists in the repository." >&2
    exit 1
fi

# 4. Run local tests before modifying anything
echo ""
echo "--> Running test suite to verify codebase before release..."
if [ -f "./run_tests.sh" ]; then
    ./run_tests.sh --local
else
    bash tests/test_cliHelpLine.sh
fi

# 5. Bump version badge in README.md
echo ""
echo "--> Updating version badge in README.md to $VERSION..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -E "s/img\.shields\.io\/badge\/version-[0-9.]+-blue\.svg/img.shields.io\/badge\/version-${VERSION}-blue.svg/" README.md
else
    sed -i -E "s/img\.shields\.io\/badge\/version-[0-9.]+-blue\.svg/img.shields.io\/badge\/version-${VERSION}-blue.svg/" README.md
fi

# Verify README sync still passes
bash tests/test_cliHelpLine.sh --readme-only

# Commit badge bump on develop
echo ""
echo "--> Committing version badge on develop..."
git add README.md
git commit -m "chore: bump version badge to $VERSION in README.md"
git push origin develop

# 6. Merge develop into main
echo ""
echo "--> Merging develop into main..."
git checkout main
git pull origin main --ff-only
git merge develop --ff-only

# 7. Create annotated tag
echo ""
echo "--> Creating annotated tag $TAG..."
git tag -a "$TAG" -m "$SUMMARY"

# 8. Push main and tag to GitHub
echo ""
echo "--> Pushing main and $TAG to GitHub..."
git push origin main
git push origin "$TAG"

# 9. Return to develop
echo ""
echo "--> Returning to develop branch..."
git checkout develop

echo ""
echo "=================================================================="
echo " [OK] Successfully released and published $TAG!"
echo "=================================================================="
