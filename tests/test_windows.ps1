# tests/test_windows.ps1 - Native Windows verification for cliHelpLine
# Tests PowerShell, Python, Node.js, and TypeScript across:
#   1. LF line endings (Git checkout)
#   2. CRLF line endings (Native Windows text files)
#   3. Mixed CRLF/LF line endings (Snippet pasted from browser into Windows CRLF file)
# Verifies standard help flags (--help, -h), native Windows help flag (/?), and normal execution.

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$examplesDir = Join-Path $projectRoot "examples"
$readmePath = Join-Path $projectRoot "README.md"

$testsPassed = 0
$testsFailed = 0

# Test runner helper: verifies help flags (--help, -h, /?) and normal run ('Hello world!')
function Test-ScriptHelpAndRun {
    param(
        [string]$Name,
        [scriptblock]$RunCmd,
        [string]$EolMode = ""
    )
    
    $displayName = if ($EolMode) { "$Name [$EolMode]" } else { $Name }

    # 1. Verify --help, -h, /?
    foreach ($flag in @("--help", "-h", "/?")) {
        try {
            $output = & $RunCmd $flag 2>&1 | Out-String
            if ($output -match [regex]::Escape($Name) -and $output -notmatch "Hello world!") {
                Write-Host "[ OK ] $displayName ($flag)"
                $script:testsPassed++
            } else {
                Write-Host "[FAIL] $displayName ($flag)"
                Write-Host "::error::$displayName ($flag) failed. Output: $($output.Trim())"
                $script:testsFailed++
            }
        } catch {
            Write-Host "[FAIL] $displayName (${flag}: $($_.Exception.Message))"
            Write-Host "::error::$displayName (${flag}: $($_.Exception.Message))"
            $script:testsFailed++
        }
    }

    # 2. Verify normal execution without flags prints 'Hello world!'
    try {
        $runOut = & $RunCmd "" 2>&1 | Out-String
        if ($runOut.Trim() -eq "Hello world!") {
            Write-Host "[ OK ] $displayName (running without --help)"
            $script:testsPassed++
        } else {
            Write-Host "[FAIL] $displayName (running without --help: expected 'Hello world!', got '$($runOut.Trim())')"
            Write-Host "::error::$displayName (running without --help: expected 'Hello world!', got '$($runOut.Trim())')"
            $script:testsFailed++
        }
    } catch {
        Write-Host "[FAIL] $displayName (running without --help: $($_.Exception.Message))"
        Write-Host "::error::$displayName (running without --help: $($_.Exception.Message))"
        $script:testsFailed++
    }
}

function Find-WorkingCommand {
    param([string[]]$Names)
    foreach ($name in $Names) {
        $cmds = Get-Command $name -All -ErrorAction SilentlyContinue
        foreach ($c in $cmds) {
            try {
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = $c.Source
                $pinfo.Arguments = "--version"
                $pinfo.RedirectStandardOutput = $true
                $pinfo.RedirectStandardError = $true
                $pinfo.UseShellExecute = $false
                $pinfo.CreateNoWindow = $true
                $p = [System.Diagnostics.Process]::Start($pinfo)
                if ($p.WaitForExit(2000)) {
                    $v = $p.StandardOutput.ReadToEnd()
                    if ($p.ExitCode -eq 0 -or $v -match "\d+\.\d+") {
                        return $c.Source
                    }
                }
            } catch {}
        }
    }
    return $null
}

Write-Host "--- Verifying Windows execution (LF, CRLF, Mixed EOL, /? flag)"

# Locate interpreters
$pyCmd = Find-WorkingCommand @("python", "python3")
$nodeCmd = Find-WorkingCommand @("node")
$tsCmd = Find-WorkingCommand @("tsx.cmd", "tsx", "bun.exe", "bun", "ts-node.cmd", "ts-node")

# Create temporary directories for CRLF and Mixed EOL variants
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("clihelpline_win_tests_" + [System.Guid]::NewGuid().ToString("N"))
$crlfDir = Join-Path $tempDir "crlf"
$mixedDir = Join-Path $tempDir "mixed"
New-Item -ItemType Directory -Path $crlfDir | Out-Null
New-Item -ItemType Directory -Path $mixedDir | Out-Null

