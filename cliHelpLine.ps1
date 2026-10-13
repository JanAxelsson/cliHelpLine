#!/usr/bin/env pwsh
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.ps1         # Run script
#   ./cliHelpLine.ps1 --help  # Help on script
#   ./cliHelpLine.ps1 -h      # Help on script
#   ./cliHelpLine.ps1 /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if ($args | Where-Object { $_ -in '--help','-h','/?' }) { $i=0; Get-Content $MyInvocation.MyCommand.Path | ForEach-Object { $i++; if ($i -eq 1 -and $_ -match '^#!') { return }; if ($_ -match '^##') { break } elseif ($_ -match '^#' -or $_.Trim() -ne '') { $_ -replace '^# ?','' } }; exit 0 }



# Explanation
# if ($args | Where-Object { $_ -in '--help','-h','/?' }) {               # Check if arguments contain help flags
#   $i = 0;                                                              # Initialize line counter
#   Get-Content $MyInvocation.MyCommand.Path | ForEach-Object {          # Stream lines from the current script file
#     $i++;                                                              # Increment line counter
#     if ($i -eq 1 -and $_ -match '^#!') { return }                      # Skip shebang line at line 1
#     if ($_ -match '^##') { break }                                     # Stop processing when '##' divider is reached
#     elseif ($_ -match '^#' -or $_.Trim() -ne '') {                     # Skip empty lines without comment character
#       $_ -replace '^# ?',''                                            # Remove '#' and one optional space, then output
#     }
#   };                                                                   # End of pipeline
#   exit 0                                                               # Terminate script cleanly with exit code 0
# }


# Runnable code
Write-Host "Hello world!"
