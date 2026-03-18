"""What-if agent for SmartPay AI.

This agent simulates a spending reduction in a given category and reports the
impact on total spend and savings without changing the original input.
"""

from __future__ import annotations

from typing import Dict, Any


class WhatIfAgent:
    """Simulates spending adjustments while keeping original data intact."""

    def analyze(
        self,
        analytics: Dict[str, Any],
        category: str = "shopping",
        reduction_pct: float = 10.0,
    ) -> Dict[str, Any]:
        """Simulate reducing spend in a category and recalculate totals."""

        categories = {k.lower(): v for k, v in analytics.get("categories", {}).items()}
        total_spend = float(analytics.get("total_spend", 0.0))
        income = float(analytics.get("income", 0.0))

        category = category.lower().strip()
        original_pct = categories.get(category, 0)

        # If the category isn't present, no changes are applied.
        if original_pct <= 0:
            return {
                "new_spend": total_spend,
                "new_savings": round(income - total_spend, 2),
                "message": (
                    f"Category '{category}' not found in spending distribution; "
                    "no what-if changes applied."
                ),
                "adjusted_category": category,
                "adjustment": 0,
            }

        # Calculate the impact of reducing that category by reduction_pct.
        reduction_factor = max(min(reduction_pct / 100.0, 1.0), 0.0)
        reduced_pct = original_pct * (1.0 - reduction_factor)

        # Recalculate total spend assuming the percentage change impacts total spend.
        # For simplicity, we assume the category reduction lowers total spend proportionally.
        pct_change = original_pct - reduced_pct
        new_total_spend = total_spend * (1.0 - (pct_change / 100.0))
        new_savings = round(income - new_total_spend, 2)

        message = (
            f"If you reduce {category} spending by {reduction_pct}% (from {original_pct}% to "
            f"{round(reduced_pct, 1)}% of total spend), your total spend would be "
            f"${new_total_spend:,.2f} and savings would be ${new_savings:,.2f}."
        )

        return {
            "new_spend": round(new_total_spend, 2),
            "new_savings": new_savings,
            "message": message,
            "adjusted_category": category,
            "adjustment": reduction_pct,
        }
