#!/usr/bin/env elixir
#
# Example script
# ==============
# 
# This is my help text ...
#
# Example use :
#
#   ./cliHelpLine.exs         # Run script
#   ./cliHelpLine.exs --help  # Help on script
#   ./cliHelpLine.exs -h      # Help on script
#   ./cliHelpLine.exs /?      # Help on script
#
# ... more help text ...

## Help -- prints header above (stops at '##')  (see https://github.com/JanAxelsson/cliHelpLine)
if Enum.any?(System.argv(), &(&1 in ["--help", "-h", "/?"])), do: (File.stream!(__ENV__.file) |> Enum.reduce_while(nil, fn l, _ -> cond do; String.starts_with?(l, "#!") -> {:cont, nil}; String.starts_with?(l, "##") -> {:halt, nil}; String.starts_with?(l, "#") -> IO.write(Regex.replace(~r/^# ?/, l, "")); {:cont, nil}; String.trim(l) != "" -> IO.write(l); {:cont, nil}; true -> {:cont, nil}; end end); System.halt(0))



# Explanation
# if Enum.any?(System.argv(), &(&1 in ["--help", "-h", "/?"])),    # Scan command line arguments for --help, -h, or /?
# do: (File.stream!(__ENV__.file)                                  # Stream lines of this source file lazily
# |> Enum.reduce_while(nil, fn l, _ ->                             # Iterate line-by-line with ability to halt early
# cond do                                                          # Evaluate conditions sequentially:
# String.starts_with?(l, "#!") -> {:cont, nil}                     # Skip shebang line at line 1 and continue
# String.starts_with?(l, "##") -> {:halt, nil}                     # Stop loop immediately when '##' boundary is hit
# String.starts_with?(l, "#") ->                                   # For comment lines:
# IO.write(Regex.replace(~r/^# ?/, l, ""))                         # Strip leading '#' and optional following space
# String.trim(l) != "" -> IO.write(l)                              # Preserve non-empty code lines
# true -> {:cont, nil}                                             # Ignore blank lines without comment markers
# end end)                                                         # Complete reduction loop
# System.halt(0))                                                  # Exit cleanly with status 0 without running program body


# Runnable code
IO.puts("Hello world!")
