"""Analyzer Agent for SmartPay AI.

Detects spending trends and analyzes transaction history.
"""

from typing import Dict, List, Tuple
from models.data_models import UserProfile, Transaction
from collections import defaultdict


class AnalyzerAgent:
    """Analyzes user spending patterns and transactions."""

    def __init__(self):
        self.name = "Analyzer Agent"

    def analyze(self, user: UserProfile) -> Dict:
        """Analyze user spending patterns.
        
        Returns:
            Dict with trend analysis and insights.
        """
        transactions = user.transactions
        if not transactions:
            return {
                "trend": "No data",
                "trend_percentage": 0,
                "highest_category": None,
                "total_spent": 0,
                "insights": ["No transaction history available"],
            }

        # Calculate spending by month
        spending_by_month = self._calculate_monthly_spending(transactions)
        months = sorted(spending_by_month.keys())

        if len(months) < 2:
            return {
                "trend": "Insufficient data",
                "trend_percentage": 0,
                "highest_category": self._get_highest_category(transactions),
                "total_spent": sum(spending_by_month.values()),
                "insights": ["Need more data to detect trends"],
            }

        # Calculate trend
        last_month_spending = spending_by_month[months[-1]]
        prev_month_spending = spending_by_month[months[-2]]

        trend_percentage = 0
        if prev_month_spending > 0:
            trend_percentage = (
                (last_month_spending - prev_month_spending) / prev_month_spending
            ) * 100

        trend = "Increasing" if trend_percentage > 0 else "Decreasing"

        # Get highest category
        highest_category = self._get_highest_category(transactions)

        # Generate insights
        insights = self._generate_insights(
            user, transactions, trend, trend_percentage, highest_category
        )

        return {
            "trend": trend,
            "trend_percentage": round(trend_percentage, 2),
            "highest_category": highest_category,
            "total_spent": round(sum(spending_by_month.values()), 2),
            "insights": insights,
        }

    def _calculate_monthly_spending(
        self, transactions: List[Transaction]
    ) -> Dict[str, float]:
        """Group spending by month."""
        monthly = defaultdict(float)
        for txn in transactions:
            # Extract month from date (assuming YYYY-MM-DD format or similar)
            try:
                month_key = txn.date[:7]  # Get YYYY-MM
            except:
                month_key = "unknown"
            monthly[month_key] += txn.amount
        return dict(monthly)

    def _get_highest_category(self, transactions: List[Transaction]) -> str:
        """Get category with highest spending."""
        category_totals = defaultdict(float)
        for txn in transactions:
            category_totals[txn.category] += txn.amount
        if not category_totals:
            return None
        return max(category_totals, key=category_totals.get)

    def _generate_insights(
        self,
        user: UserProfile,
        transactions: List[Transaction],
        trend: str,
        trend_percentage: float,
        highest_category: str,
    ) -> List[str]:
        """Generate text insights."""
        insights = []

        # Trend insight
        if trend_percentage > 10:
            insights.append(
                f"Spending increased by {abs(trend_percentage):.1f}% compared to last month."
            )
        elif trend_percentage < -10:
            insights.append(
                f"Spending decreased by {abs(trend_percentage):.1f}% compared to last month. Good job!"
            )
        else:
            insights.append("Spending pattern is stable.")

        # Category insight
        if highest_category:
            category_total = sum(
                txn.amount for txn in transactions if txn.category == highest_category
            )
            insights.append(
                f"Highest spending in '{highest_category}' category: ₹{category_total:.0f}"
            )

        # Budget comparison
        total_spent = sum(txn.amount for txn in transactions)
        avg_monthly = total_spent / max(1, len(set(t.date[:7] for t in transactions)))
        if avg_monthly > user.monthly_income * 0.8:
            insights.append(
                "You are spending 80% or more of your income. Consider reducing expenses."
            )
        elif avg_monthly < user.monthly_income * 0.5:
            insights.append("You have good spending discipline!")

        return insights
