# Build AxiMate Ripple Windows installer (conda-pack + NSIS), same pipeline as upstream CoPaw desktop.
# Prerequisites: Miniconda/Conda on PATH, Node/npm for wheel_build, NSIS (makensis on PATH or default under Program Files) unless RIPPLE_SKIP_NSIS=1.
# Run (Windows PowerShell 5.1 — no pwsh required):
#   powershell -ExecutionPolicy Bypass -File "...\integrations\ripple\desktop-windows\Build-RippleWindows.ps1"
# Or PowerShell 7+: pwsh -File ...
# If conda shows WinError 10061 to 127.0.0.1:7897, your HTTP(S)_PROXY points at a local proxy that is off.
# This script clears localhost/loopback proxy vars only for the conda-pack step unless RIPPLE_KEEP_LOCAL_PROXY=1.
# Unzip is much faster with 7-Zip. Set RIPPLE_7Z_EXE to full path of 7z.exe if not under Program Files.
# conda-unpack must run with the packed env root as working directory. RIPPLE_SKIP_CONDA_UNPACK=1 skips it (unsafe for release builds).
# If you changed console assets/branding (favicon/logo), set RIPPLE_FORCE_WHEEL_BUILD=1 so wheel_build runs even if dist already has a wheel.
# Upstream CoPaw tree: integrations/ripple/copaw — Ripple UI in console (patch or local edits).

$ErrorActionPreference = "Stop"

function Get-RippleRemovedLocalhostProxyVars {
  $removed = @{}
  foreach ($n in @(
      'HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY',
      'http_proxy', 'https_proxy', 'all_proxy'
    )) {
    $v = [Environment]::GetEnvironmentVariable($n, 'Process')
    if ([string]::IsNullOrEmpty($v)) { continue }
    if ($v -match '127\.0\.0\.1|localhost|\[::1\]') {
      $removed[$n] = $v
      [Environment]::SetEnvironmentVariable($n, $null, 'Process')
    }
  }
  return $removed
}

function Restore-RippleProxyVars {
  param([hashtable]$Removed)
  if (-not $Removed -or $Removed.Count -eq 0) { return }
  foreach ($k in @($Removed.Keys)) {
    [Environment]::SetEnvironmentVariable($k, $Removed[$k], 'Process')
  }
}

function Get-RippleMakensisExe {
  try {
    return (Get-Command makensis -ErrorAction Stop).Source
  } catch { }
  $pf86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
  $pf = [Environment]::GetEnvironmentVariable("ProgramFiles")
  foreach ($p in @(
      $(if ($pf86) { Join-Path $pf86 "NSIS\makensis.exe" } else { $null }),
      $(if ($pf) { Join-Path $pf "NSIS\makensis.exe" } else { $null }),
      $(if ($pf86) { Join-Path $pf86 "NSIS\Bin\makensis.exe" } else { $null })
    )) {
    if ($p -and (Test-Path -LiteralPath $p)) { return $p }
  }
  return $null
}

function RippleEnsureEmptyUnpackDir {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Recurse -Force }
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
  return [System.IO.Path]::GetFullPath((Get-Item -LiteralPath $Path).FullName)
}

