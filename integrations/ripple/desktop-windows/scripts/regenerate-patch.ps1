#Requires -Version 5.1
<#
.SYNOPSIS
  Regenerate 001-ripple-windows-ui.patch from integrations/ripple/copaw after editing console/.
  Stages changes under console/ (tracked updates + untracked, respecting .gitignore), writes patch, then unstages.
  Run from AxiMate repository root (or any cwd).
#>
$ErrorActionPreference = "Stop"
$aximateRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")
$copawRoot = Join-Path $aximateRoot "integrations\ripple\copaw"
$patchOut = Join-Path $aximateRoot "integrations\ripple\desktop-windows\patches\001-ripple-windows-ui.patch"

if (-not (Test-Path (Join-Path $copawRoot ".git"))) {
    throw "Expected CoPaw clone at: $copawRoot (run bootstrap-copaw.ps1 first)"
}

Push-Location $copawRoot
try {
    git add -u -- console
    $others = @(git ls-files --others --exclude-standard -- console)
    foreach ($f in $others) {
        git add -- $f
    }
    $diff = git diff --cached -- console
    if ([string]::IsNullOrWhiteSpace($diff)) {
        Write-Warning "No staged diff for console/. Nothing to write."
        git reset HEAD -- console 2>$null
        exit 1
    }
    [System.IO.File]::WriteAllText($patchOut, $diff, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Wrote: $patchOut"
}
finally {
    git reset HEAD -- console 2>$null
    Pop-Location
}
