#!/bin/sh
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.sh         # Run script
#   ./cliHelpLine.sh --help  # Help on script
#   ./cliHelpLine.sh -h      # Help on script
#   ./cliHelpLine.sh /?      # Help on script
#
# ... more help text ...

## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi



# Explanation
# if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then        # Check if the very first script argument matches --help, -h, or Windows /?
#    sed -e '1{/^#!/d;}' ... "$0"                                            # Open current script ("$0") and dynamically delete the shebang row if found at line 1
#    ... -e '/^##/q' ...                                                     # Quit processing immediately when reaching the closing '##' tag (acting as our stream break)
#    ... -e '/^\s*$/d' ...                                                   # Delete and ignore empty lines without comment characters (e.g. before '##')
#    ... -e 's/^#//g' -e 's/^ //g' ...                                       # Clean the output by removing the leading '#' character and one leading space
#    ... | sed '$d';                                                         # Pipe the result to a second sed instance to delete the very last line (removing the '##' marker itself)
#    exit 0;                                                                 # Terminate the shell script successfully after outputting the help section
# fi


# Runnable code
echo "Hello world!"
