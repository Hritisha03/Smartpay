import 'ai_insights.dart';

class FinancialChatAssistant {
  static const String systemPrompt = '''
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
''';

  static String welcomeMessage(AIFinancialReport report) {
    final topCategory = _highestCategory(report.categoryTotals);
    return 'Hi! I can help with your spending, risk, and predictions. '
        'Right now your top spending category is $topCategory.';
  }

  static String generateReply({
    required String question,
    required AIFinancialReport report,
  }) {
    final normalized = question.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Ask me about your spending, savings, risk, or next month prediction.';
    }

    final predictedExpense =
        ((report.lastMonthExpense * 0.6) + (report.aiTotalExpense * 0.4)).round();
    final savings = (report.aiSalary - report.aiTotalExpense).round();
    final topCategory = _highestCategory(report.categoryTotals);
    final topCategoryAmount = report.categoryTotals[topCategory] ?? 0;

    if (_containsAny(normalized, ['predict', 'prediction', 'next month', 'future'])) {
      return 'Your next month expense may be around Rs $predictedExpense. '
          'That estimate is based on your recent spending trend.';
    }

    if (_containsAny(normalized, ['risk', 'danger', 'overspend', 'overspending'])) {
      return 'Your current risk level is ${report.riskLevel}. '
          'Try to keep more money aside each month if spending keeps rising.';
    }

    if (_containsAny(normalized, ['saving', 'savings', 'save'])) {
      return savings > 0
          ? 'You are currently saving about Rs $savings this month. '
              'A simple next step is to move part of that into a fixed savings goal.'
          : 'You are not saving much right now. Start by cutting a small non-essential expense this month.';
    }

    if (_containsAny(normalized, ['spending', 'spent', 'expense', 'expenses', 'category'])) {
      return 'You spent the most on $topCategory at Rs ${topCategoryAmount.round()}. '
          'That is the best place to review first if you want to lower spending.';
    }

    if (_containsAny(normalized, ['advice', 'tip', 'help', 'improve', 'better'])) {
      return _buildAdvice(report, topCategory, savings);
    }

    if (_containsAny(normalized, ['health score', 'score', 'health'])) {
      return 'Your financial health score is ${report.healthScore}/100. '
          'Higher savings and steadier spending will improve it.';
    }

    return 'You spend most on $topCategory, your risk is ${report.riskLevel}, '
        'and your estimated next expense is Rs $predictedExpense. '
        'Ask if you want advice on one of these.';
  }

  static String _buildAdvice(
    AIFinancialReport report,
    String topCategory,
    int savings,
  ) {
    if (savings <= 0) {
      return 'Start with one small cut in $topCategory and set a weekly limit. '
          'That will help you create some savings first.';
    }

    if (report.healthScore >= 70) {
      return 'You are doing well. Keep your current habits and set aside part of your Rs $savings savings for emergencies.';
    }

    return 'Focus on lowering $topCategory spending a little and protect at least Rs ${((savings * 0.2).round())} each month for savings.';
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  static String _highestCategory(Map<String, double> categories) {
    if (categories.isEmpty) {
      return 'general expenses';
    }

    String highestCategory = categories.keys.first;
    double highestAmount = categories[highestCategory] ?? 0;

    categories.forEach((category, amount) {
      if (amount > highestAmount) {
        highestCategory = category;
        highestAmount = amount;
      }
    });

    return highestCategory;
  }
}
