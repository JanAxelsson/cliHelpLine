#!/bin/bash
#
# Example script
# ==============
# 
# Example help text
#
# ./printhelp.bash -h      # Help on script
# ./printhelp.bash --help  # Help on script
# ./printhelp.bash         # Run script
#
# help text
# help text




## Help -- print file header until '##', ignore first row, remove leading '# '
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then sed '1d; /^##/q; /^\s*$/d; s/^#//g; s/^ //g' $0 | sed '$d'; exit 0; fi 
## End Help


# Explanation
# if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then   # Run statement only if first argument being -h or --help
#    sed '1d;       # Delete first line
#    /^##/q;        # Discard everything from line starting with ##
#    /^\s*$/d;      # Delete blank lines at end (between comments and ##)
#    s/^#//g;       # Remove #
#    s/^ //g        # Remove first ' '
#    | sed '$d'     # Delete last line of result (## line)
#    exit 0         # Exit script after help was printed 
# fi 


# Runnable code
echo "Hello world!"
echo "First argument was : $1"
