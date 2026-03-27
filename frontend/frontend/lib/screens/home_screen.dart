import 'package:flutter/material.dart';
import '../models/user_expense_data.dart';
import '../utils/colors.dart';
import 'send_money_screen.dart';
import 'history_screen.dart';
import 'ai_report_screen.dart';
import 'multi_user_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartPay", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text("Wallet Balance"),
                  SizedBox(height: 8),
                  Text(
                    "₹10,000",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionTile(
                  icon: Icons.send,
                  label: "Send",
                  screen: SendMoneyScreen(),
                ),
                _ActionTile(
                  icon: Icons.history,
                  label: "History",
                  screen: HistoryScreen(),
                ),
                _ActionTile(
                  icon: Icons.insights,
                  label: "AI Report",
                  screen: AIReportScreen(
                    user: UserExpenseData(
                      name: 'Alice',
                      income: 45000,
                      expenses: {'rent': 15000, 'food': 5000, 'shopping': 3000},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionTile(
                  icon: Icons.group,
                  label: "Multi-User",
                  screen: const MultiUserInputScreen(),
                ),
                _ActionTile(
                  icon: Icons.trending_up,
                  label: "Comparison",
                  screen: const MultiUserInputScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget screen;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
