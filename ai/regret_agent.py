"""Regret agent for SmartPay AI.

This agent assesses savings risk based on income and total spending.
"""

from __future__ import annotations

from typing import Dict, Any


class RegretAgent:
    """A simple rule-based agent that computes savings risk."""

    RISK_THRESHOLD = 0.20  # 20% of income

    def analyze(self, income: float, total_spend: float) -> Dict[str, Any]:
        """Calculate savings and determine risk based on a simple threshold."""

        savings = float(income) - float(total_spend)
        if income <= 0:
            risk = "unknown"
            message = "Income must be a positive value to compute risk."
        else:
            threshold = float(income) * self.RISK_THRESHOLD
            if savings < threshold:
                risk = "high"
                message = (
                    "Your savings are less than 20% of income, which is a higher risk zone. "
                    "Consider reducing discretionary spending or increasing income."
                )
            else:
                risk = "low"
                message = (
                    "Your savings are above 20% of income, which indicates a lower risk "
                    "profile for short-term financial stability."
                )

        return {
            "risk": risk,
            "message": message,
            "savings": round(savings, 2),
            "threshold": round(float(income) * self.RISK_THRESHOLD, 2),
        }
