import { useState } from "react";

const TABS = ["Overview", "Day 1", "Day 2", "Day 3", "AG Prompts"];

const tech = [
  { icon: "ti-brand-python", label: "FastAPI", sub: "Backend / agent pipeline" },
  { icon: "ti-brand-flutter", label: "Flutter", sub: "Mobile app (required)" },
  { icon: "ti-database", label: "SQLite", sub: "Mock tracker DB" },
  { icon: "ti-robot", label: "Gemini 3 Pro", sub: "Core LLM via Antigravity" },
  { icon: "ti-world-search", label: "Web Search Tool", sub: "Fact verification" },
  { icon: "ti-eye-scan", label: "OCR (pytesseract)", sub: "Screenshot → text" },
];

const days = [
  {
    title: "Day 1",
    focus: "Backend + All 4 Agents",
    color: "#185FA5",
    bg: "#E6F1FB",
    aziz: [
      { time: "9–10 AM", task: "Install Antigravity, set up Python project, add .env with Gemini API key", tag: "Setup" },
      { time: "10–11 AM", task: "Run Antigravity Prompt #1 (scaffold). Review generated files, fix any broken imports.", tag: "Scaffold" },
      { time: "11 AM–1 PM", task: "Implement Agent 1 (Reader) using System Prompt #1 in agents/reader.py. Test with 2 fake news samples.", tag: "Agent 1" },
      { time: "2–4 PM", task: "Implement Agent 2 (Analyst) using System Prompt #2 in agents/analyst.py. Enable web_search tool. Test claim verification.", tag: "Agent 2" },
      { time: "4–5:30 PM", task: "Implement Agent 3 (Strategist) using System Prompt #3 in agents/strategist.py.", tag: "Agent 3" },
      { time: "5:30–7 PM", task: "Implement Agent 4 (Executor) using System Prompt #4. Build POST /analyze endpoint that chains all 4 agents.", tag: "Agent 4" },
      { time: "7–8 PM", task: "End-to-end test: paste one WhatsApp forward → full JSON output. Fix schema errors.", tag: "Test" },
    ],
    coworker: [
      { time: "9–11 AM", task: "Google 8 real Pakistani fake news examples (check Soch Fact Check, AFP Fact Check Pakistan, Dawn fact-checks). Save as plain text in a shared doc.", tag: "Research" },
      { time: "11 AM–1 PM", task: "Create 10 mock existing tracker entries in a spreadsheet: claim text, verdict, category, date, spread risk. Aziz will import these into SQLite.", tag: "Mock Data" },
      { time: "2–4 PM", task: "Write README outline: project name, problem statement, architecture diagram slots, agent descriptions, how to run. Leave code sections blank for Aziz.", tag: "Docs" },
      { time: "4–6 PM", task: "Draft the 5-minute demo script. Write exactly what will be said, line by line, from input to output. Mark timestamp cues.", tag: "Demo Script" },
      { time: "6–8 PM", task: "Test all 8 fake news samples by pasting them in the terminal using curl commands Aziz writes. Log which ones pass and which break.", tag: "Testing" },
    ],
  },
  {
    title: "Day 2",
    focus: "Flutter Mobile App",
    color: "#0F6E56",
    bg: "#E1F5EE",
    aziz: [
      { time: "9–10 AM", task: "Run Antigravity Prompt #2 (Flutter scaffold). Review generated screens structure.", tag: "Scaffold" },
      { time: "10 AM–12 PM", task: "Build Screen 1: Input screen. Text paste field + image upload button (OCR). Connect to backend POST /analyze.", tag: "Screen 1" },
      { time: "12–1 PM", task: "Build Screen 2: Loading screen. Animated agent status ticker — shows each agent activating in sequence (Reader → Analyst → Strategist → Executor).", tag: "Screen 2" },
      { time: "2–4 PM", task: "Build Screen 3: Results screen. Overall verdict badge (TRUE/FALSE/MISLEADING), confidence %, key finding, per-claim breakdown.", tag: "Screen 3" },
      { time: "4–5:30 PM", task: "Build Screen 4: Verdict Card. Shareable visual card with verdict, finding, sources, timestamp, Roman Urdu warning. Add share button.", tag: "Screen 4" },
      { time: "5:30–7 PM", task: "Build Screen 5: Tracker Dashboard. List of past entries from GET /tracker. Shows count, recent entries, spread risk badges.", tag: "Screen 5" },
      { time: "7–8 PM", task: "Connect all screens. Test full flow on Android emulator end-to-end.", tag: "Integration" },
    ],
    coworker: [
      { time: "9–11 AM", task: "Sketch the verdict card design on paper or Canva. It should look like a WhatsApp message card: verdict label, confidence bar, source logos, share button. Send to Aziz.", tag: "Design" },
      { time: "11 AM–1 PM", task: "Write all UI text strings: button labels, loading messages, error states, empty states. E.g. loading message: 'Checking sources across the web…', error: 'Could not verify this claim. Try again.'", tag: "Copy" },
      { time: "2–4 PM", task: "Create 3 polished demo inputs in a doc: (1) a political fake news forward, (2) a health misinformation claim, (3) an economic fake stat. Include the expected output for each.", tag: "Demo Inputs" },
      { time: "4–6 PM", task: "Test every screen manually using the 3 demo inputs. Log all bugs with screenshots in a shared doc for Aziz.", tag: "Testing" },
      { time: "6–8 PM", task: "Prepare the agent architecture diagram (use Canva or any tool). 4 boxes in sequence: Reader → Analyst → Strategist → Executor. Add to README.", tag: "Docs" },
    ],
  },
  {
    title: "Day 3",
    focus: "Polish, Demo & Submit",
    color: "#854F0B",
    bg: "#FAEEDA",
    aziz: [
      { time: "9–10 AM", task: "Fix all bugs logged by co-worker on Day 2. Priority: verdict card rendering + agent trace visibility.", tag: "Bug Fix" },
      { time: "10–11 AM", task: "Add Agent Trace Log UI: a scrollable panel showing each agent's activation, tool calls used, and decision made. This is required for the submission.", tag: "Trace Log" },
      { time: "11 AM–12 PM", task: "Build Before/After state panel: Before (unverified claim card) → After (verdict card + tracker entry + platform report). Side-by-side or tabbed.", tag: "Before/After" },
      { time: "12–1 PM", task: "Run full end-to-end test with all 3 polished demo inputs. Fix any failures. Polish loading animations.", tag: "Final Test" },
      { time: "2–4 PM", task: "Record demo video with co-worker. Aziz operates the app, co-worker narrates. Do 2-3 takes. Export best one.", tag: "Demo Video" },
      { time: "4–5:30 PM", task: "Export agent trace logs from Antigravity Manager View (screenshots or exported JSON). Attach to submission.", tag: "Logs" },
      { time: "5:30–7 PM", task: "Final submission: zip project, attach video, README, architecture diagram, agent trace. Submit.", tag: "Submit" },
    ],
    coworker: [
      { time: "9–11 AM", task: "Write the final README: fill in all code sections Aziz tells you to. Architecture overview, tools used, how Antigravity is used, assumptions. Must be professional.", tag: "README" },
      { time: "11 AM–12 PM", task: "Prepare the verbal demo pitch: 30-second problem statement, 2-minute live demo walkthrough, 30-second closing. Memorize it.", tag: "Pitch" },
      { time: "2–4 PM", task: "Narrate the demo video recording. Speak clearly, slowly. Follow the demo script from Day 1 exactly. Mention 'Google Antigravity' and each agent by name during the demo.", tag: "Record" },
      { time: "4–6 PM", task: "Final testing: run all 3 demo inputs one more time, confirm outputs are correct and cards look sharp. Write any last bugs found.", tag: "Final QA" },
      { time: "6–7 PM", task: "Compile submission package: README.md, architecture diagram image, demo video link, agent trace screenshots. Organise into a Google Drive folder and share link.", tag: "Package" },
    ],
  },
];

