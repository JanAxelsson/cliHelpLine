#!/usr/bin/env node
//
// Example script
// ==============
// 
// Example help text
//
// node printhelp.js hello
// node printhelp.js -h
// node printhelp.js --help
//
// help text

//// Help -- print file header until '////', ignore first row, remove leading '//'
if ( (process.argv[2] === "--help") || ( process.argv[2] ===  "-h" ) ){
    console.log(require("fs").readFileSync(__filename).toString().split(`////`)[0].replace(/^\/\//gm,'')); process.exit();
}// End Help


// Explanation
// if ( (process.argv[2] === "--help") || ( process.argv[2] ===  "-h" ) ){   // Run statement only if first argument being -h or --help
//    require("fs").readFileSync(__filename).toString()                      // Read file to string
//    .split(`////`)[0]                                                      // Split at '////'
//    .replace(/^\/\//gm,'')                                                 // Replace leading // with ''
//    process.exit();                                                        // Exit script after printing help
// }


// Example code
console.log("Hello world!");
console.log("First argument was : " + process.argv[2]);
