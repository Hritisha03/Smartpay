# SmartPay AI — Agent Architecture (One‑Page)

This document summarizes how SmartPay AI’s multi‑agent system works, where each
agent is implemented, and how the UI consumes their outputs.

## End‑to‑End Flow
1. User opens the app, views balance, and triggers actions (Send, Reports, Goals).
2. The backend runs multiple agents in parallel to generate the AI report.
3. The Transaction Guard blocks, warns, or approves payments.
4. AI Chat answers questions using the full report context.

## Core Agents (Backend)

### 1) Analyzer Agent — Spending Analysis
- File: `smartpay-ai/backend/agents/analyzer_agent.py`
- Inputs: Total spending + category breakdown
- Outputs: Trend, top category, short insights
- Used in: `AIOrchestrator.analyze_user()` (`smartpay-ai/backend/orchestrator.py`)

### 2) Prediction Agent — Expense Forecast
- File: `smartpay-ai/backend/agents/prediction_agent.py`
- Inputs: User transaction history
- Outputs: Predicted next expense + confidence
- Used in: `AIOrchestrator.analyze_user()` and `/predict-expense/{user_id}`

### 3) Risk Agent — Overspending Risk
- File: `smartpay-ai/backend/agents/risk_agent.py`
- Inputs: Income + spending
- Outputs: Risk level + warnings
- Used in: `AIOrchestrator.analyze_user()`, `/risk/{user_id}`, `/transaction-guard`

### 4) Advisor Agent (LLM) — Recommendations + Chat
- File: `smartpay-ai/backend/agents/advisor_agent.py`
- Inputs: Full financial context + user question
- Outputs: Advice and conversational replies
- Used in: `/chat`, `/transaction-guard`

### 5) Classifier Agent — Spender Type
- File: `smartpay-ai/backend/agents/classifier_agent.py`
- Inputs: Spending ratio + category distribution
- Outputs: Saver / Balanced / Overspender
- Used in: `AIOrchestrator.analyze_user()`, `/classify`

## Orchestration
- File: `smartpay-ai/backend/orchestrator.py`
- Combines the outputs of Analyzer, Predictor, Risk, Classifier, Advisor
- Produces a unified `AIReport`:
  - trend, predicted_expense, risk_level, personality_type
  - insights, advice, health_score

## AI Endpoints (Backend API)
- `POST /analyze/{user_id}` → full AI report (all agents)
- `POST /predict-expense/{user_id}` → prediction only
- `POST /risk/{user_id}` → risk only
- `POST /chat` → AI chat with full context
- `POST /transaction-guard` → approve / warn / reject payment

## UI Integration (Frontend)

### Home + Generate Report
- File: `smartpay-ai/frontend/frontend/lib/screens/home_screen.dart`
- Shows balance, health score, sparkline, and “Generate Report” tab

### Full AI Report Screen
- File: `smartpay-ai/frontend/frontend/lib/screens/ai_report_screen.dart`
- Shows full report + charts + advanced chatbox
- Chat suggestions + savings‑focused responses

### AI Chat (standalone)
- File: `smartpay-ai/frontend/frontend/lib/screens/ai_chat_screen.dart`
- Calls `/chat` with the user’s question

### Transaction Guard (Send Flow)
- File: `smartpay-ai/frontend/frontend/lib/screens/send_money_screen.dart`
- Calls `/transaction-guard` before allowing PIN + success

## Sample Users (Backend Database)
- File: `smartpay-ai/backend/database/db.py`
- Three users: Hritisha, Siba, Alok (all password `1234`)
- Patterns include overspender, balanced, and normal

## Viva‑Ready Summary
SmartPay AI uses a multi‑agent backend: analysis, prediction, risk, classification,
and advice are computed in parallel and merged into a single AI report. The UI
consumes this report for analytics and injects it into AI chat. A Transaction Guard
LLM evaluates every payment to approve, warn, or reject based on the user’s
financial state.
