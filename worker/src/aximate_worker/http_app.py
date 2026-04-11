"""MCP Streamable HTTP app for cloud / container deployment."""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from mcp.server.fastmcp.server import StreamableHTTPASGIApp
from mcp.server.streamable_http_manager import StreamableHTTPSessionManager
from starlette.applications import Starlette
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette.routing import Route

from aximate_worker.server import server as mcp_server


def create_app() -> Starlette:
    session_manager = StreamableHTTPSessionManager(
        app=mcp_server,
        stateless=True,
    )
    mcp_http = StreamableHTTPASGIApp(session_manager)

    @asynccontextmanager
    async def lifespan(_app: Starlette) -> AsyncIterator[None]:
        async with session_manager.run():
            yield

    async def health(_request: Request) -> JSONResponse:
        return JSONResponse({"status": "ok", "service": "aximate-worker"})

    return Starlette(
        lifespan=lifespan,
        routes=[
            Route("/healthz", health, methods=["GET"]),
            Route("/mcp", mcp_http, methods=["GET", "POST", "DELETE"]),
        ],
    )


# Uvicorn string import: uvicorn aximate_worker.http_app:app
app = create_app()
