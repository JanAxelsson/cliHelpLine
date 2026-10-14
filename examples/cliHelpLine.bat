@echo off
REM
REM Example script
REM ==============
REM 
REM This is my help text ...
REM
REM Example use :
REM
REM   cliHelpLine.bat         # Run script
REM   cliHelpLine.bat --help  # Help on script
REM   cliHelpLine.bat -h      # Help on script
REM   cliHelpLine.bat /?      # Help on script
REM
REM ... more help text ...

REM REM Help -- prints header above (stops at 'REM REM')  (see https://github.com/JanAxelsson/cliHelpLine)
(for %%H in (--help -h) do if /i "%~1"=="%%~H" set "_h=1") & (if "%~1"=="/?" set "_h=1") & if defined _h (powershell -NoProfile -Command "Get-Content '%~f0' | ForEach-Object { if ($_ -match '^REM REM') { exit 0 }; if ($_ -match '^REM') { $_ -replace '^REM ?','' } }" & exit /b 0)



REM Explanation
REM (for %%H in (--help -h) do if /i "%~1"=="%%~H" set "_h=1") & (if "%~1"=="/?" set "_h=1") # Check for --help, -h, or /? flags
REM if defined _h (...)                                                                       # If help flag matched, process and display header
REM   powershell -NoProfile -Command "..."                                                    # Built-in Windows PowerShell reads script safely
REM   Get-Content '%~f0'                                                                      # Reads file natively across pure LF, CRLF, and mixed EOL
REM   ForEach-Object { if ($_ -match '^REM REM') { exit 0 } ... }                             # Stops immediately at double-comment marker
REM   $_ -replace '^REM ?',''                                                                 # Strips 'REM ' prefix, preserving formatting and special chars
REM & exit /b 0                                                                               # Terminate batch script cleanly with exit code 0 when help was requested
REM
REM Note: If you want command echoing enabled during the main script,
REM simply add '@echo on' immediately after the snippet.


REM Runnable code
echo Hello world!