const agPrompts = [
  {
    group: "Antigravity Build Prompts",
    sub: "Type these into Antigravity's Agent Manager to build the code",
    color: "#185FA5",
    items: [
      {
        id: "ag1",
        label: "Prompt #1 — Scaffold Full Backend",
        when: "Day 1, 9 AM — first thing you do",
        text: `Build a Python FastAPI backend for a misinformation detection app called "FakeNews Killer".

Create this exact project structure:
fakenews_killer/
├── main.py
├── agents/
│   ├── __init__.py
│   ├── reader.py
│   ├── analyst.py
│   ├── strategist.py
│   └── executor.py
├── models/
│   ├── schemas.py
│   └── database.py
├── utils/
│   └── ocr.py
├── data/
│   └── (sqlite db will be created here)
├── requirements.txt
└── .env.example

API endpoints needed:
- POST /analyze       → accepts { "text": "..." }, runs all 4 agents in sequence, returns full pipeline result
- GET  /tracker       → returns all misinformation tracker entries from SQLite
- POST /tracker       → inserts a new entry (called by Executor agent)
- GET  /health        → returns {"status": "ok"}

Tech stack:
- Python 3.11, FastAPI, uvicorn
- google-generativeai SDK for Gemini 3 Pro (model: gemini-3-pro)
- SQLite via sqlite3 built-in
- Pydantic v2 for all request/response schemas
- python-dotenv for GOOGLE_API_KEY env variable
- CORS middleware enabled for all origins (Flutter needs this)

In main.py, the POST /analyze endpoint should call reader → analyst → strategist → executor in sequence, passing each result to the next agent.

In database.py, create a TrackerEntry table with columns: id, claim_text, verdict, category, language, spread_risk, first_detected, sources_cited, tags, status.

Seed the database with 3 example entries so the tracker is not empty on first run.

In each agents/*.py file, create a placeholder async function that accepts the previous agent's output and returns a hardcoded sample JSON response matching the expected schema. I will replace these with real prompts after scaffolding.

Include full docstrings on every function. Include a README.md with setup instructions.`,
      },
      {
        id: "ag2",
        label: "Prompt #2 — Scaffold Flutter App",
        when: "Day 2, 9 AM",
        text: `Build a Flutter mobile app for a misinformation detection tool called "FakeNews Killer".

The app connects to a FastAPI backend running at http://localhost:8000.

Create these 5 screens:

SCREEN 1 — InputScreen
- App bar with title "FakeNews Killer" and a shield icon
- Large multiline text field: "Paste a WhatsApp message, news headline, or suspicious claim..."
- An "Upload Screenshot" button (opens image picker, but just store the file for now — OCR is handled by backend)
- A prominent "Check Now" button at the bottom
- On tap, call POST /analyze with the text, then navigate to LoadingScreen

SCREEN 2 — LoadingScreen
- Dark background
- Animated sequence showing 4 agent status cards activating one by one with a 1.5s delay each:
  Card 1: "Reader Agent — Extracting claims..."
  Card 2: "Analyst Agent — Checking sources..."
  Card 3: "Strategist Agent — Planning response..."
  Card 4: "Executor Agent — Simulating actions..."
- Each card has a spinner that turns into a green checkmark when that stage completes
- When all 4 complete, auto-navigate to ResultsScreen

SCREEN 3 — ResultsScreen
- Large verdict badge at top: TRUE (green) / FALSE (red) / MISLEADING (orange) / UNVERIFIED (gray)
- Confidence percentage below badge
- Key finding text
- Expandable per-claim breakdown list
- Two action buttons: "See Verdict Card" and "View Tracker"

SCREEN 4 — VerdictCardScreen
- Styled like a shareable card (white card on dark background)
- Verdict label, confidence bar, key finding
- Source chips row
- Timestamp
- Roman Urdu warning text in italic
- Share button (uses Flutter share_plus package to share card text)

SCREEN 5 — TrackerScreen
- AppBar "Misinformation Tracker"
- Stats row: total entries, % false, % misleading
- Scrollable list of tracker entries from GET /tracker
- Each entry has verdict color badge, claim preview, spread risk chip, date

Use Material 3 design. Primary color: deep red (#C0392B). Use Google Fonts: Outfit for headings, Inter for body.

Add proper error handling on all API calls — show a snackbar if the backend is unreachable.`,
      },
      {
        id: "ag3",
        label: "Prompt #3 — Build Before/After Dashboard",
        when: "Day 3, 11 AM",
        text: `In the existing Flutter FakeNews Killer app, add a BeforeAfterScreen that shows the system state change after an analysis.

This screen is navigated to from ResultsScreen.

Layout: two panels stacked vertically, each with a clear label.

PANEL 1 — "Before" (light gray background)
Show a mock "unverified message" card:
- WhatsApp-style bubble with the original claim text
- Status: "Unverified — spreading"
- Red warning icon
- "No fact-check available" label
- Spread risk indicator showing "Unknown"

PANEL 2 — "After" (light green background)
Show three completed action cards side by side (or stacked on small screens):

Card A — Verdict Card Generated
- Green checkmark icon
- "Fact-check card created"
- Shows thumbnail of verdict (TRUE/FALSE badge)
- Timestamp of generation

Card B — Tracker Updated  
- Database icon
- "Added to misinformation database"
- Entry ID (e.g. FNK-20241205-001)
- Category and spread risk tags

Card C — Platform Report Filed
- Flag icon
- "Report drafted for platform submission"
- Target platform name
- Status: "Ready to submit"

Below both panels, add a scrollable "Agent Execution Log" panel:
- Monospace font, dark background
- Shows timestamped log lines like a terminal:
  [09:23:01] Reader Agent → 2 claims extracted
  [09:23:03] Analyst Agent → web_search called (3 queries)
  [09:23:07] Analyst Agent → verdict: FALSE (confidence: 91%)
  [09:23:08] Strategist Agent → 3 actions recommended
  [09:23:09] Executor Agent → verdict card generated
  [09:23:09] Executor Agent → tracker entry FNK-... created
  [09:23:10] Executor Agent → platform report drafted
  [09:23:10] Pipeline complete

Populate this log from the execution_log array in the API response.`,
      },
    ],
  },
  {
    group: "Agent System Prompts",
    sub: "Paste these into your agents/*.py files as the system_prompt string",
    color: "#534AB7",
    items: [
      {
        id: "sp1",
        label: "System Prompt #1 — Reader Agent",
        when: "agents/reader.py",
        text: `You are the Reader Agent in FakeNews Killer, a misinformation detection system for Pakistan.

ROLE: Extract every discrete, verifiable factual claim from raw user input. Input may be a WhatsApp forward, social media post, news screenshot (converted to text), or article — in English, Urdu, or Roman Urdu.

CRITICAL RULE: Do NOT summarize. Extract individual, independently checkable claims. "PM ne resign kar diya aur army ne control le lia" contains TWO claims — treat them separately.

YOUR PROCESS:
1. Detect language: english | urdu | roman_urdu | mixed
2. Identify content type: whatsapp_forward | news_article | social_post | screenshot
3. Scan for red-flag linguistic patterns: "SHARE IMMEDIATELY", "آگے بھیجیں", unnamed sources ("a reliable source said"), round numbers stated as exact facts, sensational ALL CAPS language, urgency phrases
4. Extract every discrete, verifiable claim — normalize each into a clean searchable English statement
5. Assign an initial suspicion score (0-10) based on linguistic red flags alone — before any fact-checking

RESPOND ONLY WITH VALID JSON. NO OTHER TEXT. NO MARKDOWN. EXACT STRUCTURE:
{
  "content_type": "whatsapp_forward",
  "language_detected": "roman_urdu",
  "red_flag_patterns": ["SHARE IMMEDIATELY", "unnamed source"],
  "initial_suspicion_score": 8,
  "claims": [
    {
      "claim_id": "C1",
      "original_text": "exact phrase from input",
      "normalized_claim": "clean searchable English statement of this claim",
      "claim_type": "event | statistic | quote | policy | image_description",
      "entities": ["named people, organizations, or places"],
      "time_reference": "today | yesterday | specific date | vague | none",
      "verifiable": true
    }
  ],
  "total_claims": 2
}`,
      },
      {
        id: "sp2",
        label: "System Prompt #2 — Analyst Agent",
        when: "agents/analyst.py",
        text: `You are the Analyst Agent in FakeNews Killer, a misinformation detection system for Pakistan.

ROLE: Fact-check each extracted claim using web search. Assign a truth confidence score to every claim. Identify specifically WHY each claim is true, false, misleading, or unverifiable.

YOU HAVE ACCESS TO WEB SEARCH. Use it for every claim. Search aggressively.

PREFERRED SOURCES (in order of trust): Dawn, Geo News, ARY News, The News, Tribune, Reuters, BBC Urdu, AP, AFP Fact Check.

VERDICT CATEGORIES:
- "false": Claim directly contradicts verified sources
- "misleading": Claim is technically true but missing critical context that changes its meaning
- "unverified": No credible sources confirm or deny — not enough evidence either way
- "true": Confirmed by multiple independent credible sources
- "satire_misread": Content is satire or parody, being shared as genuine news
- "old_news_recycled": The event was real but happened in the past — being recirculated as current
- "out_of_context": Real image or event used to support a completely different, unrelated claim

FOR EACH CLAIM:
1. Write 1-2 targeted search queries
2. Execute web searches
3. Evaluate results against the claim
4. Assign truth_score 0-100 (0=definitely false, 50=unverifiable, 100=definitely true)
5. Cite the single most credible source found

RESPOND ONLY WITH VALID JSON. NO OTHER TEXT. NO MARKDOWN. EXACT STRUCTURE:
{
  "overall_verdict": "false",
  "overall_confidence": 88,
  "analysis_summary": "2-3 sentence plain English summary of what was found",
  "claims_analysis": [
    {
      "claim_id": "C1",
      "normalized_claim": "the claim that was checked",
      "truth_score": 8,
      "verdict": "false",
      "verdict_category": "false",
      "reasoning": "Specific explanation: what sources say vs. what the claim says",
      "sources_checked": ["Dawn.com", "Geo.tv"],
      "best_source": {
        "name": "Dawn",
        "url": "https://dawn.com/example",
        "headline": "relevant article headline"
      },
      "search_queries_used": ["PM Pakistan resigned 2024", "Pakistan PM resignation news"]
    }
  ],
  "spread_risk": "high",
  "spread_risk_reason": "Political claim with emotional trigger during election period — high viral potential"
}`,
      },
      {
        id: "sp3",
        label: "System Prompt #3 — Strategist Agent",
        when: "agents/strategist.py",
        text: `You are the Strategist Agent in FakeNews Killer, a misinformation detection system for Pakistan.

ROLE: Based on the fact-check analysis results, generate specific, prioritized, actionable recommended responses. Every recommendation must be concrete and executable — not generic advice.

INPUT: The Analyst Agent's full JSON output.

YOUR PROCESS:
1. Assess overall harm potential of this misinformation
2. Identify who is most at risk (general public, specific communities, investors, patients, etc.)
3. Generate exactly 3-5 recommended actions targeting different response layers
4. Rank each action by urgency: immediate | within_24h | within_1_week
5. For each action, specify exactly what the Executor Agent will generate

ACTION TYPES:
- platform_flag: Report the content to social media platform (WhatsApp, Facebook, Twitter/X)
- public_correction: Generate a shareable fact-check post for the public
- community_alert: Alert a specific community that is targeted by this misinformation
- authority_notify: Notify relevant Pakistani authority (PEMRA, PTA, FIA Cyber Crime Wing)
- tracker_log: Log this claim to the misinformation tracking database
- media_brief: Prepare a briefing for journalists covering the original story

RESPOND ONLY WITH VALID JSON. NO OTHER TEXT. NO MARKDOWN. EXACT STRUCTURE:
{
  "harm_level": "high",
  "affected_audience": "General Pakistani public, particularly those following political news",
  "recommended_actions": [
    {
      "action_id": "A1",
      "action_type": "public_correction",
      "title": "Generate shareable fact-check card",
      "description": "Create a WhatsApp-shareable verdict card with the fact-check finding, sources, and warning",
      "urgency": "immediate",
      "simulated_output_type": "verdict_card",
      "priority_rank": 1
    }
  ],
  "do_not_share_warning": "⚠️ This message contains FALSE information. Do not forward. | ⚠️ Yeh message GALAT malumat hai. Aagay mat bhejen.",
  "context_note": "Brief explanation of why this misinformation exists and what agenda it may serve"
}`,
      },
      {
        id: "sp4",
        label: "System Prompt #4 — Executor Agent",
        when: "agents/executor.py",
        text: `You are the Executor Agent in FakeNews Killer, a misinformation detection system for Pakistan.

ROLE: Simulate the execution of the top 3 recommended actions. Generate all tangible outputs — verdict card data, tracker database entry, and platform report — as if they were being submitted to real production systems right now.

INPUT: The combined output from ALL previous agents (Reader + Analyst + Strategist results as one JSON object).

YOU MUST ALWAYS EXECUTE EXACTLY THESE THREE ACTIONS. No exceptions.

ACTION 1 — VERDICT CARD
Generate complete structured data for a shareable visual fact-check card. This will be rendered as a UI component in the mobile app and shared via WhatsApp. Every field will be displayed — make them clear, accurate, and appropriately alarming or reassuring.

ACTION 2 — TRACKER LOG ENTRY  
Generate a complete database insert object as if writing to the FakeNews Killer misinformation tracker. Include all metadata. Use the entry_id format: FNK-[YYYYMMDD]-[3 digit random number].

ACTION 3 — PLATFORM REPORT
Write a complete, professional content abuse report as if being formally submitted to a social media platform. Use formal, precise language. This should look like something a legal team would send.

RESPOND ONLY WITH VALID JSON. NO OTHER TEXT. NO MARKDOWN. EXACT STRUCTURE:
{
  "execution_timestamp": "2024-12-05T09:23:10Z",
  "actions_executed": 3,
  "verdict_card": {
    "claim_summary": "One sentence: what claim was checked",
    "overall_verdict": "FALSE",
    "verdict_color": "red",
    "confidence_percentage": 91,
    "key_finding": "One clear sentence stating the fact-check finding",
    "sources": ["Dawn", "Geo News"],
    "fact_checked_by": "FakeNews Killer AI",
    "check_timestamp": "December 5, 2024 at 9:23 AM",
    "share_text": "✅ Fact Checked by FakeNews Killer: [key finding]. Source: [source]. Visit fakenewskiller.app to check more.",
    "urdu_verdict": "جھوٹ",
    "roman_urdu_warning": "⚠️ Yeh khabar BILKUL GALAT hai. Aagay mat bhejen. FakeNews Killer ne verify kiya."
  },
  "tracker_entry": {
    "entry_id": "FNK-20241205-042",
    "claim_text": "normalized claim text",
    "verdict": "false",
    "category": "political | health | economic | religious | security | other",
    "language": "roman_urdu",
    "spread_risk": "high",
    "first_detected": "2024-12-05T09:23:10Z",
    "sources_cited": ["Dawn.com", "Geo.tv"],
    "tags": ["political", "election", "WhatsApp forward"],
    "status": "logged"
  },
  "platform_report": {
    "report_type": "Misinformation / False News",
    "platform": "WhatsApp",
    "content_description": "Description of the reported content",
    "harm_category": "Political Manipulation / Public Safety / Health Misinformation",
    "evidence_summary": "Summary of evidence found against this content",
    "recommended_action": "Remove content / Add fact-check label / Reduce algorithmic distribution",
    "reporter": "FakeNews Killer Automated Detection System — fakenewskiller.app",
    "report_body": "FORMAL REPORT BODY: Full professional text of the report, 3-4 paragraphs, suitable for submission to a platform's trust and safety team."
  },
  "execution_log": [
    {"step": 1, "action": "verdict_card_generated", "status": "success", "timestamp": "2024-12-05T09:23:09Z"},
    {"step": 2, "action": "tracker_entry_created", "entry_id": "FNK-20241205-042", "status": "success", "timestamp": "2024-12-05T09:23:09Z"},
    {"step": 3, "action": "platform_report_drafted", "platform": "WhatsApp", "status": "success", "timestamp": "2024-12-05T09:23:10Z"}
  ]
}`,
      },
    ],
  },
];

