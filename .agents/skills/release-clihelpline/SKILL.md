---
name: release-clihelpline
description: >-
  Prepares, tags, and publishes a new version release for cliHelpLine.
  Use when the user asks to release a new version, cut a release, or publish vX.Y.
---

# Release cliHelpLine

This skill guides the agent through preparing, tagging, and publishing a new release for **cliHelpLine**.

## Overview & Branching Model
- Daily development and testing occurs on `develop`.
- Releases are tagged and published from `main`.
- All releases follow incremental or semantic versions (`v0.1`, `v0.2`, `v0.3`, etc.).

---

## Automated Workflow (Preferred)

To perform the entire release safely with automatic test verification, execute the bundled release script:

```bash
./.agents/skills/release-clihelpline/scripts/release.sh <version> "<summary>"
```

### Example
```bash
./.agents/skills/release-clihelpline/scripts/release.sh 0.3 "Release version 0.3 - Support 17 languages and refined links"
```

The script automatically:
1. Verifies that the current branch is `develop` and the git working tree is clean.
2. Checks that tag `v<version>` does not already exist.
3. Runs the test suite (`./run_tests.sh --local`) to verify all languages and README sync pass.
4. Updates the version badge in `README.md` to `<version>`.
5. Commits and pushes the badge bump to `origin/develop`.
6. Switches to `main`, pulls latest changes, and fast-forward merges `develop`.
7. Creates annotated git tag `v<version>`.
8. Pushes `main` and `v<version>` to GitHub.
9. Switches back to `develop`.

---

## Manual Playbook (Step-by-Step)

If manual execution is required or requested:

### 1. Verify Prerequisites
Ensure working branch is `develop` and git status is clean:
```bash
git checkout develop
git status
./run_tests.sh --local
```

### 2. Update Version Badge in `README.md`
On line 4 of `README.md`, update the Shields.io badge:
```markdown
[![Version](https://img.shields.io/badge/version-<version>-blue.svg)](https://github.com/JanAxelsson/cliHelpLine/releases)
```
Verify README sync and commit on `develop`:
```bash
bash tests/test_cliHelpLine.sh --readme-only
git add README.md
git commit -m "chore: bump version badge to <version> in README.md"
git push origin develop
```

### 3. Fast-Forward Merge into `main`
```bash
git checkout main
git pull origin main --ff-only
git merge develop --ff-only
```

### 4. Create Annotated Tag
```bash
git tag -a "v<version>" -m "Release version <version> - <Summary>"
```

### 5. Push to GitHub
```bash
git push origin main
git push origin "v<version>"
```

### 6. Return to `develop`
```bash
git checkout develop
```
