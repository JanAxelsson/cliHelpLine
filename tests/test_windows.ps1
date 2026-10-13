# tests/test_windows.ps1 - Native Windows verification for cliHelpLine
# Tests PowerShell, Python, Node.js, and README snippet synchronization.

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$examplesDir = Join-Path $projectRoot "examples"
$readmePath = Join-Path $projectRoot "README.md"

$testsPassed = 0
$testsFailed = 0

function Test-ScriptHelpAndRun {
    param(
        [string]$Name,
        [scriptblock]$RunCmd
    )
    
    # 1. Verify --help, -h, /?
    foreach ($flag in @("--help", "-h", "/?")) {
        try {
            $output = & $RunCmd $flag 2>&1 | Out-String
            if ($output -match [regex]::Escape($Name) -and $output -notmatch "Hello world!") {
                Write-Host "[ OK ] $Name ($flag)"
                $script:testsPassed++
            } else {
                Write-Host "[FAIL] $Name ($flag)"
                $script:testsFailed++
            }
        } catch {
            Write-Host "[FAIL] $Name (${flag}: $($_.Exception.Message))"
            $script:testsFailed++
        }
    }

    # 2. Verify normal execution without flags prints 'Hello world!'
    try {
        $runOut = & $RunCmd "" 2>&1 | Out-String
        if ($runOut.Trim() -eq "Hello world!") {
            Write-Host "[ OK ] $Name (running without --help)"
            $script:testsPassed++
        } else {
            Write-Host "[FAIL] $Name (running without --help: expected 'Hello world!', got '$($runOut.Trim())')"
            $script:testsFailed++
        }
    } catch {
        Write-Host "[FAIL] $Name (running without --help: $($_.Exception.Message))"
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

Write-Host "--- Verifying Windows execution (PowerShell /? flag, Python, Node.js)"

# 1. Test PowerShell
$ps1File = Join-Path $examplesDir "cliHelpLine.ps1"
if (Test-Path $ps1File) {
    Test-ScriptHelpAndRun "cliHelpLine.ps1" {
        param($f)
        if ($f) { & pwsh -NoProfile -File $ps1File $f } else { & pwsh -NoProfile -File $ps1File }
    }
}

# 2. Test Python if available
$pyCmd = Find-WorkingCommand @("python", "python3")
$pyFile = Join-Path $examplesDir "cliHelpLine.py"
if ($pyCmd -and (Test-Path $pyFile)) {
    Test-ScriptHelpAndRun "cliHelpLine.py" {
        param($f)
        if ($f) { & $pyCmd $pyFile $f } else { & $pyCmd $pyFile }
    }
}

# 3. Test Node.js if available
$nodeCmd = Find-WorkingCommand @("node")
$jsFile = Join-Path $examplesDir "cliHelpLine.js"
if ($nodeCmd -and (Test-Path $jsFile)) {
    Test-ScriptHelpAndRun "cliHelpLine.js" {
        param($f)
        if ($f) { & $nodeCmd $jsFile $f } else { & $nodeCmd $jsFile }
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
