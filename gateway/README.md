# AxiMate Gateway

Integration point for **Higress**: authentication, AI proxy, multi-model routing,
and **Wasm** extensions (for example sensitive-input checks and token accounting).

## Layout

| Path | Purpose |
|------|---------|
| `wasm/` | Wasm-Go (or TinyGo) plugin sources built with the Higress/Envoy Wasm SDK |

## Development notes

- Plugins must **not block streaming responses**; do heavy work asynchronously or on bounded buffers.
- Record upstream **Higress version** and include `LICENSE` / `NOTICE` in release images per `docs/COMPLIANCE-APACHE2.md`.

## Next steps

1. Pin a Higress release and document the chart or operator version in the root README.
2. Add a Wasm plugin project under `wasm/` with its own `go.mod` when implementation starts.
