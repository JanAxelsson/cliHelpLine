import os
import re


def cliHelpLine(file, sysargs):
    # Use in python command line script :
    #   import sys, cliHelpLine_module
    #   cliHelpLine( __file__, sys.argv)

    if len(sysargs) > 1 and (sysargs[1] == '-h' or sysargs[1] == '--help'):
        f = open(os.path.realpath(file), 'r').read().split('##')[0]  # Read file until ##
        f = re.sub(r'^\s*[\r\n]+', '', f, flags=re.MULTILINE)  # Remove blank lines
        f = f.split('\n#')[1:]  # Split at '\n#', and remove first line
        f = "\n".join([i[1:] for i in f])  # Skipping first character for each line, and join with end-of-lines
        print(f)
        quit()
