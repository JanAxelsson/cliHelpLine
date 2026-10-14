#!/usr/bin/env bash
#
# Test suite for cliHelpLine.*
# 1. Verifies that output from 'cliHelpLine.* --help' matches line 2 up to the
#    first double-comment line, with comment characters and leading spaces stripped
#    (empty lines without comment characters are ignored).
# 2. Verifies that each script's two lines (double comment + one-liner) match
#    the code block in README.md for that language.
#

set -u

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Ensure standard binary locations are always accessible
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
README_FILE="$PROJECT_ROOT/README.md"

# ==============================================================================
# Helper Runners: Shebang extraction, direct execution, and language command execution
# ==============================================================================

# Extract the primary binary command expected by the script's shebang line (if any).
# Examples:
#   '#!/usr/bin/env -S gawk -E' -> 'gawk'
#   '#!/usr/bin/env bun'        -> 'bun'
#   '#!/bin/bash'               -> 'bash'
#   '<?php'                     -> '' (no shebang)
get_shebang_cmd() {
    local file="$1"
    local first_line
    first_line=$(head -n 1 "$file")
    case "$first_line" in
        '#!'*)
            local line="${first_line#\#!}"
            line="${line#"${line%%[![:space:]]*}"}"
            # Match '/usr/bin/env [-S] <binary>' or direct binary path
            if [[ "$line" =~ /?env[[:space:]]+(-S[[:space:]]+)?([^[:space:]]+) ]]; then
                echo "${BASH_REMATCH[2]}"
            else
                basename "${line%% *}"
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Execute a script directly via its shebang line (e.g. './cliHelpLine.py')
# - Uses '< /dev/null' to prevent interactive stdin prompts from hanging
# - Disables gem scanning on macOS to avoid Ruby Errno::EPERM
# - Configures Swift module cache path
run_script_direct() {
    local target="$1"
    shift
    RUBYOPT="--disable-gems" CLANG_MODULE_CACHE_PATH="${TMPDIR:-/tmp}/swift-cache" "$target" "$@" < /dev/null 2>/dev/null
}

