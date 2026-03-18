# SmartPay AI — Agentic Explainable Financial Decision System

A beginner-friendly multi-agent AI system that uses rule-based reasoning to analyze personal finance data.

## Project Structure

```
smartpay-ai/
├── backend/
│   ├── app.py
│   └── analytics.py
├── ai/
│   ├── ai_engine.py
│   ├── explanation_agent.py
│   ├── justification_agent.py
│   ├── peer_comparison_agent.py
│   ├── regret_agent.py
│   └── what_if_agent.py
├── api/
│   └── routes.py
├── frontend/
│   └── README.md
└── README.md
```

## Running the API

1. Create a Python environment and install Flask:

```bash
python -m venv venv
venv\Scripts\activate
pip install flask
```

2. Start the API server:

```bash
python backend/app.py
```

3. Verify it works (optional):

```bash
python backend/test_request.py
```

4. Send a POST request to `http://localhost:5000/analyze` (or use the frontend demo).

## Running the frontend demo (optional)

A simple web UI is provided under `frontend/`. To run it, serve the folder using a static server and then open the browser:

```bash
cd frontend
python -m http.server 8000
```

Then open:

```
http://localhost:8000
```

The frontend sends requests to `http://localhost:5000/analyze` and displays the JSON response.

## Example Request JSON

```json
{
  "income": 30000,
  "total_spend": 21000,
  "categories": {
    "rent": 40,
    "grocery": 35,
    "food": 15,
    "shopping": 10
  },
  "goal": 50000
}
```

## Example Response JSON

```json
{
  "insights": [
    "Your spending differs from peer averages in some categories.",
    "This score is computed by weighting each category by an importance value and then combining the results. Higher scores indicate more of your budget is allocated to higher-priority categories.",
    "Your savings are less than 20% of income, which is a higher risk zone. Consider reducing discretionary spending or increasing income.",
    "If you reduce shopping spending by 10% (from 10% to 9.0% of total spend), your total spend would be $18900.00 and savings would be $11100.00."
  ],
  "agent_breakdown": {
    "peer": {
      "message": "Your spending differs from peer averages in some categories.",
      "reason": "You spend 5% more than peers on rent.; You spend 10% more than peers on grocery. (Peer comparisons were computed against a fixed rule-based baseline.)",
      "comparison": [
        "rent: you 40%, peers 35%",
        "grocery: you 35%, peers 25%"
      ]
    },
    "justification": {
      "score": 7.7,
      "explanation": "This score is computed by weighting each category by an importance value and then combining the results. Higher scores indicate more of your budget is allocated to higher-priority categories.",
      "impact": "A higher score suggests your spending is aligned with the defined priorities. Lower scores may indicate an opportunity to re-balance spending based on goal priorities.",
      "details": [
        "rent (40%): weight=10, contribution=4.00",
        "grocery (35%): weight=7, contribution=2.45",
        "food (15%): weight=6, contribution=0.90",
        "shopping (10%): weight=3, contribution=0.30"
      ]
    },
    "regret": {
      "risk": "high",
      "message": "Your savings are less than 20% of income, which is a higher risk zone. Consider reducing discretionary spending or increasing income.",
      "savings": 9000.0,
      "threshold": 6000.0
    },
    "what_if": {
      "new_spend": 18900.0,
      "new_savings": 11100.0,
      "message": "If you reduce shopping spending by 10% (from 10% to 9.0% of total spend), your total spend would be $18900.00 and savings would be $11100.00.",
      "adjusted_category": "shopping",
      "adjustment": 10.0
    }
  },
  "explanation": "This insight is based on your income, spending distribution, and savings goal. Your spending differs from peer averages in some categories. A budget priority score of 7.7 was calculated to capture how your current spending aligns with a simple category weighting system. Your current risk level is classified as 'high'. Your savings are less than 20% of income, which is a higher risk zone. Consider reducing discretionary spending or increasing income. If you reduce shopping spending by 10% (from 10% to 9.0% of total spend), your total spend would be $18900.00 and savings would be $11100.00."
}
```
