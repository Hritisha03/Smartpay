"""Risk Agent for SmartPay AI.

Detects financial risk and generates warning messages.
"""

from typing import Dict, List
from models.data_models import UserProfile
from collections import defaultdict


class RiskAgent:
    """Analyzes financial risk and detects overspending."""

    def __init__(self):
        self.name = "Risk Agent"

    def assess_risk(self, user: UserProfile) -> Dict:
        """Assess financial risk for a user.
        
        Returns:
            Dict with risk level and warning messages.
        """
        transactions = user.transactions
        if not transactions:
            return {
                "risk_level": "Unknown",
                "risk_score": 0,
                "warnings": ["No transaction data available"],
            }

        # Calculate key metrics
        total_spent = sum(txn.amount for txn in transactions)
        spending_ratio = total_spent / (user.monthly_income * len(set(t.date[:7] for t in transactions)))
        avg_monthly = total_spent / max(1, len(set(t.date[:7] for t in transactions)))
        savings = (user.monthly_income - avg_monthly) / user.monthly_income

        # Determine risk level
        risk_score = self._calculate_risk_score(spending_ratio, savings, transactions)
        risk_level = self._categorize_risk(risk_score)

        # Generate warnings
        warnings = self._generate_warnings(
            user, spending_ratio, savings, avg_monthly, transactions
        )

        return {
            "risk_level": risk_level,
            "risk_score": round(risk_score, 2),
            "spending_ratio": round(spending_ratio, 2),
            "savings_ratio": round(savings, 2),
            "warnings": warnings,
        }

    def _calculate_risk_score(
        self, spending_ratio: float, savings: float, transactions: List
    ) -> float:
        """Calculate risk score (0-100)."""
        score = 0

        # Spending ratio component (0-40)
        if spending_ratio < 0.5:
            score += 10
        elif spending_ratio < 0.75:
            score += 25
        else:
            score += 40

        # Savings component (0-40)
        if savings > 0.3:
            score += 10
        elif savings > 0.2:
            score += 20
        elif savings > 0.1:
            score += 30
        else:
            score += 40

        # Expense stability component (0-20)
        monthly_expenses = defaultdict(float)
        for txn in transactions:
            try:
                month_key = txn.date[:7]
            except:
                month_key = "unknown"
            monthly_expenses[month_key] += txn.amount

        if len(monthly_expenses) >= 2:
            values = list(monthly_expenses.values())
            avg = sum(values) / len(values)
            variance = sum((x - avg) ** 2 for x in values) / len(values)
            std_dev = variance ** 0.5
            cv = std_dev / avg if avg > 0 else 0

            if cv < 0.1:
                score += 5
            elif cv < 0.3:
                score += 10
            else:
                score += 20

        return min(100, score)

    def _categorize_risk(self, risk_score: float) -> str:
        """Categorize risk based on score."""
        if risk_score < 30:
            return "Low"
        elif risk_score < 60:
            return "Medium"
        else:
            return "High"

    def _generate_warnings(
        self,
        user: UserProfile,
        spending_ratio: float,
        savings: float,
        avg_monthly: float,
        transactions: List,
    ) -> List[str]:
        """Generate risk warning messages."""
        warnings = []

        if spending_ratio > 0.9:
            warnings.append(
                "⚠ Critical: You are spending almost all of your income!"
            )
        elif spending_ratio > 0.8:
            warnings.append("⚠ Warning: High spending detected (>80% of income).")

        if savings < 0.1:
            warnings.append(
                "⚠ Low savings ratio (<10%). Build emergency fund quickly."
            )
        elif savings < 0.2:
            warnings.append("⚠ Savings are less than 20% of income.")

        # Check for overspending in specific categories
        category_totals = defaultdict(float)
        for txn in transactions:
            category_totals[txn.category] += txn.amount

        total = sum(category_totals.values())
        for category, amount in category_totals.items():
            percentage = (amount / total) * 100 if total > 0 else 0
            if percentage > 40:
                warnings.append(
                    f"⚠ High spending in '{category}' ({percentage:.0f}% of total)."
                )

        # Check if savings are decreasing
        monthly_expenses = defaultdict(float)
        for txn in transactions:
            try:
                month_key = txn.date[:7]
            except:
                month_key = "unknown"
            monthly_expenses[month_key] += txn.amount

        if len(monthly_expenses) >= 2:
            months = sorted(monthly_expenses.keys())
            last_month = monthly_expenses[months[-1]]
            prev_month = monthly_expenses[months[-2]]
            if last_month > prev_month * 1.1:  # 10% increase
                increase = ((last_month - prev_month) / prev_month) * 100
                warnings.append(
                    f"⚠ Spending increased by {increase:.0f}% this month."
                )

        if not warnings:
            warnings.append("✓ Financial situation is stable.")

        return warnings
