"""ML utilities for SmartPay AI.

Uses scikit-learn for predictions and clustering.
"""

from typing import List, Tuple
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler


class ExpensePredictor:
    """Linear Regression based expense predictor."""

    def __init__(self):
        self.model = LinearRegression()
        self.is_trained = False

    def train(self, historical_expenses: List[float]):
        """Train on historical expense data.
        
        Args:
            historical_expenses: List of monthly expenses in chronological order.
        """
        if len(historical_expenses) < 2:
            self.is_trained = False
            return

        # X: months (0, 1, 2, ...), y: expenses
        X = np.array(range(len(historical_expenses))).reshape(-1, 1)
        y = np.array(historical_expenses)
        self.model.fit(X, y)
        self.is_trained = True

    def predict_next(self, historical_expenses: List[float]) -> float:
        """Predict next month's expense."""
        if not self.is_trained or len(historical_expenses) < 1:
            # Fallback: weighted average
            if not historical_expenses:
                return 0
            if len(historical_expenses) == 1:
                return historical_expenses[0]
            return (historical_expenses[-1] * 0.6) + (historical_expenses[-2] * 0.4)

        # Use the trained model
        next_month = len(historical_expenses)
        prediction = self.model.predict([[next_month]])[0]
        return max(0, prediction)  # Ensure non-negative


class UserClassifier:
    """K-Means based user classification."""

    CATEGORIES = ["Saver", "Balanced", "Overspender"]

    def __init__(self, n_clusters: int = 3):
        self.n_clusters = n_clusters
        self.model = KMeans(n_clusters=n_clusters, random_state=42)
        self.scaler = StandardScaler()
        self.is_trained = False

    def train(self, user_features: List[List[float]]):
        """Train classifier on user feature vectors.
        
        Features should be: [spending_ratio, savings_ratio, expense_stability]
        """
        if len(user_features) < self.n_clusters:
            self.is_trained = False
            return

        X = np.array(user_features)
        X_scaled = self.scaler.fit_transform(X)
        self.model.fit(X_scaled)
        self.is_trained = True

    def classify(self, user_features: List[float]) -> str:
        """Classify a single user."""
        if not self.is_trained:
            # Rule-based fallback
            spending_ratio = user_features[0]
            if spending_ratio > 0.7:
                return "Overspender"
            elif spending_ratio > 0.5:
                return "Balanced"
            else:
                return "Saver"

        X = np.array(user_features).reshape(1, -1)
        X_scaled = self.scaler.transform(X)
        cluster = self.model.predict(X_scaled)[0]
        return self.CATEGORIES[cluster % len(self.CATEGORIES)]


# Global instances
predictor = ExpensePredictor()
classifier = UserClassifier()
