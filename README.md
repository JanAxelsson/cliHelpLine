# cliHelpLine

Turn your script's header comments into `--help`, `-h`, and `/?` output with a 2-line snippet. Inspired by MATLAB's comment-based help.  

Zero dependencies, zero boilerplate, and cross-platform.       

## Overview

`cliHelpLine` is a lightweight utility designed to automatically extract and display help documentation directly from your script's header comments. Instead of writing boilerplate argument-parsing code for every small script, you can simply write your documentation as comments at the top of your file, and `cliHelpLine` will fetch and format it whenever a user requests help.

## Features

- **No Boilerplate:** Say goodbye to complex argument parsing libraries for simple scripts.
- **Single Source of Truth:** Your documentation lives inside the code comments at the very top of the file.
- **Multi-language Support:** Works seamlessly across Bash, Sh, Zsh, Fish, Python, JavaScript (Node.js), Ruby, Perl, PHP, Lua, R, PowerShell, Tcl, and AWK.

## Write your header as a comment

- Write a header with comment characters from the specific language at the first character of each row.
  
  Example: `# bla bla` (bash, python, ...)
  
  Example: `// bla bla` (javascript, php, ...)

- Paste the code (below) after your commented header. 

  ## FAQ
- Shebangs (such as `#!/bin/bash`) are allowed, and will be ignored in help text.

- Empty lines are ignored

- Stops reading header at double-comment (##, ////, etc depending on language).  Already in code below if you include both rows.

- **Compatible with subsequent argument parsing:** `cliHelpLine` only intercepts execution when a help flag (`--help`, `-h`, or `/?`) is passed, printing the header and exiting (`exit 0`). For normal execution without help flags, it silently falls through, so you can freely perform any further argument parsing (manual or using libraries like `argparse`, `getopts`, `yargs`, etc.) right after it.

  
## Code to use

Copy and paste the following code for your language after the header

### Bash
```bash
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```

### Sh (POSIX)
```sh
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```

### Zsh
```zsh
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```

### Fish
```fish
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if contains -- "$argv[1]" --help -h '/?'; sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' (status filename) | sed '$d'; exit 0; end
```

### Python
```python
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
import sys, re; [print(re.sub(r'^# ?', '', line.rstrip('\r\n')) if line.startswith('#') else line.rstrip('\r\n')) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0)) and (line.startswith('#') or line.strip())] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa
```

### JavaScript
```javascript
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.some(arg => ['--help', '-h', '/?'].includes(arg))) { require('fs').readFileSync(__filename, 'utf-8').split(/\r?\n/).every(line => line.startsWith('#!') ? true : (line.startsWith('////') ? false : ((line.startsWith('//') || line.trim() !== '') && console.log(line.startsWith('//') ? line.replace(/^\/\/ ?/, '') : line), true))); process.exit(0); }
```

### Ruby
```ruby
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if ARGV.any? { |a| %w[--help -h /?].include?(a) }; File.foreach(__FILE__).with_index { |l, i| next if i == 0 && l.start_with?('#!'); break if l.start_with?('##'); puts l.sub(/^# ?/, '').chomp if l.start_with?('#') || !l.strip.empty? }; exit 0; end
```

### Perl
```perl
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (grep { $_ eq '--help' || $_ eq '-h' || $_ eq '/?' } @ARGV) { open my $f, '<', $0; while (<$f>) { next if $. == 1 && /^#!/; last if /^##/; if (/^#/ || /\S/) { s/^# ?//; print; } } exit 0; }
```

### PHP
```php
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (array_intersect($argv ?? [], ['--help', '-h', '/?'])) { foreach (file(__FILE__) as $i => $l) { if ($i === 0 && (str_starts_with($l, '#!') || str_starts_with($l, '<?php'))) continue; if (str_starts_with($l, '////')) break; if (str_starts_with($l, '//') || trim($l) !== '') echo preg_replace('/^\/\/ ?/', '', $l); } exit(0); }
```

### Lua
```lua
---- Help -- prints header above (stops at '----')  (see https://github.com/JanAxelsson/cliHelpLine)
if (function(args) for _,a in ipairs(args) do if a=="--help" or a=="-h" or a=="/?" then return true end end return false end)(arg or {}) then local f=io.open(arg[0],"r"); local n=0; for l in f:lines() do n=n+1; if not (n==1 and l:match("^#!")) then if l:match("^%-%-%-%-") then break end if l:match("^%-%-") or l:match("%S") then print((l:gsub("^%-%- ?", ""))) end end end; os.exit(0); end
```

### R
```r
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (any(commandArgs(trailingOnly=FALSE) %in% c("--help", "-h", "/?"))) { l <- readLines(sub("^--file=", "", grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)[1]), warn=FALSE); for (x in l[-1]) { if (startsWith(x, "##")) break; if (startsWith(x, "#") || nzchar(trimws(x))) cat(sub("^# ?", "", x), "\n", sep=""); }; quit(save="no", status=0); }
```

### PowerShell
```powershell
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if ($args | Where-Object { $_ -in '--help','-h','/?' }) { $i=0; Get-Content $MyInvocation.MyCommand.Path | ForEach-Object { $i++; if ($i -eq 1 -and $_ -match '^#!') { return }; if ($_ -match '^##') { break } elseif ($_ -match '^#' -or $_.Trim() -ne '') { $_ -replace '^# ?','' } }; exit 0 }
```

### Tcl
```tcl
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if {[expr {[lsearch -exact $argv "--help"] >= 0 || [lsearch -exact $argv "-h"] >= 0 || [lsearch -exact $argv "/?"] >= 0}]} { set fp [open $argv0 r]; set nr 0; while {[gets $fp line] >= 0} { incr nr; if {$nr == 1 && [string match "#!*" $line]} continue; if {[string match "##*" $line]} break; if {[string match "#*" $line] || [string trim $line] ne ""} { puts [regsub {^# ?} $line ""] } }; close $fp; exit 0 }
```

### AWK
```awk
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
BEGIN { for (i in ARGV) if (ARGV[i] ~ /^(--help|-h|\/\?)$/) { for (a in PROCINFO["argv"]) if (PROCINFO["argv"][a] ~ /^-[fE]$/) f=PROCINFO["argv"][a+1]; while ((getline l < f) > 0) { if (++nr == 1 && l ~ /^#!/ ) continue; if (l ~ /^##/) break; if (l ~ /^#/ || l ~ /\S/) { sub(/^# ?/, "", l); print l } } exit 0 } }
```

## Learn more

To use this utility in your own projects, ***you only need to copy the two rows*** corresponding 
to your programming language from the examples above. The copied rows should be pasted after the comment section of your file.

Please give the cliHelpLine project a star if you use it.

I you want to see how the scripts work, or test and run the included example scripts locally, you can clone the full repository:

```bash
git clone https://github.com/JanAxelsson/cliHelpLine
cd cliHelpLine
```

To run the test suite across all languages using Docker:

```bash
./run_tests.sh               # Run all tests (auto-starts Docker & builds image if needed)
./run_tests.sh python        # Run test for a specific language (or e.g. py, cliHelpLine.py)
./run_tests.sh py rb fish    # Run tests for multiple specific targets
./run_tests.sh --build       # Force rebuild the Docker test image
./run_tests.sh --help        # Show all options and usage
```

## Develop

If you want to add more languages please send a pull request, or make an issue

## License

This project is open-source. Check the repository files for explicit licensing details.
