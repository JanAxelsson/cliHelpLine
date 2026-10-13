# cliHelpLine

[![Tests](https://github.com/JanAxelsson/cliHelpLine/actions/workflows/tests.yml/badge.svg)](https://github.com/JanAxelsson/cliHelpLine/actions/workflows/tests.yml)
[![Version](https://img.shields.io/badge/version-0.1-blue.svg)](https://github.com/JanAxelsson/cliHelpLine/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Turn your script's header comments into `--help`, `-h`, and `/?` output with a 2-line snippet.**  
> Zero dependencies, zero boilerplate, and cross-platform across 17 scripting languages.

In environments like MATLAB and PowerShell (*Comment-Based Help*), writing help is effortless: the comments at the top of a file automatically become the documentation. `cliHelpLine` brings that exact zero-overhead pattern to Bash, Python, Node.js, Ruby, TypeScript, Julia, Swift, and 10 other languages—no heavyweight CLI frameworks or argument-parsing libraries required.

<!-- Optional: Demo GIF can be embedded here -->
<!-- ![cliHelpLine Demo](demo.gif) -->

## Quick Example

1. In your script (e.g. `backup.sh`), write your header comments followed by the 2-line snippet:

```bash
#!/bin/bash
# backup.sh - Quick directory backup tool
# Usage: ./backup.sh <source> <target>

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi

cp -r "$1" "$2"
echo "Backup complete!"
```

2. Request help from the command line:

```bash
./backup.sh --help
```

3. Clean help text is displayed directly from the header comments:

```text
backup.sh - Quick directory backup tool
Usage: ./backup.sh <source> <target>
```

## Features

- **Zero Boilerplate:** Say goodbye to complex argument parsing libraries just to print a help message.
- **Single Source of Truth:** Your documentation lives inside the code comments at the very top of your file.
- **Cross-Platform:** Works out-of-the-box with Unix `--help` and `-h`, as well as Windows `/?`.
- **Compatible with Further Argument Parsing:** Only intercepts help requests; silently falls through for normal runs so you can still parse other arguments as usual.
- **Multi-Language:** Works seamlessly across 17 scripting languages.

## Code to use

Copy and paste the two lines corresponding to your programming language right after your header comment:

<a id="languages"></a>
> **Jump to:**  
> [AWK](#awk) · [Bash](#bash) · [Fish](#fish) · [JavaScript](#javascript) · [Julia](#julia) · [Lua](#lua) · [Perl](#perl) · [PHP](#php) · [POSIX Shell](#posix-shell) · [PowerShell](#powershell) · [Python](#python) · [R](#r) · [Ruby](#ruby) · [Swift](#swift) · [Tcl](#tcl) · [TypeScript](#typescript) · [Zsh](#zsh)

### AWK
```awk
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
BEGIN { for (i in ARGV) if (ARGV[i] ~ /^(--help|-h|\/\?)$/) { for (a in PROCINFO["argv"]) if (PROCINFO["argv"][a] ~ /^-[fE]$/) f=PROCINFO["argv"][a+1]; while ((getline l < f) > 0) { if (++nr == 1 && l ~ /^#!/ ) continue; if (l ~ /^##/) break; if (l ~ /^#/ || l ~ /\S/) { sub(/^# ?/, "", l); print l } } exit 0 } }
```
> <small>**Important:** Your script must use `#!/usr/bin/env -S gawk -E` on line 1 (the `-E` flag prevents AWK from intercepting `--help`, and `gawk` is required for `PROCINFO` so the script can locate its own file). On macOS, install via `brew install gawk`; on Linux, `gawk` is typically standard.</small>

<small>[↑ Back to languages](#languages)</small>

### Bash
```bash
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```
<small>[↑ Back to languages](#languages)</small>

### Fish
```fish
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if contains -- "$argv[1]" --help -h '/?'; sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' (status filename) | sed '$d'; exit 0; end
```
<small>[↑ Back to languages](#languages)</small>

### JavaScript
```javascript
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.some(arg => ['--help', '-h', '/?'].includes(arg))) { require('fs').readFileSync(__filename, 'utf-8').split(/\r?\n/).every(line => line.startsWith('#!') ? true : (line.startsWith('////') ? false : ((line.startsWith('//') || line.trim() !== '') && console.log(line.startsWith('//') ? line.replace(/^\/\/ ?/, '') : line), true))); process.exit(0); }
```
<small>[↑ Back to languages](#languages)</small>

### Julia
```julia
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if any(in(["--help", "-h", "/?"]), ARGS); for l in eachline(@__FILE__); startswith(l, "#!") && continue; startswith(l, "##") && exit(0); (startswith(l, "#") || !isempty(strip(l))) && println(startswith(l, "#") ? replace(l, r"^# ?"=>"") : l); end; exit(0); end
```
<small>[↑ Back to languages](#languages)</small>

### Lua
```lua
---- Help -- prints header above (stops at '----')  (see https://github.com/JanAxelsson/cliHelpLine)
if (function(args) for _,a in ipairs(args) do if a=="--help" or a=="-h" or a=="/?" then return true end end return false end)(arg or {}) then local f=io.open(arg[0],"r"); local n=0; for l in f:lines() do n=n+1; if not (n==1 and l:match("^#!")) then if l:match("^%-%-%-%-") then break end if l:match("^%-%-") or l:match("%S") then print((l:gsub("^%-%- ?", ""))) end end end; os.exit(0); end
```
<small>[↑ Back to languages](#languages)</small>

### Perl
```perl
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (grep { $_ eq '--help' || $_ eq '-h' || $_ eq '/?' } @ARGV) { open my $f, '<', $0; while (<$f>) { next if $. == 1 && /^#!/; last if /^##/; if (/^#/ || /\S/) { s/^# ?//; print; } } exit 0; }
```
<small>[↑ Back to languages](#languages)</small>

### PHP
```php
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (array_intersect($argv ?? [], ['--help', '-h', '/?'])) { foreach (file(__FILE__) as $i => $l) { if ($i === 0 && (str_starts_with($l, '#!') || str_starts_with($l, '<?php'))) continue; if (str_starts_with($l, '////')) break; if (str_starts_with($l, '//') || trim($l) !== '') echo preg_replace('/^\/\/ ?/', '', $l); } exit(0); }
```
<small>[↑ Back to languages](#languages)</small>

### POSIX Shell
```sh
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```
<small>[↑ Back to languages](#languages)</small>

### PowerShell
```powershell
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if ($args | Where-Object { $_ -in '--help','-h','/?' }) { $i=0; Get-Content $MyInvocation.MyCommand.Path | ForEach-Object { $i++; if ($i -eq 1 -and $_ -match '^#!') { return }; if ($_ -match '^##') { break } elseif ($_ -match '^#' -or $_.Trim() -ne '') { $_ -replace '^# ?','' } }; exit 0 }
```
<small>[↑ Back to languages](#languages)</small>

### Python
```python
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
import sys, re; [print(re.sub(r'^# ?', '', line.rstrip('\r\n')) if line.startswith('#') else line.rstrip('\r\n')) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0)) and (line.startswith('#') or line.strip())] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa
```
<small>[↑ Back to languages](#languages)</small>

### R
```r
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if (any(commandArgs(trailingOnly=FALSE) %in% c("--help", "-h", "/?"))) { l <- readLines(sub("^--file=", "", grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)[1]), warn=FALSE); for (x in l[-1]) { if (startsWith(x, "##")) break; if (startsWith(x, "#") || nzchar(trimws(x))) cat(sub("^# ?", "", x), "\n", sep=""); }; quit(save="no", status=0); }
```
<small>[↑ Back to languages](#languages)</small>

### Ruby
```ruby
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if ARGV.any? { |a| %w[--help -h /?].include?(a) }; File.foreach(__FILE__).with_index { |l, i| next if i == 0 && l.start_with?('#!'); break if l.start_with?('##'); puts l.sub(/^# ?/, '').chomp if l.start_with?('#') || !l.strip.empty? }; exit 0; end
```
<small>[↑ Back to languages](#languages)</small>

### Swift
```swift
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
import Foundation; if CommandLine.arguments.contains(where: { ["--help", "-h", "/?"].contains($0) }) { for line in (try? String(contentsOfFile: #file, encoding: .utf8))?.components(separatedBy: .newlines) ?? [] { if line.hasPrefix("#!") { continue }; if line.hasPrefix("////") { exit(0) }; if line.hasPrefix("//") { print(line.dropFirst(line.hasPrefix("// ") ? 3 : 2)) } else if !line.trimmingCharacters(in: .whitespaces).isEmpty { print(line) } }; exit(0) }
```
<small>[↑ Back to languages](#languages)</small>

### Tcl
```tcl
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if {[expr {[lsearch -exact $argv "--help"] >= 0 || [lsearch -exact $argv "-h"] >= 0 || [lsearch -exact $argv "/?"] >= 0}]} { set fp [open $argv0 r]; set nr 0; while {[gets $fp line] >= 0} { incr nr; if {$nr == 1 && [string match "#!*" $line]} continue; if {[string match "##*" $line]} break; if {[string match "#*" $line] || [string trim $line] ne ""} { puts [regsub {^# ?} $line ""] } }; close $fp; exit 0 }
```
<small>[↑ Back to languages](#languages)</small>

### TypeScript
```typescript
//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.some((arg: string) => ['--help', '-h', '/?'].includes(arg))) { require('fs').readFileSync(__filename, 'utf-8').split(/\r?\n/).every((line: string) => line.startsWith('#!') ? true : (line.startsWith('////') ? false : ((line.startsWith('//') || line.trim() !== '') && console.log(line.startsWith('//') ? line.replace(/^\/\/ ?/, '') : line), true))); process.exit(0); }
```
> <small>**Tip:** You can run TypeScript scripts directly without a build step:</small>
> - <small>**[Bun](https://bun.sh):** Use shebang `#!/usr/bin/env bun` or run `bun script.ts`</small>
> - <small>**Node.js (23.6+):** Use shebang `#!/usr/bin/env node` or run `node script.ts` *(or `node --experimental-strip-types script.ts` on Node 22.6+)*</small>
> - <small>**[tsx](https://github.com/privatenumber/tsx):** Use shebang `#!/usr/bin/env -S npx tsx` or run `npx tsx script.ts`</small>
> - <small>**[Deno](https://deno.com):** Use shebang `#!/usr/bin/env -S deno run --allow-read` or run `deno run --allow-read script.ts`</small>

<small>[↑ Back to languages](#languages)</small>

### Zsh
```zsh
## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^[[:space:]]*$/d' -e 's/^#//g' -e 's/^ //g' "$0" | sed '$d'; exit 0; fi
```
<small>[↑ Back to languages](#languages)</small>

## How It Works & FAQ

- **Multi-line header comments:** Write your documentation as a block of comment lines at the top of your script. Each row of the header must start with the language's comment character (`#`, `//`, or `--`) at column 0.
- **Double-comment delimiter:** The snippet stops reading when it hits the double-comment marker (`##`, `////`, `----`), which acts as the boundary.
- **Shebangs are ignored:** If line 1 contains a shebang (`#!/bin/bash`, `#!/usr/bin/env python`, etc.), it is automatically skipped in the help output.
- **Empty lines & paragraph spacing:** Completely blank lines without any comment characters are ignored. Lines that contain only a comment character (such as `#`, `//`, or `--`, with or without a trailing space) are preserved as empty blank lines in the output, allowing clean paragraph separation.
- **Subsequent argument parsing:** `cliHelpLine` only intercepts execution when `--help`, `-h`, or `/?` is passed, printing the header and exiting (`exit 0`). For normal runs, it silently falls through, so you can freely perform any further argument parsing right after it.

## Testing & Local Development

You can clone the repository to test and run the included example scripts in `examples/`:

```bash
git clone https://github.com/JanAxelsson/cliHelpLine
cd cliHelpLine
```

A 3-stage multi-language test suite is included to thoroughly verify all scripts:

```bash
./run_tests.sh               # Runs all 3 test stages:
                             #   1. Local host verification (Darwin/Linux)
                             #   2. Docker full-suite verification (all 17 languages)
                             #   3. README.md code snippet synchronization
./run_tests.sh --local, -l   # Run local test + README test only (skips Docker)
./run_tests.sh --docker, -d  # Run Docker test + README test only (skips local)
./run_tests.sh python        # Run test stages for a specific language (or e.g. py)
./run_tests.sh --build       # Force rebuild the Docker test image
./run_tests.sh --help        # Show all test runner options
```

Please give the cliHelpLine project a star ⭐ on GitHub if you find it useful!

## Contributing

If you want to add support for another scripting language, feel free to open an issue or send a pull request!

## License

This project is licensed under the [MIT License](LICENSE) — feel free to copy, modify, distribute, and include these snippets in any project, whether personal, open-source, or commercial.
