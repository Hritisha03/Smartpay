"""Data models for SmartPay AI."""

from typing import List, Dict, Optional
from dataclasses import dataclass, asdict
from datetime import datetime


@dataclass
class Transaction:
    """Represents a single expense transaction."""
    user_id: str
    amount: float
    category: str
    date: str
    description: str


@dataclass
class UserProfile:
    """User profile with financial data."""
    user_id: str
    name: str
    password: str
    monthly_income: float
    monthly_goal: float
    transactions: List[Transaction]

    def to_dict(self):
        return asdict(self)


@dataclass
class AIReport:
    """AI-generated financial report."""
    trend: str
    trend_percentage: float
    predicted_expense: float
    risk_level: str
    personality_type: str
    insights: List[str]
    advice: List[str]
    health_score: float

    def to_dict(self):
        return asdict(self)
