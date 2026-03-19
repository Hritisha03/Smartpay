"""
AI Orchestrator Engine for SmartPay AI.

Coordinates all agents to produce comprehensive financial insights.
"""

from typing import Dict
from models.data_models import UserProfile, AIReport

from agents.analyzer_agent import AnalyzerAgent
from agents.prediction_agent import PredictionAgent
from agents.risk_agent import RiskAgent
from agents.classifier_agent import ClassifierAgent

from agno import Agent


# =========================
# 🔥 AGNO ADVISOR AGENT
# =========================

advisor_agent = Agent(
    name="SmartPay Advisor",
    model="openai:gpt-4o-mini",   # ✅ REQUIRED (change to ollama/mistral if offline)
    instructions="""
    You are a smart financial advisor AI.

    Your job:
    - Analyze user financial data
    - Give 4-5 short bullet-point suggestions
    - Keep advice practical and realistic
    - Use simple language
    - Do NOT give long paragraphs
    """
)


def run_advisor_agent(data: Dict):
    """Run LLM-powered advisor agent"""
    prompt = f"""
    User Financial Data:
    - Total Spending: ₹{data['total']}
    - Highest Spending Category: {data['highest_category']}
    - Risk Level: {data['risk']}
    - Spending Trend: {data['trend']}

    Provide financial advice.
    """

    response = advisor_agent.run(prompt)

    # Clean output → list of bullet points
    advice_list = [
        line.strip("-• ").strip()
        for line in response.content.split("\n")
        if line.strip()
    ]

    return {
        "recommendations": advice_list[:5]
    }


# =========================
# 🧠 ORCHESTRATOR CLASS
# =========================

class AIOrchestrator:
    """Main orchestrator that coordinates all AI agents."""

    def __init__(self):
        self.analyzer = AnalyzerAgent()
        self.predictor = PredictionAgent()
        self.risk = RiskAgent()
        self.classifier = ClassifierAgent()

    def analyze_user(self, user: UserProfile) -> AIReport:
        """Complete analysis for a single user."""

        # 🔹 Step 1: Run core agents
        analysis = self.analyzer.analyze(user)
        prediction = self.predictor.predict(user)
        risk_assessment = self.risk.assess_risk(user)
        personality = self.classifier.classify_user(user)

        # 🔹 Step 2: Run AI Advisor (Agno)
        total_spent = sum(txn.amount for txn in user.transactions)

        advice = run_advisor_agent({
            "total": total_spent,
            "highest_category": analysis.get("highest_category", "Unknown"),
            "risk": risk_assessment.get("risk_level", "Unknown"),
            "trend": analysis.get("trend", "Unknown")
        })

        # 🔹 Step 3: Combine insights
        insights = (
            analysis.get("insights", []) +
            risk_assessment.get("warnings", [])
        )

        # 🔹 Step 4: Create report
        report = AIReport(
            trend=analysis.get("trend", "Unknown"),
            trend_percentage=analysis.get("trend_percentage", 0),
            predicted_expense=prediction.get("predicted_expense", 0),
            risk_level=risk_assessment.get("risk_level", "Unknown"),
            personality_type=personality,
            insights=insights[:5],
            advice=advice.get("recommendations", []),
            health_score=self._calculate_health_score(user),
        )

        return report

    # =========================
    # 💯 HEALTH SCORE LOGIC
    # =========================

    def _calculate_health_score(self, user: UserProfile) -> float:
        """Calculate financial health score (0-100)."""

        total_spent = sum(txn.amount for txn in user.transactions)
        num_months = len(set(t.date[:7] for t in user.transactions)) or 1
        avg_monthly = total_spent / num_months

        # 🔹 Saving ratio (40%)
        saving_ratio = (user.monthly_income - avg_monthly) / user.monthly_income
        saving_score = min(40, max(0, saving_ratio * 100))

        # 🔹 Expense stability (30%)
        spending_ratio = avg_monthly / user.monthly_income
        if spending_ratio < 0.5:
            stability_score = 30
        elif spending_ratio < 0.75:
            stability_score = 15
        else:
            stability_score = 5

        # 🔹 Goal progress (20%)
        if user.monthly_goal > 0:
            goal_progress = (saving_ratio * user.monthly_income) / user.monthly_goal
            goal_score = min(20, max(0, goal_progress * 20))
        else:
            goal_score = 20

        # 🔹 Emergency buffer (10%)
        if saving_ratio > 0.3:
            emergency_score = 10
        elif saving_ratio > 0.2:
            emergency_score = 7
        elif saving_ratio > 0.1:
            emergency_score = 4
        else:
            emergency_score = 0

        total_score = (
            saving_score +
            stability_score +
            goal_score +
            emergency_score
        )

        return round(total_score, 1)