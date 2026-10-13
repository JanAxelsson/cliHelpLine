#!/usr/bin/env bash
#
# Test-skript för cliHelpLine.*
# 1. Verifierar att output från 'cliHelpLine.* --help' matchar rad 2 fram till
#    första raden med dubbelkommentar, med kommentarstecken och ett space borttaget
#    (samt att tomma rader utan kommentarstecken ignoreras).
# 2. Verifierar att skriptens två rader (dubbelkommentar + one-liner) stämmer
#    överens med kodsnutten i README.md för respektive språk.
#

set -u

# Färger
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
README_FILE="$PROJECT_ROOT/README.md"

# Funktion för att köra ett cliHelpLine-skript med --help
run_script_help() {
    local target="$1"
    local help_flag="${2:---help}"
    local ext="${target##*.}"
    local output

    # 1. Försök att köra direkt om filen är körbar
    if [ -x "$target" ]; then
        if output=$( "$target" "$help_flag" 2>/dev/null ); then
            printf "%s\n" "$output"
            return 0
        fi
    fi

    # 2. Fallback till tolk baserat på filändelse
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
            ruby "$target" "$help_flag" 2>/dev/null ;;
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
            awk -f "$target" -- "$help_flag" 2>/dev/null ;;
        *)
            "$target" "$help_flag" 2>/dev/null ;;
    esac
}

# Identifiera språknamn från filändelse för matchning mot README.md
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

# Extrahera kommentarstecken från rad 2
get_comment_char() {
    local file="$1"
    local line2
    line2=$(sed -n "2p" "$file")
    local trimmed="${line2#"${line2%%[![:space:]]*}"}"
    echo "${trimmed%% *}"
}

# Funktion för att generera förväntad hjälptext enligt specifikationen
extract_expected_help() {
    local file="$1"
    local lineno=0
    local comment_char=""
    local double_comment=""

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        lineno=$((lineno + 1))

        # Hoppa över rad 1 (shebang)
        if [ "$lineno" -eq 1 ]; then
            continue
        fi

        # Rad 2: Identifiera kommentarstecken och dubbelkommentar
        if [ "$lineno" -eq 2 ]; then
            local trimmed="${line#"${line%%[![:space:]]*}"}"
            comment_char="${trimmed%% *}"
            if [ -z "$comment_char" ]; then
                echo "Fel: Kunde inte identifiera kommentarstecken på rad 2 i $file" >&2
                return 1
            fi
            double_comment="${comment_char}${comment_char}"
        fi

        # Avsluta vid första raden med dubbelkommentar
        if [[ "$line" == "$double_comment"* ]]; then
            break
        fi

        # Hoppa över tomma rader utan kommentarstecken
        if [[ "$line" =~ ^[[:space:]]*$ ]] && [[ "$line" != *"$comment_char"* ]]; then
            continue
        fi

        # Ta bort kommentar och ett space och skriv ut resten av raden
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

# Extrahera de 2 raderna (dubbelkommentar + one-liner) från skriptet
extract_script_snippet() {
    local file="$1"
    local double_comment="$2"
    awk -v dcc="$double_comment" '
        BEGIN { found = 0 }
        $0 ~ "^" dcc { found = 1; print; next }
        found == 1 { print; exit }
    ' "$file"
}

# Extrahera de 2 raderna för ett språk från README.md
extract_readme_snippet() {
    local lang="$1"
    local readme="$2"
    awk -v lang="$lang" '
        BEGIN { in_block = 0; count = 0 }
        tolower($0) ~ "^```" tolower(lang) "$" { in_block = 1; next }
        in_block && /^```/ { exit }
        in_block && count < 2 { print; count++ }
    ' "$readme"
}

# Visa side-by-side diff med radnummer
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

# Hämta filer att testa
files=()
if [ "$#" -gt 0 ]; then
    for arg in "$@"; do
        if [ -f "$arg" ]; then
            files+=("$arg")
        elif [ -f "$PROJECT_ROOT/$arg" ]; then
            files+=("$PROJECT_ROOT/$arg")
        fi
    done
else
    for f in "$PROJECT_ROOT"/cliHelpLine.*; do
        [ -f "$f" ] || continue
        # Hoppa över test-skriptet självt eller temporära filer
        case "$(basename "$f")" in
            *test*|*.tmp|*.bak|*.swp) continue ;;
        esac
        files+=("$f")
    done
fi

if [ "${#files[@]}" -eq 0 ]; then
    echo "Inga cliHelpLine-filer hittades att testa." >&2
    exit 1
fi

total_count=0
fail_count=0

expected_tmp=$(mktemp)
actual_tmp=$(mktemp)
script_snip_tmp=$(mktemp)
readme_snip_tmp=$(mktemp)
trap 'rm -f "$expected_tmp" "$actual_tmp" "$script_snip_tmp" "$readme_snip_tmp"' EXIT

# --- Del 1: Verifierar output från --help mot header ---
echo "--- Test 1: Verifierar header mot --help output ---"
for target in "${files[@]}"; do
    total_count=$((total_count + 1))
    target_name="$(basename "$target")"

    extract_expected_help "$target" > "$expected_tmp"
    run_script_help "$target" "--help" > "$actual_tmp"

    if cmp -s "$expected_tmp" "$actual_tmp"; then
        printf "${GREEN}[ OK ]${RESET} %s\n" "$target_name"
    else
        printf "${RED}[FAIL]${RESET} %s\n" "$target_name"
        fail_count=$((fail_count + 1))
        show_side_by_side "$expected_tmp" "$actual_tmp" \
            "Förväntad ($target_name headers)" "Faktisk ($target_name --help)"
    fi
done

echo ""

# --- Del 2: Verifierar kommentar + one-liner mot README.md ---
echo "--- Test 2: Verifierar 2-raders kodsnutt mot README.md ---"
if [ ! -f "$README_FILE" ]; then
    echo "Fel: README.md hittades inte på $README_FILE" >&2
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
            printf "${RED}[FAIL]${RESET} %s (saknar kodblock för '%s' i README.md)\n" "$target_name" "$lang"
            fail_count=$((fail_count + 1))
        elif cmp -s "$script_snip_tmp" "$readme_snip_tmp"; then
            printf "${GREEN}[ OK ]${RESET} %s <-> README.md (%s)\n" "$target_name" "$lang"
        else
            printf "${RED}[FAIL]${RESET} %s <-> README.md (%s)\n" "$target_name" "$lang"
            fail_count=$((fail_count + 1))
            show_side_by_side "$script_snip_tmp" "$readme_snip_tmp" \
                "Skript ($target_name)" "README.md ($lang)"
        fi
    done
fi

echo ""
if [ "$fail_count" -eq 0 ]; then
    printf "${GREEN}Alla tester passerade ($total_count/$total_count)${RESET}\n"
    exit 0
else
    printf "${RED}$fail_count av $total_count tester misslyckades${RESET}\n"
    exit 1
fi
