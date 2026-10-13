# cliHelpLine

Adds `--help` flag to command line using the file's header comment as the help text. Inspired by Matlab's simple way of doing it. It will also add  `-h` and `/?` flags to be compatible with all platforms.

## Overview

`cliHelpLine` is a lightweight utility designed to automatically extract and display help documentation directly from your script's header comments. Instead of writing boilerplate argument-parsing code for every small script, you can simply write your documentation as comments at the top of your file, and `cliHelpLine` will fetch and format it whenever a user requests help.

## Features

- **No Boilerplate:** Say goodbye to complex argument parsing libraries for simple scripts.
- **Single Source of Truth:** Your documentation lives inside the code comments at the very top of the file.
- **Multi-language Support:** Works seamlessly across Python, Node.js, and Bash projects.

## How to use

- Write a header with comment characters from the specific language at the first character of each row.
  
  Example: `# bla bla` (bash, python, ...)
  
  Example: `// bla bla` (javascript, ...)

- Paste the code (below) after your commented header.  Note that the double comment sign is used as a marker that header ends.
- Shebangs (such as `#!/bin/bash`) are allowed, and will be ignored in help text

  
## Code to use

Copy and paste the following code for your language after the header

### Bash
```bash
## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "/?" ]; then sed -e '1{/^#!/d;}' -e '/^##/q' -e '/^\s*$/d' -e 's/^#//g' -e 's/^ //g' $0 | sed '$d'; exit 0; fi 
```

### Python
```python
## Help -- print file header until '##'  (see https://github.com/JanAxelsson/cliHelpLine)
import sys; [print(line[1:].strip() if line.startswith('#') else line.strip()) for line in open(__file__, encoding='utf-8') if not line.startswith('#!') and (not line.startswith('##') or sys.exit(0))] if any(arg in sys.argv for arg in ('--help', '-h', '/?')) else None  # noqa
```

### JavaScript
```javascript
//// Help -- print file header until '////'    (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.slice(2).some(a => ['--help', '-h', '/?'].includes(a))) { require('fs').readFileSync(__filename, 'utf8').split('\n').filter((l, i) => !(i === 0 && l.startsWith('#!'))).every(l => l.startsWith('////') && !l.includes('readFileSync') ? false : (console.log(l.replace(/^(\/\/|#)\s*/, '').trimEnd()), true)); process.exit(0); }
```

## Learn more

To use this utility in your own projects, ***you only need to copy the two rows*** corresponding 
to your programming language from the examples above. The copied rows should be pasted after the comment section of your file.

Please give the cliHelpLine project a star if you use it.

However, if you want to see how they work, or test and run the included example scripts locally, you can clone the full repository:

```bash
git clone https://github.com/JanAxelsson/cliHelpLine
cd cliHelpLine
```

## Develop

If you want to add more languages please send a pull request, or make an issue

## License

This project is open-source. Check the repository files for explicit licensing details.
