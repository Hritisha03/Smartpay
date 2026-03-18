"""In-memory database layer for SmartPay AI.

This is a lightweight in-memory storage.
Later can be replaced with Firebase Firestore.
"""

from typing import Dict, List, Optional
from models.data_models import UserProfile, Transaction
from datetime import datetime, timedelta
import random


class Database:
    """In-memory database for user profiles and transactions."""

    def __init__(self):
        self.users: Dict[str, UserProfile] = {}
        self.initialize_sample_data()

    def initialize_sample_data(self):
        """Initialize with sample multi-user data for demonstration."""
        # User 1: Saver
        user1_transactions = [
            Transaction("user1", 500, "food", "2024-01-05", "Groceries"),
            Transaction("user1", 200, "travel", "2024-01-08", "Bus"),
            Transaction("user1", 1500, "rent", "2024-01-01", "Rent"),
            Transaction("user1", 300, "utilities", "2024-01-10", "Electricity"),
            # More recent
            Transaction("user1", 520, "food", "2024-02-05", "Groceries"),
            Transaction("user1", 220, "travel", "2024-02-08", "Bus"),
            Transaction("user1", 1500, "rent", "2024-02-01", "Rent"),
            Transaction("user1", 310, "utilities", "2024-02-10", "Electricity"),
        ]
        self.users["user1"] = UserProfile(
            user_id="user1",
            name="Alok (Saver)",
            monthly_income=45000,
            monthly_goal=10000,
            transactions=user1_transactions,
        )

        # User 2: Balanced
        user2_transactions = [
            Transaction("user2", 800, "food", "2024-01-05", "Groceries & Dining"),
            Transaction("user2", 400, "travel", "2024-01-08", "Travel"),
            Transaction("user2", 2000, "rent", "2024-01-01", "Rent"),
            Transaction("user2", 500, "shopping", "2024-01-12", "Clothes"),
            Transaction("user2", 400, "utilities", "2024-01-10", "Bills"),
            # More recent
            Transaction("user2", 850, "food", "2024-02-05", "Groceries & Dining"),
            Transaction("user2", 450, "travel", "2024-02-08", "Travel"),
            Transaction("user2", 2000, "rent", "2024-02-01", "Rent"),
            Transaction("user2", 550, "shopping", "2024-02-12", "Clothes"),
            Transaction("user2", 420, "utilities", "2024-02-10", "Bills"),
        ]
        self.users["user2"] = UserProfile(
            user_id="user2",
            name="Hansikaa (Balanced)",
            monthly_income=60000,
            monthly_goal=12000,
            transactions=user2_transactions,
        )

        # User 3: Overspender
        user3_transactions = [
            Transaction("user3", 1200, "food", "2024-01-05", "Restaurants & Groceries"),
            Transaction("user3", 600, "travel", "2024-01-08", "Uber & Travel"),
            Transaction("user3", 2500, "rent", "2024-01-01", "Luxury Rent"),
            Transaction("user3", 1500, "shopping", "2024-01-12", "Shopping"),
            Transaction("user3", 800, "entertainment", "2024-01-15", "Movies & Clubs"),
            Transaction("user3", 400, "utilities", "2024-01-10", "Bills"),
            # More recent
            Transaction("user3", 1300, "food", "2024-02-05", "Restaurants & Groceries"),
            Transaction("user3", 700, "travel", "2024-02-08", "Uber & Travel"),
            Transaction("user3", 2500, "rent", "2024-02-01", "Luxury Rent"),
            Transaction("user3", 1700, "shopping", "2024-02-12", "Shopping"),
            Transaction("user3", 900, "entertainment", "2024-02-15", "Movies & Clubs"),
            Transaction("user3", 420, "utilities", "2024-02-10", "Bills"),
        ]
        self.users["user3"] = UserProfile(
            user_id="user3",
            name="Siba (Overspender)",
            monthly_income=55000,
            monthly_goal=8000,
            transactions=user3_transactions,
        )

    def add_user(self, user: UserProfile) -> bool:
        """Add a new user."""
        if user.user_id in self.users:
            return False
        self.users[user.user_id] = user
        return True

    def get_user(self, user_id: str) -> Optional[UserProfile]:
        """Get user by ID."""
        return self.users.get(user_id)

    def add_transaction(self, user_id: str, transaction: Transaction) -> bool:
        """Add transaction for a user."""
        if user_id not in self.users:
            return False
        self.users[user_id].transactions.append(transaction)
        return True

    def get_all_users(self) -> List[UserProfile]:
        """Get all users."""
        return list(self.users.values())

    def get_user_transactions(self, user_id: str) -> List[Transaction]:
        """Get all transactions for a user."""
        user = self.users.get(user_id)
        return user.transactions if user else []


# Global database instance
db = Database()
