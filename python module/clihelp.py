#!/usr/bin/env python
#
# Example script
# ==============
#
# Example help text
#
# python clihelp.py hello
# python clihelp.py -h
# python clihelp.py --help
#
# ./clihelp.py hello
# ./clihelp.py -h
# ./clihelp.py --help
#
# more help text


## Help -- print file header until '##', ignoring first row, removing leading '#'
import sys, clihelp_module
clihelp_module.clihelp(__file__, sys.argv)
# End Help


# Example code
print('Hello World!')
