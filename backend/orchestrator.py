"""AI Orchestrator Engine for SmartPay AI.

Coordinates all agents to produce comprehensive financial insights.
"""

from typing import Dict
from models.data_models import UserProfile, AIReport
from agents.analyzer_agent import AnalyzerAgent
from agents.prediction_agent import PredictionAgent
from agents.risk_agent import RiskAgent
from agents.advisor_agent import AdvisorAgent
from agents.classifier_agent import ClassifierAgent


class AIOrchestrator:
    """Main orchestrator that coordinates all AI agents."""

    def __init__(self):
        self.analyzer = AnalyzerAgent()
        self.predictor = PredictionAgent()
        self.risk = RiskAgent()
        self.advisor = AdvisorAgent()
        self.classifier = ClassifierAgent()

    def analyze_user(self, user: UserProfile) -> AIReport:
        """Complete analysis for a single user.
        
        Calls all agents and combines results into a comprehensive report.
        """
        # Call each agent
        analysis = self.analyzer.analyze(user)
        prediction = self.predictor.predict(user)
        risk_assessment = self.risk.assess_risk(user)
        personality = self.classifier.classify_user(user)
        advice = self.advisor.advise(
            user,
            risk_assessment["risk_level"],
            personality,
            analysis.get("trend_percentage", 0),
        )

        # Combine insights
        insights = (
            analysis.get("insights", [])
            + risk_assessment.get("warnings", [])
        )

        # Create report
        report = AIReport(
            trend=analysis.get("trend", "Unknown"),
            trend_percentage=analysis.get("trend_percentage", 0),
            predicted_expense=prediction.get("predicted_expense", 0),
            risk_level=risk_assessment.get("risk_level", "Unknown"),
            personality_type=personality,
            insights=insights[:5],  # Limit to 5 insights
            advice=advice.get("recommendations", [])[:5],  # Limit to 5 pieces of advice
            health_score=self._calculate_health_score(user, analysis, risk_assessment),
        )

        return report

    def _calculate_health_score(
        self, user: UserProfile, analysis: Dict, risk_assessment: Dict
    ) -> float:
        """Calculate comprehensive financial health score (0-100).
        
        Weighted formula:
        - Saving ratio (40%)
        - Expense stability (30%)
        - Goal progress (20%)
        - Emergency buffer (10%)
        """
        total_spent = sum(txn.amount for txn in user.transactions)
        num_months = len(set(t.date[:7] for t in user.transactions)) or 1
        avg_monthly = total_spent / num_months

        # Saving ratio (40%)
        saving_ratio = (user.monthly_income - avg_monthly) / user.monthly_income
        saving_score = min(40, max(0, saving_ratio * 100))

        # Expense stability (30%)
        spending_ratio = avg_monthly / user.monthly_income
        if spending_ratio < 0.5:
            stability_score = 30
        elif spending_ratio < 0.75:
            stability_score = 15
        else:
            stability_score = 5
        stability_score = max(0, min(30, stability_score))

        # Goal progress (20%)
        if user.monthly_goal > 0:
            goal_progress = (saving_ratio * user.monthly_income) / user.monthly_goal
            goal_score = min(20, max(0, goal_progress * 20))
        else:
            goal_score = 20

        # Emergency buffer (10%)
        emergency_ratio = saving_ratio
        if emergency_ratio > 0.3:
            emergency_score = 10
        elif emergency_ratio > 0.2:
            emergency_score = 7
        elif emergency_ratio > 0.1:
            emergency_score = 4
        else:
            emergency_score = 0

        total_score = (
            saving_score + stability_score + goal_score + emergency_score
        )
        return round(total_score, 1)
