# SmartPay AI Frontend Demo

A small static frontend that lets you enter income/expenses and visualize the multi-agent AI response.

## Running the frontend

1. Make sure the backend is running:

```bash
python backend/app.py
```

2. Serve this folder using a simple HTTP server:

```bash
cd frontend
python -m http.server 8000
```

3. Open in your browser:

```
http://localhost:8000
```

The page will send requests to `http://localhost:5000/analyze` and show the AI insights.
