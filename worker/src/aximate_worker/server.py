from __future__ import annotations

import asyncio
import logging

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

logger = logging.getLogger("aximate_worker")

server = Server("aximate-worker")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="echo",
            description="Return the provided message (connectivity check).",
            inputSchema={
                "type": "object",
                "properties": {"message": {"type": "string", "description": "Text to echo"}},
                "required": ["message"],
            },
        )
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name != "echo":
        logger.warning("unknown tool requested: %s", name)
        raise ValueError(f"unknown tool: {name}")
    message = arguments.get("message", "")
    if not isinstance(message, str):
        raise TypeError("message must be a string")
    logger.info("echo tool invoked", extra={"length": len(message)})
    return [TextContent(type="text", text=message)]


async def run_stdio() -> None:
    logging.basicConfig(level=logging.INFO)
    logger.info("starting MCP stdio server")
    async with stdio_server() as streams:
        await server.run(
            streams[0],
            streams[1],
            server.create_initialization_options(),
        )


def main() -> None:
    asyncio.run(run_stdio())
