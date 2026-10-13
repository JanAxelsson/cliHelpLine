#!/usr/bin/env node
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
//   node cliHelpLine.js
//   node cliHelpLine.js --help
//   node cliHelpLine.js -h
//   node cliHelpLine.js /?
//
//   ./cliHelpLine.js
//   ./cliHelpLine.js --help
//   ./cliHelpLine.js -h
//   ./cliHelpLine.js /?
//
// ... more help text ...

//// Help -- print file header until '////'    (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.some(arg => ['--help', '-h', '/?'].includes(arg))) { require('fs').readFileSync(__filename, 'utf-8').split(/\r?\n/).every(line => line.startsWith('#!') ? true : (line.startsWith('////') ? false : ((line.startsWith('//') || line.trim() !== '') && console.log(line.startsWith('//') ? line.replace(/^\/\/ ?/, '') : line), true))); process.exit(0); }


// Explanation
// if (process.argv.some(arg => ['--help', '-h', '/?'].includes(arg))) { // Scan runtime arguments to see if --help, -h, or /? is present
// require('fs').readFileSync(__filename, 'utf-8')                     // Synchronously read the entire current JavaScript file
// .split(/\r?\n/)                                                      // Split text into an array of rows, supporting both Windows and Unix line endings
// .every(line =>                                                       // Loop through rows sequentially until any cycle returns false
// line.startsWith('#!') ? true :                                       // If a Linux shebang row is present at line 1, skip it and continue (return true)
// (line.startsWith('////') ? false :                                   // If row hits '////', return false to instantly break the loop and stop printing
// ((line.startsWith('//') || line.trim() !== '') &&                    // Delete and ignore empty lines without comment characters
// console.log(                                                         // Otherwise, pass the processed row into the console output stream:
// line.startsWith('//') ? line.replace(/^\/\/ ?/, '')                  // Clean leading '//' and exactly ONE optional trailing space to preserve indentations
// : line                                                               // If it is a standard code row, print it out exactly as it is written
// ), true)));                                                          // Return true to keep the loop rolling onto the very next line
// process.exit(0); }                                                   // Gracefully close the node application so your main script logic never triggers

// Example code
console.log("Hello world!");
