<#
.SYNOPSIS
  Push latest code to the cloud server via git pull + docker compose (SSH from Windows).

.PARAMETER Bootstrap
  Run first-time Docker install + clone on the server (AlmaLinux/RHEL family).

.EXAMPLE
  .\deploy\scripts\deploy-remote.ps1 -DeployHost 212.50.255.125 -DeployUser root
.EXAMPLE
  .\deploy\scripts\deploy-remote.ps1 -Bootstrap
.EXAMPLE
  Use another key: .\deploy\scripts\deploy-remote.ps1 -SshKey "D:\keys\my_server_key"
#>
[CmdletBinding()]
param(
    [string] $DeployHost = $(if ($global:AximateDeployHost) { $global:AximateDeployHost } else { "212.50.255.125" }),
    [string] $DeployUser = $(if ($global:AximateDeployUser) { $global:AximateDeployUser } else { "root" }),
    [string] $SshKey = $(if ($null -ne $global:AximateSshKey -and '' -ne $global:AximateSshKey) { $global:AximateSshKey } else { Join-Path $env:USERPROFILE ".ssh\id_ed25519" }),
    [string] $DeployDir = $(if ($global:AximateDeployDir) { $global:AximateDeployDir } else { "/opt/aximate" }),
    [string] $GitUrl = $(if ($global:AximateGitUrl) { $global:AximateGitUrl } else { "https://github.com/Jacksonhuf/AxiMate.git" }),
    [switch] $Bootstrap
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = "${DeployUser}@${DeployHost}"

$sshArgs = @()
if ($SshKey -and (Test-Path -LiteralPath $SshKey)) {
    $sshArgs += @("-i", $SshKey)
}

$remoteExports = "export AXIMATE_DEPLOY_DIR='$DeployDir' AXIMATE_GIT_URL='$GitUrl'"

if ($Bootstrap) {
    $scriptPath = Join-Path $scriptDir "bootstrap-server.sh"
} else {
    $scriptPath = Join-Path $scriptDir "update-stack.sh"
}

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Missing script: $scriptPath"
}

$scriptText = Get-Content -LiteralPath $scriptPath -Raw -Encoding utf8
# Windows checkouts may use CRLF; remote bash requires LF or `set -euo pipefail` breaks.
$scriptText = $scriptText -replace "`r`n", "`n" -replace "`r", "`n"
$scriptText = $scriptText.TrimEnd("`r", "`n", " ") + "`n"

# Pipe script to remote bash (LF line endings recommended in repo via .gitattributes)
$scriptText | ssh @sshArgs $target "$remoteExports; bash -s"
