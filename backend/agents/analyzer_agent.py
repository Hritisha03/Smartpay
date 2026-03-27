from agno import Agent

analyzer_agent = Agent(
    name="Expense Analyzer",
    model="openai:gpt-4o-mini",
    instructions="""
    You analyze user spending patterns.

    Output:
    - Trend (Increasing / Decreasing / Stable)
    - 2-3 short insights
    - Mention highest spending category
    - Keep it simple
    """
)

def run_analyzer_agent(data):
    prompt = f"""
    Transactions Summary:
    - Total Spending: ₹{data['total']}
    - Category Breakdown: {data['categories']}

    Analyze spending behavior.
    """

    response = analyzer_agent.run(prompt)

    lines = [l.strip() for l in response.content.split("\n") if l.strip()]

    return {
        "trend": "AI Generated",
        "trend_percentage": 0,
        "insights": lines[:3],
        "highest_category": max(data["categories"], key=data["categories"].get)
    }