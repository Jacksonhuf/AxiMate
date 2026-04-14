# Build a full wheel package including the latest console frontend.
# Run from repo root: pwsh -File scripts/wheel_build.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
Set-Location -LiteralPath $RepoRoot

$ConsoleDir = Join-Path $RepoRoot "console"
$ConsoleDest = Join-Path $RepoRoot "src\copaw\console"
$ConsoleDist = Join-Path $ConsoleDir "dist"

# When set to 1, skip npm ci / npm run build and use existing console/dist (e.g. file lock on esbuild.exe).
if ($env:WHEEL_BUILD_SKIP_CONSOLE -eq "1") {
  Write-Host "[wheel_build] WHEEL_BUILD_SKIP_CONSOLE=1: using existing console/dist (no npm ci/build)."
  if (-not (Test-Path (Join-Path $ConsoleDist "index.html"))) {
    throw "WHEEL_BUILD_SKIP_CONSOLE=1 but console/dist/index.html missing. Build the console first or unset the variable."
  }
} else {
  Write-Host "[wheel_build] Building console frontend..."
  Push-Location $ConsoleDir
  try {
    npm ci
    if ($LASTEXITCODE -ne 0) { throw "npm ci failed with exit code $LASTEXITCODE" }
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "npm run build failed with exit code $LASTEXITCODE" }
  } finally {
    Pop-Location
  }
}

Write-Host "[wheel_build] Copying console/dist/* -> src/copaw/console/..."
if (Test-Path $ConsoleDest) {
  Remove-Item -Path (Join-Path $ConsoleDest "*") -Recurse -Force -ErrorAction SilentlyContinue
} else {
  New-Item -ItemType Directory -Force -Path $ConsoleDest | Out-Null
}
Copy-Item -Path (Join-Path $ConsoleDist "*") -Destination $ConsoleDest -Recurse -Force

Write-Host "[wheel_build] Building wheel + sdist..."
python -m pip install --quiet build
$DistDir = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "dist"))
if (Test-Path -LiteralPath $DistDir) {
  Get-ChildItem -LiteralPath $DistDir -Force -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
python -m build --outdir $DistDir .
if ($LASTEXITCODE -ne 0) { throw "python -m build failed with exit code $LASTEXITCODE" }

Write-Host "[wheel_build] Done. Wheel(s) in: $RepoRoot\dist\"
