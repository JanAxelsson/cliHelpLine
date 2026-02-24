#!/usr/bin/env python
#
# Example script
# ==============
#
# Example help text
#
# Example use :
#
# python cliHelpLine.py hello
# python cliHelpLine.py -h
# python cliHelpLine.py --help
#
# ./cliHelpLine.py hello
# ./cliHelpLine.py -h
# ./cliHelpLine.py --help
#
# more help text



## Help -- print file header until '##', ignoring first row, removing leading '#'
import sys, re
if sys.argv[1:]and sys.argv[1]in['-h','--help']:
    f=open(__file__).read().split('##')[0];f=re.sub(r'^\s*[\r\n]+','',f,flags=re.MULTILINE);f=f.split('\n#')[1:];f="\n".join([i[1:] for i in f]);print(f);quit()
# End Help



# Explanation
# import os, sys, re                                          # Import from Python Standard Library
# if sys.argv[1:]and sys.argv[1]in['-h','--help']:            # Run statement only if first argument is -h or --help
#    f=open(__file__).read().split('##')[0]                   # Read current script file until ##
#    f = re.sub(r'^\s*[\r\n]+', '', f, flags=re.MULTILINE);   # Remove blank lines
#    f = f.split('\n#')[1:];                                  # Split at '\n#', and remove first line
#    f = "\n".join( [ i[1:] for i in f ] );                   # Skipping first character for each line, and join with end-of-lines
#    print( f )                                               # Print resulting help text
#    quit()                                                   # Exit script after printing help


# Example code
print('Hello World!')
