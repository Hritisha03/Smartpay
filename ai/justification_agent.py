"""Justification agent for SmartPay AI.

This agent provides a simple rule-based scoring mechanism for spending categories.
"""

from __future__ import annotations

from typing import Dict, Any


class JustificationAgent:
    """Scores spending categories using a fixed weight dictionary."""

    SCORE_WEIGHTS: Dict[str, int] = {
        "rent": 10,
        "grocery": 7,
        "food": 6,
        "shopping": 3,
    }

    def analyze(self, categories: Dict[str, int]) -> Dict[str, Any]:
        """Compute a simple justification score and provide a textual explanation."""

        total_score = 0
        contributions = []

        for category, percent in categories.items():
            weight = self.SCORE_WEIGHTS.get(category, 1)
            # Score contribution is proportional to category importance and its share.
            contribution = (percent * weight) / 100.0
            total_score += contribution
            contributions.append(
                f"{category} ({percent}%): weight={weight}, contribution={contribution:.2f}"
            )

        # Normalize the score to a 0-10 scale for readability.
        normalized = min(max(total_score, 0), 10)

        explanation = (
            "This score is computed by weighting each category by an importance value and "
            "then combining the results. Higher scores indicate more of your budget is "
            "allocated to higher-priority categories."
        )

        impact = (
            "A higher score suggests your spending is aligned with the defined priorities. "
            "Lower scores may indicate an opportunity to re-balance spending based on goal priorities."
        )

        return {
            "score": round(normalized, 2),
            "explanation": explanation,
            "impact": impact,
            "details": contributions,
        }
