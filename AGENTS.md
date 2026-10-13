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

## 2. Supported Languages (14 Total)

All 14 language examples live in the `examples/` directory:

| Language | Script File | Comment Char | Boundary Marker (Double-Comment) | Runtime / Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Bash** | `examples/cliHelpLine.bash` | `#` | `##` | `bash` |
| **POSIX Shell** | `examples/cliHelpLine.sh` | `#` | `##` | `sh` (POSIX compliant) |
| **Zsh** | `examples/cliHelpLine.zsh` | `#` | `##` | `zsh` |
| **Fish** | `examples/cliHelpLine.fish` | `#` | `##` | `fish` |
| **Python** | `examples/cliHelpLine.py` | `#` | `##` | `python3` (`sys.argv`, `__file__`) |
| **JavaScript** | `examples/cliHelpLine.js` | `//` | `////` | `node` (`process.argv`, `__filename`) |
| **Ruby** | `examples/cliHelpLine.rb` | `#` | `##` | `ruby` (`ARGV`, `__FILE__`) |
| **Perl** | `examples/cliHelpLine.pl` | `#` | `##` | `perl` (`@ARGV`, `$0`) |
| **PHP** | `examples/cliHelpLine.php` | `//` | `////` | `php` (`$argv`, `__FILE__`) |
| **Lua** | `examples/cliHelpLine.lua` | `--` | `----` | `lua` (`arg`, `arg[0]`) |
| **R** | `examples/cliHelpLine.r` | `#` | `##` | `Rscript` (`commandArgs`) |
| **PowerShell** | `examples/cliHelpLine.ps1` | `#` | `##` | `pwsh` (`$args`, `$MyInvocation`) |
| **Tcl** | `examples/cliHelpLine.tcl` | `#` | `##` | `tclsh` (`$argv`, `$argv0`) |
| **AWK** | `examples/cliHelpLine.awk` | `#` | `##` | `gawk` (GNU Awk required) |

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
- **Test 1/3: Local host tests:** Verifies `--help` and running without `--help` on macOS/Linux. Missing host runtimes are gracefully reported as `[SKIP]`.
- **Test 2/3: Docker full-suite tests:** Builds and executes tests inside `clihelpline-tester` container where all 14 runtimes are installed.
- **Test 3/3: README.md verification:** Verifies the 2-line code blocks match README.md for all 14 languages.

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
