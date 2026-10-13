#!/usr/bin/env julia
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.jl         # Run script
#   ./cliHelpLine.jl --help  # Help on script
#   ./cliHelpLine.jl -h      # Help on script
#   ./cliHelpLine.jl /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if any(in(["--help", "-h", "/?"]), ARGS); for l in eachline(@__FILE__); startswith(l, "#!") && continue; startswith(l, "##") && exit(0); (startswith(l, "#") || !isempty(strip(l))) && println(startswith(l, "#") ? replace(l, r"^# ?"=>"") : l); end; exit(0); end



# Explanation
# if any(in(["--help", "-h", "/?"]), ARGS);                       # Check if any standard help flag exists inside ARGS
# for l in eachline(@__FILE__);                                    # Lazily iterate through lines of this source file
# startswith(l, "#!") && continue;                                 # Skip shebang interpreter line at line 1
# startswith(l, "##") && exit(0);                                  # Stop printing immediately upon encountering the '##' boundary marker
# (startswith(l, "#") || !isempty(strip(l))) &&                    # Delete and ignore empty lines without comment characters
# println(startswith(l, "#") ? replace(l, r"^# ?"=>"") : l);      # Strip leading '#' and one optional space from comments, print code lines as-is
# end; exit(0); end                                                # Terminate loop and exit 0 without running the main script body


# Runnable code
println("Hello world!")
