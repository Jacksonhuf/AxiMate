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
.EXAMPLE
  Write server deploy/.env from env then upgrade (never commit .env):
    $env:HICLAW_LLM_API_KEY = 'sk-...'
    .\deploy\scripts\deploy-remote.ps1 -PushEnv
#>
[CmdletBinding()]
param(
    [string] $DeployHost = $(if ($global:AximateDeployHost) { $global:AximateDeployHost } else { "212.50.255.125" }),
    [string] $DeployUser = $(if ($global:AximateDeployUser) { $global:AximateDeployUser } else { "root" }),
    [string] $SshKey = $(if ($null -ne $global:AximateSshKey -and '' -ne $global:AximateSshKey) { $global:AximateSshKey } else { Join-Path $env:USERPROFILE ".ssh\id_ed25519" }),
    [string] $DeployDir = $(if ($global:AximateDeployDir) { $global:AximateDeployDir } else { "/opt/aximate" }),
    [string] $GitUrl = $(if ($global:AximateGitUrl) { $global:AximateGitUrl } else { "https://github.com/Jacksonhuf/AxiMate.git" }),
    [switch] $Bootstrap,
    [switch] $PushEnv,
    [string] $LlmProvider = $(if ($env:HICLAW_LLM_PROVIDER) { $env:HICLAW_LLM_PROVIDER } else { "openai-compat" }),
    [string] $OpenAiBaseUrl = $(if ($env:HICLAW_OPENAI_BASE_URL) { $env:HICLAW_OPENAI_BASE_URL } else { "https://api.moonshot.cn/v1" }),
    [string] $DefaultModel = $(if ($env:HICLAW_DEFAULT_MODEL) { $env:HICLAW_DEFAULT_MODEL } else { "kimi-k2.5" }),
    [string] $LlmApiKey = $env:HICLAW_LLM_API_KEY
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = "${DeployUser}@${DeployHost}"

$sshArgs = @()
if ($SshKey -and (Test-Path -LiteralPath $SshKey)) {
    $sshArgs += @("-i", $SshKey)
}

$remoteExports = "export AXIMATE_DEPLOY_DIR='$DeployDir' AXIMATE_GIT_URL='$GitUrl'"

$scpArgs = @()
if ($SshKey -and (Test-Path -LiteralPath $SshKey)) {
    $scpArgs += @("-i", $SshKey)
}

if ($PushEnv) {
    if (-not $LlmApiKey -or $LlmApiKey.Trim().Length -eq 0) {
        throw "PushEnv requires HICLAW_LLM_API_KEY in the environment (or pass -LlmApiKey). Example: `$env:HICLAW_LLM_API_KEY='sk-...'; .\deploy\scripts\deploy-remote.ps1 -PushEnv"
    }
    $envContent = @"
HICLAW_NON_INTERACTIVE=1
HICLAW_LLM_PROVIDER=$LlmProvider
HICLAW_OPENAI_BASE_URL=$OpenAiBaseUrl
HICLAW_DEFAULT_MODEL=$DefaultModel
HICLAW_LLM_API_KEY=$LlmApiKey
"@
    $envContent = $envContent -replace "`r`n", "`n" -replace "`r", "`n"
    $tmpEnv = Join-Path $env:TEMP ("aximate-deploy-env-" + [Guid]::NewGuid().ToString("n") + ".env")
    try {
        [System.IO.File]::WriteAllText($tmpEnv, $envContent.TrimEnd() + "`n", [System.Text.UTF8Encoding]::new($false))
        $remotePath = "${DeployDir}/deploy/.env"
        $checkRepo = "test -d `"${DeployDir}/.git`" || { echo `"${DeployDir} is not a git clone (run -Bootstrap first).`" >&2; exit 1; }"
        ssh @sshArgs $target $checkRepo
        & scp @scpArgs -q $tmpEnv "${target}:${remotePath}"
        ssh @sshArgs $target "chmod 600 `"${remotePath}`""
    }
    finally {
        Remove-Item -LiteralPath $tmpEnv -Force -ErrorAction SilentlyContinue
    }
}

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
