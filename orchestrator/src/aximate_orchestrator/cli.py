from __future__ import annotations

import argparse
import logging
import sys

from aximate_orchestrator import __version__
from aximate_orchestrator.config import load_settings


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="aximate-orchestrator")
    parser.add_argument("--version", action="store_true", help="print version and exit")
    sub = parser.add_subparsers(dest="command")

    serve = sub.add_parser("serve", help="run HTTP placeholder (wire HiClaw later)")
    serve.add_argument("--host", default=None)
    serve.add_argument("--port", type=int, default=None)

    args = parser.parse_args(argv)

    if args.version:
        print(__version__)
        return 0

    if args.command == "serve":
        return _serve(args)

    parser.print_help()
    return 0


def _serve(args: argparse.Namespace) -> int:
    settings = load_settings()
    host = args.host or settings.host
    port = args.port or settings.port

    logging.basicConfig(level=getattr(logging, settings.log_level.upper(), logging.INFO))
    log = logging.getLogger("aximate_orchestrator")

    try:
        from http.server import BaseHTTPRequestHandler, HTTPServer
    except ImportError:
        log.exception("stdlib http.server unavailable")
        return 1

    class _HealthHandler(BaseHTTPRequestHandler):
        def log_message(self, fmt: str, *args_: object) -> None:
            log.info("%s - %s", self.address_string(), fmt % args_)

        def _reject_api_key(self) -> bool:
            if not settings.api_key:
                return False
            if self.headers.get("X-API-Key") != settings.api_key:
                self.send_response(401)
                self.send_header("Content-Type", "application/json")
                msg = b'{"error":"unauthorized","detail":"missing or invalid X-API-Key"}\n'
                self.send_header("Content-Length", str(len(msg)))
                self.end_headers()
                self.wfile.write(msg)
                return True
            return False

        def handle(self) -> None:  # noqa: N802
            if self._reject_api_key():
                return
            super().handle()

        def do_GET(self) -> None:  # noqa: N802
            if self.path in ("/healthz", "/"):
                body = b'{"status":"ok","service":"aximate-orchestrator"}\n'
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return
            self.send_error(404)

    server = HTTPServer((host, port), _HealthHandler)
    log.info("listening on http://%s:%s (placeholder; integrate HiClaw)", host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        log.info("shutting down")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
