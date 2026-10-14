# AGENTS.md - Developer & Agent Guide for cliHelpLine

This document provides essential context, architectural decisions, design rules, testing requirements, branching strategies, and release procedures for AI agents and human contributors working on **cliHelpLine**.

---

## 1. Project Mission & Core Philosophy

**cliHelpLine** provides universal, zero-dependency, 2-line snippets that turn a script's top-of-file header comments into `--help`, `-h`, and `/?` output.

### Key Guarantees
1. **Zero External Dependencies & Zero Boilerplate:** No external packages (like `argparse`, `commander`, `yargs`, or `clap`).
2. **2-Line Drop-in Snippet:**
   - **Line 1 (Comment marker):** Identifies the help boundary and points to the repository.
   - **Line 2 (One-liner):** Inspects CLI arguments, reads the file up to the boundary, strips comment characters and leading spaces, prints the text, and exits `0`.
3. **Dual Execution Guarantee:**
   - **With help flags (`--help`, `-h`, `/?`):** Prints header comments and immediately exits (`exit 0`). Does NOT run the main program body.
   - **Without help flags (normal invocation):** Falls through silently and executes the main program body (verified by printing `"Hello world!"`). Does NOT print the help header.

---

## 2. Supported Languages (17 Total)

All 17 language examples live in the `examples/` directory and are organized alphabetically (A–Z):

| Language | Script File | Comment Char | Boundary Marker (Double-Comment) | Runtime / Notes |
| :--- | :--- | :--- | :--- | :--- |
| **AWK** | `examples/cliHelpLine.awk` | `#` | `##` | `gawk` (GNU Awk required via shebang `-E`) |
| **Bash** | `examples/cliHelpLine.bash` | `#` | `##` | `bash` |
| **Fish** | `examples/cliHelpLine.fish` | `#` | `##` | `fish` |
| **JavaScript** | `examples/cliHelpLine.js` | `//` | `////` | `node` (`process.argv`, `__filename`) |
| **Julia** | `examples/cliHelpLine.jl` | `#` | `##` | `julia` (`ARGS`, `@__FILE__`) |
| **Lua** | `examples/cliHelpLine.lua` | `--` | `----` | `lua` (`arg`, `arg[0]`) |
| **Perl** | `examples/cliHelpLine.pl` | `#` | `##` | `perl` (`@ARGV`, `$0`) |
| **PHP** | `examples/cliHelpLine.php` | `//` | `////` | `php` (`$argv`, `__FILE__`) · also `cliHelpLine_web.php` for web |
| **PowerShell** | `examples/cliHelpLine.ps1` | `#` | `##` | `pwsh` (`$args`, `$MyInvocation`) |
| **Python** | `examples/cliHelpLine.py` | `#` | `##` | `python3` (`sys.argv`, `__file__`) |
| **R** | `examples/cliHelpLine.r` | `#` | `##` | `Rscript` (`commandArgs`) |
| **Ruby** | `examples/cliHelpLine.rb` | `#` | `##` | `ruby` (`ARGV`, `__FILE__`) |
| **Sh (POSIX Shell)** | `examples/cliHelpLine.sh` | `#` | `##` | `sh` (POSIX compliant, sorted under S) |
| **Swift** | `examples/cliHelpLine.swift` | `//` | `////` | `swift` (`CommandLine`, `#file`) |
| **Tcl** | `examples/cliHelpLine.tcl` | `#` | `##` | `tclsh` (`$argv`, `$argv0`) |
| **TypeScript** | `examples/cliHelpLine.ts` | `//` | `////` | `bun` / `node 22.6+` / `tsx` / `deno` |
| **Zsh** | `examples/cliHelpLine.zsh` | `#` | `##` | `zsh` |

---

## 3. Strict Coding & Formatting Rules

### A. Line 1 Hybrid Comment Pattern
The first line of every snippet MUST strictly adhere to this exact pattern:
```text
<dcc> Help -- prints header above (stops at '<dcc>')  (see https://github.com/JanAxelsson/cliHelpLine)
```
Where `<dcc>` is the language's double comment:
* `#` languages $\rightarrow$ `##`
* `//` languages $\rightarrow$ `////`
* `--` languages $\rightarrow$ `----`

