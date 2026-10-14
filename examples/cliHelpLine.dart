#!/usr/bin/env dart
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
//   ./cliHelpLine.dart         // Run script
//   ./cliHelpLine.dart --help  // Help on script
//   ./cliHelpLine.dart -h      // Help on script
//   ./cliHelpLine.dart /?      // Help on script
//
// ... more help text ...

//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
import 'dart:io'; void main(List<String> a) { if (a.any(['--help', '-h', '/?'].contains)) { for (var l in File(Platform.script.toFilePath()).readAsLinesSync()) { if (l.startsWith('#!')) continue; if (l.startsWith('////')) exit(0); if (l.startsWith('//')) print(l.replaceFirst(RegExp(r'^// ?'), '')); else if (l.trim().isNotEmpty) print(l); }; exit(0); }



// Explanation
// import 'dart:io'; void main(List<String> a) {                   // Import dart:io and begin entry-point main function
// if (a.any(['--help', '-h', '/?'].contains)) {                   // Check if command-line arguments match any help flag
// for (var l in File(Platform.script.toFilePath())                // Resolve executing script path via Platform.script
// .readAsLinesSync()) {                                           // Read all lines synchronously from the source script
// if (l.startsWith('#!')) continue;                               // Skip shebang execution line at line 1
// if (l.startsWith('////')) exit(0);                              // Break instantly and exit 0 upon encountering '////'
// if (l.startsWith('//')) print(l.replaceFirst(RegExp(r'^// ?'), '')); // Strip '//' and optional following space
// else if (l.trim().isNotEmpty) print(l);                         // Print non-empty code lines as-is
// }; exit(0); }                                                   // Gracefully exit 0 before executing main script logic


// Runnable code
  print("Hello world!");
}
