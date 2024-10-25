#!/usr/bin/env node
//
// Example script
// ==============
// 
// Example help text
//
// node clihelp.js hello
// node clihelp.js -h
// node clihelp.js --help
//
// help text

//// Help -- print file header until '////', ignore first row, remove leading '//'
if ( (process.argv[2] === "--help") || ( process.argv[2] ===  "-h" ) ){
    console.log( require("fs").readFileSync(__filename).toString().replace(/^.*\n/, '').split(`////`)[0].replace(/^\s*[\r\n]/gm, '').replace(/^\/\//gm,'').replace(/^ /gm,'') ); process.exit();
}// End Help


// Explanation
// if ( (process.argv[2] === "--help") || ( process.argv[2] ===  "-h" ) ){   // Run statement only if first argument being -h or --help
//    require("fs").readFileSync(__filename).toString()                      // Read file to string
//    .replace(/^.*\n/, '')                                                  // Remove first line
//    .split(`////`)[0]                                                      // Split at '////'
//    .replace(/^\s*[\r\n]/gm, '')                                           // Remove blank lines
//    .replace(/^\/\//gm,'')                                                 // Remove leading '//' 
//    .replace(/^ /gm,'')                                                    // Remove leading ' '
//    process.exit();                                                        // Exit script after printing help
// }


// Example code
console.log("Hello world!");
