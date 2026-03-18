# SmartPay AI — Quick Start Guide

Get SmartPay AI running in 5 minutes!

## ⚡ 5-Minute Quick Start

### Step 1: Start Backend (3 minutes)

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt
python main.py
```

✅ Success: Server starts at `http://localhost:8000`

### Step 2: Run Frontend (2 minutes)

```bash
# In a NEW terminal
cd frontend/frontend
flutter pub get
flutter run -d chrome
```

✅ Success: App opens in browser

---

## 🧪 Test the API Immediately

In a 3rd terminal, test endpoints:

```bash
# 1. Get all users
curl http://localhost:8000/users

# 2. Get specific user
curl http://localhost:8000/users/user1

# 3. Run AI analysis
curl -X POST http://localhost:8000/analyze/user1

# 4. Get risk assessment
curl -X POST http://localhost:8000/risk/user1

# 5. Classify all users
curl -X POST http://localhost:8000/classify

# 6. What-if simulation
curl -X POST http://localhost:8000/simulate \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user1","category":"shopping","reduction_percentage":15}'
```

---

## 🎮 Test in Flutter UI

1. **Home Screen:** View 3 sections
   - Wallet balance
   - Action tiles (Send, History, AI Report, Multi-User, Comparison)

2. **AI Report Screen:** Click "AI Report" tile
   - View Key Metrics (Income, Expenses, Savings)
   - See Health Score (0-100, color-coded)
   - Check Risk Level (Low/Medium/High)
   - View Spending Trend Chart
   - See Category Breakdown
   - Read AI Insights & Recommendations
   - Click "What-If Simulation" button

3. **Multi-User Screen:** Click "Multi-User" tile
   - See 3 pre-loaded users (Alice, Bob, Charlie)
   - View each user's breakdown
   - Click "View AI Report" for individual analysis
   - Add/Edit/Delete users

---

## 📊 Sample API Responses

### GET /users
```json
{
  "users": [
    {
      "user_id": "user1",
      "name": "Alice (Saver)",
      "monthly_income": 45000,
      "monthly_goal": 10000,
      "transaction_count": 8
    }
  ],
  "total_users": 3
}
```

### POST /analyze/{user_id}
```json
{
  "user_id": "user1",
  "name": "Alice (Saver)",
  "report": {
    "trend": "Stable",
    "trend_percentage": 1.77,
    "predicted_expense": 4832.5,
    "risk_level": "Low",
    "personality_type": "Saver",
    "health_score": 85.7,
    "insights": [
      "Spending pattern is stable.",
      "Highest spending in 'rent' category: ₹21000.0",
      "You have good spending discipline!"
    ],
    "advice": [
      "✓ Excellent financial discipline!",
      "Consider investing surplus funds for wealth growth.",
      "Review investment options aligned with your goals."
    ]
  }
}
```

### POST /classify
```json
{
  "classifications": {
    "user1": {
      "name": "Alice (Saver)",
      "type": "Saver"
    },
    "user2": {
      "name": "Bob (Balanced)",
      "type": "Balanced"
    },
    "user3": {
      "name": "Charlie (Overspender)",
      "type": "Overspender"
    }
  },
  "summary": {
    "Saver": 1,
    "Balanced": 1,
    "Overspender": 1
  },
  "total_users": 3
}
```

---

## 🔍 Understanding the AI

### How Prediction Works
- Analyzes last 2-3 months of expenses
- Uses Linear Regression to find trend
- Predicts next month based on pattern
- Higher data = higher confidence

### Risk Calculation
```
Risk Score = 40% (spending ratio) + 40% (savings) + 20% (stability)
- Low: 0-30
- Medium: 30-60
- High: 60+
```

### Health Score Calculation
```
Score = 40% (saving ratio) + 30% (expense stability) 
      + 20% (goal progress) + 10% (emergency buffer)
- Excellent: 70+
- Good: 50-70
- Needs Improvement: <50
```

### User Personality
- **Saver:** Spends <50% of income
- **Balanced:** Spends 50-75% of income
- **Overspender:** Spends >75% of income

---

## ⚙️ Environment Variables (Optional)

Create `.env` in `backend/`:
```
FASTAPI_DEBUG=True
DB_TYPE=memory  # or 'firestore'
```

---

## 🐛 Common Issues & Fixes

### "Port 8000 already in use"
```bash
# Use different port
uvicorn main:app --port 8001
```

### "Module not found" error
```bash
# Make sure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
```

### Flutter won't build
```bash
cd frontend/frontend
flutter clean
flutter pub get
flutter pub upgrade
```

### Charts not showing
```bash
# Update pubspec.yaml, then run:
flutter pub get
flutter pub upgrade
```

---

## 📱 Running on Different Platforms

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android Emulator
```bash
flutter run -d emulator-5554
```

### iOS Simulator
```bash
flutter run -d simulator
```

### Real Device
```bash
flutter run
```

---

## 📈 Next Steps

1. **Modify Sample Data:** Edit `backend/database/db.py` to add your own users
2. **Add Transactions:** Use `POST /transactions` endpoint
3. **Firebase Integration:** Update `database/db.py` with Firestore
4. **Custom UI:** Modify `lib/screens/` Dart files
5. **Advanced ML:** Implement LSTM in `ml_utils/ml_engine.py`

---

## 📚 API Documentation

Once backend is running, visit:
```
http://localhost:8000/docs        # Interactive Swagger UI
http://localhost:8000/redoc       # ReDoc documentation
```

---

## 💡 Pro Tips

1. **Test Different Users:** Change URL `/analyze/user1` to `/analyze/user2` or `/analyze/user3`
2. **Modify Categories:** Edit expenses in `backend/database/db.py` line 50-70
3. **Change Thresholds:** Adjust risk levels in `backend/agents/risk_agent.py`
4. **Custom Insights:** Modify text generation in `backend/agents/analyzer_agent.py`
5. **Live Prediction:** Add real transactions via API to train model

---

## 🚀 Performance Tips

- Load all users on startup: `GET /users`
- Cache health scores: Only recalculate on new transactions
- Batch predictions: `POST /predict-expense` for multiple users
- Debounce charts: Wait for data before rendering

---

## 📞 Support

- **Docs:** See [FULL_STACK_README.md](./FULL_STACK_README.md)
- **API Errors:** Check `http://localhost:8000/docs` for error details
- **Flutter Issues:** Check `flutter doctor` output

---

**Ready? Start backend now! 🚀**

```bash
cd backend && python main.py
```
