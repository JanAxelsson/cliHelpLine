# cliHelpLine

Add a `--help` flag to command line programs in multiple languages — using the file's header comment as the help text. Inspired by Matlab's simple way of doing it.

## Overview

`cliHelpLine` is a lightweight utility designed to automatically extract and display help documentation directly from your script's header comments. Instead of writing boilerplate argument-parsing code for every small script, you can simply write your documentation as comments at the top of your file, and `cliHelpLine` will fetch and format it whenever a user requests help.

## Features

- **No Boilerplate:** Say goodbye to complex argument parsing libraries for simple scripts.
- **Single Source of Truth:** Your documentation lives inside the code comments at the very top of the file.
- **Multi-language Support:** Works seamlessly across Python, Node.js, and Bash projects.

## Code Examples

### Bash
```bash
## Help -- print file header until '##', ignore shebang row, remove leading '# '  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' $0 | sed '$d'; exit 0; fi 
## End Help
```

### Python
```python
## Help -- print file header until '##', ignore shebang row, remove leading '# '  (see https://github.com/JanAxelsson/cliHelpLine)
import sys; [print(line[1:].strip() if line.startswith('#') else line.strip()) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0))] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa
## End Help
```

### JavaScript
```javascript
//// Help -- print file header until '////', ignore shebang row, remove leading '// '  (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.slice(2).some(a => ['--help', '-h', '/?'].includes(a))) { require('fs').readFileSync(__filename, 'utf8').split('\n').filter((l, i) => !(i === 0 && l.startsWith('#!'))).every(l => l.startsWith('////') && !l.includes('readFileSync') ? false : (console.log(l.replace(/^(\/\/|#)\s*/, '').trimEnd()), true)); process.exit(0); }
//// End Help
```

## Installation & Setup

To use this utility in your own projects, **you only need to copy the three rows 
** corresponding to your programming language from the examples above. The copied rows should be pasted after the comment section of your file.

However, if you want to test and run the included example scripts locally, you can clone the full repository:

```bash
git clone https://github.com/JanAxelsson/cliHelpLine
cd cliHelpLine
```

### File Structure

The project consists of the following key files:
* `cliHelpLine.py` & `python module/` — Python implementations
* `cliHelpLine.js` — JavaScript/Node.js utility
* `cliHelpLine.bash` — Bash shell script component

## License

This project is open-source. Check the repository files for explicit licensing details.
