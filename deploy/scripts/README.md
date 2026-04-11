# Deploy scripts

Defaults target **AlmaLinux 9** (dnf, firewalld) and clone  
[https://github.com/Jacksonhuf/AxiMate.git](https://github.com/Jacksonhuf/AxiMate.git) for **scripts + `deploy/.env`**.

The server runtime is **native upstream [HiClaw](https://github.com/alibaba/hiclaw)** (includes **Higress**; **CoPaw** as Worker runtime). Not a custom Nginx/Python stack.

| Script | Where it runs | Purpose |
|--------|----------------|---------|
| `bootstrap-server.sh` | Cloud server (root) | Docker + git clone/pull AxiMate, load `deploy/.env`, run `deploy/native/install-hiclaw.sh` |
| `update-stack.sh` | Cloud server | `git pull` + re-run HiClaw installer (upgrade) |
| `deploy-remote.ps1` | Windows | Pipe shell script over SSH |
| `deploy-remote.sh` | Linux/macOS | Same |

## Windows

Default SSH key: `%USERPROFILE%\.ssh\id_ed25519` when the file exists.

**First time**

```powershell
# Edit deploy\.env.example locally, commit is optional; on server cp .env.example .env and set HICLAW_LLM_API_KEY
.\deploy\scripts\deploy-remote.ps1 -Bootstrap
```

**Upgrade (after git push)**

```powershell
.\deploy\scripts\deploy-remote.ps1
```

**Push `deploy/.env` to the server (API key stays off Git)** — defaults match Kimi CN (`openai-compat` + `https://api.moonshot.cn/v1` + `kimi-k2.5`):

```powershell
$env:HICLAW_LLM_API_KEY = 'sk-your-key'
.\deploy\scripts\deploy-remote.ps1 -PushEnv
```

Override with `$env:HICLAW_LLM_PROVIDER`, `HICLAW_OPENAI_BASE_URL`, `HICLAW_DEFAULT_MODEL` if needed.

## Server-only

After pushing this repo to GitHub:

```bash
export AXIMATE_GIT_URL='https://github.com/Jacksonhuf/AxiMate.git'
export AXIMATE_DEPLOY_DIR=/opt/aximate
sudo bash /opt/aximate/deploy/scripts/bootstrap-server.sh
```

## Environment variables

| Variable | Default | Meaning |
|----------|---------|---------|
| `AXIMATE_GIT_URL` | `https://github.com/Jacksonhuf/AxiMate.git` | This repo (scripts) |
| `AXIMATE_DEPLOY_DIR` | `/opt/aximate` | Clone path |
| `AXIMATE_SSH_KEY` | *(Linux script)* `~/.ssh/id_ed25519` if present | `ssh -i` |
| `HICLAW_*` | see `deploy/.env.example` | Passed through to [HiClaw installer](https://raw.githubusercontent.com/alibaba/hiclaw/main/install/hiclaw-install.sh) |

## Security

SSH keys only; put `HICLAW_LLM_API_KEY` (and for `openai-compat`, `HICLAW_OPENAI_BASE_URL`) in server `deploy/.env`, never commit it.
