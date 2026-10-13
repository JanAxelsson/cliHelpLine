#!/usr/bin/env ruby
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.rb         # Run script
#   ./cliHelpLine.rb --help  # Help on script
#   ./cliHelpLine.rb -h      # Help on script
#   ./cliHelpLine.rb /?      # Help on script
#
# ... more help text ...

## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
if ARGV.any? { |a| %w[--help -h /?].include?(a) }; File.foreach(__FILE__).with_index { |l, i| next if i == 0 && l.start_with?('#!'); break if l.start_with?('##'); puts l.sub(/^# ?/, '').chomp if l.start_with?('#') || !l.strip.empty? }; exit 0; end



# Explanation
# if ARGV.any? { |a| %w[--help -h /?].include?(a) };                     # Check if ARGV contains --help, -h, or /?
#   File.foreach(__FILE__).with_index { |l, i|                           # Read this script file line by line with index
#     next if i == 0 && l.start_with?('#!');                             # Skip shebang on line 1
#     break if l.start_with?('##');                                      # Stop at double comment marker '##'
#     puts l.sub(/^# ?/, '').chomp if l.start_with?('#') || !l.strip.empty? # Strip '#' and optional space; ignore empty lines without '#'
#   };                                                                   # End of file iteration loop
#   exit 0;                                                              # Exit cleanly with status 0
# end


# Runnable code
puts "Hello world!"
