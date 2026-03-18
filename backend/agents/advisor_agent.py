"""Advisor Agent for SmartPay AI.

Generates personalized financial recommendations.
"""

from typing import Dict, List
from models.data_models import UserProfile
from collections import defaultdict


class AdvisorAgent:
    """Generates personalized financial advice and recommendations."""

    def __init__(self):
        self.name = "Advisor Agent"

    def advise(
        self,
        user: UserProfile,
        risk_level: str,
        personality: str,
        trend_percentage: float,
    ) -> Dict:
        """Generate personalized advice.
        
        Args:
            user: User profile
            risk_level: Current risk level (Low/Medium/High)
            personality: User classification (Saver/Balanced/Overspender)
            trend_percentage: Spending trend percentage
            
        Returns:
            Dict with recommendations.
        """
        advice = []

        # Risk-based advice
        if risk_level == "High":
            advice.append("🔴 Urgently reduce spending to avoid financial stress.")
            advice.append("Create a strict monthly budget and track daily expenses.")
            advice.append("Set up emergency fund (3-6 months of expenses).")
        elif risk_level == "Medium":
            advice.append("Consider optimizing your spending patterns.")
            advice.append("Set spending limits for discretionary categories.")

        # Personality-based advice
        if personality == "Overspender":
            # Find highest spending categories
            category_totals = self._get_category_totals(user.transactions)
            top_categories = sorted(
                category_totals.items(), key=lambda x: x[1], reverse=True
            )[:2]

            for category, amount in top_categories:
                if category not in ["rent", "utilities"]:
                    advice.append(
                        f"reduce spending in '{category}' by 15-20%."
                    )

            advice.append("Use the 50/30/20 budgeting rule:")
            advice.append("  - 50% needs (rent, food, utilities)")
            advice.append("  - 30% wants (entertainment, shopping)")
            advice.append("  - 20% savings & debt repayment")

        elif personality == "Balanced":
            advice.append("✓ You have a good spending balance.")
            advice.append("Focus on increasing savings by 2-3% monthly.")
            advice.append("Maintain your current spending discipline.")

        elif personality == "Saver":
            advice.append("✓ Excellent financial discipline!")
            advice.append("Consider investing surplus funds for wealth growth.")
            advice.append("Review investment options aligned with your goals.")

        # Trend-based advice
        if trend_percentage > 15:
            advice.append(f"Recent spending spike (+{trend_percentage:.0f}%). Investigate causes.")
            advice.append("Cut non-essential expenses immediately.")
        elif trend_percentage < -10:
            advice.append(f"✓ Great! Spending decreased by {abs(trend_percentage):.0f}%.")
            advice.append("Maintain this positive momentum.")

        # Goal-based advice
        remaining_budget = user.monthly_goal
        if remaining_budget > 0:
            advice.append(
                f"Your savings goal is ₹{user.monthly_goal:.0f}/month. You're {self._get_goal_progress(user):.0f}% there."
            )

        return {
            "recommendations": advice,
            "priority_actions": self._get_priority_actions(
                user, risk_level, personality
            ),
        }

    def _get_category_totals(self, transactions) -> Dict:
        """Get total spending by category."""
        totals = defaultdict(float)
        for txn in transactions:
            totals[txn.category] += txn.amount
        return dict(totals)

    def _get_goal_progress(self, user: UserProfile) -> float:
        """Get progress towards savings goal."""
        total_spent = sum(txn.amount for txn in user.transactions)
        num_months = len(set(t.date[:7] for t in user.transactions)) or 1
        avg_spent = total_spent / num_months
        avg_saved = (user.monthly_income - avg_spent) / user.monthly_income * 100
        goal_percentage = (user.monthly_goal / user.monthly_income) * 100
        return min(100, (avg_saved / max(1, goal_percentage)) * 100)

    def _get_priority_actions(
        self, user: UserProfile, risk_level: str, personality: str
    ) -> List[str]:
        """Get top priority actions for the user."""
        actions = []

        if risk_level == "High":
            actions.append("1. Cut unnecessary expenses NOW")
            actions.append("2. Review budget weekly")
            actions.append("3. Consider additional income sources")
        elif risk_level == "Medium":
            actions.append("1. Reduce discretionary spending")
            actions.append("2. Track spending categories")
            actions.append("3. Build 3-month emergency fund")
        else:
            actions.append("1. Maintain current discipline")
            actions.append("2. Increase savings rate")
            actions.append("3. Plan long-term investments")

        return actions