const tagColors = {
  Setup: ["#E6F1FB", "#0C447C"],
  Scaffold: ["#EEEDFE", "#3C3489"],
  "Agent 1": ["#E6F1FB", "#185FA5"],
  "Agent 2": ["#E6F1FB", "#185FA5"],
  "Agent 3": ["#E6F1FB", "#185FA5"],
  "Agent 4": ["#E6F1FB", "#185FA5"],
  Test: ["#EAF3DE", "#3B6D11"],
  Research: ["#FAEEDA", "#854F0B"],
  "Mock Data": ["#FAEEDA", "#854F0B"],
  Docs: ["#F1EFE8", "#444441"],
  "Demo Script": ["#EEEDFE", "#534AB7"],
  Testing: ["#EAF3DE", "#3B6D11"],
  "Screen 1": ["#E6F1FB", "#185FA5"],
  "Screen 2": ["#E6F1FB", "#185FA5"],
  "Screen 3": ["#E6F1FB", "#185FA5"],
  "Screen 4": ["#E6F1FB", "#185FA5"],
  "Screen 5": ["#E6F1FB", "#185FA5"],
  Integration: ["#EAF3DE", "#3B6D11"],
  Design: ["#FAEEDA", "#854F0B"],
  Copy: ["#F1EFE8", "#444441"],
  "Demo Inputs": ["#EEEDFE", "#534AB7"],
  "Bug Fix": ["#FCEBEB", "#A32D2D"],
  "Trace Log": ["#E6F1FB", "#185FA5"],
  "Before/After": ["#EEEDFE", "#534AB7"],
  "Final Test": ["#EAF3DE", "#3B6D11"],
  "Demo Video": ["#EEEDFE", "#534AB7"],
  Logs: ["#F1EFE8", "#444441"],
  Submit: ["#EAF3DE", "#3B6D11"],
  README: ["#F1EFE8", "#444441"],
  Pitch: ["#EEEDFE", "#534AB7"],
  Record: ["#EEEDFE", "#534AB7"],
  "Final QA": ["#EAF3DE", "#3B6D11"],
  Package: ["#EAF3DE", "#3B6D11"],
};

