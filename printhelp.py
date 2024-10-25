#!/usr/bin/env python
#
# Example script
# ==============
#
# Example help text
#
# python printhelp.py hello
# python printhelp.py -h
# python printhelp.py --help
#
# more help text
#
# ./printhelp.py hello
# ./printhelp.py -h
# ./printhelp.py --help
#
# even more help text

## Help -- print file header until '##', ignoring first row, removing leading '#'
import os, sys
if len(sys.argv) > 1 and (sys.argv[1] == '-h' or sys.argv[1] == '--help'):
    print(*open(os.path.realpath(__file__), 'r', encoding='utf-8').read().split('##')[0].split('\n#')[1:], sep='\n'); quit()
# End Help


# Explanation
# import os, sys                                # Import from Python Standard Library
# if len(sys.argv) > 1 and (sys.argv[1] == '-h' or sys.argv[1] == '--help'):    # Run statement only if non-empty first argument is -h or --help
#    result1= open( os.path.realpath(__file__), 'r', encoding='utf-8' ).read()  # Read current script file
#    result2 = result1.split('##')[0]           # Keep part before '##'
#    result3 = result2.split('\n#')[1:]         # Split at character '#' at beginning of line (gives list), and keep all but first line
#    print(*result3, sep='\n' )                 # Print list items on new rows (\n was removed in previous step)
#    quit()                                     # Exit script after printing help


# Example code
print('Hello World!')
if len(sys.argv) > 1 :
    print('First argument was : ', sys.argv[1])
