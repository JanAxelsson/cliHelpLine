#!/usr/bin/env swift
//
// Example script
// ==============
// 
// This is my help text ...
//
// Example use :
//
//   ./cliHelpLine.swift         // Run script
//   ./cliHelpLine.swift --help  // Help on script
//   ./cliHelpLine.swift -h      // Help on script
//   ./cliHelpLine.swift /?      // Help on script
//
// ... more help text ...

//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
import Foundation; if CommandLine.arguments.contains(where: { ["--help", "-h", "/?"].contains($0) }) { for line in (try? String(contentsOfFile: #file, encoding: .utf8))?.components(separatedBy: .newlines) ?? [] { if line.hasPrefix("#!") { continue }; if line.hasPrefix("////") { exit(0) }; if line.hasPrefix("//") { print(line.dropFirst(line.hasPrefix("// ") ? 3 : 2)) } else if !line.trimmingCharacters(in: .whitespaces).isEmpty { print(line) } }; exit(0) }



// Explanation
// import Foundation;                                                  // Import Foundation framework for command-line arguments and file operations
// if CommandLine.arguments.contains(where: {                          // Check if any argument matches our supported help flags
// ["--help", "-h", "/?"].contains($0) }) {                            // Flags checked: standard long help, short flag, and Windows-style /?
// for line in (try? String(contentsOfFile: #file, encoding: .utf8))?  // Read this file's UTF-8 source content into memory using #file location
// .components(separatedBy: .newlines) ?? [] {                         // Split into individual lines across both Unix and Windows newlines
// if line.hasPrefix("#!") { continue };                               // Skip shebang interpreter line at line 1
// if line.hasPrefix("////") { exit(0) };                               // Stop printing immediately upon encountering the '////' boundary marker
// if line.hasPrefix("//") {                                           // If line starts with '//', strip marker and optional space
// print(line.dropFirst(line.hasPrefix("// ") ? 3 : 2))                // Drop 3 chars if space present ("// "), else 2 chars ("//")
// } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {      // Otherwise preserve non-empty code lines
// print(line)                                                         // Output the line
// } };                                                                // Close loop
// exit(0) }                                                           // Exit successfully without running the main script logic


// Runnable code
print("Hello world!")
