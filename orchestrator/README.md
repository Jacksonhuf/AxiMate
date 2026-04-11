# AxiMate Orchestrator

**HiClaw**-oriented service: task decomposition, multi-agent coordination,
and durable workflow state (implementation to be wired to your HiClaw deployment).

## Setup

```bash
cd orchestrator
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -e ".[dev]"
aximate-orchestrator --help
```

## API surface

Expose **gRPC** and/or **REST** to the Gateway and call Workers via **MCP** or internal RPC as defined in your deployment.

## Compliance

List HiClaw and transitive Apache-2.0 dependencies in the release SBOM; retain upstream `NOTICE` when redistributing.
