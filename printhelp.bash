#!/bin/bash
#
# Example script
# ==============
# 
# Example help text
#
# ./printhelp.bash -h
# ./printhelp.bash --help
#
# help text

## Help -- print file header until '##', ignore first row, remove leading '#'
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then sed '1d; /^##/q; s/^#//g; s/^ //g' $0 | sed '$d'; exit 0; fi 
## End Help


# Explanation
# if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then   # Run statement only if first argument being -h or --help
#    sed '1d;       # Delete first line
#    /^##/q;        # Discard everything from line starting with ##
#    s/^#//g;       # Replace # at beginning of line with ''
#    s/^ //g        # Replace ' ' at new beginning of line with ''
#    | sed '$d'     # Delete last line of  result
#    exit 0         # Exit script after help was printed 
# fi 


# Example code
echo "Hello world!"
echo "First argument was : $1"
