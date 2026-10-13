#!/usr/bin/env fish
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.fish         # Run script
#   ./cliHelpLine.fish --help  # Help on script
#   ./cliHelpLine.fish -h      # Help on script
#   ./cliHelpLine.fish /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if contains -- "$argv[1]" --help -h '/?'; sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' (status filename) | sed '$d'; exit 0; end



# Explanation
# if contains -- "$argv[1]" --help -h '/?';                             # Check if first argument matches --help, -h, or '/?'
#    sed -e '1{/^#!/d;}' ... (status filename)                           # Open script via (status filename) and delete shebang at line 1
#    ... -e '/^##/q' ...                                                 # Stop processing when reaching '##'
#    ... -e '/^\s*$/d' ...                                               # Delete empty lines without comment characters
#    ... -e 's/^#//g' -e 's/^ //g' ...                                   # Remove leading '#' and one optional leading space
#    ... | sed '$d';                                                     # Strip the last line ('##' marker)
#    exit 0;                                                             # Exit cleanly after printing help
# end


# Runnable code
echo "Hello world!"
