"""Prediction Agent for SmartPay AI.

Uses ML to predict future expenses based on historical data.
"""

from typing import Dict, List
from models.data_models import UserProfile
from ml_utils.ml_engine import predictor
from collections import defaultdict


class PredictionAgent:
    """Predicts future expenses using machine learning."""

    def __init__(self):
        self.name = "Prediction Agent"

    def predict(self, user: UserProfile) -> Dict:
        """Predict next month's expense.
        
        Returns:
            Dict with prediction and confidence metrics.
        """
        transactions = user.transactions
        if not transactions:
            return {"predicted_expense": 0, "confidence": "low", "method": "inline"}

        # Calculate monthly expenses
        monthly_expenses = self._get_monthly_expenses(transactions)
        if not monthly_expenses:
            return {"predicted_expense": 0, "confidence": "low", "method": "inline"}

        monthly_list = sorted(monthly_expenses.values())

        # Train predictor
        predictor.train(monthly_list)

        # Get prediction
        if predictor.is_trained:
            predicted = predictor.predict_next(monthly_list)
            confidence = "high" if len(monthly_list) >= 3 else "medium"
            method = "Linear Regression"
        else:
            # Fallback: weighted average
            if len(monthly_list) >= 2:
                predicted = (monthly_list[-1] * 0.6) + (monthly_list[-2] * 0.4)
                confidence = "medium"
            else:
                predicted = monthly_list[-1] if monthly_list else 0
                confidence = "low"
            method = "Weighted Average"

        return {
            "predicted_expense": round(predicted, 2),
            "confidence": confidence,
            "method": method,
            "historical_avg": round(sum(monthly_list) / len(monthly_list), 2)
            if monthly_list
            else 0,
        }

    def _get_monthly_expenses(self, transactions) -> Dict[str, float]:
        """Group expenses by month."""
        monthly = defaultdict(float)
        for txn in transactions:
            try:
                month_key = txn.date[:7]  # YYYY-MM
            except:
                month_key = "unknown"
            monthly[month_key] += txn.amount
        return dict(monthly)
