"""Analytics utilities for SmartPay AI.

This module provides a simple rule-based computation over transaction data.
"""

from __future__ import annotations

from typing import Dict, List, Optional


def compute_analytics(
    transactions: List[Dict[str, float]], income: float, goal: float
) -> Dict[str, object]:
    """Compute spending analytics from a list of transactions.

    Args:
        transactions: A list of transactions like [{"category": "rent", "amount": 1200}, ...].
        income: Total income for the period.
        goal: Savings goal for the period.

    Returns:
        A JSON-serializable dict matching the required output shape.
    """

    # Summarize spend by category
    category_totals: Dict[str, float] = {}
    for txn in transactions:
        cat = str(txn.get("category", "unknown")).lower().strip()
        amount = float(txn.get("amount", 0))
        if amount < 0:
            amount = abs(amount)
        category_totals[cat] = category_totals.get(cat, 0.0) + amount

    total_spend = sum(category_totals.values())
    total_spend = round(total_spend, 2)

    # Compute percentage distribution by category
    categories_percent: Dict[str, int] = {}
    if total_spend > 0:
        for cat, amt in category_totals.items():
            pct = round((amt / total_spend) * 100)
            categories_percent[cat] = pct

        # Ensure percentages add up to 100 by adjusting the largest category
        pct_sum = sum(categories_percent.values())
        if pct_sum != 100:
            # Adjust the category with max spend to make the total 100
            max_cat = max(categories_percent, key=categories_percent.get)
            categories_percent[max_cat] += 100 - pct_sum

    return {
        "income": float(income),
        "total_spend": total_spend,
        "categories": categories_percent,
        "goal": float(goal),
    }
