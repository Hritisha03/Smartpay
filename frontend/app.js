/*
  Simple frontend to call the SmartPay AI /analyze endpoint.
*/

const resultEl = document.getElementById("result");
const form = document.getElementById("analyzeForm");

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  const income = Number(document.getElementById("income").value);
  const totalSpend = Number(document.getElementById("totalSpend").value);
  const goal = Number(document.getElementById("goal").value);
  let categories;

  try {
    categories = JSON.parse(document.getElementById("categories").value);
  } catch (err) {
    resultEl.textContent = "Invalid JSON in categories field.";
    return;
  }

  const payload = { income, total_spend: totalSpend, categories, goal };

  resultEl.textContent = "Analyzing...";

  try {
    const response = await fetch("http://localhost:5000/analyze", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (!response.ok) {
      resultEl.textContent = JSON.stringify(data, null, 2);
      return;
    }

    resultEl.textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    resultEl.textContent = `Request failed: ${error.message}`;
  }
});