# Use UTF8 without BOM to avoid breaking Node.js shebang line resolution
$encNoBom = New-Object System.Text.UTF8Encoding($false)

try {
    # Generate CRLF and Mixed line ending variants
    $targets = @("cliHelpLine.ps1", "cliHelpLine.py", "cliHelpLine.js", "cliHelpLine.ts", "cliHelpLine.bat")
    foreach ($name in $targets) {
        $src = Join-Path $examplesDir $name
        if (-not (Test-Path $src)) { continue }

        $text = [System.IO.File]::ReadAllText($src)

        # 1. Pure CRLF: convert all line breaks to \r\n
        $crlfText = $text -replace "`r`n", "`n" -replace "`n", "`r`n"
        [System.IO.File]::WriteAllText((Join-Path $crlfDir $name), $crlfText, $encNoBom)

        # 2. Mixed CRLF/LF: simulates copying LF snippets from browser into a Windows CRLF file
        #    Header comments & user code use \r\n, snippet lines use \n
        $lines = [System.IO.File]::ReadAllLines($src)
        $sb = New-Object System.Text.StringBuilder
        foreach ($line in $lines) {
            if ($line -match "Help -- prints" -or $line -match '^\s*(if|import|for)\s*.*(sys\.argv|process\.argv|\$args|--help)') {
                [void]$sb.Append($line + "`n")
            } else {
                [void]$sb.Append($line + "`r`n")
            }
        }
        [System.IO.File]::WriteAllText((Join-Path $mixedDir $name), $sb.ToString(), $encNoBom)
    }

    # Test all 3 line ending modes across the supported Windows runtimes
    $modes = @(
        @{ Tag = "LF"; Dir = $examplesDir },
        @{ Tag = "CRLF"; Dir = $crlfDir },
        @{ Tag = "Mixed"; Dir = $mixedDir }
    )

    foreach ($m in $modes) {
        $tag = $m.Tag
        $dir = $m.Dir

        # 1. PowerShell (.ps1)
        $ps1File = Join-Path $dir "cliHelpLine.ps1"
        if (Test-Path $ps1File) {
            Test-ScriptHelpAndRun "cliHelpLine.ps1" {
                param($f)
                if ($f) { & pwsh -NoProfile -File $ps1File $f } else { & pwsh -NoProfile -File $ps1File }
            } $tag
        }

        # 2. Python (.py)
        $pyFile = Join-Path $dir "cliHelpLine.py"
        if ($pyCmd -and (Test-Path $pyFile)) {
            Test-ScriptHelpAndRun "cliHelpLine.py" {
                param($f)
                if ($f) { & $pyCmd $pyFile $f } else { & $pyCmd $pyFile }
            } $tag
        }

        # 3. Node.js (.js)
        $jsFile = Join-Path $dir "cliHelpLine.js"
        if ($nodeCmd -and (Test-Path $jsFile)) {
            Test-ScriptHelpAndRun "cliHelpLine.js" {
                param($f)
                if ($f) { & $nodeCmd $jsFile $f } else { & $nodeCmd $jsFile }
            } $tag
        }

        # 4. TypeScript (.ts)
        $tsFile = Join-Path $dir "cliHelpLine.ts"
        if ($tsCmd -and (Test-Path $tsFile)) {
            Test-ScriptHelpAndRun "cliHelpLine.ts" {
                param($f)
                if ($f) { & $tsCmd $tsFile $f } else { & $tsCmd $tsFile }
            } $tag
        }

        # 5. Batch (.bat)
        $batFile = Join-Path $dir "cliHelpLine.bat"
        if (Test-Path $batFile) {
            Test-ScriptHelpAndRun "cliHelpLine.bat" {
                param($f)
                if ($f) { & cmd.exe /c "`"$batFile $f`"" } else { & cmd.exe /c "`"$batFile`"" }
            } $tag
        }
    }
}
finally {
    # Clean up temporary directories
    if (Test-Path $tempDir) {
        Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
    }
}

Write-Host ""
if ($testsFailed -eq 0) {
    Write-Host "All tests passed ($testsPassed/$testsPassed)"
    exit 0
} else {
    Write-Host "$testsFailed of $($testsPassed + $testsFailed) tests failed"
    exit 1
}
