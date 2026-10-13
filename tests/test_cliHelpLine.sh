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
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
README_FILE="$PROJECT_ROOT/README.md"

# Function to run a cliHelpLine script with --help
run_script_help() {
    local target="$1"
    local help_flag="${2:---help}"
    local ext="${target##*.}"
    local output

    # 1. Try direct execution if executable
    if [ -x "$target" ]; then
        if output=$( RUBYOPT="--disable-gems" "$target" "$help_flag" 2>/dev/null ); then
            printf "%s\n" "$output"
            return 0
        fi
    fi

    # 2. Fall back to interpreter based on file extension
    case "$ext" in
        bash)
            bash "$target" "$help_flag" 2>/dev/null ;;
        sh)
            sh "$target" "$help_flag" 2>/dev/null ;;
        zsh)
            zsh "$target" "$help_flag" 2>/dev/null ;;
        fish)
            fish "$target" "$help_flag" 2>/dev/null ;;
        py)
            if command -v python3 >/dev/null 2>&1 && output=$(python3 "$target" "$help_flag" 2>/dev/null); then
                printf "%s\n" "$output"
            elif [ -x /opt/homebrew/bin/python3 ]; then
                /opt/homebrew/bin/python3 "$target" "$help_flag" 2>/dev/null
            elif [ -x /usr/bin/python3 ]; then
                /usr/bin/python3 "$target" "$help_flag" 2>/dev/null
            elif command -v python >/dev/null 2>&1; then
                python "$target" "$help_flag" 2>/dev/null
            fi ;;
        js|mjs|cjs)
            if command -v node >/dev/null 2>&1 && output=$(node "$target" "$help_flag" 2>/dev/null); then
                printf "%s\n" "$output"
            elif [ -x /usr/local/bin/node ]; then
                /usr/local/bin/node "$target" "$help_flag" 2>/dev/null
            elif [ -x /opt/homebrew/bin/node ]; then
                /opt/homebrew/bin/node "$target" "$help_flag" 2>/dev/null
            fi ;;
        rb)
            RUBYOPT="--disable-gems" ruby --disable-gems "$target" "$help_flag" 2>/dev/null ;;
        pl)
            perl "$target" "$help_flag" 2>/dev/null ;;
        php)
            php "$target" "$help_flag" 2>/dev/null ;;
        lua)
            lua "$target" "$help_flag" 2>/dev/null || lua5.4 "$target" "$help_flag" 2>/dev/null ;;
        r|R)
            Rscript "$target" "$help_flag" 2>/dev/null ;;
        ps1)
            pwsh -NoProfile -File "$target" "$help_flag" 2>/dev/null ;;
        tcl)
            tclsh "$target" "$help_flag" 2>/dev/null ;;
        awk)
            if command -v gawk >/dev/null 2>&1; then
                gawk -f "$target" -- "$help_flag" 2>/dev/null
            elif command -v awk >/dev/null 2>&1; then
                awk -f "$target" -- "$help_flag" 2>/dev/null
            fi ;;
        *)
            "$target" "$help_flag" 2>/dev/null ;;
    esac
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
        *)    return 0 ;;
    esac
}

get_interpreter_name() {
    local ext="${1##*.}"
    case "$ext" in
        bash)       echo "bash" ;;
        sh)         echo "sh" ;;
        zsh)        echo "zsh" ;;
        fish)       echo "fish" ;;
        py)         echo "python3" ;;
        js|mjs|cjs) echo "node" ;;
        rb)         echo "ruby" ;;
        pl)         echo "perl" ;;
        php)        echo "php" ;;
        lua)        echo "lua" ;;
        r|R)        echo "Rscript" ;;
        ps1)        echo "pwsh" ;;
        tcl)        echo "tclsh" ;;
        awk)        echo "gawk" ;;
        *)          echo "$ext" ;;
    esac
}

# Map file extension to language identifier in README.md
lang_for_file() {
    local ext="${1##*.}"
    case "$ext" in
        bash)       echo "bash" ;;
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
        *)          echo "$ext" ;;
    esac
}

# Extract comment character from line 2
get_comment_char() {
    local file="$1"
    local line2
    line2=$(sed -n "2p" "$file")
    local trimmed="${line2#"${line2%%[![:space:]]*}"}"
    echo "${trimmed%% *}"
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

        # Skip line 1 (shebang)
        if [ "$lineno" -eq 1 ]; then
            continue
        fi

        # Line 2: Identify comment character and double-comment marker
        if [ "$lineno" -eq 2 ]; then
            local trimmed="${line#"${line%%[![:space:]]*}"}"
            comment_char="${trimmed%% *}"
            if [ -z "$comment_char" ]; then
                echo "Error: Could not identify comment character on line 2 in $file" >&2
                return 1
            fi
            double_comment="${comment_char}${comment_char}"
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
RUN_HELP=1
RUN_README=1
filtered_args=()

for arg in "$@"; do
    case "$arg" in
        --help-only)
            RUN_README=0
            ;;
        --readme-only)
            RUN_HELP=0
            ;;
        *)
            filtered_args+=("$arg")
            ;;
    esac
