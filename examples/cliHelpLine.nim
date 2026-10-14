#!/usr/bin/env -S nim r --hints:off
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.nim         # Run script
#   ./cliHelpLine.nim --help  # Help on script
#   ./cliHelpLine.nim -h      # Help on script
#   ./cliHelpLine.nim /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
import std/[os, sequtils, strutils]; if ["--help", "-h", "/?"].anyIt(it in commandLineParams()): (for l in currentSourcePath().lines: (if l.startsWith("#!"): continue elif l.startsWith("##"): quit(0) elif l.startsWith("#"): (if l.len > 1 and l[1] == ' ': echo l[2..^1] else: echo l[1..^1]) elif l.strip != "": echo l)); quit(0)



# Explanation
# import std/[os, sequtils, strutils];                             # Import standard OS, sequence, and string modules
# if ["--help", "-h", "/?"].anyIt(it in commandLineParams()):      # Check if any command-line parameter matches help flags
# (for l in currentSourcePath().lines:                             # Iterate through lines of current source file
# if l.startsWith("#!"): continue                                  # Skip shebang line at line 1
# elif l.startsWith("##"): quit(0)                                 # Exit immediately upon reaching '##' boundary
# elif l.startsWith("#"):                                          # Strip leading '#' and optional following space:
# (if l.len > 1 and l[1] == ' ': echo l[2..^1] else: echo l[1..^1])
# elif l.strip != "": echo l));                                    # Preserve non-empty code lines
# quit(0)                                                          # Exit 0 cleanly without executing main program body


# Runnable code
echo "Hello world!"
