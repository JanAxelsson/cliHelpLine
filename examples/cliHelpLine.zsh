#!/usr/bin/env zsh
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.zsh         # Run script
#   ./cliHelpLine.zsh --help  # Help on script
#   ./cliHelpLine.zsh -h      # Help on script
#   ./cliHelpLine.zsh /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi



# Explanation
# if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then        # Check if the first argument matches --help, -h, or /?
#    sed -e '1{/^#!/d;}' ... "$0"                                            # Read current script ($0) and delete shebang on line 1
#    ... -e '/^##/q' ...                                                     # Stop processing when reaching '##'
#    ... -e '/^[[:space:]]*$/d' ...                                          # Delete empty lines without comment characters
#    ... -e 's/^#//g' -e 's/^ //g' ...                                       # Remove leading '#' and one optional leading space
#    ... | sed '$d';                                                         # Strip the last line (the '##' line itself)
#    exit 0;                                                                 # Exit successfully after printing help
# fi


# Runnable code
echo "Hello world!"
