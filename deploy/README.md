# AxiMate cloud deployment (native upstream stack)

This repository **does not** ship a custom Nginx/Python gateway/orchestrator/worker stack.

Cloud deployment runs the **upstream [HiClaw](https://github.com/alibaba/hiclaw)** installer, which includes:

- **[Higress](https://github.com/alibaba/higress)** — AI Gateway (LLM proxy, MCP, credentials)
- **HiClaw Manager / Workers** — multi-agent orchestration (Matrix, MinIO, etc.)
- **[CoPaw](https://github.com/agentscope-ai/CoPaw)** — selectable **Worker runtime** inside HiClaw (not a separate compose service in this repo)

All three upstreams are **Apache-2.0** (verify each repo `LICENSE` in your SBOM).

## Prerequisites

- AlmaLinux / RHEL-family or similar, **root** SSH
- Docker Engine + Compose plugin (installed by `bootstrap-server.sh` if missing)
- Open firewall ports for HiClaw defaults (script opens them when firewalld is on):
  - `18088` — Element Web  
  - `18080` — Higress gateway (default host port)  
  - `18001` — Higress console  
  - `18888` — Manager console  
  - `8443` — TLS entry (if used)

Override with `HICLAW_PORT_*` in `deploy/.env` (see upstream installer).

## LLM API Key（阿里云百炼）

本仓库约定的云上安装方式使用 **阿里云百炼（DashScope）** 的 API Key 填入 **`HICLAW_LLM_API_KEY`**（与 HiClaw Quick Start 中的阿里系模型路径一致）。请在 [阿里云百炼 / DashScope 控制台](https://bailian.console.aliyun.com/) 创建 API Key，写入服务器上的 `deploy/.env`，**勿提交到 Git**。

`deploy/.env.example` 中默认 **`HICLAW_LLM_PROVIDER=alibaba-cloud`**；若改用其它供应商，需自行对照 [HiClaw 安装脚本](https://raw.githubusercontent.com/alibaba/hiclaw/main/install/hiclaw-install.sh) 中的环境变量说明（与 AxiMate 产品约定无关时不在此展开）。

## First-time deploy

```bash
cd deploy
cp .env.example .env
# Edit .env: set HICLAW_LLM_API_KEY (百炼) and any optional HICLAW_* vars
```

On the server (or from Windows: `deploy-remote.ps1 -Bootstrap`):

```bash
sudo bash deploy/scripts/bootstrap-server.sh
```

If `.env` was just created, the script exits and asks you to fill `HICLAW_LLM_API_KEY`, then run again.

## Upgrade

After `git push`, from your PC:

```powershell
.\deploy\scripts\deploy-remote.ps1
```

Or on the server:

```bash
sudo bash /opt/aximate/deploy/scripts/update-stack.sh
```

## Interactive install

Set `HICLAW_NON_INTERACTIVE=0` in `deploy/.env` and run the bootstrap again (SSH session with TTY). You can omit `HICLAW_LLM_API_KEY` in the file and enter it in the wizard.

## Standalone CoPaw Web UI (optional)

HiClaw uses CoPaw as a **Worker** engine. If you also want the standalone CoPaw browser app, follow  
[agentscope-ai/CoPaw](https://github.com/agentscope-ai/CoPaw) (`docker run … agentscope/copaw`) — that is **separate** from this deploy path and may overlap functionally; use only if you need both.

## Migrating from the old AxiMate demo stack

Earlier revisions used a local `docker-compose` (Nginx + Python). If those containers still run (e.g. on port **80**), remove them before relying on HiClaw ports:

```bash
docker rm -f deploy-gateway-1 deploy-orchestrator-1 deploy-worker-1 2>/dev/null || true
docker compose -f /opt/aximate/deploy/docker-compose.yml down --remove-orphans 2>/dev/null || true
```

## References

- HiClaw install script (env vars): `https://raw.githubusercontent.com/alibaba/hiclaw/main/install/hiclaw-install.sh`
- Higress standalone / Helm: [Higress docs](https://higress.io/)