### B. POSIX `sed` Compatibility
In shell scripts (`bash`, `sh`, `zsh`, `fish`, `run_tests.sh`), **NEVER** use GNU-only `\s`. Always use POSIX character classes:
* **CORRECT:** `/^[[:space:]]*$/d`
* **WRONG:** `/^\s*$/d` (breaks BSD `sed` on macOS)

### C. AWK Specifics & GNU Awk Requirement
Standard BSD/macOS `awk` lacks process introspection (`PROCINFO`) and intercepts `--help` via `getopt` before the script runs.
* `cliHelpLine.awk` MUST use the shebang:
  ```awk
  #!/usr/bin/env -S gawk -E
  ```
* `-E` prevents option swallowing so `--help` reaches the script.
* `PROCINFO["argv"]` allows the script to find its own file path.

### D. Ruby on macOS Sandbox
Ruby on macOS can throw `Errno::EPERM` when scanning `~/.gem`. Always pass `RUBYOPT="--disable-gems"` or `ruby --disable-gems` in tests.

### E. Non-Interactive CLI Input Handling
When invoking command-line runners in test scripts (especially `npx tsx`), always redirect standard input from `/dev/null` (`< /dev/null`). This prevents interactive prompts (like package installation confirmations or package update notices) from hanging the test suite indefinitely.

### F. README Structure & Navigation Rules
1. **Alphabetical Ordering:**
   All 17 language sections in `README.md` under `## Code to use` must be sorted strictly alphabetically from A to Z (with `Sh (POSIX Shell)` positioned under **S** between `Ruby` and `Swift`).
2. **Quick-Jump Index Bar:**
   Located at `<a id="languages"></a>` directly beneath `## Code to use`. Contains clean links to each language anchor:
   `> [AWK](#awk) · [Bash](#bash) · ... · [Zsh](#zsh)`
3. **Explicit HTML Anchors:**
   Place `<a id="<lang>"></a>` directly above each `### <LanguageName>` heading. This guarantees navigation works consistently regardless of Markdown engine slugification.
4. **Clean Headings:**
   Keep headings clean text without large inline URLs or hyperlinks (e.g. `### Bash`, NOT `### Bash · [link](...)`).
5. **Compact Footers with Up-Arrow Return:**
   Immediately following each code block (or following any language-specific tip block), include a single `<small>` footer combining the example link and an up-arrow return to the index:
   ```markdown
   <small>[`cliHelpLine.<ext>`](examples/cliHelpLine.<ext>) · [↑](#languages "Back to languages")</small>
   ```
6. **Byte-for-Byte Synchronization:**
   Test 3 extracts the 2-line code blocks from `README.md` and verifies that they match the respective files in `examples/` byte-for-byte.

### G. Shebang Execution & Runtime Resolution
- **Direct Shebang Inspection:** When testing direct execution (`./cliHelpLine.<ext>`), `tests/test_cliHelpLine.sh` inspects the script's line 1 shebang using `get_shebang_cmd` to determine the exact required binary (e.g. `gawk` for AWK, `bun` for TypeScript, `pwsh` for PowerShell). If the binary is not present on the host or container, the test is cleanly reported under `Skipped:` rather than triggering a false failure.
- **TypeScript & Bun:** `examples/cliHelpLine.ts` uses `#!/usr/bin/env bun`. Both Docker (`tests/Dockerfile`) and macOS CI (`.github/workflows/tests.yml`) install `bun` via `npm install -g tsx bun` so that both direct shebang execution and language command execution run cleanly.
- **Lua Compatibility in Debian:** Debian packages Lua as `lua5.4` (`/usr/bin/lua5.4`). `tests/Dockerfile` creates a symlink `ln -sf /usr/bin/lua5.4 /usr/local/bin/lua` so that `#!/usr/bin/env lua` succeeds without failing.
- **PHP CLI vs. Web Dual Examples:** PHP scripts in web environments (FastCGI, PHP-FPM, Apache) leak shebang lines into HTTP response headers/body. cliHelpLine provides `examples/cliHelpLine.php` (CLI with `#!/usr/bin/env php` and `<?php`) and `examples/cliHelpLine_web.php` (starts directly with `<?php` without shebang). The test suite automatically tests both under `php <file>` and cleanly skips `cliHelpLine_web.php` in direct shebang execution.
- **Accurate Counting:** Test counting uses independent `total_run`, `pass_count`, `fail_count`, and `skip_count` variables to ensure test summaries remain mathematically accurate across subsets and skipped tests.

