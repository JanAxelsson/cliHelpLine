# AGENTS.md - Developer & Agent Guide for cliHelpLine

This document provides essential context, architectural decisions, design rules, and testing requirements for AI agents and human contributors working on **cliHelpLine**.

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

All 17 language examples live in the `examples/` directory:

| Language | Script File | Comment Char | Boundary Marker (Double-Comment) | Runtime / Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Bash** | `examples/cliHelpLine.bash` | `#` | `##` | `bash` |
| **POSIX Shell** | `examples/cliHelpLine.sh` | `#` | `##` | `sh` (POSIX compliant) |
| **Zsh** | `examples/cliHelpLine.zsh` | `#` | `##` | `zsh` |
| **Fish** | `examples/cliHelpLine.fish` | `#` | `##` | `fish` |
| **Python** | `examples/cliHelpLine.py` | `#` | `##` | `python3` (`sys.argv`, `__file__`) |
| **JavaScript** | `examples/cliHelpLine.js` | `//` | `////` | `node` (`process.argv`, `__filename`) |
| **TypeScript** | `examples/cliHelpLine.ts` | `//` | `////` | `tsx` / `bun` / `deno` / `node` |
| **Ruby** | `examples/cliHelpLine.rb` | `#` | `##` | `ruby` (`ARGV`, `__FILE__`) |
| **Perl** | `examples/cliHelpLine.pl` | `#` | `##` | `perl` (`@ARGV`, `$0`) |
| **PHP** | `examples/cliHelpLine.php` | `//` | `////` | `php` (`$argv`, `__FILE__`) |
| **Lua** | `examples/cliHelpLine.lua` | `--` | `----` | `lua` (`arg`, `arg[0]`) |
| **R** | `examples/cliHelpLine.r` | `#` | `##` | `Rscript` (`commandArgs`) |
| **PowerShell** | `examples/cliHelpLine.ps1` | `#` | `##` | `pwsh` (`$args`, `$MyInvocation`) |
| **Tcl** | `examples/cliHelpLine.tcl` | `#` | `##` | `tclsh` (`$argv`, `$argv0`) |
| **AWK** | `examples/cliHelpLine.awk` | `#` | `##` | `gawk` (GNU Awk required) |
| **Julia** | `examples/cliHelpLine.jl` | `#` | `##` | `julia` (`ARGS`, `@__FILE__`) |
| **Swift** | `examples/cliHelpLine.swift` | `//` | `////` | `swift` (`CommandLine`, `#file`) |

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

### E. README Synchronization
Test 3 verifies that each script's 2-line snippet matches the corresponding code block in `README.md` byte-for-byte. If you change a snippet in a script, you MUST update `README.md`, and vice versa.

---

## 4. Testing Architecture (3 Stages)

The test suite is orchestrated by [`run_tests.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/run_tests.sh), which invokes [`tests/test_cliHelpLine.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/test_cliHelpLine.sh):

```
                     ./run_tests.sh
                           │
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
Stage 1: Local Host   Stage 2: Docker     Stage 3: README
(Verifies installed   (Verifies all 14    (Synchronizes
 local runtimes)       runtimes in slim    2-line snippet
                       container)          against README)
```

### What Each Script Test Checks:
1. **Help Flag Verification:** Invokes script with `--help`. Verifies output matches header comments and stops at boundary.
2. **Normal Execution Verification:** Invokes script without arguments. Verifies output falls through cleanly to main code and prints `"Hello world!"` (and NOT the help text).

