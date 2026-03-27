class GoalModel {
  final String title;
  final double targetAmount;
  final double currentSaved;
  final DateTime? targetDate;

  GoalModel({
    required this.title,
    required this.targetAmount,
    required this.currentSaved,
    this.targetDate,
  });

  double get progress => targetAmount <= 0
      ? 0
      : (currentSaved / targetAmount).clamp(0, 1);

  double requiredMonthlySaving(double monthlySavings) {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final months = (targetDate!.year - now.year) * 12 + (targetDate!.month - now.month);
    if (months <= 0) return targetAmount - currentSaved;
    final remaining = (targetAmount - currentSaved).clamp(0, double.infinity);
    return remaining / months;
  }
}
