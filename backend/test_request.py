"""Simple client to test the SmartPay AI /analyze endpoint."""

import json
import urllib.request

URL = "http://127.0.0.1:5000/analyze"

payload = {
    "income": 30000,
    "total_spend": 21000,
    "categories": {"rent": 40, "grocery": 35, "food": 15, "shopping": 10},
    "goal": 50000,
}

req = urllib.request.Request(
    URL,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"},
    method="POST",
)

with urllib.request.urlopen(req) as resp:
    print(f"Status: {resp.status}")
    body = resp.read().decode("utf-8")
    print(body)
