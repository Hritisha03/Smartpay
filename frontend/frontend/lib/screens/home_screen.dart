import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../models/user_expense_data.dart';
import '../utils/ai_insights.dart';
import '../utils/app_state.dart';
import 'ai_chat_screen.dart';
import 'ai_report_screen.dart';
import 'history_screen.dart';
import 'multi_user_screen.dart';
import 'receive_money_screen.dart';
import 'send_money_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(onNavigateToGoals: () => _setIndex(2)),
          const _AnalyticsTab(),
          const _GoalsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Generate Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
        ],
      ),
    );
  }

  void _setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Generate Report';
      case 2:
        return 'Goals';
      default:
        return 'SmartPay';
    }
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onNavigateToGoals;

  const _HomeTab({required this.onNavigateToGoals});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: AppState.balance,
            builder: (context, balance, _) {
              return _BalanceCard(balance: balance);
            },
          ),
          const SizedBox(height: 20),
          const _HealthScoreCard(),
          const SizedBox(height: 20),
          const Text(
            'Spending Trend (12 months)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const _SparklineCard(),
          const SizedBox(height: 20),
          const Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _ActionRow(onNavigateToGoals: onNavigateToGoals),
          const SizedBox(height: 24),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _RecentTransactions(),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.balance,
      builder: (context, balance, _) {
        final report = AIFinancialReport(
          aiSalary: balance,
          aiTotalExpense:
              AppState.categoryTotals.values.fold(0.0, (a, b) => a + b),
          categoryTotals: AppState.categoryTotals,
          lastMonthExpense: AppState.monthlySpending.last,
          goal: balance * 1.2,
        );
        final score = report.healthScore;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFDCFCE7),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Score',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      score >= 70
                          ? 'Strong balance between spending and savings.'
                          : 'You have room to improve savings this month.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SparklineCard extends StatelessWidget {
  const _SparklineCard();

  @override
  Widget build(BuildContext context) {
    final points = AppState.monthlySpending;
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF38BDF8),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF38BDF8).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onNavigateToGoals;

  const _ActionRow({required this.onNavigateToGoals});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionTile(
          label: 'Send',
          icon: Icons.send,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
            );
          },
        ),
        _ActionTile(
          label: 'Receive',
          icon: Icons.call_received,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiveMoneyScreen()),
            );
          },
        ),
        _ActionTile(
          label: 'Reports',
          icon: Icons.analytics,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIReportScreen(
                  user: UserExpenseData(
                    name: 'Hritisha',
                    income: AppState.balance.value,
                    expenses: AppState.categoryTotals,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, size: 28, color: const Color(0xFF111827)),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.transactions,
      builder: (context, transactions, _) {
        final items = transactions.take(4).toList();
        return Column(
          children: items
              .map(
                (tx) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        tx.isDebit ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                    child: Icon(
                      tx.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: tx.isDebit ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(tx.title),
                  subtitle: Text(tx.subtitle),
                  trailing: Text(tx.isDebit ? '-Rs ${tx.amount}' : '+Rs ${tx.amount}'),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.balance,
      builder: (context, balance, _) {
        final report = AIFinancialReport(
          aiSalary: balance,
          aiTotalExpense:
              AppState.categoryTotals.values.fold(0.0, (a, b) => a + b),
          categoryTotals: AppState.categoryTotals,
          lastMonthExpense: AppState.monthlySpending.last,
          goal: balance * 1.2,
        );
        final predictedExpense =
            (report.lastMonthExpense * 0.6) + (report.aiTotalExpense * 0.4);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                title: 'Predicted Next Expense',
                value: 'Rs ${predictedExpense.round()}',
                subtitle: 'Based on recent spending trend.',
                fallbackValue: 'Rs ${report.aiTotalExpense.round()}',
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Risk Level',
                value: report.riskLevel,
                subtitle: 'Spending vs savings check.',
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Top Category',
                value: _topCategory(AppState.categoryTotals),
                subtitle: 'Highest spending category this month.',
              ),
              const SizedBox(height: 20),
              const Text(
                'Generated Insights',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(report.buildReport()),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AIReportScreen(
                        user: UserExpenseData(
                          name: 'Hritisha',
                          income: balance,
                          expenses: AppState.categoryTotals,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.insights),
                label: const Text('View Full Report'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIChatScreen()),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open AI Chat'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MultiUserInputScreen()),
                  );
                },
                icon: const Icon(Icons.group),
                label: const Text('Multi-User Analytics'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _topCategory(Map<String, double> categories) {
    if (categories.isEmpty) {
      return 'None';
    }
    final entry = categories.entries.reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String? fallbackValue;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.fallbackValue,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? (fallbackValue ?? '-') : value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _GoalsTab extends StatefulWidget {
  const _GoalsTab();

  @override
  State<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<_GoalsTab> {
  void _addGoal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Goal name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Target month (YYYY-MM)',
                hintText: '2026-12',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final target = double.tryParse(targetController.text.trim()) ?? 0;
              final rawDate = dateController.text.trim();
              DateTime? targetDate;
              if (rawDate.contains('-')) {
                final parts = rawDate.split('-');
                if (parts.length == 2) {
                  final year = int.tryParse(parts[0]) ?? 0;
                  final month = int.tryParse(parts[1]) ?? 0;
                  if (year > 0 && month > 0 && month <= 12) {
                    targetDate = DateTime(year, month, 1);
                  }
                }
              }
              if (title.isNotEmpty && target > 0) {
                setState(() {
                  AppState.addGoal(
                    GoalModel(
                      title: title,
                      targetAmount: target,
                      currentSaved: 0,
                      targetDate: targetDate,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = AppState.goals;
    final avgMonthlySpend =
        AppState.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final monthlySavingsRaw = AppState.monthlyIncome - avgMonthlySpend;
    final monthlySavings = monthlySavingsRaw < 0 ? 0.0 : monthlySavingsRaw;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Goals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: _addGoal,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map((goal) {
            final months = monthlySavings <= 0
                ? null
                : ((goal.targetAmount - goal.currentSaved) / monthlySavings)
                    .ceil();
            final eta = months == null
                ? 'No savings buffer'
                : '${months} mo';
            final requiredMonthly = goal.requiredMonthlySaving(monthlySavings);
            final isOverSpending = requiredMonthly > monthlySavings;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Target: Rs ${goal.targetAmount.toStringAsFixed(0)}'),
                  if (goal.targetDate != null) ...[
                    const SizedBox(height: 4),
                    Text('Target month: ${goal.targetDate!.year}-${goal.targetDate!.month.toString().padLeft(2, '0')}'),
                  ],
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                  ),
                  const SizedBox(height: 6),
                  Text('Estimated completion: $eta'),
                  if (goal.targetDate != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Required monthly saving: Rs ${requiredMonthly.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isOverSpending ? Colors.red : Colors.black87,
                      ),
                    ),
                    if (isOverSpending)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Warning: current spending is too high to hit this goal.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
