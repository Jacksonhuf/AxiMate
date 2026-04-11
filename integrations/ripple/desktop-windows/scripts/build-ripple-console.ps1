#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$desktopRoot = Split-Path -Parent $PSScriptRoot
$rippleRoot = Split-Path -Parent $desktopRoot
$copawConsole = Join-Path $rippleRoot "copaw\console"

if (-not (Test-Path $copawConsole)) {
    throw "Run bootstrap-copaw.ps1 first. Expected: $copawConsole"
}

$env:VITE_RIPPLE_DESKTOP = "1"
Set-Location $copawConsole
if (-not (Test-Path "node_modules")) {
    npm ci
}
npm run build
Write-Host "Output: $copawConsole\dist"
