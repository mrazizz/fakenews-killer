"""
SQLite persistence layer for FakeNews Killer.
Creates the TrackerEntry table and seeds it with 3 example rows on first run.
"""

import sqlite3
import json
from pathlib import Path
from datetime import datetime, timezone

DB_DIR = Path(__file__).resolve().parent.parent / "data"
DB_PATH = DB_DIR / "fakenews_killer.db"


def _get_connection() -> sqlite3.Connection:
    """Return a module-level connection (created once, reused)."""
    DB_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH), check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn


# Module-level connection
_conn: sqlite3.Connection | None = None


def get_db() -> sqlite3.Connection:
    """Lazy-initialise and return the shared DB connection."""
    global _conn
    if _conn is None:
        _conn = _get_connection()
        _create_tables(_conn)
        _seed_if_empty(_conn)
    return _conn


# ──────────────────────── Schema & Seed ────────────────────────

def _create_tables(conn: sqlite3.Connection) -> None:
    """Create the TrackerEntry table if it doesn't exist yet."""
    conn.execute("""
        CREATE TABLE IF NOT EXISTS tracker (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_text      TEXT    NOT NULL,
            verdict         TEXT    NOT NULL,
            category        TEXT    NOT NULL,
            language        TEXT    NOT NULL DEFAULT 'en',
            spread_risk     TEXT    NOT NULL DEFAULT 'low',
            first_detected  TEXT    NOT NULL,
            sources_cited   TEXT    NOT NULL DEFAULT '[]',
            tags            TEXT    NOT NULL DEFAULT '[]',
            status          TEXT    NOT NULL DEFAULT 'active',
            confidence_score INTEGER NOT NULL DEFAULT 0
        )
    """)
    try:
        conn.execute("ALTER TABLE tracker ADD COLUMN confidence_score INTEGER NOT NULL DEFAULT 0")
    except sqlite3.OperationalError:
        pass  # Column already exists
    conn.commit()


def _seed_if_empty(conn: sqlite3.Connection) -> None:
    """Insert 3 example tracker entries so the dashboard isn't blank on first boot."""
    count = conn.execute("SELECT COUNT(*) FROM tracker").fetchone()[0]
    if count > 0:
        return

    seeds = [
        {
            "claim_text": "Pakistan's GDP growth has reached 15% in 2026, the highest in South Asia.",
            "verdict": "false",
            "category": "economic",
            "language": "en",
            "spread_risk": "high",
            "first_detected": "2026-05-10T08:30:00Z",
            "sources_cited": json.dumps(["State Bank of Pakistan", "World Bank Data Portal"]),
            "tags": json.dumps(["economy", "gdp", "pakistan", "viral"]),
            "status": "active",
            "confidence_score": 95,
        },
        {
            "claim_text": "Polio vaccine causes infertility — thousands affected in Sindh province.",
            "verdict": "false",
            "category": "health",
            "language": "en",
            "spread_risk": "critical",
            "first_detected": "2026-04-22T14:00:00Z",
            "sources_cited": json.dumps(["WHO Pakistan", "NIH Islamabad", "Dawn News"]),
            "tags": json.dumps(["health", "polio", "vaccine", "sindh", "misinfo"]),
            "status": "active",
            "confidence_score": 98,
        },
        {
            "claim_text": "نئی تعلیمی پالیسی میں اردو کو ختم کر دیا گیا ہے۔",
            "verdict": "misleading",
            "category": "political",
            "language": "ur",
            "spread_risk": "medium",
            "first_detected": "2026-05-01T11:15:00Z",
            "sources_cited": json.dumps(["Ministry of Education Pakistan", "Geo News"]),
            "tags": json.dumps(["education", "urdu", "policy", "misleading"]),
            "status": "active",
            "confidence_score": 75,
        },
    ]

    for entry in seeds:
        conn.execute(
            """INSERT INTO tracker
               (claim_text, verdict, category, language, spread_risk,
                first_detected, sources_cited, tags, status, confidence_score)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                entry["claim_text"], entry["verdict"], entry["category"],
                entry["language"], entry["spread_risk"], entry["first_detected"],
                entry["sources_cited"], entry["tags"], entry["status"], entry["confidence_score"]
            ),
        )
    conn.commit()


# ──────────────────────── CRUD helpers ────────────────────────

def insert_tracker_entry(
    claim_text: str,
    verdict: str,
    category: str,
    language: str = "en",
    spread_risk: str = "low",
    sources_cited: str = "[]",
    tags: str = "[]",
    status: str = "active",
    confidence_score: int = 0,
) -> dict:
    """Insert a new row into the tracker table and return it as a dict."""
    conn = get_db()
    now = datetime.now(timezone.utc).isoformat()
    cursor = conn.execute(
        """INSERT INTO tracker
           (claim_text, verdict, category, language, spread_risk,
            first_detected, sources_cited, tags, status, confidence_score)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (claim_text, verdict, category, language, spread_risk,
         now, sources_cited, tags, status, confidence_score),
    )
    conn.commit()
    return get_tracker_entry(cursor.lastrowid)


def get_tracker_entry(entry_id: int) -> dict | None:
    """Fetch a single tracker row by ID."""
    conn = get_db()
    row = conn.execute("SELECT * FROM tracker WHERE id = ?", (entry_id,)).fetchone()
    return dict(row) if row else None


def get_all_tracker_entries() -> list[dict]:
    """Return every tracker row, newest first."""
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM tracker ORDER BY first_detected DESC"
    ).fetchall()
    return [dict(r) for r in rows]