function Expand-RipplePackedEnvZip {
  param(
    [Parameter(Mandatory = $true)][string]$ZipPath,
    [Parameter(Mandatory = $true)][string]$DestinationDir
  )
  if (-not (Test-Path -LiteralPath $ZipPath)) {
    throw "Zip not found: $ZipPath (check build_common output and paths under copaw\dist)"
  }
  $zipFull = [System.IO.Path]::GetFullPath((Get-Item -LiteralPath $ZipPath).FullName)
  $sizeMb = [math]::Round((Get-Item -LiteralPath $zipFull).Length / 1MB, 1)
  Write-Host "[ripple_win] Unzip $sizeMb MB -> $([System.IO.Path]::GetFullPath($DestinationDir))"
  Write-Host "[ripple_win] Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Write-Host "[ripple_win] Large envs: often 10–40+ min. If you see **no new lines**, disk/CPU flicker usually means it is still working."

  $destFull = RippleEnsureEmptyUnpackDir $DestinationDir

  $ok = $false
  $sevenZip = $null
  if ($env:RIPPLE_7Z_EXE -and (Test-Path -LiteralPath $env:RIPPLE_7Z_EXE)) {
    $sevenZip = $env:RIPPLE_7Z_EXE
    Write-Host "[ripple_win] Using 7-Zip from RIPPLE_7Z_EXE=$sevenZip"
  }
  if (-not $sevenZip) {
    $sevenCandidates = @()
    if ($env:ProgramFiles) { $sevenCandidates += (Join-Path $env:ProgramFiles "7-Zip\7z.exe") }
    $pf86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    if ($pf86) { $sevenCandidates += (Join-Path $pf86 "7-Zip\7z.exe") }
    $sevenZip = $sevenCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
  }

  if ($sevenZip) {
    Write-Host "[ripple_win] Using 7-Zip (fast + % progress below): $sevenZip"
    $outArg = "-o$destFull"
    # -bsp1: print progress to console so the window does not look frozen
    & $sevenZip x $zipFull $outArg -y -aoa -bsp1
    if ($LASTEXITCODE -eq 0) { $ok = $true }
    else { Write-Host "[ripple_win] 7z exit $LASTEXITCODE; retrying with tar / Expand-Archive." -ForegroundColor Yellow }
  }

  if (-not $ok -and (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Host "[ripple_win] Using tar (no percentage; heartbeat every 30s)..."
    $destFull = RippleEnsureEmptyUnpackDir $DestinationDir
    $tarExe = (Get-Command tar -ErrorAction Stop).Source
    $p = Start-Process -FilePath $tarExe -ArgumentList @("-xf", $zipFull, "-C", $destFull) -NoNewWindow -PassThru
    while (-not $p.HasExited) {
      Start-Sleep -Seconds 30
      Write-Host "[ripple_win] tar still running... $(Get-Date -Format 'HH:mm:ss')"
    }
    $p.WaitForExit()
    if ($p.ExitCode -eq 0) { $ok = $true }
    else {
      Write-Host "[ripple_win] tar exit $($p.ExitCode); falling back to Expand-Archive." -ForegroundColor Yellow
    }
  } elseif (-not $ok -and -not (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Host "[ripple_win] tar not found." -ForegroundColor Yellow
  }

  if (-not $ok) {
    Write-Host "[ripple_win] Using Expand-Archive (slowest path; install 7-Zip next time)." -ForegroundColor Yellow
    $destFull = RippleEnsureEmptyUnpackDir $DestinationDir
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "[ripple_win] Running Expand-Archive in a background job — you will see a line every 45s while it runs."
    $unzipJob = Start-Job -ScriptBlock {
      param($z, $d)
      Expand-Archive -LiteralPath $z -DestinationPath $d -Force
    } -ArgumentList $zipFull, $destFull
    try {
      while ($unzipJob.State -eq 'Running') {
        Start-Sleep -Seconds 45
        if ($unzipJob.State -eq 'Running') {
          Write-Host "[ripple_win] Expand-Archive still running... $(Get-Date -Format 'HH:mm:ss') (install 7-Zip to avoid this slow path)"
        }
      }
      try {
        Receive-Job $unzipJob -ErrorAction Stop
      } catch {
        throw "Expand-Archive failed: $_"
      }
      if ($unzipJob.State -ne 'Completed') {
        throw "Expand-Archive job ended as $($unzipJob.State). Install 7-Zip; verify copaw-env.zip and disk space."
      }
    } finally {
      Remove-Job $unzipJob -Force -ErrorAction SilentlyContinue
    }
    $sw.Stop()
    Write-Host "[ripple_win] Expand-Archive finished in $([math]::Round($sw.Elapsed.TotalMinutes, 1)) min"
  }
  Write-Host "[ripple_win] Unpack complete at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

$RipplePackRoot = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $RipplePackRoot "..\copaw")).Path
Set-Location $RepoRoot
Write-Host "[ripple_win] COPAW_REPO=$RepoRoot"
$PackDir = Join-Path $RepoRoot "scripts\pack"
$DistName = if ($env:DIST) { $env:DIST } else { "dist" }
$DistRoot = Join-Path $RepoRoot $DistName
$Archive = Join-Path $DistRoot "copaw-env.zip"
$Unpacked = Join-Path $DistRoot "win-unpacked"
$NsiPath = Join-Path $RipplePackRoot "ripple_desktop.nsi"

# Same list as copaw scripts/pack/build_common.py CONDA_UNPACK_AFFECTED_PACKAGES (conda-pack issue #154).
$CondaUnpackAffectedPackages = @("huggingface_hub", "docker", "pywin32")

New-Item -ItemType Directory -Force -Path $DistRoot | Out-Null

$has7zEarly = ($env:RIPPLE_7Z_EXE -and (Test-Path -LiteralPath $env:RIPPLE_7Z_EXE))
if (-not $has7zEarly) {
  $sevenEarly = @()
  if ($env:ProgramFiles) { $sevenEarly += (Join-Path $env:ProgramFiles "7-Zip\7z.exe") }
  $pf86e = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
  if ($pf86e) { $sevenEarly += (Join-Path $pf86e "7-Zip\7z.exe") }
  $has7zEarly = [bool]($sevenEarly | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1)
}
if (-not $has7zEarly) {
  Write-Host ""
  Write-Host ">>> RIPPLE: 7-Zip not found — unzip will be slow. Install from https://www.7-zip.org/  or:  winget install 7zip.7zip" -ForegroundColor Yellow
  Write-Host ">>> Optional: add Windows Defender exclusion for faster unpack: $DistRoot" -ForegroundColor DarkYellow
  Write-Host ""
}

Write-Host "== Building wheel (Ripple console frontend bundled into wheel) =="
$VersionFile = Join-Path $RepoRoot "src\copaw\__version__.py"
$CurrentVersion = ""
if (Test-Path $VersionFile) {
  $verMatch = [regex]::Match((Get-Content $VersionFile -Raw), '__version__\s*=\s*"([^"]+)"')
  if ($verMatch.Success) { $CurrentVersion = $verMatch.Groups[1].Value }
}
$RunWheelBuild = $true
if ($CurrentVersion) {
  $wheelGlob = Join-Path $DistRoot "copaw-$CurrentVersion-*.whl"
  $existingWheels = Get-ChildItem -Path $wheelGlob -ErrorAction SilentlyContinue
  if ($existingWheels.Count -gt 0) {
    if ($env:RIPPLE_FORCE_WHEEL_BUILD -eq "1") {
      Write-Host "RIPPLE_FORCE_WHEEL_BUILD=1: rebuilding wheel even though dist already has $CurrentVersion."
    } else {
      Write-Host "dist/ already has wheel for version $CurrentVersion, skipping wheel_build."
      $RunWheelBuild = $false
    }
  } else {
    $oldWheels = Get-ChildItem -Path (Join-Path $DistRoot "copaw-*.whl") -ErrorAction SilentlyContinue
    if ($oldWheels.Count -gt 0) {
      Write-Host "Removing old wheel files: $($oldWheels | ForEach-Object { $_.Name })"
      $oldWheels | Remove-Item -Force
    }
  }
}
if ($RunWheelBuild) {
  $WheelBuildScript = Join-Path $RepoRoot "scripts\wheel_build.ps1"
  if (-not (Test-Path $WheelBuildScript)) { throw "wheel_build.ps1 not found: $WheelBuildScript" }
  & $WheelBuildScript
  if ($LASTEXITCODE -ne 0) { throw "wheel_build.ps1 failed with exit code $LASTEXITCODE" }
}

Write-Host "== Building conda-packed env =="
$proxyBackup = @{}
if ($env:RIPPLE_KEEP_LOCAL_PROXY -ne "1") {
  $proxyBackup = Get-RippleRemovedLocalhostProxyVars
  if ($proxyBackup.Count -gt 0) {
    Write-Host "[ripple_win] Unset localhost proxy env for this step (avoids 127.0.0.1:7897 refused when Clash/V2Ray is off)."
    Write-Host "[ripple_win] To keep proxy vars: set RIPPLE_KEEP_LOCAL_PROXY=1 and ensure your local proxy is running."
  }
}
try {
  & python $PackDir\build_common.py --output $Archive --format zip --cache-wheels
  if ($LASTEXITCODE -ne 0) { throw "build_common.py failed with exit code $LASTEXITCODE" }
} finally {
  Restore-RippleProxyVars $proxyBackup
}
if (-not (Test-Path $Archive)) { throw "Archive not created: $Archive" }

Write-Host "== Unpacking env =="
Write-Host "[ripple_win] Archive (absolute): $Archive"
try {
  Expand-RipplePackedEnvZip -ZipPath $Archive -DestinationDir $Unpacked
} catch {
  Write-Host "[ripple_win] Unpack failed: $_" -ForegroundColor Red
  throw
}

$EnvRoot = $Unpacked
if (-not (Test-Path (Join-Path $EnvRoot "python.exe"))) {
  $found = Get-ChildItem -Path $Unpacked -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName "python.exe") } |
    Select-Object -First 1
  if ($found) { $EnvRoot = $found.FullName; Write-Host "[ripple_win] Env root: $EnvRoot" }
}
if (-not (Test-Path (Join-Path $EnvRoot "python.exe"))) {
  throw "python.exe not found in unpacked env (checked $Unpacked and one level down)."
}
if (-not [System.IO.Path]::IsPathRooted($EnvRoot)) {
  $EnvRoot = Join-Path $RepoRoot $EnvRoot
}
Write-Host "[ripple_win] python.exe at: $EnvRoot"

