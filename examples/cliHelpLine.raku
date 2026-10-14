#!/usr/bin/env raku
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.raku         # Run script
#   ./cliHelpLine.raku --help  # Help on script
#   ./cliHelpLine.raku -h      # Help on script
#   ./cliHelpLine.raku /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if @*ARGS.any eq ('--help' | '-h' | '/?') { for $?FILE.IO.lines { next if .starts-with('#!'); last if .starts-with('##'); say .starts-with('#') ?? .subst(/^ '#' ' '? /, '') !! $_ if .starts-with('#') || .trim ne ''; }; exit 0; }



# Explanation
# if @*ARGS.any eq ('--help' | '-h' | '/?') {                          # Check if any command line argument matches --help, -h, or /?
#   for $?FILE.IO.lines {                                              # Iterate through lines of current script file ($?FILE)
#     next if .starts-with('#!');                                      # Skip shebang line if present at line 1
#     last if .starts-with('##');                                      # Stop reading when hitting '##' boundary marker
#     say .starts-with('#') ?? .subst(/^ '#' ' '? /, '') !! $_         # Strip leading '#' and one optional space, preserving indentation
#       if .starts-with('#') || .trim ne '';                           # Skip empty lines without comment character
#   };
#   exit 0;                                                            # Terminate script execution successfully
# }


# Runnable code
say "Hello world!";
