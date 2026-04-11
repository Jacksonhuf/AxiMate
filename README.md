# AxiMate

Enterprise-oriented AI agent platform. **AxiMate is built on the native open-source
stack: [Higress](https://github.com/alibaba/higress) (gateway), [HiClaw](https://github.com/alibaba/hiclaw)
(orchestration / multi-agent runtime), and [CoPaw](https://github.com/agentscope-ai/CoPaw)
(worker runtime inside HiClaw).** Each upstream is **Apache License 2.0** — confirm
wording in every release SBOM and each project’s `LICENSE`.

| Concern | Upstream | Notes |
|---------|----------|--------|
| Gateway | **Higress** | Bundled by HiClaw installer as “Higress AI Gateway” |
| Orchestration | **HiClaw** | Manager–Workers, Matrix, MinIO, etc. |
| Worker engine | **CoPaw** | Choose CoPaw as a Worker type in HiClaw (see HiClaw docs) |

This repository holds **product documentation, compliance notes, and deployment glue**
that invoke the **official HiClaw install script** on your server. It does **not**
vendor or replace those upstreams.

## Repository layout

| Path | Role |
|------|------|
| `deploy/` | Server bootstrap, `.env` template, SSH helpers, native HiClaw installer wrapper |
| `deploy/native/` | Thin script: downloads and runs upstream `hiclaw-install.sh` |
| `docs/` | Architecture, compliance, **CoPaw local dev** (`DEV-COPAW.md`) |
| `copaw-extensions/` | Optional: AxiMate-owned CoPaw skill templates / scripts (see `docs/DEV-COPAW.md`) |

## Monorepo development model

Single Git repo for **AxiMate branding, docs, and deployment automation**. Runtime
binaries and containers come from **HiClaw / Higress / CoPaw** images and installers,
pinned by `HICLAW_VERSION` (and related env vars) in `deploy/.env`.

## Local development (CoPaw)

To build on **CoPaw** first (without deploying HiClaw): follow **`docs/DEV-COPAW.md`** — `pip install copaw` / Docker / upstream source install, plus Skills and MCP links.

## Principles

- Prefer **gRPC** or **REST** between services where you extend the stack.
- **MCP** for tools remains aligned with Higress + HiClaw patterns.
- Apache-2.0 obligations: `docs/COMPLIANCE-APACHE2.md`.

## Cloud deployment

Native stack on a VM (AlmaLinux, etc.):

1. Copy `deploy/.env.example` → `deploy/.env` and set **`HICLAW_LLM_API_KEY`** plus provider vars (`HICLAW_LLM_PROVIDER`, and for Kimi etc. **`HICLAW_OPENAI_BASE_URL`**) when `HICLAW_NON_INTERACTIVE=1` (see `deploy/README.md`).
2. Run **`deploy/scripts/bootstrap-server.sh`** on the server (or `deploy-remote.ps1 -Bootstrap` from Windows).

Details, ports, and upgrades: **`deploy/README.md`**.

**Automated SSH deploy:** `deploy/scripts/README.md` and `deploy-remote.ps1`.

## Compliance

`LICENSE` and `NOTICE` cover AxiMate-authored files in this repo. Upstream
components carry their own notices — see SBOM per release.

## Disclaimer

Compliance text in `docs/` is operational guidance, not legal advice.
