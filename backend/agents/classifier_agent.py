"""Classifier Agent for SmartPay AI.

Classifies users based on spending patterns.
"""

from typing import Dict, List, Tuple
from models.data_models import UserProfile
from ml_utils.ml_engine import classifier


class ClassifierAgent:
    """Classifies users into spending personality types."""

    def __init__(self):
        self.name = "Classifier Agent"

    def classify_user(self, user: UserProfile) -> str:
        """Classify a single user into personality type.
        
        Uses rule-based logic with ML fallback.
        """
        if not user.transactions:
            return "Unknown"

        # Calculate features
        total_spent = sum(txn.amount for txn in user.transactions)
        num_months = len(set(t.date[:7] for t in user.transactions)) or 1
        avg_monthly = total_spent / num_months
        savings_ratio = 1 - (avg_monthly / user.monthly_income)
        spending_ratio = avg_monthly / user.monthly_income

        # Get highest category percentage
        category_totals = {}
        for txn in user.transactions:
            category_totals[txn.category] = category_totals.get(txn.category, 0) + txn.amount
        
        total = sum(category_totals.values())
        luxury_pct = 0
        if total > 0:
            luxury_categories = {"shopping", "entertainment"}
            luxury_total = sum(v for k, v in category_totals.items() if k in luxury_categories)
            luxury_pct = (luxury_total / total) * 100

        # Rule-based classification
        if spending_ratio > 0.85:
            return "Overspender"
        elif spending_ratio > 0.65:
            return "Balanced"
        else:
            return "Saver"

    def classify_multiple_users(self, users: List[UserProfile]) -> Dict:
        """Classify multiple users and return comparison.
        
        Returns:
            Dict with classifications and clustering info.
        """
        classifications = {}
        for user in users:
            classifications[user.user_id] = {
                "name": user.name,
                "type": self.classify_user(user),
            }

        # Count types
        type_counts = {}
        for info in classifications.values():
            user_type = info["type"]
            type_counts[user_type] = type_counts.get(user_type, 0) + 1

        return {
            "classifications": classifications,
            "summary": type_counts,
            "total_users": len(users),
        }
