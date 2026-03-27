"""FastAPI backend for SmartPay AI.

This is the main API server with all AI endpoints.
"""

from fastapi import FastAPI, jsonify
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
import json
from pydantic import BaseModel
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(__file__))

from models.data_models import Transaction, UserProfile
from database.db import db
from orchestrator import AIOrchestrator
from agents.classifier_agent import ClassifierAgent
from agents.risk_agent import run_risk_agent

app = FastAPI(title="SmartPay AI", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize AI orchestrator
orchestrator = AIOrchestrator()
classifier = ClassifierAgent()


# ==================== Request Models ====================


class TransactionRequest(BaseModel):
    """Request model for adding a transaction."""
    user_id: str
    amount: float
    category: str
    date: str
    description: str


class WhatIfRequest(BaseModel):
    """Request model for what-if simulation."""
    user_id: str
    category: str
    reduction_percentage: float


class GuardRequest(BaseModel):
    """Request model for transaction guard."""
    user_id: str
    recipient: str
    amount: float


class LoginRequest(BaseModel):
    name: str
    password: str


# ==================== Endpoints ====================


@app.get("/")
def read_root():
    """Root endpoint - API info."""
    return {
        "app": "SmartPay AI",
        "version": "1.0.0",
        "endpoints": [
            "GET /users - Get all users",
            "GET /users/{user_id} - Get single user",
            "POST /transactions - Add transaction",
            "POST /analyze/{user_id} - Analyze user",
            "POST /classify - Classify all users",
            "POST /simulate - What-if simulation",
        ],
    }


@app.get("/users")
def get_all_users():
    """Get all users with their profiles."""
    users = db.get_all_users()
    return {
        "users": [
            {
                "user_id": u.user_id,
                "name": u.name,
                "monthly_income": u.monthly_income,
                "monthly_goal": u.monthly_goal,
                "transaction_count": len(u.transactions),
            }
            for u in users
        ],
        "total_users": len(users),
    }


@app.post("/login")
def login(request: LoginRequest):
    users = db.get_all_users()
    for u in users:
        if u.name.lower() == request.name.lower() and u.password == request.password:
            return {"user_id": u.user_id, "name": u.name}
    return {"error": "Invalid credentials"}, 401


@app.get("/users/{user_id}")
def get_user(user_id: str):
    """Get specific user profile."""
    user = db.get_user(user_id)
    if not user:
        return {"error": "User not found"}, 404

    return {
        "user_id": user.user_id,
        "name": user.name,
        "monthly_income": user.monthly_income,
        "monthly_goal": user.monthly_goal,
        "total_transactions": len(user.transactions),
        "transactions": [
            {
                "amount": t.amount,
                "category": t.category,
                "date": t.date,
                "description": t.description,
            }
            for t in user.transactions[-10:]  # Last 10 transactions
        ],
    }


@app.post("/transactions")
def add_transaction(request: TransactionRequest):
    """Add a new transaction for a user."""
    transaction = Transaction(
        user_id=request.user_id,
        amount=request.amount,
        category=request.category,
        date=request.date,
        description=request.description,
    )
    success = db.add_transaction(request.user_id, transaction)

    if not success:
        return {"error": "User not found"}, 404

    return {"success": True, "message": "Transaction added"}


@app.post("/analyze/{user_id}")
def analyze_user(user_id: str):
    """Run complete AI analysis for a user."""
    user = db.get_user(user_id)
    if not user:
        return {"error": "User not found"}, 404

    report = orchestrator.analyze_user(user)

    return {
        "user_id": user_id,
        "name": user.name,
        "report": {
            "trend": report.trend,
            "trend_percentage": report.trend_percentage,
            "predicted_expense": report.predicted_expense,
            "risk_level": report.risk_level,
            "personality_type": report.personality_type,
            "health_score": report.health_score,
            "insights": report.insights,
            "advice": report.advice,
        },
    }


@app.post("/classify")
def classify_all_users():
    """Classify all users into personality types."""
    users = db.get_all_users()
    result = classifier.classify_multiple_users(users)

    return {
        "classifications": result["classifications"],
        "summary": result["summary"],
        "total_users": result["total_users"],
    }


@app.post("/simulate")
def what_if_simulation(request: WhatIfRequest):
    """Simulate expense reduction (what-if scenario)."""
    user = db.get_user(request.user_id)
    if not user:
        return {"error": "User not found"}, 404

    # Get current expenses by category
    category_totals = {}
    for txn in user.transactions:
        category_totals[txn.category] = (
            category_totals.get(txn.category, 0) + txn.amount
        )

    total_spent = sum(category_totals.values())
    current_avg_monthly = total_spent / max(
        1, len(set(t.date[:7] for t in user.transactions))
    )

    # Simulate reduction
    category_amount = category_totals.get(request.category, 0)
    if category_amount <= 0:
        return {
            "error": f"Category '{request.category}' not found",
        }, 400

    reduction_amount = (
        category_amount * request.reduction_percentage / 100
    )
    simulated_monthly = (
        current_avg_monthly - reduction_amount
    ) / max(1, len(set(t.date[:7] for t in user.transactions)))

    new_savings = user.monthly_income - simulated_monthly
    savings_improvement = (
        new_savings - (user.monthly_income - current_avg_monthly)
    )

    return {
        "user_id": request.user_id,
        "current_monthly_spend": round(current_avg_monthly, 2),
        "reduced_category": request.category,
        "reduction_percentage": request.reduction_percentage,
        "reduction_amount": round(reduction_amount, 2),
        "new_monthly_spend": round(simulated_monthly, 2),
        "new_savings": round(new_savings, 2),
        "savings_improvement": round(savings_improvement, 2),
        "message": f"If you reduce {request.category} by {request.reduction_percentage}%, you save â‚¹{savings_improvement:.0f}/month.",
    }


@app.post("/predict-expense/{user_id}")
def predict_next_expense(user_id: str):
    """Predict next month's expense."""
    user = db.get_user(user_id)
    if not user:
        return {"error": "User not found"}, 404

    prediction = orchestrator.predictor.predict(user)

    return {
        "user_id": user_id,
        "predicted_expense": prediction.get("predicted_expense"),
        "confidence": prediction.get("confidence"),
        "method": prediction.get("method"),
        "historical_average": prediction.get("historical_avg"),
    }


@app.post("/risk/{user_id}")
def assess_risk(user_id: str):
    """Assess financial risk for a user."""
    user = db.get_user(user_id)
    if not user:
        return {"error": "User not found"}, 404

    total_spent = sum(txn.amount for txn in user.transactions)
    risk_assessment = run_risk_agent(
        {
            "income": user.monthly_income,
            "spending": total_spent,
        }
    )

    return {
        "user_id": user_id,
        "risk_level": risk_assessment.get("risk_level"),
        "warnings": risk_assessment.get("warnings"),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)


class ChatRequest(BaseModel):
    user_id: str
    message: str


from agents.advisor_agent import advisor_agent  # reuse LLM


@app.post("/chat")
def chat(req: ChatRequest):
    user = db.get_user(req.user_id)

    if not user:
        return {"error": "User not found"}

    report = orchestrator.analyze_user(user)

    total_spending = sum(txn.amount for txn in user.transactions)
    categories = {}
    for txn in user.transactions:
        categories[txn.category] = categories.get(txn.category, 0) + txn.amount

    prompt = f"""
    You are an intelligent financial assistant inside a finance app.

    You are powered by multiple AI capabilities:
    - Spending Analysis (trends, categories)
    - Expense Prediction (future spending)
    - Risk Assessment (overspending risk)
    - Financial Advice (improvement suggestions)

    You already have the user's financial data:

    - Income: {user.monthly_income}
    - Total Spending: {total_spending}
    - Category Breakdown: {categories}
    - Predicted Next Expense: {report.predicted_expense}
    - Risk Level: {report.risk_level}
    - Insights: {report.insights}
    - Advice: {report.advice}

    User Question:
    {req.message}

    Your task:
    1. Understand what the user is asking.
    2. Internally decide which capability is needed:
       - prediction
       - risk
       - analysis
       - advice
       - or a combination
    3. Use ONLY the relevant data provided.
    4. If needed, combine multiple insights (for example: prediction + risk).
    5. Give a clear, simple, and practical answer.
    6. Do NOT make up new data.
    7. Keep the answer concise and user-friendly.

    Final Answer:
    """

    response = advisor_agent.run(prompt)

    return {"reply": response.content}


@app.post("/transaction-guard")
def transaction_guard(req: GuardRequest):
    user = db.get_user(req.user_id)
    if not user:
        return {"error": "User not found"}, 404

    total_spent = sum(txn.amount for txn in user.transactions)
    num_months = len(set(t.date[:7] for t in user.transactions)) or 1
    avg_monthly = total_spent / num_months
    balance_estimate = max(0, user.monthly_income - avg_monthly)
    risk_assessment = run_risk_agent(
        {"income": user.monthly_income, "spending": total_spent}
    )

    guard_prompt = f"""
    You are Transaction Guard AI. Decide whether to Approve, Warn, or Reject a payment.
    Use only the data provided. Output JSON with keys decision and reason.

    User Data:
    - Balance: {balance_estimate}
    - Monthly Income: {user.monthly_income}
    - Average Monthly Spend: {avg_monthly}
    - Risk Level: {risk_assessment.get('risk_level')}

    Payment Request:
    - Recipient: {req.recipient}
    - Amount: {req.amount}

    Rules:
    - Reject if amount is clearly unaffordable or risk is high and amount is large.
    - Warn if amount is significant but could be ok with caution.
    - Approve if amount is reasonable.
    """

    response = advisor_agent.run(guard_prompt)
    content = response.content.strip()

    decision = "warn"
    reason = "Please review this payment before proceeding."
    try:
        data = json.loads(content)
        decision = str(data.get("decision", decision)).lower()
        reason = str(data.get("reason", reason))
    except Exception:
        lowered = content.lower()
        if "reject" in lowered:
            decision = "reject"
        elif "approve" in lowered:
            decision = "approve"
        reason = content[:240] if content else reason

    return {"decision": decision, "reason": reason}
