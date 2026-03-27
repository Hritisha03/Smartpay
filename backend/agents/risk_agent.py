from agno import Agent

risk_agent = Agent(
    name="Risk Analyzer",
    model="openai:gpt-4o-mini",
    instructions="""
    You assess financial risk.

    Output:
    - Risk Level (Low / Medium / High)
    - 2 short warning messages
    """
)

def run_risk_agent(data):
    prompt = f"""
    User Financial Data:
    - Income: ₹{data['income']}
    - Spending: ₹{data['spending']}

    Assess financial risk.
    """

    response = risk_agent.run(prompt)

    text = response.content.lower()

    if "high" in text:
        risk = "High"
    elif "medium" in text:
        risk = "Medium"
    else:
        risk = "Low"

    warnings = [
        line.strip("-• ").strip()
        for line in response.content.split("\n")
        if line.strip()
    ]

    return {
        "risk_level": risk,
        "warnings": warnings[:2]
    }