$CondaUnpack = Join-Path $EnvRoot "Scripts\conda-unpack.exe"
if (Test-Path $CondaUnpack) {
  Write-Host "[ripple_win] Running conda-unpack (may touch 90k+ files; CPU often ~0% while Disk is busy — normal)..."
  Write-Host "[ripple_win] Stuck? Move repo to a short path (e.g. C:\b\copaw), exclude win-unpacked from Defender, close apps locking Python under that tree."

  if ($env:RIPPLE_SKIP_CONDA_UNPACK -eq "1") {
    Write-Host "[ripple_win] WARN: RIPPLE_SKIP_CONDA_UNPACK=1 — skipping conda-unpack. Packaged app may break unless paths match build host; only for debugging." -ForegroundColor Red
  } else {
    # Must run with env root as CWD so prefix rewriting matches conda-pack layout
    $cup = Start-Process -FilePath $CondaUnpack -WorkingDirectory $EnvRoot -NoNewWindow -PassThru
    while (-not $cup.HasExited) {
      Start-Sleep -Seconds 60
      Write-Host "[ripple_win] conda-unpack still running... $(Get-Date -Format 'HH:mm:ss')  (watch Task Manager -> Disk for $EnvRoot drive)"
    }
    $cup.WaitForExit()
    if ($cup.ExitCode -ne 0) { throw "conda-unpack failed with exit code $($cup.ExitCode)" }
  }

  Write-Host "[ripple_win] Reinstalling packages affected by conda-unpack on Windows..."
  $WheelsCache = Join-Path $RepoRoot ".cache\conda_unpack_wheels"
  $pythonExe = Join-Path $EnvRoot "python.exe"
  $useWheelCache = Test-Path $WheelsCache
  if (-not $useWheelCache) {
    Write-Host "[ripple_win] WARN: wheels cache missing at $WheelsCache; will use PyPI for reinstalls." -ForegroundColor Yellow
  }
  foreach ($pkg in $CondaUnpackAffectedPackages) {
    Write-Host "  Reinstalling $pkg..."
    if ($useWheelCache) {
      & $pythonExe -m pip install --force-reinstall --no-deps `
        --find-links $WheelsCache --no-index $pkg
    }
    if (-not $useWheelCache -or $LASTEXITCODE -ne 0) {
      Write-Host "  Retrying $pkg from PyPI..." -ForegroundColor DarkYellow
      & $pythonExe -m pip install --force-reinstall --no-deps $pkg
    }
    if ($LASTEXITCODE -ne 0) { throw "Failed to reinstall $pkg after conda-unpack (fix conda-pack / pip)." }
  }
  & $pythonExe -c "from huggingface_hub import file_download; print('huggingface_hub OK')"
  if ($LASTEXITCODE -ne 0) { throw "huggingface_hub import failed after reinstall." }
  & $pythonExe -c "import docker.constants; print('docker OK')"
  if ($LASTEXITCODE -ne 0) { throw "docker import failed after reinstall." }
  & $pythonExe -c "import win32api; print('pywin32 OK')"
  if ($LASTEXITCODE -ne 0) { throw "pywin32 import failed after reinstall." }
} else {
  Write-Host "[ripple_win] WARN: conda-unpack.exe not found, skipping." -ForegroundColor Yellow
}

Write-Host "== Pre-compiling Python bytecode =="
$pythonExe = Join-Path $EnvRoot "python.exe"
if (Test-Path $pythonExe) {
  & $pythonExe -m compileall -q -j 0 $EnvRoot
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[ripple_win] WARN: compileall reported errors (often third-party test files); if the checks above passed, the app may still run." -ForegroundColor Yellow
  }
}

$LauncherBat = Join-Path $EnvRoot "Ripple Desktop.bat"
@"
@echo off
cd /d "%~dp0"

set "PATH=%~dp0;%~dp0Scripts;%PATH%"

if not defined COPAW_LOG_LEVEL set "COPAW_LOG_LEVEL=info"

set "CERT_TMP=%TEMP%\copaw_cert_%RANDOM%.txt"
"%~dp0python.exe" -u -c "import certifi; print(certifi.where())" > "%CERT_TMP%" 2>nul
set /p CERT_FILE=<"%CERT_TMP%"
del "%CERT_TMP%" 2>nul
if defined CERT_FILE (
  if exist "%CERT_FILE%" (
    set "SSL_CERT_FILE=%CERT_FILE%"
    set "REQUESTS_CA_BUNDLE=%CERT_FILE%"
    set "CURL_CA_BUNDLE=%CERT_FILE%"
  )
)

if not exist "%USERPROFILE%\.copaw\config.json" (
  "%~dp0python.exe" -u -m copaw init --defaults --accept-security
)
"%~dp0python.exe" -u -m copaw desktop --log-level %COPAW_LOG_LEVEL%
"@ | Set-Content -Path $LauncherBat -Encoding ASCII

$DebugBat = Join-Path $EnvRoot "Ripple Desktop (Debug).bat"
@"
@echo off
cd /d "%~dp0"

set "PATH=%~dp0;%~dp0Scripts;%PATH%"

if not defined COPAW_LOG_LEVEL set "COPAW_LOG_LEVEL=debug"

set "CERT_TMP=%TEMP%\copaw_cert_%RANDOM%.txt"
"%~dp0python.exe" -u -c "import certifi; print(certifi.where())" > "%CERT_TMP%" 2>nul
set /p CERT_FILE=<"%CERT_TMP%"
del "%CERT_TMP%" 2>nul
if defined CERT_FILE (
  if exist "%CERT_FILE%" (
    set "SSL_CERT_FILE=%CERT_FILE%"
    set "REQUESTS_CA_BUNDLE=%CERT_FILE%"
    set "CURL_CA_BUNDLE=%CERT_FILE%"
  )
)

echo ====================================
echo Ripple Console (Powered by CoPaw) - Debug
echo ====================================
echo Working Directory: %cd%
echo Python: "%~dp0python.exe"
echo Log Level: %COPAW_LOG_LEVEL%
echo.
if not exist "%USERPROFILE%\.copaw\config.json" (
  echo [Init] Creating config...
  "%~dp0python.exe" -u -m copaw init --defaults --accept-security
)
echo [Launch] copaw desktop --log-level=%COPAW_LOG_LEVEL%
echo.
"%~dp0python.exe" -u -m copaw desktop --log-level %COPAW_LOG_LEVEL%
echo.
pause
"@ | Set-Content -Path $DebugBat -Encoding ASCII

$LauncherVbs = Join-Path $EnvRoot "Ripple Desktop.vbs"
@"
Set WshShell = CreateObject("WScript.Shell")
batPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\Ripple Desktop.bat"
WshShell.Run Chr(34) & batPath & Chr(34), 0, False
Set WshShell = Nothing
"@ | Set-Content -Path $LauncherVbs -Encoding ASCII

$CopawCmd = Join-Path $EnvRoot "copaw.cmd"
@"
@"%~dp0python.exe" -u -m copaw %*
"@ | Set-Content -Path $CopawCmd -Encoding ASCII

$IconSrc = Join-Path $RipplePackRoot "assets\icon.ico"
if (Test-Path $IconSrc) {
  Copy-Item $IconSrc -Destination $EnvRoot -Force
  Write-Host "[ripple_win] Copied icon.ico to env root"
} else {
  Write-Host "[ripple_win] WARN: icon.ico not found at $IconSrc" -ForegroundColor Yellow
}

Write-Host "== Building NSIS (Ripple-Setup) =="
if ($env:RIPPLE_SKIP_NSIS -eq "1") {
  Write-Host "RIPPLE_SKIP_NSIS=1: skipping makensis. Portable tree (zip the folder or run Ripple Desktop.bat):"
  Write-Host "  $((Resolve-Path $EnvRoot).Path)"
  exit 0
}

$Version = $CurrentVersion
if (-not $Version) {
  try {
    $Version = (& (Join-Path $EnvRoot "python.exe") -c "from importlib.metadata import version; print(version('copaw'))" 2>&1) -replace '\s+$', ''
  } catch { }
}
if (-not $Version) { $Version = "0.0.0"; Write-Host "[ripple_win] WARN: fallback version 0.0.0" }
Write-Host "[ripple_win] Version: $Version"

$OutInstaller = Join-Path $DistRoot "Ripple-Setup-$Version.exe"
$UnpackedFull = (Resolve-Path $EnvRoot).Path
$OutputExeNsi = [System.IO.Path]::GetFullPath($OutInstaller)

if (-not (Test-Path $NsiPath)) { throw "NSIS script not found: $NsiPath" }

$makensisExe = Get-RippleMakensisExe
if (-not $makensisExe) {
  throw "makensis not found. Install NSIS from https://nsis.sourceforge.io/ and either add it to PATH or use the default install folder (Program Files (x86)\NSIS)."
}
Write-Host "[ripple_win] makensis: $makensisExe"

$nsiArgs = @(
  "/DCOPAW_VERSION=$Version",
  "/DOUTPUT_EXE=$OutputExeNsi",
  "/DUNPACKED=$UnpackedFull",
  $NsiPath
)
Write-Host "[ripple_win] makensis $($nsiArgs -join ' ')"
$nsisOutput = & $makensisExe @nsiArgs 2>&1 | Out-String
Write-Host $nsisOutput
if ($LASTEXITCODE -ne 0) { throw "makensis failed with exit code $LASTEXITCODE" }
if (-not (Test-Path $OutInstaller)) { throw "Installer not created: $OutInstaller" }
Write-Host "== Done: $OutInstaller =="
