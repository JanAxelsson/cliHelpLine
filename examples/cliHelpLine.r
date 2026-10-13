#!/usr/bin/env Rscript
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.r         # Run script
#   ./cliHelpLine.r --help  # Help on script
#   ./cliHelpLine.r -h      # Help on script
#   ./cliHelpLine.r /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (any(commandArgs(trailingOnly=FALSE) %in% c("--help", "-h", "/?"))) { l <- readLines(sub("^--file=", "", grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)[1]), warn=FALSE); for (x in l[-1]) { if (startsWith(x, "##")) break; if (startsWith(x, "#") || nzchar(trimws(x))) cat(sub("^# ?", "", x), "\n", sep=""); }; quit(save="no", status=0); }



# Explanation
# if (any(commandArgs(trailingOnly=FALSE) %in% c("--help", "-h", "/?"))) { # Check if command-line arguments contain help flags
#   f <- sub("^--file=", "", grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)[1]) # Resolve path to this script
#   l <- readLines(f, warn=FALSE)                                          # Read all lines from file
#   for (x in l[-1]) {                                                     # Loop over all lines skipping line 1 (shebang)
#     if (startsWith(x, "##")) break                                       # Stop at closing marker '##'
#     if (startsWith(x, "#") || nzchar(trimws(x)))                         # Skip blank lines without '#'
#       cat(sub("^# ?", "", x), "\n", sep="")                              # Strip '#' and optional space, then print line
#   }
#   quit(save="no", status=0)                                              # Exit R process without saving workspace
# }


# Runnable code
cat("Hello world!\n")