# Execute a script using its language command first (e.g. 'python3 cliHelpLine.py')
# Passes language-specific flags (e.g. gawk '-E' to avoid option swallowing, pwsh '-NoProfile -File')
run_script_cmd() {
    local target="$1"
    shift
    local ext="${target##*.}"

    case "$ext" in
        bash)
            bash "$target" "$@" < /dev/null 2>/dev/null ;;
        sh)
            sh "$target" "$@" < /dev/null 2>/dev/null ;;
        zsh)
            zsh "$target" "$@" < /dev/null 2>/dev/null ;;
        fish)
            fish "$target" "$@" < /dev/null 2>/dev/null ;;
        py)
            if command -v python3 >/dev/null 2>&1; then
                python3 "$target" "$@" < /dev/null 2>/dev/null
            elif command -v python >/dev/null 2>&1; then
                python "$target" "$@" < /dev/null 2>/dev/null
            fi ;;
        js|mjs|cjs)
            node "$target" "$@" < /dev/null 2>/dev/null ;;
        rb)
            RUBYOPT="--disable-gems" ruby --disable-gems "$target" "$@" < /dev/null 2>/dev/null ;;
        pl)
            perl "$target" "$@" < /dev/null 2>/dev/null ;;
        php)
            php "$target" "$@" < /dev/null 2>/dev/null ;;
        lua)
            if command -v lua >/dev/null 2>&1; then
                lua "$target" "$@" < /dev/null 2>/dev/null
            else
                lua5.4 "$target" "$@" < /dev/null 2>/dev/null
            fi ;;
        r|R)
            Rscript "$target" "$@" < /dev/null 2>/dev/null ;;
        ps1)
            pwsh -NoProfile -File "$target" "$@" < /dev/null 2>/dev/null ;;
        tcl)
            tclsh "$target" "$@" < /dev/null 2>/dev/null ;;
        awk)
            if command -v gawk >/dev/null 2>&1; then
                gawk -E "$target" "$@" < /dev/null 2>/dev/null
            elif command -v awk >/dev/null 2>&1; then
                if [ "$#" -gt 0 ]; then
                    awk -f "$target" -- "$@" < /dev/null 2>/dev/null
                else
                    awk -f "$target" < /dev/null 2>/dev/null
                fi
            fi ;;
        ts)
            if command -v bun >/dev/null 2>&1; then
                bun run "$target" "$@" < /dev/null 2>/dev/null
            elif command -v tsx >/dev/null 2>&1; then
                tsx "$target" "$@" < /dev/null 2>/dev/null
            elif command -v ts-node >/dev/null 2>&1; then
                ts-node --transpile-only "$target" "$@" < /dev/null 2>/dev/null
            elif command -v node >/dev/null 2>&1; then
                node --experimental-strip-types "$target" "$@" < /dev/null 2>/dev/null
            fi ;;
        jl)
            julia "$target" "$@" < /dev/null 2>/dev/null ;;
        swift)
            swift -module-cache-path "${TMPDIR:-/tmp}/swift-cache" "$target" "$@" < /dev/null 2>/dev/null ;;
        cr)
            crystal run "$target" -- "$@" < /dev/null 2>/dev/null ;;
        dart)
            dart run "$target" "$@" < /dev/null 2>/dev/null ;;
        exs)
            elixir "$target" "$@" < /dev/null 2>/dev/null ;;
        groovy)
            groovy "$target" "$@" < /dev/null 2>/dev/null ;;
        nim)
            nim r --hints:off "$target" "$@" < /dev/null 2>/dev/null ;;
        raku)
            raku "$target" "$@" < /dev/null 2>/dev/null ;;
        bat|cmd)
            if command -v cmd.exe >/dev/null 2>&1; then
                cmd.exe /c "$target" "$@" < /dev/null 2>/dev/null
            elif command -v cmd >/dev/null 2>&1; then
                cmd /c "$target" "$@" < /dev/null 2>/dev/null
            fi ;;
        *)
            "$target" "$@" < /dev/null 2>/dev/null ;;
    esac
}

# General runner that tries direct execution first, then language command
run_script() {
    run_script_direct "$@" || run_script_cmd "$@"
}

# Check if the required interpreter is available on the system
is_interpreter_available() {
    local target="$1"
    local ext="${target##*.}"
    case "$ext" in
        bash) command -v bash >/dev/null 2>&1 ;;
        sh)   command -v sh >/dev/null 2>&1 ;;
        zsh)  command -v zsh >/dev/null 2>&1 ;;
        fish) command -v fish >/dev/null 2>&1 ;;
        py)   command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 ;;
        js|mjs|cjs) command -v node >/dev/null 2>&1 ;;
        rb)   command -v ruby >/dev/null 2>&1 ;;
        pl)   command -v perl >/dev/null 2>&1 ;;
        php)  command -v php >/dev/null 2>&1 ;;
        lua)  command -v lua >/dev/null 2>&1 || command -v lua5.4 >/dev/null 2>&1 ;;
        r|R)  command -v Rscript >/dev/null 2>&1 ;;
        ps1)  command -v pwsh >/dev/null 2>&1 ;;
        tcl)  command -v tclsh >/dev/null 2>&1 ;;
        awk)  command -v gawk >/dev/null 2>&1 ;;
        ts)   command -v bun >/dev/null 2>&1 || command -v tsx >/dev/null 2>&1 || command -v ts-node >/dev/null 2>&1 || (command -v node >/dev/null 2>&1 && node --experimental-strip-types -e 'process.exit(0)' >/dev/null 2>&1) ;;
        jl)   command -v julia >/dev/null 2>&1 ;;
        swift) command -v swift >/dev/null 2>&1 ;;
        cr)   command -v crystal >/dev/null 2>&1 ;;
        dart) command -v dart >/dev/null 2>&1 ;;
        exs)  command -v elixir >/dev/null 2>&1 ;;
        groovy) command -v groovy >/dev/null 2>&1 ;;
        nim)  command -v nim >/dev/null 2>&1 ;;
        raku) command -v raku >/dev/null 2>&1 ;;
        bat|cmd) command -v cmd.exe >/dev/null 2>&1 || command -v cmd >/dev/null 2>&1 ;;
        *)    return 0 ;;
    esac
}

