#!/usr/bin/env lua
--
-- Example script
-- ==============
-- 
-- This is my help text ...
--
-- Example use :
--
--   ./cliHelpLine.lua         -- Run script
--   ./cliHelpLine.lua --help  -- Help on script
--   ./cliHelpLine.lua -h      -- Help on script
--   ./cliHelpLine.lua /?      -- Help on script
--
-- ... more help text ...

---- Help -- print file header until '----'  (see https://github.com/JanAxelsson/cliHelpLine)
if (function(args) for _,a in ipairs(args) do if a=="--help" or a=="-h" or a=="/?" then return true end end return false end)(arg or {}) then local f=io.open(arg[0],"r"); local n=0; for l in f:lines() do n=n+1; if not (n==1 and l:match("^#!")) then if l:match("^%-%-%-%-") then break end if l:match("^%-%-") or l:match("%S") then print((l:gsub("^%-%- ?", ""))) end end end; os.exit(0); end



-- Explanation
-- if (function(args) ... end)(arg or {}) then                           -- Check if arg array contains --help, -h, or /?
--   local f = io.open(arg[0], "r");                                     -- Open current script file for reading
--   local n = 0;                                                        -- Track line numbers
--   for l in f:lines() do                                               -- Iterate line by line
--     n = n + 1;                                                        -- Increment line counter
--     if not (n == 1 and l:match("^#!")) then                           -- Skip shebang line at line 1
--       if l:match("^%-%-%-%-") then break end                          -- Stop processing at '----' marker
--       if l:match("^%-%-") or l:match("%S") then                       -- Ignore blank lines without '--'
--         print((l:gsub("^%-%- ?", "")))                                -- Remove '--' and optional space, extra parens discard gsub count
--       end
--     end
--   end
--   os.exit(0);                                                         -- Exit script cleanly with code 0
-- end


-- Runnable code
print("Hello world!")
