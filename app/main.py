"""
Gcode AgentOS
=========

Production deployment entry point for Gcode.

Run:
    python -m app.main
"""

from os import getenv
from pathlib import Path

from agno.os import AgentOS

from db import get_postgres_db
from gcode.agent import gcode
from agno.os.interfaces.agui import AGUI
from agno.os.interfaces.a2a import A2A

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
runtime_env = getenv("RUNTIME_ENV", "dev")
scheduler_base_url = getenv("AGENTOS_URL", "http://127.0.0.1:8001")

# ---------------------------------------------------------------------------
# Interfaces
# ---------------------------------------------------------------------------
interfaces: list = [
    AGUI(agent=gcode),
    A2A(agents=[gcode])
]

TELEGRAM_TOKEN = getenv("TELEGRAM_TOKEN", "")
if TELEGRAM_TOKEN:
    from agno.os.interfaces.telegram import Telegram

    interfaces.append(
        Telegram(
            agent=gcode,
            token=TELEGRAM_TOKEN,
            streaming=True,
            reply_to_mentions_only=False,
        )
    )

    TELEGRAM_CHAT_ID = getenv("TELEGRAM_CHAT_ID", "")
    if TELEGRAM_CHAT_ID:
        from agno.tools.telegram import TelegramTools
        gcode.tools.append(TelegramTools())


# ---------------------------------------------------------------------------
# Create AgentOS
# ---------------------------------------------------------------------------
agent_os = AgentOS(
    name="Gcode",
    agents=[gcode],
    interfaces=interfaces,
    tracing=True,
    scheduler=True,
    scheduler_base_url=scheduler_base_url,
    db=get_postgres_db(),
    config=str(Path(__file__).parent / "config.yaml"),
)

app = agent_os.get_app()

if __name__ == "__main__":
    agent_os.serve(
        app="main:app",
        reload=runtime_env == "dev",
    )
