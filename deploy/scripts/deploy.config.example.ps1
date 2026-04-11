# Copy to deploy.config.ps1 (do not commit secrets) and dot-source before deploy-remote.ps1, or pass parameters explicitly.
# Example:
#   . .\deploy\scripts\deploy.config.ps1
#   .\deploy\scripts\deploy-remote.ps1

$global:AximateDeployHost = "212.50.255.125"
$global:AximateDeployUser = "root"
# Optional: path to private key
# $global:AximateSshKey = "$env:USERPROFILE\.ssh\id_ed25519"
$global:AximateDeployDir = "/opt/aximate"
$global:AximateGitUrl = "https://github.com/Jacksonhuf/AxiMate.git"