done

# Determine files to test
files=()
if [ "${#filtered_args[@]}" -gt 0 ]; then
    for arg in "${filtered_args[@]}"; do
        arg_clean="${arg#.}"
        if [ -f "$arg" ]; then
            files+=("$arg")
        elif [ -f "$PROJECT_ROOT/$arg" ]; then
            files+=("$PROJECT_ROOT/$arg")
        elif [ -f "$PROJECT_ROOT/cliHelpLine.$arg_clean" ]; then
            files+=("$PROJECT_ROOT/cliHelpLine.$arg_clean")
        else
            # Match against language name (e.g. 'python' -> cliHelpLine.py)
            matched=""
            for f in "$PROJECT_ROOT"/cliHelpLine.*; do
                [ -f "$f" ] || continue
                lang=$(lang_for_file "$f")
                if [ "$lang" = "$arg" ]; then
                    files+=("$f")
                    matched=1
                    break
                fi
            done
            if [ -z "$matched" ]; then
                echo "Warning: No test file found for '$arg'" >&2
            fi
        fi
    done
else
    for f in "$PROJECT_ROOT"/cliHelpLine.*; do
        [ -f "$f" ] || continue
        # Skip the test script itself or temporary files
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

total_count=0
fail_count=0
skip_count=0

expected_tmp=$(mktemp)
actual_tmp=$(mktemp)
script_snip_tmp=$(mktemp)
readme_snip_tmp=$(mktemp)
trap 'rm -f "$expected_tmp" "$actual_tmp" "$script_snip_tmp" "$readme_snip_tmp"' EXIT

# --- Part 1: Verify output from --help against header ---
if [ "$RUN_HELP" -eq 1 ]; then
    echo "--- Verifying header against --help output ---"
    for target in "${files[@]}"; do
        total_count=$((total_count + 1))
        target_name="$(basename "$target")"

        if ! is_interpreter_available "$target"; then
            interp=$(get_interpreter_name "$target")
            printf "${YELLOW}[SKIP]${RESET} %s ('%s' not installed)\n" "$target_name" "$interp"
            skip_count=$((skip_count + 1))
            continue
        fi

        extract_expected_help "$target" > "$expected_tmp"
        run_script_help "$target" "--help" > "$actual_tmp"

        if cmp -s "$expected_tmp" "$actual_tmp"; then
            printf "${GREEN}[ OK ]${RESET} %s\n" "$target_name"
        else
            printf "${RED}[FAIL]${RESET} %s\n" "$target_name"
            fail_count=$((fail_count + 1))
            show_side_by_side "$expected_tmp" "$actual_tmp" \
                "Expected ($target_name headers)" "Actual ($target_name --help)"
        fi
    done
    echo ""
fi

# --- Part 2: Verify comment + one-liner against README.md ---
if [ "$RUN_README" -eq 1 ]; then
    echo "--- Verifying 2-line code snippet against README.md ---"
    if [ ! -f "$README_FILE" ]; then
        echo "Error: README.md not found at $README_FILE" >&2
        fail_count=$((fail_count + 1))
    else
        for target in "${files[@]}"; do
            total_count=$((total_count + 1))
            target_name="$(basename "$target")"
            lang=$(lang_for_file "$target")
            cc=$(get_comment_char "$target")
            dcc="${cc}${cc}"

            extract_script_snippet "$target" "$dcc" > "$script_snip_tmp"
            extract_readme_snippet "$lang" "$README_FILE" > "$readme_snip_tmp"

            if [ ! -s "$readme_snip_tmp" ]; then
                printf "${RED}[FAIL]${RESET} %s (missing code block for '%s' in README.md)\n" "$target_name" "$lang"
                fail_count=$((fail_count + 1))
            elif cmp -s "$script_snip_tmp" "$readme_snip_tmp"; then
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
        printf "${GREEN}All available tests passed ($((total_count - skip_count))/$total_count, $skip_count skipped)${RESET}\n"
    else
        printf "${GREEN}All tests passed ($total_count/$total_count)${RESET}\n"
    fi
    exit 0
else
    if [ "$skip_count" -gt 0 ]; then
        printf "${RED}$fail_count of $total_count tests failed ($skip_count skipped)${RESET}\n"
    else
        printf "${RED}$fail_count of $total_count tests failed${RESET}\n"
    fi
    exit 1
fi
