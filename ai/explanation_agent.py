"""Explanation agent for SmartPay AI.

This agent creates a human-readable explanation that ties together the outputs
from the other agents.
"""

from __future__ import annotations

from typing import Dict, Any


class ExplanationAgent:
    """Builds a concise, explainable summary of agent outputs."""

    def explain(
        self,
        peer: Dict[str, Any],
        justification: Dict[str, Any],
        regret: Dict[str, Any],
        what_if: Dict[str, Any],
    ) -> str:
        """Create a sentence that references the agent outputs."""

        parts = []

        # Base rationale
        parts.append(
            "This insight is based on your income, spending distribution, and savings goal."
        )

        # Peer comparison cues
        if peer.get("message"):
            parts.append(peer["message"])

        # Justification summary
        score = justification.get("score")
        if score is not None:
            parts.append(
                f"A budget priority score of {score} was calculated to capture how your "
                "current spending aligns with a simple category weighting system."
            )

        # Regret / risk cue
        if regret.get("risk"):
            parts.append(
                f"Your current risk level is classified as '{regret['risk']}'. "
                f"{regret.get('message', '')}"
            )

        # What-if highlight
        if what_if.get("message"):
            parts.append(what_if["message"])

        return " ".join(parts)
