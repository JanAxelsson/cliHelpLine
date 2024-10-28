#!/usr/bin/env python
#
# Example script
# ==============
#
# Example help text
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
import sys, cliHelpLine_module
cliHelpLine_module.cliHelpLine(__file__, sys.argv)
# End Help


# Example code
print('Hello World!')
