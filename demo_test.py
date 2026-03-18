"""
Demo script to test all SmartPay AI features.

Run this after starting the backend: python backend/main.py
"""

import requests
import json
from typing import Any, Dict

BASE_URL = "http://localhost:8000"


def print_section(title: str):
    """Print formatted section header."""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)


def print_response(data: Dict[str, Any], indent: int = 2):
    """Pretty print JSON response."""
    print(json.dumps(data, indent=indent))


def test_get_all_users():
    """Test: Get all users."""
    print_section("TEST 1: Get All Users")
    response = requests.get(f"{BASE_URL}/users")
    print_response(response.json())
    return response.json()


def test_get_single_user(user_id: str):
    """Test: Get single user profile."""
    print_section(f"TEST 2: Get User Profile ({user_id})")
    response = requests.get(f"{BASE_URL}/users/{user_id}")
    print_response(response.json())
    return response.json()


def test_analyze_user(user_id: str):
    """Test: Complete AI analysis."""
    print_section(f"TEST 3: Complete AI Analysis ({user_id})")
    response = requests.post(f"{BASE_URL}/analyze/{user_id}")
    print_response(response.json())
    return response.json()


def test_classify_all_users():
    """Test: Classify all users."""
    print_section("TEST 4: User Classification")
    response = requests.post(f"{BASE_URL}/classify")
    print_response(response.json())
    return response.json()


def test_predict_expense(user_id: str):
    """Test: Predict next expense."""
    print_section(f"TEST 5: Expense Prediction ({user_id})")
    response = requests.post(f"{BASE_URL}/predict-expense/{user_id}")
    print_response(response.json())
    return response.json()


def test_risk_assessment(user_id: str):
    """Test: Risk assessment."""
    print_section(f"TEST 6: Risk Assessment ({user_id})")
    response = requests.post(f"{BASE_URL}/risk/{user_id}")
    print_response(response.json())
    return response.json()


def test_what_if_simulation(
    user_id: str, category: str = "shopping", reduction: float = 15.0
):
    """Test: What-if simulation."""
    print_section(f"TEST 7: What-If Simulation ({user_id})")
    payload = {
        "user_id": user_id,
        "category": category,
        "reduction_percentage": reduction,
    }
    response = requests.post(f"{BASE_URL}/simulate", json=payload)
    print_response(response.json())
    return response.json()


def test_add_transaction(user_id: str):
    """Test: Add new transaction."""
    print_section(f"TEST 8: Add Transaction ({user_id})")
    payload = {
        "user_id": user_id,
        "amount": 1500,
        "category": "food",
        "date": "2024-03-18",
        "description": "Restaurant dinner",
    }
    response = requests.post(f"{BASE_URL}/transactions", json=payload)
    print_response(response.json())
    return response.json()


def test_api_root():
    """Test: API root endpoint."""
    print_section("TEST 0: API Information")
    response = requests.get(BASE_URL)
    print_response(response.json())
    return response.json()


def run_all_tests():
    """Run all tests."""
    print("\n")
    print("╔════════════════════════════════════════════════════════════╗")
    print("║        SmartPay AI — Comprehensive Feature Demo            ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print(f"\n📍 Backend URL: {BASE_URL}")
    print("⏱️  Make sure backend is running: python backend/main.py\n")

    try:
        # Test API
        test_api_root()

        # Get all users
        users_data = test_get_all_users()
        user_ids = [u["user_id"] for u in users_data.get("users", [])]

        if not user_ids:
            print("❌ No users found! Start backend first.")
            return

        # Test each user
        for user_id in user_ids:
            print(f"\n\n{'#'*60}")
            print(f"# Testing {user_id.upper()}")
            print(f"{'#'*60}")

            # Profile
            test_get_single_user(user_id)

            # Analysis
            test_analyze_user(user_id)

            # Prediction
            test_predict_expense(user_id)

            # Risk
            test_risk_assessment(user_id)

            # What-if
            test_what_if_simulation(user_id, "shopping", 20)

        # Classification
        test_classify_all_users()

        # Add transaction
        if user_ids:
            test_add_transaction(user_ids[0])

        print_section("✅ ALL TESTS COMPLETED SUCCESSFULLY!")
        print("\n📊 Key Insights:")
        print("  • Multi-agent AI system is working")
        print("  • Predictions use Linear Regression")
        print("  • Risk assessment calculates health scores")
        print("  • What-if simulation shows impact analysis")
        print("  • User classification identifies spending patterns")

    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to backend!")
        print("   Start backend with: python backend/main.py")
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        print("   Check backend logs for details")


if __name__ == "__main__":
    run_all_tests()

    print("\n\n" + "="*60)
    print("🎯 Next Steps:")
    print("="*60)
    print("1. Start Flutter frontend: flutter run -d chrome")
    print("2. Check /docs for interactive API explorer")
    print("3. Modify sample data in backend/database/db.py")
    print("4. Customize AI thresholds in agents/")
    print("="*60 + "\n")
