#!/usr/bin/env python
#
# Example script
# ==============
#
# This is my help text ...
#
# Example use :
#
#   python cliHelpLine.py hello
#   python cliHelpLine.py --help
#   python cliHelpLine.py -h
#   python cliHelpLine.py /?
#
#   ./cliHelpLine.py hello
#   ./cliHelpLine.py --help
#  ./cliHelpLine.py -h
#   ./cliHelpLine.py /?
#
# ... more help text ...

## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
import sys, re; [print(re.sub(r'^# ?', '', line.rstrip('\r\n')) if line.startswith('#') else line.rstrip('\r\n')) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0))] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa# End Help



# Explanation
# import sys, re;                                             # Import sys for CLI args/exiting, and re for regular expression substitutions
# if any(arg in sys.argv for arg in ('--help', '-h', '/?')) \ # Check if any standard help flag exists inside the command line arguments
# else None                                                   # Fallback condition for the ternary operator if no help flags are present
# [ ... for line in open(__file__, encoding='utf-8') ... ]    # List comprehension that opens and iterates through this script line by line
# if not line.startswith('#!')                                # Skip over the environment shebang execution line if it is present
# and (not line.startswith('##')                              # Keep parsing lines sequentially as long as the '##' divider isn't hit
# or sys.exit(0))                                             # Short-circuit trigger: if '##' is hit, instantly kill the script process
# print(re.sub(r'^# ?', '', line.rstrip('\r\n'))             # Clean trailing newlines, then strip starting '#' and exactly ONE optional space
# if line.startswith('#')                                     # Only apply the character substitution rule if the current row is a comment
# else line.rstrip('\r\n'))                                   # If it is a normal code line, just drop the trailing newline characters
# # noqa                                                       # Instruct automated code linters to overlook PEP 8 line length boundaries         




# Example code
print('Hello World!')
