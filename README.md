# AxiMate

Enterprise-oriented AI agent platform. **AxiMate** ships as three product lines
(**Spring**, **Confluence**, **Ripple**) built on the native open-source stack
**[Higress](https://github.com/alibaba/higress)** (gateway), **[HiClaw](https://github.com/alibaba/hiclaw)**
(orchestration / multi-agent runtime), and **[CoPaw](https://github.com/agentscope-ai/CoPaw)**
(worker runtime). Each upstream is **Apache License 2.0** — confirm wording in every
release SBOM and each project’s `LICENSE`.

## Product lines (imagery · flow)

| AxiMate name | Role | Upstream |
|--------------|------|----------|
| **AxiMate Spring** | Gateway / unified ingress | Higress (via HiClaw install) |
| **AxiMate Confluence** | Orchestration, Matrix, MinIO | HiClaw |
| **AxiMate Ripple** | Lightweight execution / assistant | CoPaw |

Use full names such as **AxiMate Confluence (Powered by HiClaw)** in external docs to avoid confusion with unrelated products.

This repository holds **product documentation, compliance notes, deployment glue**,
and **per-line integration slots** under `integrations/`. It invokes the **official
HiClaw install script** for cloud installs and does **not** vendor upstream source trees.

## Repository layout

| Path | Role |
|------|------|
| **`integrations/spring/`** | **AxiMate Spring** — gateway notes (Higress) |
| **`integrations/confluence/`** | **AxiMate Confluence** — orchestration notes (HiClaw); install via `deploy/` |
| **`integrations/ripple/`** | **AxiMate Ripple** — start here for CoPaw extensions (**`integrations/ripple/extensions/`**) |
| `deploy/` | Server bootstrap, `.env`, SSH helpers, `install-hiclaw.sh` wrapper |
| `deploy/native/` | Downloads and runs upstream `hiclaw-install.sh` |
| `docs/` | Architecture, **`DIRECTORY.md`**, **`PRODUCT-PACKAGING.md`** (release rules), compliance, **`DEV-RIPPLE.md`** |

**Full directory design:** [`docs/DIRECTORY.md`](docs/DIRECTORY.md).

**Product packaging / release rules (project-wide):** [`docs/PRODUCT-PACKAGING.md`](docs/PRODUCT-PACKAGING.md) — which lines may ship standalone (Ripple, Spring) vs Confluence as full HiClaw stack.

## Monorepo development model

Single Git repo for **AxiMate branding, docs, and deployment automation**. Runtime
binaries and containers come from **HiClaw / Higress / CoPaw** images and installers,
pinned by `HICLAW_VERSION` (and related env vars) in `deploy/.env`.

## Local development (Ripple / CoPaw)

To build on **Ripple** first (without deploying Confluence / HiClaw): follow
**[`docs/DEV-RIPPLE.md`](docs/DEV-RIPPLE.md)** — `pip install copaw` / Docker / upstream
source install, plus Skills and MCP links. Put AxiMate-specific assets under
**`integrations/ripple/extensions/`**.

## Principles

- Prefer **gRPC** or **REST** between services where you extend the stack.
- **MCP** for tools remains aligned with Higress + HiClaw patterns.
- Apache-2.0 obligations: `docs/COMPLIANCE-APACHE2.md`.

## Cloud deployment

Native stack on a VM (AlmaLinux, etc.):

1. Copy `deploy/.env.example` → `deploy/.env` and set **`HICLAW_LLM_API_KEY`** plus provider vars when `HICLAW_NON_INTERACTIVE=1` (see `deploy/README.md`).
2. Run **`deploy/scripts/bootstrap-server.sh`** on the server (or `deploy-remote.ps1 -Bootstrap` from Windows).

Details, ports, and upgrades: **`deploy/README.md`**.

**Automated SSH deploy:** `deploy/scripts/README.md` and `deploy-remote.ps1`.

## Compliance

`LICENSE` and `NOTICE` cover AxiMate-authored files in this repo. Upstream
components carry their own notices — see SBOM per release.

## Disclaimer

Compliance text in `docs/` is operational guidance, not legal advice.
