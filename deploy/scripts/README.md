# Deploy scripts

Defaults target **AlmaLinux 9** (dnf, firewalld) and the public repo  
[https://github.com/Jacksonhuf/AxiMate.git](https://github.com/Jacksonhuf/AxiMate.git).  
Override with environment variables or PowerShell parameters.

| Script | Where it runs | Purpose |
|--------|----------------|---------|
| `bootstrap-server.sh` | Cloud server (root) | Install Docker + Compose, clone/pull repo, create `deploy/.env`, `docker compose up` |
| `update-stack.sh` | Cloud server | `git pull --ff-only` + rebuild/restart stack |
| `deploy-remote.ps1` | Your Windows PC | Pipes the shell script over **SSH** (no separate SCP step) |
| `deploy-remote.sh` | Linux/macOS laptop | Same as above using OpenSSH client |

## Windows (from repo root)

By default **deploy-remote.ps1** uses **`%USERPROFILE%\.ssh\id_ed25519`** when that file exists (same as `Join-Path $env:USERPROFILE '.ssh\id_ed25519'`). Override with `-SshKey "D:\path\to\key"` if needed.

First time on a fresh VM:

```powershell
.\deploy\scripts\deploy-remote.ps1 -Bootstrap
```

Later updates (after `git push`):

```powershell
.\deploy\scripts\deploy-remote.ps1
```

Optional: copy `deploy.config.example.ps1` to `deploy.config.ps1` (gitignored), edit host/user/key, then:

```powershell
. .\deploy\scripts\deploy.config.ps1
.\deploy\scripts\deploy-remote.ps1
```

## Server-only (SSH session on the VM)

```bash
export AXIMATE_GIT_URL='https://github.com/Jacksonhuf/AxiMate.git'
export AXIMATE_DEPLOY_DIR=/opt/aximate
curl -fsSL https://raw.githubusercontent.com/Jacksonhuf/AxiMate/main/deploy/scripts/bootstrap-server.sh | bash
```

(Only works after you have pushed `main` to GitHub; otherwise `scp` the script or clone the repo first.)

Or after cloning manually:

```bash
sudo bash deploy/scripts/bootstrap-server.sh
sudo bash deploy/scripts/update-stack.sh
```

## Environment variables

| Variable | Default | Meaning |
|----------|---------|---------|
| `AXIMATE_GIT_URL` | `https://github.com/Jacksonhuf/AxiMate.git` | Clone/pull URL (use token in URL for private repos — do not log) |
| `AXIMATE_DEPLOY_DIR` | `/opt/aximate` | Install path on server |
| `AXIMATE_SSH_KEY` | *(unset)*; if unset and `~/.ssh/id_ed25519` exists, **deploy-remote.sh** uses it | Identity file for `ssh -i` (Linux/macOS script only) |

## Security

- Use **SSH keys**, not passwords in scripts.
- Do **not** commit GitHub tokens or production secrets; keep them in server `deploy/.env` only.
- Your server IP and root user appear only as **defaults** you can override; restrict SSH (`AllowUsers`, firewall, key-only auth) on the VM.
