#!/usr/bin/env crystal
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.cr         # Run script
#   ./cliHelpLine.cr --help  # Help on script
#   ./cliHelpLine.cr -h      # Help on script
#   ./cliHelpLine.cr /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (ARGV & ["--help", "-h", "/?"]).any?; File.each_line(__FILE__) { |l| next if l.starts_with?("#!"); break if l.starts_with?("##"); puts l.starts_with?("#") ? l.sub(/^# ?/, "") : l if l.starts_with?("#") || !l.strip.empty? }; exit 0; end



# Explanation
# if (ARGV & ["--help", "-h", "/?"]).any?;                         # Check if any standard help flag exists inside ARGV
# File.each_line(__FILE__) { |l|                                   # Lazily stream lines of this source file
# next if l.starts_with?("#!");                                    # Skip shebang execution row if present at line 1
# break if l.starts_with?("##");                                   # Stop parsing immediately upon hitting the '##' marker
# puts l.starts_with?("#") ? l.sub(/^# ?/, "") : l                 # Strip leading '#' and one optional following space
# if l.starts_with?("#") || !l.strip.empty?                        # Delete and ignore empty lines without comment characters
# }; exit 0; end                                                   # Stop execution and exit 0 without running main program body


# Runnable code
puts "Hello world!"
