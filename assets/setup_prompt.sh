#!/bin/bash
# Terminal styling for cliHelpLine demo recording
trap 'printf "\033[0m"' DEBUG

set_next_prompt() {
    export PS1=$'\n\033[1;32m$ '
}

# First prompt has no leading blank line (starts at row 1)
export PS1=$'\033[1;32m$ '
PROMPT_COMMAND="set_next_prompt"

cd assets 2>/dev/null || true
clear
