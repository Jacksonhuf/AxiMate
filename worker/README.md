# AxiMate Worker

Hosts **MCP** tools and skills (CoPaw / ClawWorker–aligned execution plane).

## Setup

```bash
cd worker
python -m venv .venv
.venv\Scripts\activate
pip install -e ".[dev]"
python -m aximate_worker
```

The default transport is **stdio** (typical for MCP). Integrate with HiClaw or the
Orchestrator by spawning this process or using your chosen MCP client transport.

### HTTP (Docker / cloud)

MCP **Streamable HTTP** for container deployments:

```bash
python -m aximate_worker --transport http
# or: uvicorn aximate_worker.http_app:app --host 0.0.0.0 --port 8090
```

Environment: `AXIMATE_WORKER_HOST`, `AXIMATE_WORKER_PORT`, `AXIMATE_WORKER_LOG_LEVEL`, or
`AXIMATE_WORKER_TRANSPORT=http` as default for `python -m aximate_worker` when no `--transport` is passed.

## Adding a skill

1. Register tools in `aximate_worker/server.py` (or split into modules under `skills/`).
2. Ensure errors are logged with **audit-friendly** context (no secrets in logs).
3. Document input/output schema for Orchestrator contract tests.

## Compliance

Pin third-party versions in SBOM; ship `LICENSE` / `NOTICE` with any bundle that
contains upstream sources or static links to Apache-2.0 libraries.
