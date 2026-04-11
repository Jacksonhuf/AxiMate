# AxiMate

Enterprise-oriented AI agent platform built on Alibaba cloud-native open-source
components: **Gateway** (Higress), **Orchestrator** (HiClaw), **Worker**
(CoPaw / ClawWorker-style MCP skills).

## Repository layout

| Path | Role |
|------|------|
| `gateway/` | Higress integration, Wasm plugins, AI proxy routing |
| `orchestrator/` | Task decomposition, multi-agent coordination, state |
| `worker/` | Tool and skill execution via Model Context Protocol (MCP) |
| `docs/` | Architecture and license compliance |

## Monorepo development model

AxiMate is developed as **one repository** with three logical components (`gateway/`,
`orchestrator/`, `worker/`). This keeps a single **product** and **release story**,
simplifies cross-layer API changes, and centralizes compliance artifacts (`LICENSE`,
`NOTICE`, `docs/COMPLIANCE-APACHE2.md`).

**Guidelines**

- Prefer changes in this repo for first-party Gateway/Orchestrator/Worker code.
- Treat **upstream** projects (Higress, HiClaw, and similar) as **dependencies or
  forks** with pinned versions recorded in release notes and SBOM—not necessarily
  vendored into this tree unless you maintain a fork.
- If a layer later needs its own lifecycle (separate team or cadence), split that
  component into its own repository **only after** stabilizing public APIs and
  documenting version compatibility.

## Principles

- Prefer **gRPC** or **REST** between services.
- Worker capabilities are exposed through **MCP** for consistent tool discovery.
- Upstream Apache-2.0 obligations are tracked in `docs/COMPLIANCE-APACHE2.md`.

## Quick start (development)

Use a **dedicated virtual environment** for AxiMate (for example `python -m venv .venv`
in `orchestrator/` and `worker/` separately). The Worker pulls `mcp`, which may upgrade
`anyio` / `starlette` and conflict with other global packages such as older FastAPI.

Each component has its own README. Typical flow:

1. **Orchestrator**: Python virtualenv, `pip install -e ./orchestrator[dev]`, run the CLI entry point described in `orchestrator/README.md`.
2. **Worker**: `pip install -e ./worker[dev]`, run the MCP host as described in `worker/README.md`.
3. **Gateway**: Follow `gateway/README.md` for Higress/Wasm build and deployment.

## Cloud deployment (Docker Compose)

For a **three-container** demo on a cloud VM (Nginx + orchestrator + worker HTTP), see **`deploy/README.md`**.

```bash
cd deploy && cp .env.example .env && docker compose up -d --build
```

**Automated SSH deploy** (Windows → AlmaLinux): see `deploy/scripts/README.md` and `deploy-remote.ps1 -Bootstrap`.

## Compliance

This repository ships with `LICENSE` and `NOTICE`. Before any release, complete
the checklist in `docs/COMPLIANCE-APACHE2.md` and attach an updated SBOM.

## Disclaimer

Compliance guidance in `docs/` is operational documentation, not legal advice.
