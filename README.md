# 🛡️ FakeNews Killer
### AI-Powered Misinformation Detection for Pakistan
> Built at the Google Antigravity Hackathon — Lahore, 2026

---

## 📌 Problem Statement

Pakistan is one of the world's most active WhatsApp markets. Every day, millions of people forward unverified claims — political rumors, fake health advice, fabricated statistics — with zero friction. There is no fast, local-language, mobile-first tool to verify a claim before sharing it. FakeNews Killer fills that gap.

---

## 🎯 What It Does

A user pastes any suspicious claim — a WhatsApp forward, a news headline, a screenshot — into the app. Within seconds, a 4-agent AI pipeline powered by Google Gemini fact-checks every claim against live web sources, assigns a confidence-rated verdict (TRUE / FALSE / MISLEADING / UNVERIFIED), generates a shareable verdict card, logs the finding to a misinformation tracker database, and drafts a formal platform abuse report — all automatically.

---

## 🏗️ Architecture

```
User Input (Text / Screenshot)
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│                  Flutter Mobile App                      │
│  InputScreen → LoadingScreen → ResultsScreen            │
│  VerdictCardScreen · TrackerScreen · BeforeAfterScreen  │
└────────────────────────┬────────────────────────────────┘
                         │  POST /analyze/stream  (SSE)
                         ▼
┌─────────────────────────────────────────────────────────┐
│              FastAPI Backend  (Python 3.11)              │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌───────┐ │
│  │  Reader  │→ │ Analyst  │→ │ Strategist │→ │Execut.│ │
│  │  Agent   │  │  Agent   │  │   Agent    │  │ Agent │ │
│  └──────────┘  └──────────┘  └────────────┘  └───┬───┘ │
│                    │  Web Search Tool               │    │
│                    └── Google Search Grounding      │    │
│                                                     ▼    │
│                                              SQLite DB   │
└─────────────────────────────────────────────────────────┘
```

---

## 🤖 The 4-Agent Pipeline

| # | Agent | Role | Tools Used |
|---|-------|------|------------|
| 1 | **Reader** | Extracts every discrete, independently verifiable claim from raw input. Detects language (English / Urdu / Roman Urdu), content type (WhatsApp forward, news article, social post, screenshot), and red-flag linguistic patterns. Assigns an initial suspicion score 0–10 before any fact-checking. | Gemini 2.5 Flash |
| 2 | **Analyst** | Fact-checks each extracted claim using live web search. Assigns a truth score 0–100 per claim, a verdict category (false / misleading / unverified / true / satire_misread / old_news_recycled / out_of_context), and cites the single most credible Pakistani or international source found. | Gemini 2.5 Flash + Google Search Grounding |
| 3 | **Strategist** | Assesses harm potential, identifies the at-risk audience, and generates 3–5 prioritised, concrete recommended actions (platform_flag, public_correction, community_alert, authority_notify, tracker_log, media_brief) with urgency rankings. | Gemini 2.5 Flash |
| 4 | **Executor** | Executes all three mandatory outputs simultaneously: generates the shareable verdict card data, writes a structured entry to the SQLite misinformation tracker, and drafts a formal platform content-abuse report suitable for submission to WhatsApp / Facebook / X Trust & Safety teams. | Gemini 2.5 Flash |

### How Antigravity Powers This

All 4 agents were scaffolded, prompted, and iteratively refined using **Google Antigravity's Agent Manager**. Antigravity was used to:
- Generate the initial FastAPI + Flutter project scaffold via Prompt #1 and Prompt #2
- Write and test each agent's system prompt in isolation before wiring them together
- View the full agent trace log (Reader → Analyst → Strategist → Executor) with per-step tool call visibility
- Iterate on the SSE streaming endpoint that syncs real agent completion events to the Flutter loading screen

---

## 📱 Mobile App — 6 Screens

