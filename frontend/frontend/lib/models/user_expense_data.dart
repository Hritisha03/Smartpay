/// User expense model used across multiple screens.
///
/// This is a lightweight model optimized for UI-level working data.
class UserExpenseData {
  final String name;
  final double income;
  final Map<String, double> expenses;

  UserExpenseData({
    required this.name,
    required this.income,
    required this.expenses,
  });

  /// Total expense sum.
  double get totalExpense =>
      expenses.values.fold(0.0, (previous, element) => previous + element);

  /// A simple heuristic to represent previous month's expense for trend simulation.
  /// It assumes last month was slightly lower than this month.
  double get lastMonthExpense => totalExpense * 0.92;

  /// Default savings goal (1.5x monthly income).
  double get defaultGoal => income * 1.5;
}
