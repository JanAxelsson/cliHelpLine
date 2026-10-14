<?php
//
// Example script (Web & HTTP safe)
// ================================
// 
// This is my help text ...
//
// Example use :
//
//   php cliHelpLine_web.php         // Run script via CLI
//   php cliHelpLine_web.php --help  // Help on script via CLI
//   php cliHelpLine_web.php -h      // Help on script via CLI
//   php cliHelpLine_web.php /?      // Help on script via CLI
//
// ... more help text ...

//// Help -- prints header above (stops at '////')  (see https://github.com/JanAxelsson/cliHelpLine)
if (array_intersect($argv ?? [], ['--help', '-h', '/?'])) { foreach (file(__FILE__) as $i => $l) { if ($i <= 1 && (str_starts_with($l, '#!') || str_starts_with($l, '<?php'))) continue; if (str_starts_with($l, '////')) break; if (str_starts_with($l, '//') || trim($l) !== '') echo preg_replace('/^\/\/ ?/', '', $l); } exit(0); }



// Explanation
// if (array_intersect($argv ?? [], ['--help', '-h', '/?'])) {           // Check if $argv contains --help, -h, or /?
//   foreach (file(__FILE__) as $i => $l) {                              // Read file into an array of lines and iterate
//     if ($i <= 1 && (str_starts_with($l, '#!') || str_starts_with($l, '<?php'))) continue; // Skip shebang or <?php tag
//     if (str_starts_with($l, '////')) break;                           // Stop loop when reaching '////' marker
//     if (str_starts_with($l, '//') || trim($l) !== '')                 // Ignore blank lines without comment chars
//       echo preg_replace('/^\/\/ ?/', '', $l);                         // Remove leading '//' and optional space, then print
//   }
//   exit(0);                                                            // Exit script cleanly with status code 0
// }


// Runnable code
echo "Hello world!\n";
