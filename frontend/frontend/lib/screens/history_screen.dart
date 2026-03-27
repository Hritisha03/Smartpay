import 'package:flutter/material.dart';
import '../utils/app_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final avgMonthlySpend =
        AppState.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final monthlySavingsRaw = AppState.monthlyIncome - avgMonthlySpend;
    final monthlySavings = monthlySavingsRaw < 0 ? 0.0 : monthlySavingsRaw;
    final hasGoalWarning = AppState.goals.any(
      (goal) => goal.targetDate != null && goal.requiredMonthlySaving(monthlySavings) > monthlySavings,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
      ),
      body: ValueListenableBuilder(
        valueListenable: AppState.transactions,
        builder: (context, transactions, _) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length + (hasGoalWarning ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              if (hasGoalWarning && index == 0) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Text(
                    'Warning: current spending may prevent hitting your goals this month.',
                    style: TextStyle(color: Color(0xFFB91C1C)),
                  ),
                );
              }
              final txIndex = hasGoalWarning ? index - 1 : index;
              final tx = transactions[txIndex];
              return ListTile(
                leading: Icon(
                  tx.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: tx.isDebit ? Colors.red : Colors.green,
                ),
                title: Text(tx.title),
                subtitle: Text(tx.subtitle),
                trailing: const Text("Success"),
              );
            },
          );
        },
      ),
    );
  }
}
