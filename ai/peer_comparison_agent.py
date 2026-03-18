"""Peer comparison agent for SmartPay AI.

This agent compares the user's spending distribution against a set of
predefined peer averages to produce an explainable insight.
"""

from __future__ import annotations

from typing import Dict, Any


class PeerComparisonAgent:
    """A simple agent that compares user spending to peer averages."""

    # Predefined average percentages for each category.
    # These are rule-based values; in a real system, these could come from a dataset.
    PEER_AVERAGES: Dict[str, int] = {
        "rent": 35,
        "grocery": 25,
        "food": 15,
        "shopping": 10,
        "utilities": 8,
        "entertainment": 7,
    }

    def analyze(self, categories: Dict[str, int]) -> Dict[str, Any]:
        """Compare user category percentages to peer averages.

        Args:
            categories: Mapping from category name to percentage of total spend.

        Returns:
            A dict with a message and reasoning.
        """

        explanations = []
        comparisons = []

        for category, percent in categories.items():
            peer_avg = self.PEER_AVERAGES.get(category, None)
            if peer_avg is None:
                continue

            diff = percent - peer_avg
            if diff > 5:
                explanations.append(
                    f"You spend {diff}% more than peers on {category}."
                )
                comparisons.append(
                    f"{category}: you {percent}%, peers {peer_avg}%"
                )
            elif diff < -5:
                explanations.append(
                    f"You spend {abs(diff)}% less than peers on {category}."
                )
                comparisons.append(
                    f"{category}: you {percent}%, peers {peer_avg}%"
                )

        if not explanations:
            message = "Your spending distribution is close to typical peer averages."
            reason = "No category deviated significantly from the predefined peer averages."
        else:
            message = "Your spending differs from peer averages in some categories."
            reason = (
                "; ".join(explanations)
                + " (Peer comparisons were computed against a fixed rule-based baseline.)"
            )

        return {"message": message, "reason": reason, "comparison": comparisons}