# Return the command prefix used to invoke the script explicitly (e.g. 'python3', 'gawk -E', 'node')
# Used both for test logging and for extracting the base interpreter binary when reporting skips.
get_command_display() {
    local target="$1"
    local ext="${target##*.}"
    case "$ext" in
        awk)
            if command -v gawk >/dev/null 2>&1; then echo "gawk -E"; else echo "gawk"; fi ;;
        bash) echo "bash" ;;
        bat|cmd)
            if command -v cmd.exe >/dev/null 2>&1; then echo "cmd.exe"; else echo "cmd"; fi ;;
        sh)   echo "sh" ;;
        zsh)  echo "zsh" ;;
        fish) echo "fish" ;;
        py)
            if command -v python3 >/dev/null 2>&1; then echo "python3"; elif command -v python >/dev/null 2>&1; then echo "python"; else echo "python3"; fi ;;
        js|mjs|cjs) echo "node" ;;
        rb)   echo "ruby" ;;
        pl)   echo "perl" ;;
        php)  echo "php" ;;
        lua)
            if command -v lua >/dev/null 2>&1; then echo "lua"; else echo "lua5.4"; fi ;;
        r|R)  echo "Rscript" ;;
        ps1)  echo "pwsh" ;;
        tcl)  echo "tclsh" ;;
        jl)   echo "julia" ;;
        swift) echo "swift" ;;
        cr)   echo "crystal run" ;;
        dart) echo "dart run" ;;
        exs)  echo "elixir" ;;
        groovy) echo "groovy" ;;
        nim)  echo "nim r" ;;
        raku) echo "raku" ;;
        ts)
            if command -v bun >/dev/null 2>&1; then echo "bun";
            elif command -v tsx >/dev/null 2>&1; then echo "tsx";
            elif command -v ts-node >/dev/null 2>&1; then echo "ts-node";
            else echo "bun/tsx"; fi ;;
        *)    echo "$ext" ;;
    esac
}

# Map file extension to language identifier in README.md
lang_for_file() {
    local ext="${1##*.}"
    case "$ext" in
        bash)       echo "bash" ;;
        bat|cmd)    echo "bat" ;;
        sh)         echo "sh" ;;
        zsh)        echo "zsh" ;;
        fish)       echo "fish" ;;
        py)         echo "python" ;;
        js|mjs|cjs) echo "javascript" ;;
        rb)         echo "ruby" ;;
        pl)         echo "perl" ;;
        php)        echo "php" ;;
        lua)        echo "lua" ;;
        r|R)        echo "r" ;;
        ps1)        echo "powershell" ;;
        tcl)        echo "tcl" ;;
        awk)        echo "awk" ;;
        cr)         echo "crystal" ;;
        dart)       echo "dart" ;;
        exs)        echo "elixir" ;;
        groovy)     echo "groovy" ;;
        nim)        echo "nim" ;;
        raku)       echo "raku" ;;
        ts)         echo "typescript" ;;
        jl)         echo "julia" ;;
        swift)      echo "swift" ;;
        *)          echo "$ext" ;;
    esac
}

# Extract comment character from the first comment line
get_comment_char() {
    local file="$1"
    local line
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        local trimmed="${line#"${line%%[![:space:]]*}"}"
        [ -z "$trimmed" ] && continue
        [[ "$trimmed" == '#!'* ]] && continue
        [[ "$trimmed" == '<?php'* ]] && continue
        [[ "$trimmed" == '@echo off'* ]] && continue
        echo "${trimmed%% *}"
        return 0
    done < "$file"
}

