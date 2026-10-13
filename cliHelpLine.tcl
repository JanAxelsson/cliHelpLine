#!/usr/bin/env tclsh
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.tcl         # Run script
#   ./cliHelpLine.tcl --help  # Help on script
#   ./cliHelpLine.tcl -h      # Help on script
#   ./cliHelpLine.tcl /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if {[expr {[lsearch -exact $argv "--help"] >= 0 || [lsearch -exact $argv "-h"] >= 0 || [lsearch -exact $argv "/?"] >= 0}]} { set fp [open $argv0 r]; set nr 0; while {[gets $fp line] >= 0} { incr nr; if {$nr == 1 && [string match "#!*" $line]} continue; if {[string match "##*" $line]} break; if {[string match "#*" $line] || [string trim $line] ne ""} { puts [regsub {^# ?} $line ""] } }; close $fp; exit 0 }



# Explanation
# if {[expr {[lsearch -exact $argv "--help"] >= 0 ...}]} {                # Check if $argv contains --help, -h, or /?
#   set fp [open $argv0 r];                                              # Open current script file ($argv0) for reading
#   set nr 0;                                                            # Initialize line counter
#   while {[gets $fp line] >= 0} {                                       # Read file line by line
#     incr nr;                                                           # Increment line count
#     if {$nr == 1 && [string match "#!*" $line]} continue;              # Skip shebang on line 1
#     if {[string match "##*" $line]} break;                             # Break at double comment marker '##'
#     if {[string match "#*" $line] || [string trim $line] ne ""} {      # Ignore blank lines without '#'
#       puts [regsub {^# ?} $line ""]                                    # Strip '#' and optional space, then print line
#     }
#   };                                                                   # End of loop
#   close $fp;                                                           # Close file handle
#   exit 0                                                               # Terminate script cleanly
# }


# Runnable code
puts "Hello world!"
