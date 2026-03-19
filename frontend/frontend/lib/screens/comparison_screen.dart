import 'package:flutter/material.dart';
import '../models/user_expense_data.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  // 🔥 Dummy data (later you can pass real data)
  List<UserExpenseData> get users => [
        UserExpenseData(
          name: 'Alok',
          income: 45000,
          expenses: {'rent': 15000, 'food': 5000, 'shopping': 3000},
        ),
        UserExpenseData(
          name: 'Siba',
          income: 60000,
          expenses: {'rent': 20000, 'food': 8000, 'shopping': 5000},
        ),
        UserExpenseData(
          name: 'Hritisha',
          income: 55000,
          expenses: {'rent': 18000, 'food': 10000, 'shopping': 12000},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Comparison"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 SUMMARY CARDS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("Users", users.length.toString()),
                _buildSummaryCard(
                  "Avg Income",
                  "₹${_avgIncome().toStringAsFixed(0)}",
                ),
                _buildSummaryCard(
                  "Avg Savings",
                  "₹${_avgSavings().toStringAsFixed(0)}",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 👑 TOP SPENDER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Top Spender 🏆",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _topSpender().name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 USER LIST
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final totalExpense = user.expenses.values
                      .fold<double>(0, (p, c) => p + c);
                  final savings = user.income - totalExpense;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.name),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text("₹${user.income}"),
                            Text(
                              "Savings: ₹${savings.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: savings > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 HELPERS

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _avgIncome() {
    return users.map((u) => u.income).reduce((a, b) => a + b) /
        users.length;
  }

  double _avgSavings() {
    return users
            .map((u) =>
                u.income -
                u.expenses.values.fold<double>(0, (p, c) => p + c))
            .reduce((a, b) => a + b) /
        users.length;
  }

  UserExpenseData _topSpender() {
    users.sort((a, b) {
      final aExp =
          a.expenses.values.fold<double>(0, (p, c) => p + c);
      final bExp =
          b.expenses.values.fold<double>(0, (p, c) => p + c);
      return bExp.compareTo(aExp);
    });
    return users.first;
  }
}