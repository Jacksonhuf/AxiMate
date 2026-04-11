#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 0 helper: search common locations for CoPaw Desktop / app data (read-only).
#>
$ErrorActionPreference = "SilentlyContinue"

$patterns = @("*CoPaw*", "*copaw*", "*AgentScope*")
$roots = @(
    ${env:ProgramFiles},
    ${env:ProgramFiles(x86)},
    ${env:LOCALAPPDATA},
    ${env:APPDATA},
    (Join-Path ${env:USERPROFILE} "AppData\Local\Programs")
)

Write-Host "=== AxiMate Ripple / Phase 0: CoPaw Desktop path hints ===" -ForegroundColor Cyan
Write-Host "This script only lists paths; it does not modify anything.`n"

foreach ($root in $roots) {
    if (-not $root -or -not (Test-Path -LiteralPath $root)) { continue }
    Write-Host "--- Under: $root ---" -ForegroundColor Yellow
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $root -Directory -Filter $pat -Recurse -Depth 4 -ErrorAction SilentlyContinue |
            Select-Object -First 20 -ExpandProperty FullName
    }
}

Write-Host "`nDone. Manually open the app install dir from Start Menu shortcut -> Properties -> Open File Location." -ForegroundColor Gray
