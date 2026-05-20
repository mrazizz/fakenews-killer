# 🕵️ FakeNews Killer
### Autonomous Misinformation Detection & Action System for Pakistan

> *"It doesn't just detect fake news. It reads it, verifies it, decides what to do, and acts — all in under 15 seconds."*

---

## 🏆 What We Built

**FakeNews Killer** is a 4-agent autonomous AI pipeline that transforms raw, unverified WhatsApp forwards and news headlines into verified verdicts — and then **takes action**. No human in the loop. No stopping at "here's a summary." The system reads, thinks, decides, and executes.

In Pakistan, where misinformation spreads via WhatsApp faster than any newsroom can respond, this matters.

---

## 🎯 Problem Statement

Every day, millions of Pakistanis receive unverified news forwards — political rumours, health hoaxes, economic panic, religious misinformation. By the time a journalist or fact-checker responds, the damage is done.

Existing tools either:
- Stop at summarization (not useful)
- Require manual journalist review (too slow)
- Are English-only (excludes most of Pakistan)

**FakeNews Killer solves all three.**

---

## 🤖 How It Works — The 4-Agent Pipeline

Every input flows through four specialized AI agents, orchestrated by **Google Antigravity**:

```
User Input (text / screenshot)
        │
        ▼
┌───────────────────┐
│   READER AGENT    │  Extracts discrete, verifiable claims
│                   │  Detects language (English / Urdu / Roman Urdu)
│                   │  Flags linguistic red-flag patterns
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  ANALYST AGENT    │  Fact-checks each claim via Web Search
│   [web_search]    │  Cross-references: Dawn, Geo, Reuters, AFP
│                   │  Assigns truth score (0–100) per claim
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ STRATEGIST AGENT  │  Assesses harm level & affected audience
│                   │  Generates 3–5 prioritized, actionable responses
│                   │  Plans exactly what the Executor will do
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  EXECUTOR AGENT   │  Simulates 3 real actions:
│                   │  1. Verdict Card (shareable WhatsApp card)
│                   │  2. Tracker DB Entry (misinformation log)
│                   │  3. Platform Abuse Report (to WhatsApp/FB/X)
└───────────────────┘
         │
         ▼
  Full JSON result → Flutter Mobile App
```

This is not summarization. This is **insight → decision → execution**.

---

## 📱 Mobile App — 5 Screens

Built in Flutter. Runs on Android.

| Screen | What It Shows |
|--------|--------------|
| **Input** | Paste a WhatsApp message or upload a screenshot |
| **Loading** | Live agent ticker — watch all 4 agents activate in real time |
| **Results** | Verdict badge (TRUE / FALSE / MISLEADING), confidence %, per-claim breakdown |
| **Verdict Card** | Shareable visual card with Roman Urdu warning — ready to send back into WhatsApp |
| **Tracker Dashboard** | Full misinformation database — past entries, spread risk, categories |

---

## ⚡ Action Simulation — What the Executor Actually Does

This satisfies the hackathon's **critical requirement**: simulate execution of at least one action.

We simulate **three**:

### Action 1 — Verdict Card Generated
A fully structured, WhatsApp-shareable fact-check card containing:
- Verdict (TRUE / FALSE / MISLEADING / UNVERIFIED)
- Confidence percentage
- Key finding in plain English
- Sources (Dawn, Geo, Reuters, etc.)
- Roman Urdu warning: *"⚠️ Yeh khabar BILKUL GALAT hai. Aagay mat bhejen."*
- Timestamp and fact-checker attribution

### Action 2 — Tracker Database Entry Created
A structured record inserted into the misinformation tracker database:
```json
{
  "entry_id": "FNK-20241205-042",
  "claim_text": "...",
  "verdict": "false",
  "category": "political",
  "spread_risk": "high",
  "sources_cited": ["Dawn.com", "Geo.tv"],
  "tags": ["election", "WhatsApp forward"]
}
```

### Action 3 — Platform Abuse Report Filed
A formal, professionally written content abuse report drafted for submission to WhatsApp, Facebook, or X — including harm category, evidence summary, and recommended platform action.

---

## 🔄 Before → After State Change

The app includes a **Before/After panel** showing exactly what changed:

**Before:** Unverified claim — spreading, no fact-check available, spread risk unknown.

**After:**
- ✅ Verdict card created and ready to share
- ✅ Tracker entry logged (FNK-YYYYMMDD-XXX)
- ✅ Platform report drafted and ready to submit

Plus a scrollable **Agent Execution Log** — a terminal-style trace of every decision made:
```
[09:23:01] Reader Agent    → 2 claims extracted
[09:23:03] Analyst Agent   → web_search called (3 queries)
[09:23:07] Analyst Agent   → verdict: FALSE (confidence: 91%)
[09:23:08] Strategist Agent → 3 actions recommended
[09:23:09] Executor Agent  → verdict card generated
[09:23:09] Executor Agent  → tracker entry FNK-20241205-042 created
[09:23:10] Executor Agent  → platform report drafted
[09:23:10] Pipeline complete
```

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Agent Orchestration** | Google Antigravity | Core workflow — all 4 agents run through Antigravity's Agent Manager |
| **LLM** | Gemini 3 Pro (via Antigravity) | Reasoning, analysis, content generation |
| **Web Search Tool** | Antigravity built-in | Live fact-checking against real sources |
| **Backend** | FastAPI (Python 3.11) | Agent pipeline, REST API, data layer |
| **Database** | SQLite | Misinformation tracker persistence |
| **OCR** | pytesseract | Screenshot → text extraction |
| **Mobile App** | Flutter (Android) | Full mobile UI, 5 screens |
| **Schema Validation** | Pydantic v2 | Strict JSON output from every agent |