### H. Line Endings (EOL), Windows Realities, and GitHub Copy-Paste Semantics
1. **GitHub Markdown Spec & Browser Clipboard Realities:**
   - The [GitHub Flavored Markdown (GFM) specification](https://github.github.com/gfm/#line-endings) explicitly mandates that all line breaks in Markdown source files are normalized to Unix `\n` (LF) during server-side HTML rendering.
   - When a user copies a code block from GitHub's web interface (via the "Copy" button or manual `Ctrl+C`), the browser's Clipboard API (`navigator.clipboard.writeText`) places raw `\n` (LF) strings onto the Windows clipboard.
   - There is no repository-side mechanism (via `.gitattributes`, HTTP headers, or HTML tricks) to force GitHub's web application to deliver or copy `\r\n`.
2. **The 3 EOL States on Windows:**
   - **Pure LF:** Checkouts directly from Git (enforced by `.gitattributes` via `* text=auto eol=lf`) or edited in Unix-configured editors.
   - **Pure CRLF:** Standard Windows files created or saved in traditional Windows editors (classic Notepad, Visual Studio) where all lines end with `\r\n`.
   - **Mixed CRLF + LF (The Browser Copy-Paste Scenario):** When a Windows developer pastes an LF snippet copied from GitHub into their existing Windows CRLF script (`Ctrl+V`), modern editors (VS Code, Sublime Text, Notepad++) insert the clipboard's `\n` literally. The resulting file has `\r\n` for top header comments and script body, but `\n` for the 2-line snippet.
3. **Strict Resilient One-Liner Design:**
   Because neither GitHub nor the developer's text editor can be controlled, snippets for Windows-supported languages must be resilient across all 3 states:
   - **PowerShell (`cliHelpLine.ps1`):** `Get-Content` uses .NET `StreamReader.ReadLine()`, which inherently strips away both `\r\n` and `\n` on all OSes.
   - **Python (`cliHelpLine.py`):** Uses `.rstrip('\r\n')` (and universal newlines in `open(...)`), stripping carriage returns regardless of line ending style.
   - **JavaScript / TypeScript (`cliHelpLine.js` & `cliHelpLine.ts`):** Uses `.split(/\r?\n/)`, splitting cleanly on both `\r\n` and `\n` without leaving trailing `\r` carriage returns.
   - **Ruby (`cliHelpLine.rb`):** Uses `.chomp` (removes `\r\n`, `\n`, or `\r`).
   - **Perl (`cliHelpLine.pl`):** Uses `s/\r?\n$//` or `chomp`.
4. **Why Unix (Linux & macOS) Must NOT Test CRLF:**
   - On Linux and macOS, the kernel's `execve()` system call inspects shebang lines directly. If a file has CRLF endings, `\r` is treated as part of the interpreter binary name (`/usr/bin/env: 'python3\r': No such file or directory`), causing immediate OS kernel failure for all 17 languages.
   - POSIX shells (`bash`, `sh`, `zsh`) treat `\r` as illegal syntax tokens (`syntax error near unexpected token $'\r'`).
   - Therefore, CRLF is an unsupported defect state on Unix.
5. **Windows Native CI Testing (`tests/test_windows.ps1`):**
   - [`tests/test_windows.ps1`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/test_windows.ps1) verifies PowerShell, Python, Node.js, and TypeScript across all 3 EOL modes (`[LF]`, `[CRLF]`, and `[Mixed]`), testing `--help`, `-h`, the native Windows `/?` flag, and normal execution without arguments (48 tests total).
   - **No-BOM UTF-8 Requirement:** When generating test fixtures programmatically in PowerShell/.NET, always instantiate `New-Object System.Text.UTF8Encoding($false)`. Using default `[System.Text.Encoding]::UTF8` emits a UTF-8 Byte Order Mark (BOM: `\xEF\xBB\xBF`), which prepends invisible bytes before `#!` and causes Node.js syntax errors.

---

## 4. Testing Architecture (3 Stages)

The test suite is orchestrated by [`run_tests.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/run_tests.sh), which invokes [`tests/test_cliHelpLine.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/test_cliHelpLine.sh):

```text
                     ./run_tests.sh
                           │
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
Stage 1: Local Host   Stage 2: Docker     Stage 3: README
(Verifies installed   (Verifies all 16    (Synchronizes
 local runtimes)       Linux runtimes in   2-line snippets
                       slim container)     against README)
```

### What Each Script Test Checks:
Every language script is verified under **both** invocation methods:
1. **Direct Shebang Execution (`./cliHelpLine.<ext>`):**
   - Invokes script directly via its shebang line (`#!`). All 17 languages support direct shebang execution (including PHP via `#!/usr/bin/env php` followed by `<?php`).
   - Verifies `--help` matches header comments and stops at boundary.
   - Verifies execution without arguments prints `"Hello world!"`.
2. **Language Command Execution (`<cmd> cliHelpLine.<ext>`):**
   - Invokes script with its language command as starter (`bash cliHelpLine.bash`, `python3 cliHelpLine.py`, `php cliHelpLine.php`, `gawk -E cliHelpLine.awk`, etc.).
   - Verifies `--help` matches header comments and stops at boundary.
   - Verifies execution without arguments prints `"Hello world!"`.

### Summary Stages:
- **Test 1/3: Local host tests:** Verifies direct execution via shebang, execution via language command starter, and running without `--help` on macOS/Linux. Missing host runtimes are quietly collected and reported underneath (`Skipped: <ext> (<runtime> not found)`) so that test logs remain clean with only `[ OK ]` or `[FAIL]`.
- **Test 2/3: Docker full-suite tests:** Builds and executes tests inside `clihelpline-tester` container where 16 Linux runtimes (including Julia 1.10.12 and tsx/bun/node) are installed. Both shebang and language command execution are verified across all Linux runtimes. Swift is skipped on Linux and verified on macOS.
- **Test 3/3: README.md verification:** Verifies the 2-line code blocks match README.md for all 17 languages byte-for-byte.

### Continuous Integration (GitHub Actions - 3 Platforms):
Automated CI runs on every push and pull request across all branches via `.github/workflows/tests.yml`.

> [!NOTE]
> The workflow file lives in `.github/workflows/tests.yml`. Because its folder begins with a dot (`.`), it is hidden by default in macOS Finder (press `Cmd` + `Shift` + `.` to reveal) and `ls` (use `ls -la`), but it is **fully tracked and version-controlled by Git** (never ignored by `.gitignore`).

#### Architecture Overview
```text
┌────────────────────────┐  ┌──────────────┐  ┌────────────────┐
│ test-docker-and-readme │  │  test-macos  │  │  test-windows  │
│     (ubuntu-latest)    │  │(macos-latest)│  │(windows-latest)│
└───────────┬────────────┘  └──────┬───────┘  └───────┬────────┘
            │                      │                  │
            └──────────────┬───────┴──────────────────┘
                           ▼
                ┌─────────────────────┐
                │       summary       │
                │   (ubuntu-latest)   │
                │ Generates Dashboard │
                └─────────────────────┘
```

#### The 4 Jobs Explained:
1. **`test-docker-and-readme` (Linux `ubuntu-latest`):**
   - **Docker Buildx Cache:** Uses GitHub Actions cache (`type=gha`) to cache the `clihelpline-tester` Docker image layers, speeding up builds to seconds.
   - **Stage 1 (Docker Full Suite):** Runs `tests/test_cliHelpLine.sh --help-only` inside the Docker container, testing all 16 Linux runtimes for direct shebang execution, language command execution, and normal execution (`"Hello world!"`). Container includes `lua` symlink (`/usr/local/bin/lua -> /usr/bin/lua5.4`) and npm packages `tsx` and `bun`.
   - **Stage 2 (README Sync):** Runs `tests/test_cliHelpLine.sh --readme-only` on the host, verifying all 17 language snippets against `README.md` byte-for-byte.
   - **Output Passing:** Emits stripped text results directly to job outputs (`$GITHUB_OUTPUT`) in memory without creating fragile blob zip artifacts.

2. **`test-macos` (macOS `macos-latest`):**
   - **Native Darwin Runner:** Executes on Apple Silicon (M-series) macOS hardware.
   - **Homebrew & npm Setup:** Installs `gawk`, `fish`, `lua`, `php`, `r`, and `julia` via Homebrew, and `tsx` and `bun` via npm (`pwsh`, `python3`, `node`, `ruby`, `perl`, `bash`, `zsh`, `swift` are native/pre-installed).
   - **Stage 3 (macOS Native Tests):** Runs `tests/test_cliHelpLine.sh --help-only` directly on Darwin, guaranteeing BSD `sed`, `gawk`, Swift, and macOS permission compatibility. Does **not** re-run README sync (avoids test duplication).
   - **Output Passing:** Emits results to `$GITHUB_OUTPUT`.

3. **`test-windows` (Windows `windows-latest`):**
   - **Native Windows Server Runner:** Executes natively in PowerShell 7 (`pwsh`).
   - **Stage 4 (Windows Native Tests):** Runs [`tests/test_windows.ps1`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/test_windows.ps1) to verify PowerShell (`pwsh`), Python, Node.js, and TypeScript across LF, CRLF, and Mixed line endings.
   - **Windows-Specific Validation:** Explicitly tests the native Windows **`/?`** flag in addition to `-h` and `--help`, plus normal execution across all 3 line ending modes (pure LF from git, pure Windows CRLF, and mixed CRLF/LF simulating pasting from a browser). Does **not** re-run README sync (avoids test duplication).
   - **Output Passing:** Emits results to `$env:GITHUB_OUTPUT`.

4. **`summary` (Unified Front-Page Dashboard):**
   - Runs on `ubuntu-latest` after all 3 parallel test jobs complete (`if: always()`).
   - Receives the 4 stage outputs via environment variables and executes [`tests/format_summary.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/format_summary.sh).
   - **Zero Console Clutter:** Suppresses bash execution tracing so that opening the job log displays only pristine, formatted output.
   - **Front-Page Step Summary:** Writes Markdown directly to `$GITHUB_STEP_SUMMARY`, rendering all 4 stages in exact requested order on the GitHub Actions run homepage:
     1. 🐧 Docker Tests (All Linux Languages)
     2. 📖 Sync with README.md (All 17 Languages)
     3. 🍏 macOS Tests (Darwin Host)
     4. 🪟 Windows Tests (Native Host)
     5. 🏆 Total Test Summary
   - Evaluates prerequisite job statuses and exits with code 1 if any stage experienced a failure.

---

## 5. Test Runner Commands

```bash
# Run all 3 test stages (Local, Docker, README)
./run_tests.sh

# Run local host tests + README test only (skips Docker)
./run_tests.sh --local
./run_tests.sh -l

# Run Docker tests + README test only (skips local)
./run_tests.sh --docker
./run_tests.sh -d

# Run all 3 test stages for specific language(s) or script(s)
./run_tests.sh py
./run_tests.sh bash zsh fish
./run_tests.sh cliHelpLine.awk

# Force rebuild the Docker test image
./run_tests.sh --build

# View test runner options
./run_tests.sh --help

# Granular sub-test execution via test_cliHelpLine.sh
bash tests/test_cliHelpLine.sh --shebang-only  # Run direct shebang tests only
bash tests/test_cliHelpLine.sh --cmd-only      # Run language command tests only
bash tests/test_cliHelpLine.sh --help-only     # Run both shebang and cmd tests (skips README)
bash tests/test_cliHelpLine.sh --readme-only   # Run README verification only
```

---

## 6. Checklist: How to Add a New Language

When adding language #18+:
1. **Create `examples/cliHelpLine.<ext>`:**
   - Shebang (if applicable).
   - Multi-line header documentation.
   - Line 1: `<dcc> Help -- prints header above (stops at '<dcc>')  (see https://github.com/JanAxelsson/cliHelpLine)`
   - Line 2: The self-contained one-liner.
   - Code explanation in comments.
   - Runnable code block printing `"Hello world!"`.
2. **Update `README.md`:**
   - Add language link to the alphabetical jump bar under `## Code to use`.
   - Add `<a id="<lang>"></a>` and `### <LanguageName>` in alphabetical position.
   - Add the exact 2-line code block in fenced syntax (```` ```<lang> ````).
   - Add footer link: `<small>[`cliHelpLine.<ext>`](examples/cliHelpLine.<ext>) · [↑](#languages "Back to languages")</small>`.
   - Update total language count in header / summary text if applicable.
3. **Update `tests/test_cliHelpLine.sh`:**
   - Add extension mapping in `lang_for_file()`.
   - Add interpreter availability check in `is_interpreter_available()`.
   - Add display command in `get_command_display()` (used for test logging and skip binary detection).
   - Add execution command in `run_script_cmd()`.
4. **Update `tests/Dockerfile`:**
   - Add interpreter package or binary installation to `apt-get install` or `/opt`.
5. **Verify:**
   - Run `./run_tests.sh --local` and `./run_tests.sh --docker` (or `./run_tests.sh --build`).
   - Ensure all 3 test stages pass.
6. **Update `AGENTS.md`:**
   - Add the new language to the table in Section 2 (alphabetical order).
   - Increment total language counts in the documentation.

---

## 7. Branching Strategy & Git Workflow

The repository follows a clean two-branch development model:

### The Branches
- **`develop` (Default Working Branch):**
  - All new features, bug fixes, documentation enhancements, refactors, and updates to `AGENTS.md` are developed and committed directly on `develop`.
  - CI workflows run on every push to `develop`.
- **`main` (Production / Stable Release Branch):**
  - Strictly reflects tagged, stable releases (`v0.1`, `v0.2`, etc.).
  - Code is never modified directly on `main`; it is updated exclusively by merging `develop` during the release process.

### How `AGENTS.md` Is Handled Across Branches
- `AGENTS.md` is a version-controlled Git file tracked in the repository root.
- **Proactive Maintenance Rule:** Agents must automatically update `AGENTS.md` on `develop` without waiting for explicit user prompts whenever architectural decisions, CI modifications, new language support, or testing conventions are added or altered. Always summarize any updates made to `AGENTS.md` in the response.
- **Always update `AGENTS.md` on `develop`:** Since everyday work happens on `develop`, keeping `AGENTS.md` updated here ensures that agents and human contributors always have access to the latest architectural guidelines, checklists, and lessons learned.
- **Automatic propagation to `main`:** When `develop` is merged into `main` during a release, `main` automatically receives the exact updated version of `AGENTS.md`. No separate manual syncing or cherry-picking is required.

---

## 8. Release Process Playbook (Step-by-Step)

Follow this exact procedure whenever cutting a new version (e.g. `v0.2` $\rightarrow$ `v0.3`):

### Step 1: Bump the Version Badge in `README.md` (on `develop`)
Line 4 of `README.md` contains the Shields.io version badge:
```markdown
[![Version](https://img.shields.io/badge/version-<X.Y>-blue.svg)](https://github.com/JanAxelsson/cliHelpLine/releases)
```
Update `<X.Y>` to the new version number (e.g. `0.3`), verify README sync (`bash tests/test_cliHelpLine.sh --readme-only`), and commit:
```bash
git add README.md
git commit -m "chore: bump version badge to <X.Y> in README.md"
git push origin develop
```

### Step 2: Merge `develop` into `main`
Switch to `main` and fast-forward merge the verified `develop` branch:
```bash
git checkout main
git merge develop --ff-only
```

### Step 3: Create an Annotated Git Tag
Create an annotated release tag documenting key additions:
```bash
git tag -a v<X.Y> -m "Release version <X.Y> - <Short summary of features/fixes>"
```

### Step 4: Push `main` and the Tag to GitHub
```bash
git push origin main
git push origin v<X.Y>
```
*Pushing the tag automatically registers the release on GitHub under Releases & Tags.*

### Step 5: Switch Back to `develop`
Always return to `develop` so subsequent development work continues on the working branch:
```bash
git checkout develop
```
