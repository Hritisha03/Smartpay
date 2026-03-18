"""Backend entrypoint for SmartPay AI.

This module exposes a simple Flask API endpoint that accepts analytics JSON
and returns insights produced by our multi-agent AI system.
"""

from __future__ import annotations

import os
import sys
from typing import Any, Dict

# Ensure the root project directory is on the import path so `ai` can be imported
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from flask import Flask, jsonify, request

from ai.ai_engine import SmartPayAIEngine

app = Flask(__name__)
engine = SmartPayAIEngine()


@app.route("/analyze", methods=["POST"])
def analyze() -> Any:
    """Analyze incoming analytics JSON and return AI insights."""

    payload: Dict[str, Any] = request.get_json(force=True, silent=True) or {}

    # Basic validation - ensure required fields exist.
    if not isinstance(payload, dict):
        return jsonify({"error": "Invalid JSON payload."}), 400

    required_keys = {"income", "total_spend", "categories", "goal"}
    missing = required_keys - payload.keys()
    if missing:
        return (
            jsonify({"error": f"Missing required fields: {', '.join(sorted(missing))}"}),
            400,
        )

    # Delegate to the AI engine.
    result = engine.analyze(payload)

    response = jsonify(result)
    # Allow local frontends to call the API without CORS issues.
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response


@app.after_request
def _add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response


if __name__ == "__main__":
    # For local development.
    app.run(host="0.0.0.0", port=5000, debug=True)
