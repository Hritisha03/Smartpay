"""AI orchestration engine for SmartPay AI.

This module ties together all agents and produces a combined response.
"""

from __future__ import annotations

from typing import Dict, Any

from ai.peer_comparison_agent import PeerComparisonAgent
from ai.justification_agent import JustificationAgent
from ai.regret_agent import RegretAgent
from ai.what_if_agent import WhatIfAgent
from ai.explanation_agent import ExplanationAgent


class SmartPayAIEngine:
    """Orchestrator that coordinates multiple explainable agents."""

    def __init__(self) -> None:
        self.peer_agent = PeerComparisonAgent()
        self.just_agent = JustificationAgent()
        self.regret_agent = RegretAgent()
        self.what_if_agent = WhatIfAgent()
        self.explanation_agent = ExplanationAgent()

    def analyze(self, analytics: Dict[str, Any]) -> Dict[str, Any]:
        """Invoke each agent and combine their outputs into a single response."""

        peer_output = self.peer_agent.analyze(analytics.get("categories", {}))
        justification_output = self.just_agent.analyze(analytics.get("categories", {}))
        regret_output = self.regret_agent.analyze(
            income=analytics.get("income", 0),
            total_spend=analytics.get("total_spend", 0),
        )
        what_if_output = self.what_if_agent.analyze(analytics)

        explanation_text = self.explanation_agent.explain(
            peer=peer_output,
            justification=justification_output,
            regret=regret_output,
            what_if=what_if_output,
        )

        return {
            "insights": [
                peer_output.get("message"),
                justification_output.get("explanation"),
                regret_output.get("message"),
                what_if_output.get("message"),
            ],
            "agent_breakdown": {
                "peer": peer_output,
                "justification": justification_output,
                "regret": regret_output,
                "what_if": what_if_output,
            },
            "explanation": explanation_text,
        }
