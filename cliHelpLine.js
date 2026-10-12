#!/usr/bin/env node
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
// node cliHelpLine.js
// node cliHelpLine.js --help
// node cliHelpLine.js -h
// node cliHelpLine.js /?
//
// ./cliHelpLine.js
// ./cliHelpLine.js --help
// ./cliHelpLine.js -h
// ./cliHelpLine.js /?
//
// ... more help text ...

//// Help -- print file header until '////'    (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.slice(2).some(a => ['--help', '-h', '/?'].includes(a))) { require('fs').readFileSync(__filename, 'utf8').split('\n').filter((l, i) => !(i === 0 && l.startsWith('#!'))).every(l => l.startsWith('////') && !l.includes('readFileSync') ? false : (console.log(l.replace(/^(\/\/|#)\s*/, '').trimEnd()), true)); process.exit(0); }
//// End Help


// Explanation
// if (process.argv.slice(2).some(a => ['--help', '-h', '/?'].includes(a))) {                                                                   // Check runtime arguments (excluding node/script paths) for --help, -h, or Windows /?
//    require('fs').readFileSync(__filename, 'utf8').split('\n')                                                                                // Read current file as a UTF-8 string and split it into an array of individual lines
//    .filter((l, i) => !(i === 0 && l.startsWith('#!')))                                                                                       // Dynamically drop the shebang row if it exists at index 0, keeping the rest intact
//    .every(l => l.startsWith('////') && !l.includes('readFileSync') ? false : (console.log(l.replace(/^(\/\/|#)\s*/, '').trimEnd()), true));  // Process lines: return false (stop) if '////' hits, avoiding self-triggering, else clean '//' or '#' and print
//    process.exit(0);                                                                                                                          // Terminate the Node.js process immediately after printing the help text
// }


// Example code
console.log("Hello world!");