### Summary Stages:
- **Test 1/3: Local host tests:** Verifies `--help` and running without `--help` on macOS/Linux. Missing host runtimes are gracefully reported in quiet text underneath.
- **Test 2/3: Docker full-suite tests:** Builds and executes tests inside `clihelpline-tester` container where all Linux runtimes are installed.
- **Test 3/3: README.md verification:** Verifies the 2-line code blocks match README.md for all 17 languages.

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
   - **Stage 1 (Docker Full Suite):** Runs `tests/test_cliHelpLine.sh --help-only` inside the Docker container, testing all 14 runtimes for both `--help` output and normal execution (`"Hello world!"`).
   - **Stage 2 (README Sync):** Runs `tests/test_cliHelpLine.sh --readme-only` on the host, verifying all 14 language snippets against `README.md` byte-for-byte.
   - **Output Passing:** Emits stripped text results directly to job outputs (`$GITHUB_OUTPUT`) in memory without creating fragile blob zip artifacts.

2. **`test-macos` (macOS `macos-latest`):**
   - **Native Darwin Runner:** Executes on Apple Silicon (M-series) macOS hardware.
   - **Homebrew Setup:** Installs `gawk`, `fish`, `lua`, `php`, and `r` via Homebrew (`pwsh`, `python3`, `node`, `ruby`, `perl`, `bash`, `zsh` are pre-installed).
   - **Stage 3 (macOS Native Tests):** Runs `tests/test_cliHelpLine.sh --help-only` directly on Darwin, guaranteeing BSD `sed`, `gawk`, and macOS permission compatibility. Does **not** re-run README sync (avoids test duplication).
   - **Output Passing:** Emits results to `$GITHUB_OUTPUT`.

3. **`test-windows` (Windows `windows-latest`):**
   - **Native Windows Server Runner:** Executes natively in PowerShell 7 (`pwsh`).
   - **Stage 4 (Windows Native Tests):** Runs [`tests/test_windows.ps1`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/test_windows.ps1) to verify PowerShell (`pwsh`), Python, and Node.js.
   - **Windows-Specific Validation:** Explicitly tests the native Windows **`/?`** flag in addition to `-h` and `--help`, plus normal execution. Does **not** re-run README sync (avoids test duplication).
   - **Output Passing:** Emits results to `$env:GITHUB_OUTPUT`.

4. **`summary` (Unified Front-Page Dashboard):**
   - Runs on `ubuntu-latest` after all 3 parallel test jobs complete (`if: always()`).
   - Receives the 4 stage outputs via environment variables and executes [`tests/format_summary.sh`](file:///Users/jan/Documents/Projects/cliHelpLine/tests/format_summary.sh).
   - **Zero Console Clutter:** Suppresses bash execution tracing so that opening the job log displays only pristine, formatted output.
   - **Front-Page Step Summary:** Writes Markdown directly to `$GITHUB_STEP_SUMMARY`, rendering all 4 stages in exact requested order on the GitHub Actions run homepage:
     1. 🐧 Docker Tests (All 14 Languages)
     2. 📖 Sync with README.md
     3. 🍏 macOS Tests (Darwin Host)
     4. 🪟 Windows Tests (Native Host)
     5. 🏆 Total Test Summary (All 54 tests)
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
```

---

## 6. Checklist: How to Add a New Language

When adding language #15:
1. **Create `examples/cliHelpLine.<ext>`:**
   - Shebang (if applicable).
   - Multi-line header documentation.
   - Line 1: `<dcc> Help -- prints header above (stops at '<dcc>')  (see https://github.com/JanAxelsson/cliHelpLine)`
   - Line 2: The self-contained one-liner.
   - Code explanation in comments.
   - Runnable code block printing `"Hello world!"`.
2. **Update `README.md`:**
   - Add a `### <LanguageName>` section under `## Code to use` with the exact 2-line block.
   - Update language count mentions if necessary.
3. **Update `tests/test_cliHelpLine.sh`:**
   - Add extension mapping in `lang_for_file()`.
   - Add interpreter check in `is_interpreter_available()` and `get_interpreter_name()`.
   - Add execution command in `run_script()`.
4. **Update `tests/Dockerfile`:**
   - Add the interpreter package to `apt-get install`.
5. **Verify:**
   - Run `./run_tests.sh --build` and ensure all 3 test stages pass.