---

## 🌐 How Google Antigravity Is Used

Google Antigravity is **central** to this system — not bolted on.

- **All 4 agents are defined and orchestrated in Antigravity's Agent Manager.** Each agent is a separate reasoning unit with its own system prompt, tools, and output schema.
- **The web_search tool** is enabled on the Analyst Agent, allowing live fact-checking against real news sources at runtime.
- **The Antigravity Manager View** provides a complete visual trace of every agent activation, tool call, and decision — this is the agent trace log submitted with the project.
- The FastAPI backend calls Antigravity's Gemini 3 Pro endpoint for each agent, passing context from the previous agent's output — creating a true chained reasoning pipeline.

This is not a wrapper. Antigravity handles the reasoning, the tool execution, and the agent coordination.

---

## 🚀 Running the Project

### Prerequisites
- Python 3.11+
- Flutter SDK
- Google Antigravity API key (Gemini 3 Pro access)

### Backend Setup
```bash
cd fakenews_killer
pip install -r requirements.txt
cp .env.example .env
# Add your GOOGLE_API_KEY to .env
uvicorn main:app --reload
```

### Flutter App Setup
```bash
cd fakenews_killer_app
flutter pub get
flutter run
```

### API Endpoints
```
POST /analyze     →  Run full 4-agent pipeline on input text
GET  /tracker     →  Retrieve all misinformation tracker entries
POST /tracker     →  Insert new tracker entry
GET  /health      →  Health check
```

---

## 📊 Example: End-to-End Flow

**Input (Roman Urdu WhatsApp forward):**
```
URGENT! PM ne resign kar diya aur army ne complete control le lia hai.
Sab channels band hone wale hain. SHARE KAREIN JALDI!
```

**Pipeline Output:**

| Agent | Output |
|-------|--------|
| Reader | 2 claims extracted: (1) PM resigned, (2) Army took control. Suspicion score: 9/10. Red flags: urgency phrase, unnamed source, ALL CAPS |
| Analyst | Claim 1: FALSE (score: 4/100) — Dawn, Geo, Tribune all confirm no resignation. Claim 2: FALSE (score: 6/100) — No credible military action reported |
| Strategist | Harm: HIGH. Audience: General Pakistani public. Actions: public_correction (immediate), tracker_log (immediate), platform_flag (within 24h) |
| Executor | Verdict card generated. Tracker entry FNK-20241205-042 created. WhatsApp report drafted. |

---

## 🌍 Domain Relevance — Why Pakistan

- Pakistan is ranked among the top countries for WhatsApp misinformation spread
- Roman Urdu and mixed-language content is almost entirely ignored by existing fact-check tools
- The system handles English, Urdu, and Roman Urdu natively
- Sources are prioritized for Pakistani journalism: Dawn, Geo, ARY, Tribune, The News
- Platform reports can target WhatsApp, Facebook, and Twitter/X — the primary vectors in Pakistan

---

## 💡 Design Decisions & Assumptions

- **Agent chaining over single-prompt:** Each agent has a narrow, well-defined responsibility. This produces better structured outputs than a single large prompt.
- **Simulated actions are complete:** The executor generates full, submission-ready outputs — not placeholders. The verdict card, tracker entry, and platform report are all fully populated.
- **Roman Urdu is a first-class language:** The Reader Agent explicitly detects and handles roman_urdu as a language type.
- **Spread risk is a first-class metric:** The system explicitly assesses and logs viral potential, not just truth value.
- **No real personal data used:** All demo inputs are inspired by real news categories but contain no real personal information.

---

## 📁 Project Structure

```
fakenews_killer/
├── main.py                  # FastAPI app, endpoint routing
├── agents/
│   ├── reader.py            # Agent 1 — claim extraction
│   ├── analyst.py           # Agent 2 — fact-checking + web search
│   ├── strategist.py        # Agent 3 — action planning
│   └── executor.py          # Agent 4 — action simulation
├── models/
│   ├── schemas.py           # Pydantic request/response models
│   └── database.py          # SQLite tracker DB setup
├── utils/
│   └── ocr.py               # pytesseract screenshot → text
├── data/                    # SQLite DB (auto-created)
├── requirements.txt
└── .env.example

fakenews_killer_app/         # Flutter mobile app
├── lib/
│   ├── screens/
│   │   ├── input_screen.dart
│   │   ├── loading_screen.dart
│   │   ├── results_screen.dart
│   │   ├── verdict_card_screen.dart
│   │   ├── tracker_screen.dart
│   │   └── before_after_screen.dart
│   └── main.dart
└── pubspec.yaml
```

---

## 👥 Team

**Muhammad Aziz** — Backend, agent pipeline, Flutter app, API integration

**Muhammad Zakir** — Research, demo content, documentation, demo video, QA testing

Built at the Google Antigravity Hackathon, Lahore — May 2026.

---

*FakeNews Killer — Because the truth deserves a faster distribution network than the lie.*