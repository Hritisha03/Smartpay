"""Optional Flask routes for SmartPay AI.

This module is used to decouple route definitions from the backend startup script.
"""

from __future__ import annotations

from flask import Blueprint, jsonify, request

from ai.ai_engine import SmartPayAIEngine

bp = Blueprint("smartpay_ai", __name__)
engine = SmartPayAIEngine()


@bp.route("/analyze", methods=["POST"])
def analyze() -> object:
    payload = request.get_json(force=True, silent=True) or {}

    required_keys = {"income", "total_spend", "categories", "goal"}
    missing = required_keys - payload.keys()
    if missing:
        return (
            jsonify({"error": f"Missing required fields: {', '.join(sorted(missing))}"}),
            400,
        )

    return jsonify(engine.analyze(payload))
