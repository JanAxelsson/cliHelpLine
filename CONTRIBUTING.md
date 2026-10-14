# Contributing to cliHelpLine

Thank you for your interest in contributing to **cliHelpLine**!

The goal of this project is to provide universal, zero-dependency, 2-line snippets that turn a script's top-of-file header comments into `--help`, `-h`, and `/?` output across any scripting language.

---

## Code of Conduct & Core Guarantees

Every contribution must preserve cliHelpLine's 3 core guarantees:

1. **Zero External Dependencies & Zero Boilerplate:** No external packages (like `argparse`, `commander`, `yargs`, or `clap`). Built-in runtime capabilities only.
2. **2-Line Drop-in Snippet:**
   - **Line 1 (Comment marker):** Identifies the help boundary and links back to the repository.
   - **Line 2 (One-liner):** Inspects CLI arguments, reads the file up to the boundary, strips comment characters and leading spaces, prints the text, and exits `0`.
3. **Dual Execution Guarantee:**
   - **With help flags (`--help`, `-h`, `/?`):** Prints header comments and immediately exits (`exit 0`). Does NOT run the main program body.
   - **Without help flags (normal invocation):** Falls through silently and executes the main program body (demonstrated by printing `"Hello world!"`). Does NOT print the help header.

---

## Checklist: Adding a New Language

When adding support for a new language:

1. **Create `examples/cliHelpLine.<ext>`:**
   - Standard shebang on line 1 (if applicable).
   - Multi-line header documentation block.
   - Line 1 of snippet: `<dcc> Help -- prints header above (stops at '<dcc>')  (see https://github.com/JanAxelsson/cliHelpLine)`
     *(Where `<dcc>` is `##`, `////`, `----`, or `REM REM`)*.
   - Line 2 of snippet: The self-contained one-liner.
   - Inline comments explaining how the snippet works.
   - Runnable code block printing `"Hello world!"`.

2. **Update `README.md`:**
   - Add language link to the alphabetical jump bar under `## CODE TO USE`.
   - Add `<a id="<lang>"></a>` and `#### > <LanguageName>` heading in alphabetical position (A–Z).
   - Add the 2-line snippet in a fenced code block matching the example file byte-for-byte.
   - Add return footer: `<small>[`cliHelpLine.<ext>`](examples/cliHelpLine.<ext>) · [↑](#languages "Back to languages")</small>`.

3. **Update Test Runner & Container (if applicable):**
   - If direct execution requires a specific interpreter, update `get_shebang_cmd` in `tests/test_cliHelpLine.sh`.
   - If language requires a Linux package, add runtime to `tests/Dockerfile`.

4. **Update `AGENTS.md`:**
   - Add the language to the Supported Languages table in Section 2.

---

## Local Testing

cliHelpLine includes a 3-stage multi-language test suite:

```bash
# Run local host tests + README synchronization
./run_tests.sh --local

# Run Docker full-suite verification (all Linux runtimes)
./run_tests.sh --docker

# Test a specific language
./run_tests.sh python
./run_tests.sh bash

# Run all 3 stages (Local, Docker, README)
./run_tests.sh
```

Before opening a pull request, ensure `./run_tests.sh --local` passes 100%.

---

## Pull Request Guidelines

1. **Branch Naming:** Use feature branches branched from `develop` (e.g. `feature/add-kotlin-script` or `fix/sed-posix-compatibility`).
2. **Byte-for-Byte Sync:** Test 3 verifies that snippets in `README.md` match `examples/` byte-for-byte.
3. **Commit Messages:** Follow standard conventional commits format (e.g. `feat: add support for <language>`, `docs: improve example description`).
4. **Target Branch:** Direct pull requests to the `develop` branch.
