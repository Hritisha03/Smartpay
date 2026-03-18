"""FastAPI backend for SmartPay AI.

This is the main API server with all AI endpoints.
"""

from fastapi import FastAPI, jsonify
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
from pydantic import BaseModel
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(__file__))

from models.data_models import Transaction, UserProfile
from database.db import db
from orchestrator import AIOrchestrator
from agents.classifier_agent import ClassifierAgent

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
        "message": f"If you reduce {request.category} by {request.reduction_percentage}%, you save ₹{savings_improvement:.0f}/month.",
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

    risk_assessment = orchestrator.risk.assess_risk(user)

    return {
        "user_id": user_id,
        "risk_level": risk_assessment.get("risk_level"),
        "risk_score": risk_assessment.get("risk_score"),
        "spending_ratio": risk_assessment.get("spending_ratio"),
        "savings_ratio": risk_assessment.get("savings_ratio"),
        "warnings": risk_assessment.get("warnings"),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
