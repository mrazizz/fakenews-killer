"""
Firestore persistence layer for FakeNews Killer.
Stores TrackerEntry documents in the 'tracker' collection.
Seeds with 3 example entries on first run.
"""

import json
from datetime import datetime, timezone
from google.cloud import firestore

# ── Module-level Firestore client (lazy-init) ──
_db: firestore.Client | None = None
_initialised: bool = False

COLLECTION = "tracker"


def _get_client() -> firestore.Client:
    """Return a shared Firestore client (created once, reused)."""
    global _db
    if _db is None:
        _db = firestore.Client()
    return _db


def get_db():
    """Lazy-initialise Firestore and seed if empty.

    This is called at app startup from main.py — keeps the same interface
    as the old SQLite version so nothing else needs to change.
    """
    global _initialised
    client = _get_client()
    if not _initialised:
        _seed_if_empty(client)
        _initialised = True
    return client


# ──────────────────────── Seed ────────────────────────

def _seed_if_empty(client: firestore.Client) -> None:
    """Insert 3 example tracker entries so the dashboard isn't blank on first boot."""
    coll = client.collection(COLLECTION)

    # Quick check: if any document exists, skip seeding
    existing = coll.limit(1).get()
    if len(existing) > 0:
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
            "claim_text": "\u0646\u0626\u06cc \u062a\u0639\u0644\u06cc\u0645\u06cc \u067e\u0627\u0644\u06cc\u0633\u06cc \u0645\u06cc\u06ba \u0627\u0631\u062f\u0648 \u06a9\u0648 \u062e\u062a\u0645 \u06a9\u0631 \u062f\u06cc\u0627 \u06af\u06cc\u0627 \u06c1\u06d2\u06d4",
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
        coll.add(entry)


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
    """Insert a new document into the tracker collection and return it as a dict."""
    client = _get_client()
    now = datetime.now(timezone.utc).isoformat()
    entry = {
        "claim_text": claim_text,
        "verdict": verdict,
        "category": category,
        "language": language,
        "spread_risk": spread_risk,
        "first_detected": now,
        "sources_cited": sources_cited,
        "tags": tags,
        "status": status,
        "confidence_score": confidence_score,
    }
    _, doc_ref = client.collection(COLLECTION).add(entry)
    entry["id"] = doc_ref.id
    return entry


def get_tracker_entry(entry_id: str) -> dict | None:
    """Fetch a single tracker document by ID."""
    client = _get_client()
    doc = client.collection(COLLECTION).document(entry_id).get()
    if doc.exists:
        data = doc.to_dict()
        data["id"] = doc.id
        return data
    return None


def get_all_tracker_entries() -> list[dict]:
    """Return every tracker document, newest first."""
    client = _get_client()
    docs = (
        client.collection(COLLECTION)
        .order_by("first_detected", direction=firestore.Query.DESCENDING)
        .stream()
    )
    results = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        results.append(data)
    return results
