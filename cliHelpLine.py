#!/usr/bin/env python
#
# Example script
# ==============
#
# This is my help text ...
#
# Example use :
#
# python cliHelpLine.py hello
# python cliHelpLine.py --help
# python cliHelpLine.py -h
# python cliHelpLine.py /?
#
# ./cliHelpLine.py hello
# ./cliHelpLine.py --help
# ./cliHelpLine.py -h
# ./cliHelpLine.py /?
#
# ... more help text ...


## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
import sys; [print(line[1:].strip() if line.startswith('#') else line.strip()) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0))] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa
# End Help



# Explanation
#
# import sys;                                                 # Import system module to access arguments and exit the script
# if any(arg in sys.argv for arg in ('--help', '-h', '/?')) \ # Run only if any of the help flags are present in command line args
# else None                                                   # Do nothing if no help flag is found (fallback of the ternary operator)
# [ ... for line in open(__file__, encoding='utf-8') ... ]    # List comprehension opening the current script file and reading line by line
# if not line.startswith('#!')                                # Skip the shebang line (e.g., #!/usr/bin/env python) if present
# and (not line.startswith('##')                              # Continue processing as long as the line does not start with ##
# or sys.exit(0))                                             # If a line starts with ##, trigger sys.exit(0) to stop immediately
# print(line[1:].strip() if line.startswith('#')              # If line is a comment, strip the '#' and whitespace, then print it
# else line.strip())                                          # Otherwise print the stripped line (runs until sys.exit hits)
# # noqa                                                       # Tell linters to ignore PEP 8 line-length violations for this line





# Example code
print('Hello World!')
