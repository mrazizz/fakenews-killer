"""
FakeNews Killer — Agent package.

Provides the four-agent pipeline:
    Reader  →  Analyst  →  Strategist  →  Executor

Each agent exposes a single ``async run(...)`` function.
"""

from .reader import run as run_reader
from .analyst import run as run_analyst
from .strategist import run as run_strategist
from .executor import run as run_executor

__all__ = ["run_reader", "run_analyst", "run_strategist", "run_executor"]
