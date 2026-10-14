#!/usr/bin/env bun
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
//   ./cliHelpLine.ts         // Run script
//   ./cliHelpLine.ts --help  // Help on script
//   ./cliHelpLine.ts -h      // Help on script
//   ./cliHelpLine.ts /?      // Help on script
//
// ... more help text ...

//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (process.argv.some((arg: string) => ['--help', '-h', '/?'].includes(arg))) { require('fs').readFileSync(__filename, 'utf-8').split(/\r?\n/).every((line: string) => line.startsWith('#!') ? true : (line.startsWith('////') ? false : ((line.startsWith('//') || line.trim() !== '') && console.log(line.startsWith('//') ? line.replace(/^\/\/ ?/, '') : line), true))); process.exit(0); }



// Explanation
// if (process.argv.some((arg: string) => ['--help', '-h', '/?'].includes(arg))) { // Scan runtime arguments to see if --help, -h, or /? is present
// require('fs').readFileSync(__filename, 'utf-8')                                  // Synchronously read the entire current TypeScript file
// .split(/\r?\n/)                                                                   // Split text into an array of rows, supporting both Windows and Unix line endings
// .every((line: string) =>                                                          // Loop through rows sequentially until any cycle returns false
// line.startsWith('#!') ? true :                                                    // If an environment shebang row is present at line 1, skip it and continue
// (line.startsWith('////') ? false :                                                // If row hits '////', return false to instantly break the loop and stop printing
// ((line.startsWith('//') || line.trim() !== '') &&                                 // Delete and ignore empty lines without comment characters
// console.log(                                                                      // Otherwise, pass the processed row into the console output stream:
// line.startsWith('//') ? line.replace(/^\/\/ ?/, '')                               // Clean leading '//' and exactly ONE optional following space to preserve indentations
// : line                                                                            // If it is a standard code row, print it out exactly as it is written
// ), true)));                                                                       // Return true to keep the loop rolling onto the very next line
// process.exit(0); }                                                                // Gracefully close the process so your main script logic never triggers


// Runnable code
console.log("Hello world!");
