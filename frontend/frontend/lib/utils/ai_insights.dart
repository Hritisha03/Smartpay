/// Helper utilities to compute explainable AI-style financial insights.
///
/// This module is intentionally kept simple and rule-based. All calculations are
/// deterministic and based solely on numeric inputs.

class AIFinancialReport {
  final double aiSalary; // Total income available
  final double aiTotalExpense; // Total expenses in the current month
  final Map<String, double> categoryTotals; // Map of category->amount spent
  final double lastMonthExpense; // Expense value from previous month
  final double goal; // Savings goal

  AIFinancialReport({
    required this.aiSalary,
    required this.aiTotalExpense,
    required this.categoryTotals,
    required this.lastMonthExpense,
    required this.goal,
  });

  /// Calculate the percent change from last month to this month.
  double _spendingTrendPercent() {
    if (lastMonthExpense <= 0) {
      return 0.0;
    }
    return ((aiTotalExpense - lastMonthExpense) / lastMonthExpense) * 100.0;
  }

  /// Predict the next month expense using a weighted average.
  /// next = (lastMonth * 0.6) + (currentMonth * 0.4)
  double _predictNextMonthExpense() {
    return (lastMonthExpense * 0.6) + (aiTotalExpense * 0.4);
  }

  /// Classify spending behavior based on a simplified "luxury" category share.
  String _behavioralClassification() {
    const luxuryCategories = ["shopping", "entertainment", "travel"];
    final total = categoryTotals.values.fold<double>(0.0, (a, b) => a + b);
    if (total <= 0) {
      return "Disciplined Saver";
    }

    final luxuryTotal = categoryTotals.entries
        .where((entry) => luxuryCategories.contains(entry.key.toLowerCase()))
        .fold<double>(0.0, (a, b) => a + b.value);

    final luxuryPct = (luxuryTotal / total) * 100.0;

    if (luxuryPct > 30) {
      return "Impulsive Spender";
    } else if (luxuryPct >= 15) {
      return "Balanced Spender";
    }
    return "Disciplined Saver";
  }

  /// Compute a stability score between 0 and 1.0 based on expense changes.
  double _expenseStability() {
    if (lastMonthExpense <= 0) {
      return 1.0;
    }
    final diff = (aiTotalExpense - lastMonthExpense).abs();
    final maxVal = aiTotalExpense > lastMonthExpense ? aiTotalExpense : lastMonthExpense;
    if (maxVal == 0) {
      return 1.0;
    }
    final stability = 1.0 - (diff / maxVal);
    return stability.clamp(0.0, 1.0);
  }

  /// Calculate how far along the user is towards their savings goal (0..1). 
  double _goalProgress() {
    if (goal <= 0) {
      return 0.0;
    }
    final savings = (aiSalary - aiTotalExpense).clamp(0.0, double.infinity);
    return (savings / goal).clamp(0.0, 1.0);
  }

  /// Calculate the emergency buffer as a value between 0..1.
  /// We assume a healthy buffer is 3 months of expenses.
  double _emergencyBuffer() {
    if (aiTotalExpense <= 0) {
      return 1.0;
    }
    final savings = (aiSalary - aiTotalExpense).clamp(0.0, double.infinity);
    final target = aiTotalExpense * 3;
    if (target <= 0) {
      return 0.0;
    }
    return (savings / target).clamp(0.0, 1.0);
  }

  /// Compute the overall health score, normalized to 0..100.
  int _healthScore() {
    final savingRatio = aiSalary <= 0
        ? 0.0
        : ((aiSalary - aiTotalExpense) / aiSalary).clamp(0.0, 1.0);
    final expenseStability = _expenseStability();
    final goalProgress = _goalProgress();
    final emergencyBuffer = _emergencyBuffer();

    final rawScore =
        (savingRatio * 40) + (expenseStability * 30) + (goalProgress * 20) + (emergencyBuffer * 10);

    return rawScore.clamp(0.0, 100.0).round();
  }

  /// Determine if there is a high risk of overspending.
  String _riskPrediction(double trendPercent) {
    final savings = (aiSalary - aiTotalExpense).clamp(0.0, double.infinity);
    final savingRatio = aiSalary <= 0 ? 0.0 : (savings / aiSalary);

    final spendingIncreasing = trendPercent > 0;
    final lowSavings = savingRatio < 0.10;

    if (spendingIncreasing && lowSavings) {
      return "⚠ High risk of overspending next month";
    }
    return "Low";
  }

  /// Public getter for the overall health score (0..100).
  int get healthScore => _healthScore();

  /// Public getter for risk level derived from the latest spending trend.
  String get riskLevel => _riskPrediction(_spendingTrendPercent());

  /// Generate a set of simple insight sentences.
  List<String> _generateInsights(double trendPercent) {
    final insights = <String>[];
    final trendIncreasing = trendPercent > 0;
    final trendStable = trendPercent.abs() < 5;

    if (trendIncreasing) {
      insights.add("Your spending trend is rising compared to last month.");
    } else if (trendStable) {
      insights.add("Your spending pattern is stable.");
    } else {
      insights.add("Your spending is decreasing, good job keeping costs down.");
    }

    final savings = (aiSalary - aiTotalExpense).clamp(0.0, double.infinity);
    final savingRatio = aiSalary <= 0 ? 0.0 : (savings / aiSalary);
    if (savingRatio > 0.3) {
      insights.add("Your financial health is improving.");
    }

    if (savingRatio < 0.1) {
      insights.add("Your saving pattern is unstable; consider setting aside more each month.");
    }

    // Detect overspending in a key category
    final shopping = categoryTotals["shopping"] ?? 0.0;
    if (shopping > 0 && shopping > (aiSalary * 0.15)) {
      insights.add("You are overspending in shopping compared to your income.");
    }

    return insights;
  }

  /// Return a formatted report string.
  String buildReport() {
    final trendPercent = _spendingTrendPercent();
    final predicted = _predictNextMonthExpense();
    final trendLabel = trendPercent >= 0 ? "Increasing" : "Decreasing";
    final trendAbsolute = trendPercent.abs().round();

    final personality = _behavioralClassification();
    final healthScore = _healthScore();
    final risk = _riskPrediction(trendPercent);
    final insights = _generateInsights(trendPercent);

    final buffer = StringBuffer();
    buffer.writeln("AI Financial Report:\n");
    buffer.writeln("📈 Trend: $trendLabel (${trendAbsolute}%)");
    buffer.writeln("💰 Predicted Expense: ₹${predicted.round()}");
    buffer.writeln();
    buffer.writeln("🧠 Personality: $personality");
    buffer.writeln();
    buffer.writeln("💯 Health Score: $healthScore/100");
    buffer.writeln();
    buffer.writeln("⚠ Risk: $risk");
    buffer.writeln();
    buffer.writeln("💡 Insights:");
    for (final insight in insights) {
      buffer.writeln("- $insight");
    }

    return buffer.toString();
  }
}
