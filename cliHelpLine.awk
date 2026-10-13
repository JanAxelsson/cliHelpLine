#!/usr/bin/gawk -E
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.awk         # Run script
#   ./cliHelpLine.awk --help  # Help on script
#   ./cliHelpLine.awk -h      # Help on script
#   ./cliHelpLine.awk /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
BEGIN { for (i in ARGV) if (ARGV[i] ~ /^(--help|-h|\/\?)$/) { for (a in PROCINFO["argv"]) if (PROCINFO["argv"][a] ~ /^-[fE]$/) f=PROCINFO["argv"][a+1]; while ((getline l < f) > 0) { if (++nr == 1 && l ~ /^#!/ ) continue; if (l ~ /^##/) break; if (l ~ /^#/ || l ~ /\S/) { sub(/^# ?/, "", l); print l } } exit 0 } }



# Explanation
# BEGIN {
#   for (i in ARGV) if (ARGV[i] ~ /^(--help|-h|\/\?)$/) {                # Check if arguments contain help flags
#     for (a in PROCINFO["argv"]) if (PROCINFO["argv"][a] ~ /^-[fE]$/)   # Scan invocation args for -f or -E flag
#       f = PROCINFO["argv"][a+1];                                       # Extract script file path
#     while ((getline l < f) > 0) {                                      # Read script lines sequentially
#       if (++nr == 1 && l ~ /^#!/ ) continue;                           # Skip shebang line on line 1
#       if (l ~ /^##/) break;                                            # Stop when reaching '##' marker
#       if (l ~ /^#/ || l ~ /\S/) {                                      # Skip empty lines without comment char
#         sub(/^# ?/, "", l);                                            # Remove '#' and one optional space
#         print l;                                                       # Output formatted help line
#       }
#     }
#     exit 0;                                                            # Exit AWK process successfully
#   }
# }


# Runnable code
BEGIN { print "Hello world!" }
