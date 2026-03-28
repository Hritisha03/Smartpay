import 'package:flutter/material.dart';

import 'ai_report_screen.dart';
import '../models/user_expense_data.dart';
import '../utils/colors.dart';

class MultiUserInputScreen extends StatefulWidget {
  const MultiUserInputScreen({super.key});

  @override
  State<MultiUserInputScreen> createState() => _MultiUserInputScreenState();
}

class _MultiUserInputScreenState extends State<MultiUserInputScreen> {
  final List<UserExpenseData> users = [
    UserExpenseData(
      name: 'Hritisha',
      income: 45000,
      expenses: {'rent': 15000, 'food': 6000, 'shopping': 2500, 'travel': 1500},
    ),
    UserExpenseData(
      name: 'Alok',
      income: 60000,
      expenses: {'rent': 20000, 'food': 9000, 'shopping': 6000, 'travel': 3000},
    ),
    UserExpenseData(
      name: 'Siba',
      income: 55000,
      expenses: {'rent': 18000, 'food': 12000, 'shopping': 14000, 'travel': 5000},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Multi-User Expenses'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserCard(users[index], index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserCard(UserExpenseData user, int index) {
    final totalExpense =
        user.expenses.values.fold<double>(0, (p, c) => p + c);
    final savings = user.income - totalExpense;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3300D4FF),
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _editUser(index),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deleteUser(index),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Income', 'Rs ${user.income}'),
                _buildMetric(
                    'Expenses', 'Rs ${totalExpense.toStringAsFixed(0)}'),
                _buildMetric(
                  'Savings',
                  'Rs ${savings.toStringAsFixed(0)}',
                  color: savings > 0 ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            ...user.expenses.entries.map(
              (e) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.toUpperCase()),
                    Text('Rs ${e.value.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _viewAIReport(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View AI Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => _UserInputDialog(
        onSave: (user) => setState(() => users.add(user)),
      ),
    );
  }

  void _editUser(int index) {
    showDialog(
      context: context,
      builder: (context) => _UserInputDialog(
        initialUser: users[index],
        onSave: (user) => setState(() => users[index] = user),
      ),
    );
  }

  void _deleteUser(int index) {
    setState(() => users.removeAt(index));
  }

  void _viewAIReport(UserExpenseData user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIReportScreen(user: user),
      ),
    );
  }
}

class _UserInputDialog extends StatefulWidget {
  final UserExpenseData? initialUser;
  final Function(UserExpenseData) onSave;

  const _UserInputDialog({
    super.key,
    this.initialUser,
    required this.onSave,
  });

  @override
  State<_UserInputDialog> createState() => _UserInputDialogState();
}

class _UserInputDialogState extends State<_UserInputDialog> {
  late TextEditingController nameController;
  late TextEditingController incomeController;
  final Map<String, TextEditingController> expenseControllers = {};

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.initialUser?.name ?? '');
    incomeController = TextEditingController(
        text: (widget.initialUser?.income ?? 0).toStringAsFixed(0));

    for (final entry in (widget.initialUser?.expenses ?? {}).entries) {
      expenseControllers[entry.key] =
          TextEditingController(text: entry.value.toStringAsFixed(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialUser == null ? 'Add User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: incomeController,
              decoration: const InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ...['rent', 'food', 'shopping', 'travel'].map((cat) {
              expenseControllers.putIfAbsent(cat, () => TextEditingController());
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: expenseControllers[cat],
                  decoration: InputDecoration(labelText: cat),
                  keyboardType: TextInputType.number,
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final expenses = <String, double>{};
            expenseControllers.forEach((key, controller) {
              final value = double.tryParse(controller.text) ?? 0;
              if (value > 0) expenses[key] = value;
            });

            widget.onSave(UserExpenseData(
              name: nameController.text,
              income: double.tryParse(incomeController.text) ?? 0,
              expenses: expenses,
            ));

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    incomeController.dispose();
    expenseControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
