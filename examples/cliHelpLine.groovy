#!/usr/bin/env groovy
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
//   ./cliHelpLine.groovy         // Run script
//   ./cliHelpLine.groovy --help  // Help on script
//   ./cliHelpLine.groovy -h      // Help on script
//   ./cliHelpLine.groovy /?      // Help on script
//
// ... more help text ...

//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (args.any { it in ["--help", "-h", "/?"] }) { new File(getClass().protectionDomain.codeSource.location.path).eachLine { l -> if (l.startsWith("#!")) return; if (l.startsWith("////")) System.exit(0); if (l.startsWith("//")) println(l.replaceFirst("^// ?", "")); else if (l.trim()) println(l) }; System.exit(0) }



// Explanation
// if (args.any { it in ["--help", "-h", "/?"] }) {                # Scan implicit script args for help flags
// new File(getClass().protectionDomain.codeSource.location.path)  # Introspect source file path on disk
// .eachLine { l ->                                                # Stream each line sequentially
// if (l.startsWith("#!")) return;                                 # Skip shebang line on line 1
// if (l.startsWith("////")) System.exit(0);                       # Halt execution immediately at '////' boundary
// if (l.startsWith("//")) println(l.replaceFirst("^// ?", ""));   # Strip '//' and optional following space
// else if (l.trim()) println(l)                                   # Preserve non-empty code lines
// }; System.exit(0) }                                             # Exit cleanly with status 0 without running main logic


// Runnable code
println "Hello world!"
