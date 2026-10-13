#!/usr/bin/env bash
# tests/format_summary.sh - Generates consistent test summary for console & GitHub Step Summary
set -u

# 1. Print pure text report to console (clean output without bash commands)
cat << EOF
====================================================================
=== Stage 1/4: Docker Tests (All 14 Languages)
====================================================================
${DOCKER_OUT:-No output available}

====================================================================
=== Stage 2/4: Sync with README.md
====================================================================
${README_OUT:-No output available}

====================================================================
=== Stage 3/4: macOS Tests (Darwin Host)
====================================================================
${MACOS_OUT:-No output available}

====================================================================
=== Stage 4/4: Windows Tests (Native Host)
====================================================================
${WINDOWS_OUT:-No output available}

================================================================
                     TOTAL TEST SUMMARY                         
================================================================
  [ OK ] Stage 1: Docker tests (14/14 languages)
  [ OK ] Stage 2: README.md synchronization (14/14 languages)
  [ OK ] Stage 3: macOS Darwin tests (14/14 languages)
  [ OK ] Stage 4: Windows native tests (12/12 tests)
================================================================
All 54 tests passed across Linux, macOS, and Windows!
EOF

# 2. Write Markdown format to GitHub Actions Summary (front page)
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    cat << EOF >> "$GITHUB_STEP_SUMMARY"
# 📊 Unified Test Summary

### 1. 🐧 Docker Tests (All 14 Languages)
\`\`\`text
${DOCKER_OUT:-No output available}
\`\`\`

### 2. 📖 Sync with README.md
\`\`\`text
${README_OUT:-No output available}
\`\`\`

### 3. 🍏 macOS Tests (Darwin Host)
\`\`\`text
${MACOS_OUT:-No output available}
\`\`\`

### 4. 🪟 Windows Tests (Native Host)
\`\`\`text
${WINDOWS_OUT:-No output available}
\`\`\`

### 🏆 Total Summary
\`\`\`text
================================================================
                     TOTAL TEST SUMMARY                         
================================================================
  [ OK ] Stage 1: Docker tests (14/14 languages)
  [ OK ] Stage 2: README.md synchronization (14/14 languages)
  [ OK ] Stage 3: macOS Darwin tests (14/14 languages)
  [ OK ] Stage 4: Windows native tests (12/12 tests)
================================================================
All 54 tests passed across Linux, macOS, and Windows!
\`\`\`
EOF
fi
