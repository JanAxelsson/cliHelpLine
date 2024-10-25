#!/usr/bin/env python
#
# Example script
# ==============
#
# Example help text
#
# python clihelp_using_module.py hello
# python clihelp_using_module.py -h
# python clihelp_using_module.py --help
#
# ./clihelp_using_module.py hello
# ./clihelp_using_module.py -h
# ./clihelp_using_module.py --help
#
# more help text


## Help -- print file header until '##', ignoring first row, removing leading '#'
import sys, clihelp_module
clihelp_module.clihelp(__file__, sys.argv)
# End Help


# Example code
print('Hello World!')