# Extract expected help text according to specification
extract_expected_help() {
    local file="$1"
    local lineno=0
    local comment_char=""
    local double_comment=""

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        lineno=$((lineno + 1))

        # Skip line 1 shebang
        if [ "$lineno" -eq 1 ] && [[ "$line" == '#!'* ]]; then
            continue
        fi

        # Skip opening <?php tag if present at top
        if [ "$lineno" -le 2 ] && [[ "$line" == '<?php'* ]]; then
            continue
        fi

        # Skip opening @echo off if present at top
        if [ "$lineno" -le 2 ] && [[ "$line" == '@echo off'* ]]; then
            continue
        fi

        # Identify comment character and double-comment marker from first comment line
        if [ -z "$comment_char" ]; then
            local trimmed="${line#"${line%%[![:space:]]*}"}"
            comment_char="${trimmed%% *}"
            if [ -z "$comment_char" ]; then
                echo "Error: Could not identify comment character in $file" >&2
                return 1
            fi
            if [ "$comment_char" = "REM" ]; then
                double_comment="REM REM"
            else
                double_comment="${comment_char}${comment_char}"
            fi
        fi

        # Stop at first line starting with double comment marker
        if [[ "$line" == "$double_comment"* ]]; then
            break
        fi

        # Skip empty lines without comment character
        if [[ "$line" =~ ^[[:space:]]*$ ]] && [[ "$line" != *"$comment_char"* ]]; then
            continue
        fi

        # Remove comment character and one space, output remaining text
        if [[ "$line" == "$comment_char "* ]]; then
            printf "%s\n" "${line#"$comment_char "}"
        elif [[ "$line" == "$comment_char" ]]; then
            printf "\n"
        elif [[ "$line" == "$comment_char"* ]]; then
            printf "%s\n" "${line#"$comment_char"}"
        else
            printf "%s\n" "$line"
        fi
    done < "$file"
}

# Extract the 2 lines (double comment + one-liner) from script
extract_script_snippet() {
    local file="$1"
    local double_comment="$2"
    awk -v dcc="$double_comment" '
        BEGIN { found = 0 }
        { sub(/\r$/, "") }
        $0 ~ "^" dcc { found = 1; print; next }
        found == 1 { print; exit }
    ' "$file"
}

