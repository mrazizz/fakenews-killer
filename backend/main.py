"""
FakeNews Killer — FastAPI entry point.

Endpoints:
    POST /analyze   →  Run the 4-agent pipeline on submitted text.
    GET  /tracker   →  List all misinformation tracker entries.
    POST /tracker   →  Insert a new tracker entry manually.
    GET  /health    →  Simple health-check.

Start the server:
    uvicorn main:app --reload
"""

import sys
import os
from pathlib import Path

# ── make project root importable ──
ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import json as json_module
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv

from models.schemas import (
    AnalyzeRequest,
    AnalyzeResponse,
    TrackerEntry,
    HealthResponse,
)
from models.database import get_db, get_all_tracker_entries, insert_tracker_entry
from agents import run_reader, run_analyst, run_strategist, run_executor

# ── load env ──
load_dotenv(ROOT / ".env.local")
load_dotenv(ROOT / ".env")  # fallback

app = FastAPI(
    title="FakeNews Killer API",
    description="AI-powered misinformation detection system for Pakistan.",
    version="1.0.0",
)

# ── CORS — allow everything so Flutter can reach us ──
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─────────────────────────── Startup ───────────────────────────

@app.on_event("startup")
async def startup():
    """Initialise DB (creates tables + seeds) on first request."""
    get_db()


# ─────────────────────────── Routes ────────────────────────────

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Return a simple health-check response."""
    return HealthResponse(status="ok")


@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze(payload: AnalyzeRequest):
    """
    Run the full 4-agent pipeline on the submitted text.

    Flow:  Reader → Analyst → Strategist → Executor

    Each agent receives the previous agent's output and enriches
    the analysis. The Executor also persists the result to the
    misinformation tracker database.
    """
    try:
        # Stage 1 — Reader
        reader_out = await run_reader(payload.text)

        # Stage 2 — Analyst
        analyst_out = await run_analyst(reader_out)

        # Stage 3 — Strategist
        strategist_out = await run_strategist(analyst_out)

        # Stage 4 — Executor (also writes to tracker DB)
        executor_out = await run_executor(strategist_out, analyst_out, reader_out)

        return AnalyzeResponse(
            reader=reader_out,
            analyst=analyst_out,
            strategist=strategist_out,
            executor=executor_out,
        )

    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/analyze/stream")
async def analyze_stream(payload: AnalyzeRequest):
    """
    SSE streaming version of the analysis pipeline.

    Emits one Server-Sent Event per agent completion:
        data: {"agent": "reader",     "status": "complete"}
        data: {"agent": "analyst",    "status": "complete"}
        data: {"agent": "strategist", "status": "complete"}
        data: {"agent": "executor",   "status": "complete"}
        data: {"agent": "pipeline",   "status": "complete", "result": {...}}

    On error:
        data: {"agent": "pipeline",   "status": "error", "error": "..."}
    """
    async def event_generator():
        try:
            # Stage 1 — Reader
            reader_out = await run_reader(payload.text)
            yield f"data: {json_module.dumps({'agent': 'reader', 'status': 'complete'})}\n\n"

            # Stage 2 — Analyst
            analyst_out = await run_analyst(reader_out)
            yield f"data: {json_module.dumps({'agent': 'analyst', 'status': 'complete'})}\n\n"

            # Stage 3 — Strategist
            strategist_out = await run_strategist(analyst_out)
            yield f"data: {json_module.dumps({'agent': 'strategist', 'status': 'complete'})}\n\n"

            # Stage 4 — Executor
            executor_out = await run_executor(strategist_out, analyst_out, reader_out)
            yield f"data: {json_module.dumps({'agent': 'executor', 'status': 'complete'})}\n\n"

            # Final — full result
            result = AnalyzeResponse(
                reader=reader_out,
                analyst=analyst_out,
                strategist=strategist_out,
                executor=executor_out,
            )
            yield f"data: {json_module.dumps({'agent': 'pipeline', 'status': 'complete', 'result': result.model_dump()})}\n\n"

        except Exception as exc:
            yield f"data: {json_module.dumps({'agent': 'pipeline', 'status': 'error', 'error': str(exc)})}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@app.get("/tracker", response_model=list[TrackerEntry])
async def list_tracker():
    """Return every entry in the misinformation tracker, newest first."""
    return get_all_tracker_entries()


@app.post("/tracker", response_model=TrackerEntry, status_code=201)
async def add_tracker_entry(entry: TrackerEntry):
    """
    Manually insert a new entry into the misinformation tracker.

    This is also called internally by the Executor agent at the end
    of each analysis pipeline run.
    """
    result = insert_tracker_entry(
        claim_text=entry.claim_text,
        verdict=entry.verdict,
        category=entry.category,
        language=entry.language,
        spread_risk=entry.spread_risk,
        sources_cited=entry.sources_cited,
        tags=entry.tags,
        status=entry.status,
    )
    if result is None:
        raise HTTPException(status_code=500, detail="Failed to insert entry")
    return result
