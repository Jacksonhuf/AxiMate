from __future__ import annotations

import argparse
import asyncio
import logging
import os
import sys


def main() -> None:
    default_transport = os.environ.get("AXIMATE_WORKER_TRANSPORT", "stdio").lower()
    parser = argparse.ArgumentParser(prog="python -m aximate_worker")
    parser.add_argument(
        "--transport",
        choices=("stdio", "http"),
        default=default_transport if default_transport in ("stdio", "http") else "stdio",
        help="stdio for local MCP clients; http for Docker / cloud (MCP Streamable HTTP)",
    )
    args = parser.parse_args()

    if args.transport == "stdio":
        from aximate_worker.server import run_stdio

        asyncio.run(run_stdio())
        return

    import uvicorn

    from aximate_worker.config import load_worker_settings
    from aximate_worker.http_app import create_app

    settings = load_worker_settings()
    logging.basicConfig(level=getattr(logging, settings.log_level.upper(), logging.INFO))
    uvicorn.run(
        create_app(),
        host=settings.host,
        port=settings.port,
        log_level=settings.log_level.lower(),
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