export default function BuildPlan() {
  const [tab, setTab] = useState(0);
  const [copied, setCopied] = useState(null);

  const copy = (text, id) => {
    navigator.clipboard.writeText(text);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  };

  const s = {
    wrap: { fontFamily: "var(--font-sans)", color: "var(--color-text-primary)", paddingBottom: 40 },
    header: { padding: "20px 0 0" },
    title: { fontSize: 20, fontWeight: 500, margin: "0 0 4px" },
    sub: { fontSize: 13, color: "var(--color-text-secondary)", margin: 0 },
    tabs: { display: "flex", gap: 4, padding: "16px 0 0", borderBottom: "0.5px solid var(--color-border-tertiary)", marginBottom: 20 },
    tabBtn: (active) => ({
      padding: "8px 16px", fontSize: 13, fontWeight: active ? 500 : 400,
      background: active ? "var(--color-background-secondary)" : "transparent",
      border: "0.5px solid " + (active ? "var(--color-border-secondary)" : "transparent"),
      borderRadius: "var(--border-radius-md)", cursor: "pointer",
      color: active ? "var(--color-text-primary)" : "var(--color-text-secondary)",
      transition: "all 0.15s",
    }),
    techGrid: { display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 10, marginBottom: 24 },
    techCard: { background: "var(--color-background-secondary)", borderRadius: "var(--border-radius-md)", padding: "12px 14px", display: "flex", alignItems: "center", gap: 10 },
    techIcon: { fontSize: 20, color: "var(--color-text-secondary)" },
    techLabel: { fontSize: 13, fontWeight: 500, margin: 0 },
    techSub: { fontSize: 11.5, color: "var(--color-text-secondary)", margin: 0 },
    dayHeader: (color, bg) => ({ background: bg, border: "0.5px solid " + color + "33", borderRadius: "var(--border-radius-lg)", padding: "14px 18px", marginBottom: 18, display: "flex", alignItems: "center", justifyContent: "space-between" }),
    dayTitle: (color) => ({ fontSize: 17, fontWeight: 500, color, margin: 0 }),
    dayFocus: { fontSize: 13, color: "var(--color-text-secondary)", margin: 0 },
    cols: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14 },
    colHead: (color) => ({ fontSize: 12, fontWeight: 500, color, marginBottom: 10, display: "flex", alignItems: "center", gap: 6 }),
    taskCard: { background: "var(--color-background-primary)", border: "0.5px solid var(--color-border-tertiary)", borderRadius: "var(--border-radius-md)", padding: "10px 12px", marginBottom: 8 },
    taskTime: { fontSize: 11, color: "var(--color-text-secondary)", marginBottom: 4 },
    taskText: { fontSize: 12.5, lineHeight: 1.6, margin: 0 },
    tagPill: ([bg, col]) => ({ display: "inline-block", fontSize: 10, fontWeight: 500, padding: "2px 7px", borderRadius: 20, background: bg, color: col, marginBottom: 5 }),
    sectionHead: { fontSize: 15, fontWeight: 500, margin: "0 0 4px" },
    sectionSub: { fontSize: 12.5, color: "var(--color-text-secondary)", margin: "0 0 14px" },
    promptCard: { border: "0.5px solid var(--color-border-tertiary)", borderRadius: "var(--border-radius-lg)", overflow: "hidden", marginBottom: 14 },
    promptHeader: { padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: "0.5px solid var(--color-border-tertiary)", background: "var(--color-background-secondary)" },
    promptLabel: { fontSize: 13.5, fontWeight: 500, margin: 0 },
    promptWhen: (color) => ({ fontSize: 11, color: "#fff", background: color, padding: "2px 8px", borderRadius: 20, fontWeight: 500 }),
    promptBody: { padding: "14px 16px", background: "var(--color-background-primary)" },
    pre: { background: "var(--color-background-secondary)", borderRadius: "var(--border-radius-md)", padding: "14px 16px", fontSize: 11.5, lineHeight: 1.7, fontFamily: "var(--font-mono)", overflowX: "auto", margin: "0 0 10px", whiteSpace: "pre-wrap", wordBreak: "break-word", color: "var(--color-text-primary)" },
    copyBtn: (done) => ({ display: "flex", alignItems: "center", gap: 5, fontSize: 12, padding: "6px 14px", border: "0.5px solid var(--color-border-secondary)", borderRadius: "var(--border-radius-md)", background: done ? "var(--color-background-success)" : "transparent", color: done ? "var(--color-text-success)" : "var(--color-text-secondary)", cursor: "pointer", transition: "all 0.15s" }),
    groupHead: (color) => ({ borderLeft: "3px solid " + color, paddingLeft: 12, marginBottom: 4 }),
    divider: { borderTop: "0.5px solid var(--color-border-tertiary)", margin: "24px 0" },
  };

  return (
    <div style={s.wrap}>
      <div style={s.header}>
        <h1 style={s.title}>🕵️ FakeNews Killer — 3-Day Build Plan</h1>
        <p style={s.sub}>You + co-worker · Google Antigravity · Lahore hackathon</p>
      </div>

      <div style={s.tabs}>
        {TABS.map((t, i) => (
          <button key={t} style={s.tabBtn(tab === i)} onClick={() => setTab(i)}>{t}</button>
        ))}
      </div>

      {/* OVERVIEW */}
      {tab === 0 && (
        <div>
          <p style={{ fontSize: 13.5, color: "var(--color-text-secondary)", lineHeight: 1.7, marginTop: 0 }}>
            Two people, 3 days, one submission. Aziz handles all code. Your co-worker handles research, testing, docs, and the demo video. Below is the tech stack, then drill into each day.
          </p>
          <div style={{ fontSize: 13, fontWeight: 500, marginBottom: 10 }}>Tech stack</div>
          <div style={s.techGrid}>
            {tech.map(t => (
              <div key={t.label} style={s.techCard}>
                <i className={`ti ${t.icon}`} style={s.techIcon} aria-hidden="true" />
                <div>
                  <p style={s.techLabel}>{t.label}</p>
                  <p style={s.techSub}>{t.sub}</p>
                </div>
              </div>
            ))}
          </div>
          <div style={{ border: "0.5px solid var(--color-border-tertiary)", borderRadius: "var(--border-radius-lg)", overflow: "hidden" }}>
            {[
              ["Pipeline flow", "Input text → Reader Agent → Analyst Agent (web search) → Strategist Agent → Executor Agent → JSON result"],
              ["Mobile app", "Flutter (Android). 5 screens: Input → Loading (agent ticker) → Results → Verdict Card → Tracker Dashboard"],
              ["Critical req met", "Executor fires 3 simulated actions: verdict card generated, tracker entry created, platform report drafted"],
              ["Antigravity usage", "Agent Manager View runs all 4 agents. Use Manager View screenshots as your agent trace log submission"],
              ["Submission", "Working mobile app + 3–5 min demo video + README + agent trace logs from Antigravity"],
            ].map(([label, val], i) => (
              <div key={i} style={{ display: "flex", gap: 0, borderBottom: i < 4 ? "0.5px solid var(--color-border-tertiary)" : "none" }}>
                <div style={{ width: 160, minWidth: 160, padding: "11px 14px", fontSize: 12.5, fontWeight: 500, color: "var(--color-text-secondary)", background: "var(--color-background-secondary)", borderRight: "0.5px solid var(--color-border-tertiary)" }}>{label}</div>
                <div style={{ padding: "11px 14px", fontSize: 12.5, lineHeight: 1.6 }}>{val}</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* DAY TABS */}
      {[1, 2, 3].includes(tab) && (() => {
        const d = days[tab - 1];
        return (
          <div>
            <div style={s.dayHeader(d.color, d.bg)}>
              <div>
                <p style={s.dayTitle(d.color)}>{d.title} — {d.focus}</p>
              </div>
              <div style={{ fontSize: 12.5, color: d.color, fontWeight: 500 }}>{d.aziz.length + d.coworker.length} tasks total</div>
            </div>
            <div style={s.cols}>
              <div>
                <div style={s.colHead(d.color)}><i className="ti ti-code" aria-hidden="true" /> Aziz — coding</div>
                {d.aziz.map((t, i) => (
                  <div key={i} style={s.taskCard}>
                    <div style={s.tagPill(tagColors[t.tag] || ["#F1EFE8", "#444441"])}>{t.tag}</div>
                    <div style={s.taskTime}>{t.time}</div>
                    <p style={s.taskText}>{t.task}</p>
                  </div>
                ))}
              </div>
              <div>
                <div style={s.colHead("#854F0B")}><i className="ti ti-user" aria-hidden="true" /> Co-worker — no code needed</div>
                {d.coworker.map((t, i) => (
                  <div key={i} style={s.taskCard}>
                    <div style={s.tagPill(tagColors[t.tag] || ["#F1EFE8", "#444441"])}>{t.tag}</div>
                    <div style={s.taskTime}>{t.time}</div>
                    <p style={s.taskText}>{t.task}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        );
      })()}

      {/* PROMPTS TAB */}
      {tab === 4 && (
        <div>
          {agPrompts.map((group, gi) => (
            <div key={gi}>
              <div style={s.groupHead(group.color)}>
                <div style={s.sectionHead}>{group.group}</div>
                <div style={{ fontSize: 12.5, color: "var(--color-text-secondary)" }}>{group.sub}</div>
              </div>
              <div style={{ marginTop: 14 }}>
                {group.items.map((p) => (
                  <div key={p.id} style={s.promptCard}>
                    <div style={s.promptHeader}>
                      <p style={s.promptLabel}>{p.label}</p>
                      <span style={s.promptWhen(group.color)}>{p.when}</span>
                    </div>
                    <div style={s.promptBody}>
                      <pre style={s.pre}>{p.text}</pre>
                      <button style={s.copyBtn(copied === p.id)} onClick={() => copy(p.text, p.id)}>
                        <i className={`ti ${copied === p.id ? "ti-check" : "ti-copy"}`} aria-hidden="true" />
                        {copied === p.id ? "Copied!" : "Copy prompt"}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
              {gi === 0 && <div style={s.divider} />}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
