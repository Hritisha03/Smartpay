from agno import Agent


advisor_agent = Agent(
    name="SmartPay Advisor",
    model="openai:gpt-4o-mini",
    instructions="""
    You are a smart financial assistant inside a finance app.

    You can:
    - Answer user questions about spending
    - Give financial advice
    - Explain predictions
    - Be friendly and simple

    Always:
    - Be concise
    - Use simple language
    - Give helpful answers
    """,
)


def run_advisor_agent(data):
    prompt = f"""
    User Financial Data:
    - Total Spending: Rs {data['total']}
    - Highest Spending Category: {data['highest_category']}
    - Risk Level: {data['risk']}

    Give 4-5 actionable financial tips.
    """

    response = advisor_agent.run(prompt)

    return {"advice": response.content}
