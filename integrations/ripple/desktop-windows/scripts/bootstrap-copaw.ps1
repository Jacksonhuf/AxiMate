#Requires -Version 5.1
<#
.SYNOPSIS
  Clone upstream CoPaw (if missing) and apply AxiMate Ripple console patch.
#>
$ErrorActionPreference = "Stop"
$desktopRoot = Split-Path -Parent $PSScriptRoot
$rippleRoot = Split-Path -Parent $desktopRoot
$copawRoot = Join-Path $rippleRoot "copaw"
$patchFile = Join-Path $desktopRoot "patches\001-ripple-windows-ui.patch"

if (-not (Test-Path $patchFile)) {
    throw "Missing patch: $patchFile"
}

if (-not (Test-Path (Join-Path $copawRoot ".git"))) {
    Write-Host "Cloning CoPaw -> $copawRoot"
    git clone --depth 1 --branch main https://github.com/agentscope-ai/CoPaw.git $copawRoot
}

Push-Location $copawRoot
try {
    git apply --check $patchFile
    if ($LASTEXITCODE -ne 0) {
        throw @"
Patch cannot be applied (already applied or console/ dirty?).
From repo root: git -C integrations/ripple/copaw checkout -- console
Then re-run this script.
"@
    }
    git apply $patchFile
    Write-Host "Ripple UI patch applied under $copawRoot\console"
}
finally {
    Pop-Location
}
