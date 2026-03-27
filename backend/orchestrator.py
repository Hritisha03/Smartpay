"""AI Orchestrator Engine for SmartPay AI.

Coordinates all agents to produce comprehensive financial insights.
"""

from typing import Dict

from models.data_models import AIReport, UserProfile

from agents.advisor_agent import run_advisor_agent
from agents.analyzer_agent import run_analyzer_agent
from agents.classifier_agent import ClassifierAgent
from agents.prediction_agent import PredictionAgent
from agents.risk_agent import run_risk_agent


class AIOrchestrator:
    """Main orchestrator that coordinates all AI agents."""

    def __init__(self):
        self.predictor = PredictionAgent()
        self.classifier = ClassifierAgent()

    def analyze_user(self, user: UserProfile) -> AIReport:
        """Complete analysis for a single user."""
        category_totals = self._build_category_totals(user)
        total_spent = sum(txn.amount for txn in user.transactions)

        analysis = run_analyzer_agent(
            {
                "total": total_spent,
                "categories": category_totals,
            }
        )
        prediction = self.predictor.predict(user)
        risk_assessment = run_risk_agent(
            {
                "income": user.monthly_income,
                "spending": total_spent,
            }
        )
        personality = self.classifier.classify_user(user)
        advice = run_advisor_agent(
            {
                "total": total_spent,
                "highest_category": analysis.get("highest_category", "Unknown"),
                "risk": risk_assessment.get("risk_level", "Unknown"),
                "trend": analysis.get("trend", "Unknown"),
            }
        )

        insights = analysis.get("insights", []) + risk_assessment.get("warnings", [])
        advice_items = self._normalize_advice(advice)

        return AIReport(
            trend=analysis.get("trend", "Unknown"),
            trend_percentage=analysis.get("trend_percentage", 0),
            predicted_expense=prediction.get("predicted_expense", 0),
            risk_level=risk_assessment.get("risk_level", "Unknown"),
            personality_type=personality,
            insights=insights[:5],
            advice=advice_items,
            health_score=self._calculate_health_score(user),
        )

    def _build_category_totals(self, user: UserProfile) -> Dict[str, float]:
        category_totals: Dict[str, float] = {}
        for txn in user.transactions:
            category_totals[txn.category] = category_totals.get(txn.category, 0) + txn.amount
        return category_totals

    def _normalize_advice(self, advice: Dict) -> list[str]:
        if advice.get("recommendations"):
            return advice["recommendations"][:5]

        raw_text = advice.get("advice", "")
        return [
            line.strip("-* ").strip()
            for line in raw_text.split("\n")
            if line.strip()
        ][:5]

    def _calculate_health_score(self, user: UserProfile) -> float:
        """Calculate financial health score (0-100)."""
        total_spent = sum(txn.amount for txn in user.transactions)
        num_months = len(set(t.date[:7] for t in user.transactions)) or 1
        avg_monthly = total_spent / num_months

        saving_ratio = (user.monthly_income - avg_monthly) / user.monthly_income
        saving_score = min(40, max(0, saving_ratio * 100))

        spending_ratio = avg_monthly / user.monthly_income
        if spending_ratio < 0.5:
            stability_score = 30
        elif spending_ratio < 0.75:
            stability_score = 15
        else:
            stability_score = 5

        if user.monthly_goal > 0:
            goal_progress = (saving_ratio * user.monthly_income) / user.monthly_goal
            goal_score = min(20, max(0, goal_progress * 20))
        else:
            goal_score = 20

        if saving_ratio > 0.3:
            emergency_score = 10
        elif saving_ratio > 0.2:
            emergency_score = 7
        elif saving_ratio > 0.1:
            emergency_score = 4
        else:
            emergency_score = 0

        total_score = saving_score + stability_score + goal_score + emergency_score
        return round(total_score, 1)
