#!/usr/bin/env perl
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.pl         # Run script
#   ./cliHelpLine.pl --help  # Help on script
#   ./cliHelpLine.pl -h      # Help on script
#   ./cliHelpLine.pl /?      # Help on script
#
# ... more help text ...

## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
if (grep { $_ eq '--help' || $_ eq '-h' || $_ eq '/?' } @ARGV) { open my $f, '<', $0; while (<$f>) { next if $. == 1 && /^#!/; last if /^##/; if (/^#/ || /\S/) { s/^# ?//; print; } } exit 0; }



# Explanation
# if (grep { $_ eq '--help' || $_ eq '-h' || $_ eq '/?' } @ARGV) { # Check if any command line argument matches --help, -h, or /?
#   open my $f, '<', $0;                                           # Open current script file ($0) for reading
#   while (<$f>) {                                                 # Iterate through file line by line
#     next if $. == 1 && /^#!/;                                    # Skip shebang line at line 1
#     last if /^##/;                                               # Stop reading when hitting '##' marker
#     if (/^#/ || /\S/) {                                          # Skip empty lines without comment character
#       s/^# ?//;                                                  # Remove leading '#' and one optional space
#       print;                                                     # Output formatted help line
#     }
#   }
#   exit 0;                                                        # Terminate script execution successfully
# }


# Runnable code
print "Hello world!\n";
