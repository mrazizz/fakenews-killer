# FakeNews Killer 🛡️

AI-powered misinformation detection system for Pakistan. Built for the Google Antigravity Hackathon.

## Architecture

```
POST /analyze  →  Reader → Analyst → Strategist → Executor  →  JSON result
```

| Agent | Role |
|-------|------|
| **Reader** | Cleans input text, extracts factual claims, detects language |
| **Analyst** | Evaluates each claim for truthfulness with evidence & confidence |
| **Strategist** | Assesses severity, spread risk, and Pakistan-specific context |
| **Executor** | Produces final verdict, saves to tracker DB, generates Urdu summary |

## Project Structure

```
fakenews-killer/
├── main.py                 # FastAPI app + routes
├── agents/
│   ├── reader.py           # Stage 1 — content extraction
│   ├── analyst.py          # Stage 2 — claim analysis
│   ├── strategist.py       # Stage 3 — strategy & context
│   └── executor.py         # Stage 4 — final verdict
├── models/
│   ├── schemas.py          # Pydantic v2 models
│   └── database.py         # SQLite + seed data
├── utils/
│   └── ocr.py              # Gemini-powered image OCR
├── data/                   # SQLite DB lives here
├── requirements.txt
├── .env.local              # Your API key (git-ignored)
└── .env.example            # Template
```

## Quick Start

### 1. Clone & install

```bash
git clone https://github.com/mrazizz/fakenews-killer.git
cd fakenews-killer
pip install -r requirements.txt
```

### 2. Configure API key

```bash
cp .env.example .env.local
# Edit .env.local and paste your GOOGLE_API_KEY
```

### 3. Run the server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Test it

```bash
# Health check
curl http://localhost:8000/health

# Analyze a claim
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "Pakistan GDP has reached 15% growth in 2026"}'

# View tracker
curl http://localhost:8000/tracker
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/analyze` | Submit text for full 4-agent analysis pipeline |
| `GET` | `/tracker` | List all misinformation tracker entries |
| `POST` | `/tracker` | Manually add a tracker entry |
| `GET` | `/health` | Health check — returns `{"status": "ok"}` |

## Tech Stack

- **Backend:** Python 3.14, FastAPI, Uvicorn
- **LLM:** Google Gemini 3 Pro via `google-genai` SDK
- **Database:** SQLite (zero-config, file-based)
- **Validation:** Pydantic v2
- **Mobile:** Flutter (separate repo / directory)

## License

Built for the Google Antigravity Hackathon 2026.