# Extract the 2 lines for a language from README.md
extract_readme_snippet() {
    local lang="$1"
    local readme="$2"
    awk -v lang="$lang" '
        BEGIN { in_code_section = 0; in_block = 0; count = 0 }
        { sub(/\r$/, "") }
        /^## Code to use/ { in_code_section = 1 }
        in_code_section && tolower($0) ~ "^```" tolower(lang) "$" { in_block = 1; next }
        in_block && /^```/ { exit }
        in_block && count < 2 { print; count++ }
    ' "$readme"
}

# Display side-by-side diff with line numbers
show_side_by_side() {
    local left_file="$1"
    local right_file="$2"
    local left_label="$3"
    local right_label="$4"

    local width
    width=$(tput cols 2>/dev/null || echo 100)
    [ "$width" -lt 80 ] && width=100
    local half=$(( (width - 6) / 2 ))

    printf "\n  %-*s | %-*s\n" "$half" "$left_label" "$half" "$right_label"
    printf "  %s\n" "$(printf '%*s' "$width" '' | tr ' ' '-')"
    diff -y -W "$width" <(nl -ba "$left_file") <(nl -ba "$right_file") | sed 's/^/  /' || true
    printf "\n"
}

# Parse flags for sub-tests
RUN_DIRECT=1
RUN_CMD=1
RUN_README=1
filtered_args=()

for arg in "$@"; do
    case "$arg" in
        --help-only)
            RUN_README=0
            ;;
        --readme-only)
            RUN_DIRECT=0
            RUN_CMD=0
            ;;
        --direct-only|--shebang-only)
            RUN_CMD=0
            RUN_README=0
            ;;
        --cmd-only)
            RUN_DIRECT=0
            RUN_README=0
            ;;
        *)
            filtered_args+=("$arg")
            ;;
    esac
done

# ==============================================================================
# Target File Discovery: Identify which script files to test
# ==============================================================================
# The test runner supports running against specific files, extensions, or language
# names (e.g. './run_tests.sh py', './run_tests.sh bash', 'cliHelpLine.php'), or
# running against the full suite if no positional arguments were provided.
# ==============================================================================
EXAMPLES_DIR="$PROJECT_ROOT/examples"
files=()

if [ "${#filtered_args[@]}" -gt 0 ]; then
    # Mode A: User supplied target arguments (file path, extension, or language name)
    for arg in "${filtered_args[@]}"; do
        arg_clean="${arg#.}"
        arg_clean="$(basename "$arg_clean")"
        if [ -f "$arg" ]; then
            # Direct path provided (e.g. 'examples/cliHelpLine.py')
            files+=("$arg")
        elif [ -f "$EXAMPLES_DIR/$arg" ]; then
            # Relative to examples directory (e.g. 'cliHelpLine.py')
            files+=("$EXAMPLES_DIR/$arg")
        elif [ -f "$PROJECT_ROOT/$arg" ]; then
            # Relative to project root
            files+=("$PROJECT_ROOT/$arg")
        elif [ -f "$EXAMPLES_DIR/cliHelpLine.$arg_clean" ]; then
            # Extension shorthand provided (e.g. 'py' -> 'cliHelpLine.py')
            files+=("$EXAMPLES_DIR/cliHelpLine.$arg_clean")
        elif [ -f "$PROJECT_ROOT/cliHelpLine.$arg_clean" ]; then
            files+=("$PROJECT_ROOT/cliHelpLine.$arg_clean")
        else
            # Language name provided (e.g. 'python' -> matches 'examples/cliHelpLine.py')
            matched=""
            for search_dir in "$EXAMPLES_DIR" "$PROJECT_ROOT"; do
                [ -d "$search_dir" ] || continue
                for f in "$search_dir"/cliHelpLine.* "$search_dir"/cliHelpLine_*.*; do
                    [ -f "$f" ] || continue
                    lang=$(lang_for_file "$f")
                    if [ "$lang" = "$arg" ]; then
                        files+=("$f")
                        matched=1
                    fi
                done
                [ -n "$matched" ] && break
            done
            if [ -z "$matched" ]; then
                echo "Warning: No test file found for '$arg'" >&2
            fi
        fi
    done
else
    # Mode B: Default full-suite discovery
    # Globs all 'cliHelpLine.*' (standard scripts) and 'cliHelpLine_*.*' (specialized variants,
    # e.g. 'cliHelpLine_web.php') across the examples directory.
    search_dir="$EXAMPLES_DIR"
    [ -d "$search_dir" ] || search_dir="$PROJECT_ROOT"
    for f in "$search_dir"/cliHelpLine.* "$search_dir"/cliHelpLine_*.*; do
        [ -f "$f" ] || continue
        # Ignore self (test runner scripts), temporary backups, or editor swap files
        case "$(basename "$f")" in
            *test*|*.tmp|*.bak|*.swp) continue ;;
        esac
        files+=("$f")
    done
fi

if [ "${#files[@]}" -eq 0 ]; then
    echo "No cliHelpLine files found to test." >&2
    exit 1
fi

# ==============================================================================
# Test Execution State & Temp Files
# ==============================================================================
# Independent counters ensure accurate math across sub-test filters and skipped targets:
#   total_run  : total number of individual tests actually executed
#   pass_count : number of tests that passed
#   fail_count : number of tests that failed
#   skip_count : number of tests skipped due to missing host interpreters
total_run=0
pass_count=0
fail_count=0
skip_count=0

# Temporary files for capturing and comparing expected vs actual outputs
expected_tmp=$(mktemp)
actual_tmp=$(mktemp)
run_actual_tmp=$(mktemp)
script_snip_tmp=$(mktemp)
readme_snip_tmp=$(mktemp)
trap 'rm -f "$expected_tmp" "$actual_tmp" "$run_actual_tmp" "$script_snip_tmp" "$readme_snip_tmp"' EXIT

# ==============================================================================
# Part 1: Verify direct execution via shebang (./cliHelpLine.<ext>)
# ==============================================================================
# Tests running each script directly via its shebang line ('#!'):
#   1. './cliHelpLine.<ext> --help' -> must match header comments and stop at boundary
#   2. './cliHelpLine.<ext>'        -> must fall through and print 'Hello world!'
# Scripts without a shebang (e.g. 'cliHelpLine_web.php') are quietly collected in
# 'direct_skipped' without failing. Scripts requiring interpreters not installed on
# the host/container (e.g. Swift on Linux) are cleanly skipped.
if [ "$RUN_DIRECT" -eq 1 ]; then
    echo "--- Verifying direct execution via shebang (./cliHelpLine.<ext>) "
    direct_skipped=()
    for target in "${files[@]}"; do
        target_name="$(basename "$target")"

        # Check if file has a shebang line
        if ! head -n 1 "$target" | grep -q '^#!'; then
            direct_skipped+=("$target_name (no shebang)")
            continue
        fi

        shebang_cmd=$(get_shebang_cmd "$target")
        if [ -n "$shebang_cmd" ] && ! command -v "$shebang_cmd" >/dev/null 2>&1; then
            direct_skipped+=("$target_name ('$shebang_cmd' not installed)")
            skip_count=$((skip_count + 1))
            continue
        fi

        total_run=$((total_run + 1))

        # 1. Help output verification: --help must match header comments and stop
        extract_expected_help "$target" > "$expected_tmp"
        run_script_direct "$target" "--help" > "$actual_tmp"

        if ! cmp -s "$expected_tmp" "$actual_tmp"; then
            printf "${RED}[FAIL]${RESET} ./%s (--help output mismatch)\n" "$target_name"
            fail_count=$((fail_count + 1))
            show_side_by_side "$expected_tmp" "$actual_tmp" \
                "Expected ($target_name headers)" "Actual (./$target_name --help)"
            continue
        fi

        # 2. Running without --help: must execute main script and print 'Hello world!'
        run_script_direct "$target" > "$run_actual_tmp"
        run_output=$(tr -d '\r' < "$run_actual_tmp" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ "$run_output" != "Hello world!" ]; then
            printf "${RED}[FAIL]${RESET} ./%s (running without --help failed: expected 'Hello world!', got '%s')\n" "$target_name" "$run_output"
            fail_count=$((fail_count + 1))
            continue
        fi

        pass_count=$((pass_count + 1))
        printf "${GREEN}[ OK ]${RESET} ./%s\n" "$target_name"
    done
    if [ "${#direct_skipped[@]}" -gt 0 ]; then
        echo ""
        printf "Skipped: %s\n" "$(IFS=', '; echo "${direct_skipped[*]}")"
    fi
    echo ""
fi

# ==============================================================================
# Part 2: Verify language command execution (<cmd> cliHelpLine.<ext>)
# ==============================================================================
# Tests running each script with its language interpreter starter:
#   1. '<cmd> cliHelpLine.<ext> --help' -> must match header comments and stop at boundary
#   2. '<cmd> cliHelpLine.<ext>'        -> must fall through and print 'Hello world!'
# Examples: 'python3 cliHelpLine.py', 'gawk -E cliHelpLine.awk', 'node cliHelpLine.js'
if [ "$RUN_CMD" -eq 1 ]; then
    echo "--- Verifying language command execution (<cmd> cliHelpLine.<ext>) "
    cmd_skipped=()
    for target in "${files[@]}"; do
        target_name="$(basename "$target")"
        cmd_display=$(get_command_display "$target")
        bin_name="${cmd_display%% *}"  # Extract primary binary (e.g. 'gawk' from 'gawk -E')

        # Check if the runtime interpreter is available on the system
        if ! is_interpreter_available "$target"; then
            cmd_skipped+=("$target_name ('$bin_name' not installed)")
            skip_count=$((skip_count + 1))
            continue
        fi

        total_run=$((total_run + 1))

        # 1. Help output verification: --help must match header comments and stop
        extract_expected_help "$target" > "$expected_tmp"
        run_script_cmd "$target" "--help" > "$actual_tmp"

        if ! cmp -s "$expected_tmp" "$actual_tmp"; then
            printf "${RED}[FAIL]${RESET} %s %s (--help output mismatch)\n" "$cmd_display" "$target_name"
            fail_count=$((fail_count + 1))
            show_side_by_side "$expected_tmp" "$actual_tmp" \
                "Expected ($target_name headers)" "Actual ($cmd_display $target_name --help)"
            continue
        fi

        # 2. Running without --help: must execute main script and print 'Hello world!'
        run_script_cmd "$target" > "$run_actual_tmp"
        run_output=$(tr -d '\r' < "$run_actual_tmp" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ "$run_output" != "Hello world!" ]; then
            printf "${RED}[FAIL]${RESET} %s %s (running without --help failed: expected 'Hello world!', got '%s')\n" "$cmd_display" "$target_name" "$run_output"
            fail_count=$((fail_count + 1))
            continue
        fi

        pass_count=$((pass_count + 1))
        printf "${GREEN}[ OK ]${RESET} %s %s\n" "$cmd_display" "$target_name"
    done
    if [ "${#cmd_skipped[@]}" -gt 0 ]; then
        echo ""
        printf "Skipped: %s\n" "$(IFS=', '; echo "${cmd_skipped[*]}")"
    fi
    echo ""
fi

# ==============================================================================
# Part 3: Verify 2-line code snippet against README.md
# ==============================================================================
# Extracts the double-comment marker line and one-liner snippet from each script
# and compares them byte-for-byte against the fenced code block in README.md.
if [ "$RUN_README" -eq 1 ]; then
    echo "--- Verifying 2-line code snippet against README.md "
    if [ ! -f "$README_FILE" ]; then
        echo "Error: README.md not found at $README_FILE" >&2
        fail_count=$((fail_count + 1))
    else
        for target in "${files[@]}"; do
            total_run=$((total_run + 1))
            target_name="$(basename "$target")"
            lang=$(lang_for_file "$target")
            cc=$(get_comment_char "$target")
            if [ "$cc" = "REM" ]; then
                dcc="REM REM"
            else
                dcc="${cc}${cc}"
            fi

            extract_script_snippet "$target" "$dcc" > "$script_snip_tmp"
            extract_readme_snippet "$lang" "$README_FILE" > "$readme_snip_tmp"

            if [ ! -s "$readme_snip_tmp" ]; then
                printf "${RED}[FAIL]${RESET} %s (missing code block for '%s' in README.md)\n" "$target_name" "$lang"
                fail_count=$((fail_count + 1))
            elif cmp -s "$script_snip_tmp" "$readme_snip_tmp"; then
                pass_count=$((pass_count + 1))
                printf "${GREEN}[ OK ]${RESET} %s <-> README.md (%s)\n" "$target_name" "$lang"
            else
                printf "${RED}[FAIL]${RESET} %s <-> README.md (%s)\n" "$target_name" "$lang"
                fail_count=$((fail_count + 1))
                show_side_by_side "$script_snip_tmp" "$readme_snip_tmp" \
                    "Script ($target_name)" "README.md ($lang)"
            fi
        done
    fi
    echo ""
fi

echo ""
if [ "$fail_count" -eq 0 ]; then
    if [ "$skip_count" -gt 0 ]; then
        printf "${GREEN}All available tests passed ($pass_count/$pass_count)${RESET}\n"
    else
        printf "${GREEN}All tests passed ($pass_count/$pass_count)${RESET}\n"
    fi
    exit 0
else
    if [ "$skip_count" -gt 0 ]; then
        printf "${RED}$fail_count of $total_run tests failed ($skip_count skipped)${RESET}\n"
    else
        printf "${RED}$fail_count of $total_run tests failed${RESET}\n"
    fi
    exit 1
fi