| Screen | Description |
|--------|-------------|
| **Input Screen** | Claude-style chat interface. Watermark app logo at 6% opacity on pure black background. Bottom-pinned expandable text input that grows upward as text increases. "Add Screenshot" button for OCR uploads. Circular send button activates when text is non-empty. Right-side drawer opens navigation. |
| **Loading Screen** | 4 agent status cards that tick to green checkmarks in real time as each agent completes — synced to actual SSE events from the backend, not fake timers. |
| **Results Screen** | Overall verdict badge (TRUE / FALSE / MISLEADING / UNVERIFIED) with confidence %, key finding, and expandable per-claim breakdown list. |
| **Verdict Card Screen** | Shareable visual card with verdict, confidence bar, key finding, source chips, and Roman Urdu warning text. One-tap share as image via native share sheet. |
| **Tracker Screen** | Misinformation tracker dashboard. Stats row (total entries, % false, % misleading). Scrollable list of all past verdicts. Tapping any entry opens its full verdict card. |
| **System Impact Screen** | Before/After view. "Before" shows a WhatsApp-style unverified message bubble. "After" shows staggered animated cards for verdict generated, tracker updated, and platform report drafted. Scrollable terminal-style agent execution log at the bottom. |

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | Flutter (Dart) | Cross-platform mobile app |
| Fonts | Google Fonts — Outfit + Inter | Typography |
| Backend | Python 3.11 + FastAPI + Uvicorn | API server and agent pipeline |
| LLM | Google Gemini 2.5 Flash | Core reasoning for all 4 agents |
| Web Search | Google Search Grounding (via Gemini) | Live fact-checking in Analyst agent |
| Database | SQLite (built-in `sqlite3`) | Misinformation tracker storage |
| Streaming | Server-Sent Events (SSE) | Real-time agent progress to Flutter |
| Validation | Pydantic v2 | All request/response schemas |
| Config | python-dotenv | API key management |
| OCR | Pillow + Gemini Vision | Screenshot-to-text (image uploads) |

---

## 🚀 Running the Project

### Prerequisites
- Python 3.11+
- Flutter 3.x (with Android SDK)
- A Google Gemini API key

### Backend

```bash
cd fakenewskiller/backend

# Install dependencies
pip install -r requirements.txt

# Create .env file
echo "GOOGLE_API_KEY=your_key_here" > .env

# Start the server (accessible on local network)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Verify it's running:
```
GET http://localhost:8000/health  →  {"status": "ok"}
GET http://localhost:8000/docs    →  Swagger UI
```

### Flutter App

```bash
cd fakenewskiller/app

# Install dependencies
flutter pub get

# Find your PC's local IP (for physical device testing)
ipconfig  # look for IPv4 Address under WiFi adapter

# Update baseUrl in lib/services/api_service.dart
# Change: http://localhost:8000
# To:     http://192.168.x.x:8000  (your PC's IP)

