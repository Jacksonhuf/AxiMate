# AxiMate cloud deployment (Docker Compose)

This stack runs three containers: **gateway** (Nginx demo front), **orchestrator**, and **worker** (MCP over **Streamable HTTP** on `/mcp`).

It is suitable for **integration testing** on a cloud VM. Replace Nginx with **Higress** when you move to production.

## Prerequisites

- Docker Engine 24+ and Docker Compose v2
- Open the chosen host port (default **80**) in your cloud security group / firewall

## Deploy

From the **repository root**:

```bash
cd deploy
cp .env.example .env
# Edit .env: AXIMATE_PUBLIC_HOST, optional AXIMATE_GATEWAY_BASIC_*, AXIMATE_ORCH_API_KEY

docker compose up -d --build
```

Or from the repo root in one line:

```bash
docker compose -f deploy/docker-compose.yml --env-file deploy/.env up -d --build
```

## Health checks

Replace `YOUR_HOST` with `AXIMATE_PUBLIC_HOST` (or `localhost` if you tunnel / test locally).

```bash
curl -s "http://YOUR_HOST/healthz"
curl -s "http://YOUR_HOST/api/orchestrator/healthz"
curl -s "http://YOUR_HOST/api/worker/healthz"
```

With HTTP Basic on the gateway:

```bash
curl -s -u "USER:PASS" "http://YOUR_HOST/api/orchestrator/healthz"
```

With orchestrator API key (header is forwarded by Nginx):

```bash
curl -s -H "X-API-Key: YOUR_KEY" "http://YOUR_HOST/api/orchestrator/healthz"
```

## MCP (Worker) URL

Clients that support MCP Streamable HTTP should use the gateway path:

```text
http://YOUR_HOST/api/worker/mcp
```

(Use HTTPS and a real domain in production.)

## Automated deploy (AlmaLinux + Windows)

Official Git remote: [github.com/Jacksonhuf/AxiMate](https://github.com/Jacksonhuf/AxiMate).

1. **Push this repository** to GitHub (the remote above must contain `deploy/` and Compose files).
2. On your cloud VM (**AlmaLinux 9**), ensure SSH access (e.g. `ssh root@212.50.255.125` with a key).
3. From your **Windows** dev machine, in the cloned repo:

   ```powershell
   .\deploy\scripts\deploy-remote.ps1 -Bootstrap
   ```

   Subsequent releases:

   ```powershell
   git push
   .\deploy\scripts\deploy-remote.ps1
   ```

See **`deploy/scripts/README.md`** for `deploy-remote.sh`, environment variables, and private-repo notes.

## Notes

- **Line endings**: `deploy/gateway/docker-entrypoint.sh` must use **LF** inside the Linux image. If the gateway container fails to start on Windows checkouts, run `dos2unix` or set Git `core.autocrlf` appropriately.
- **Monorepo**: build `context` is the **repository root** so both `orchestrator/` and `worker/` sources are available to their Dockerfiles.
