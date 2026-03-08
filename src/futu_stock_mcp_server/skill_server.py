"""
Skill endpoint server for OpenClaw intranet mode.
Serves GET /skill with the OpenClaw skill markdown, with {{MCP_SERVER_URL}} replaced by the actual MCP URL.
Runs on mcp_port + 1 when MCP is in streamable-http mode (e.g. 8001 when MCP is on 8000).
"""

import os
import threading
from importlib import resources
from starlette.applications import Starlette
from starlette.requests import Request
from starlette.responses import Response
from starlette.routing import Route

PLACEHOLDER = "{{MCP_SERVER_URL}}"


def _load_skill_template() -> str:
    """Load skill template from package or repo (dev fallback)."""
    try:
        with resources.files(__package__).joinpath("skill_openclaw_intranet.md").open(
            encoding="utf-8"
        ) as f:
            out = f.read()
        if out:
            return out
    except Exception:
        pass
    # Fallback: repo path when running from source (futu-stock-1.0.0/SKILL-OPENCLAW-INTRANET.md)
    try:
        pkg_dir = resources.files(__package__).joinpath(".").resolve()
        repo_root = pkg_dir.parent.parent
        fallback = repo_root / "futu-stock-1.0.0" / "SKILL-OPENCLAW-INTRANET.md"
        if fallback.is_file():
            return fallback.read_text(encoding="utf-8").replace(
                "http://192.168.1.100:8000/mcp", PLACEHOLDER
            )
    except Exception:
        pass
    return ""


def _build_mcp_url(request: Request, mcp_port: int) -> str:
    """Build MCP URL from request Host and configured mcp_port, or use MCP_PUBLIC_URL."""
    public = os.environ.get("MCP_PUBLIC_URL", "").strip()
    if public:
        return public.rstrip("/") if public.endswith("/") else public
    host_header = request.headers.get("host", "")
    if not host_header:
        return f"http://127.0.0.1:{mcp_port}/mcp"
    # Replace port in Host with mcp_port (e.g. host:8001 -> host:8000)
    if ":" in host_header:
        host_part = host_header.rsplit(":", 1)[0]
    else:
        host_part = host_header
    return f"http://{host_part}:{mcp_port}/mcp"


def make_skill_app(mcp_port: int):
    """Create Starlette app that serves GET /skill with URL-replaced skill content."""
    template = _load_skill_template()

    async def skill_route(request: Request) -> Response:
        mcp_url = _build_mcp_url(request, mcp_port)
        body = template.replace(PLACEHOLDER, mcp_url)
        return Response(body, media_type="text/markdown; charset=utf-8")

    return Starlette(
        routes=[
            Route("/skill", skill_route, methods=["GET"]),
            Route("/", skill_route, methods=["GET"]),  # convenience: / also returns skill
        ]
    )


def run_skill_server(mcp_host: str, mcp_port: int) -> threading.Thread:
    """
    Start the skill server in a daemon thread on mcp_port + 1.
    Returns the thread (already started). Skill URL will be http://<host>:<mcp_port+1>/skill
    """
    skill_port = mcp_port + 1
    app = make_skill_app(mcp_port)

    def _run():
        import uvicorn
        uvicorn.run(
            app,
            host=mcp_host,
            port=skill_port,
            log_level="warning",
        )

    t = threading.Thread(target=_run, daemon=True)
    t.start()
    return t