# Run on connected device
flutter run
```

> **Physical device note:** Your phone and PC must be on the same WiFi network. Start the backend with `--host 0.0.0.0` so it listens on the local network.

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check — returns `{"status": "ok"}` |
| `POST` | `/analyze` | Full pipeline, returns complete JSON result |
| `POST` | `/analyze/stream` | SSE streaming — emits one event per agent completion |
| `GET` | `/tracker` | Returns all misinformation tracker entries, newest first |
| `POST` | `/tracker` | Manually insert a tracker entry |

### SSE Stream Events (`/analyze/stream`)

```json
{"agent": "reader",     "status": "complete"}
{"agent": "analyst",    "status": "complete"}
{"agent": "strategist", "status": "complete"}
{"agent": "executor",   "status": "complete"}
{"agent": "pipeline",   "status": "complete", "result": { ...full result... }}
```

---

## 📂 Project Structure

```
fakenewskiller/
├── backend/
│   ├── main.py                  # FastAPI app + all endpoints
│   ├── agents/
│   │   ├── __init__.py          # run_reader / run_analyst / etc. exports
│   │   ├── reader.py            # Agent 1 — claim extraction
│   │   ├── analyst.py           # Agent 2 — fact-checking + web search
│   │   ├── strategist.py        # Agent 3 — response strategy
│   │   └── executor.py          # Agent 4 — output generation + DB write
│   ├── models/
│   │   ├── schemas.py           # Pydantic v2 models for all I/O
│   │   └── database.py          # SQLite setup, seed data, CRUD
│   ├── utils/
│   │   ├── gemini_client.py     # Model fallback utility (quota resilience)
│   │   └── ocr.py               # Screenshot → text via Gemini Vision
│   ├── data/                    # SQLite database file (auto-created)
│   └── requirements.txt
│
└── app/
    ├── lib/
    │   ├── main.dart            # App entry, dark theme config
    │   ├── models/
    │   │   ├── analysis_result.dart
    │   │   └── tracker_entry.dart
    │   ├── services/
    │   │   └── api_service.dart # HTTP + SSE client
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── input_screen.dart
    │   │   ├── loading_screen.dart
    │   │   ├── results_screen.dart
    │   │   ├── verdict_card_screen.dart
    │   │   ├── tracker_screen.dart
    │   │   └── before_after_screen.dart
    │   └── widgets/
    │       ├── app_scaffold.dart  # Shared scaffold with global menu icon
    │       └── app_drawer.dart    # Right-side navigation drawer
    └── assets/
        └── images/
            ├── logo.png
            └── logo.svg
```

---

## 🌍 Pakistan-Specific Design Decisions

- **Multilingual support** — Reader Agent handles English, Urdu (اردو), and Roman Urdu natively
- **WhatsApp-first** — Input screen, verdict card format, and sharing flow are optimised for forwarding on WhatsApp
- **Local source trust hierarchy** — Analyst Agent prioritises Dawn, Geo News, ARY News, The News, Tribune, BBC Urdu before international outlets
- **Bilingual warnings** — Every verdict card includes both English and Roman Urdu warning text ("Yeh khabar BILKUL GALAT hai. Aagay mat bhejen.")
- **Platform reporting** — Executor drafts formal reports targeting WhatsApp, Facebook, and X in the context of PTA / PEMRA / FIA Cyber Crime Wing regulatory environment

---

## 🔬 Agent Trace Log (Sample)

```
[09:23:01] Reader Agent    → 2 claims extracted (roman_urdu, suspicion: 8/10)
[09:23:03] Analyst Agent   → web_search called (3 queries)
[09:23:07] Analyst Agent   → verdict: FALSE (confidence: 91%)
[09:23:08] Strategist Agent→ 3 actions recommended (harm: high)
[09:23:09] Executor Agent  → verdict card generated
[09:23:09] Executor Agent  → tracker entry FNK-20260520-042 created
[09:23:10] Executor Agent  → platform report drafted (WhatsApp)
[09:23:10] Pipeline complete
```

---

## 👥 Team

| Role | Responsibilities |
|------|-----------------|
| **Aziz** (Developer) | FastAPI backend, all 4 agents, Flutter app (6 screens), SSE streaming, SQLite, Antigravity integration |
| **Co-worker** | Research, fake news sample collection, demo script, README, architecture diagram, demo video narration |

---

## 📋 Submission Checklist

- [x] Working Flutter mobile app (Android)
- [x] FastAPI backend with 4-agent pipeline
- [x] Google Antigravity used for agent scaffolding and management
- [x] Web Search Tool integrated (Analyst Agent — Google Search Grounding)
- [x] Executor fires 3 real actions (verdict card + tracker entry + platform report)
- [x] SSE streaming endpoint for real-time agent progress
- [x] Misinformation tracker with persistent SQLite storage
- [x] Shareable verdict card with native share sheet
- [x] Bilingual output (English + Roman Urdu)
- [x] Agent trace log visible in System Impact screen
- [x] Demo video recorded

---

*FakeNews Killer — Built with Google Antigravity · Gemini 2.5 Flash · Flutter · FastAPI*