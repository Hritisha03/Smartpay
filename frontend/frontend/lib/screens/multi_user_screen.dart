import 'package:flutter/material.dart';

import 'ai_report_screen.dart';
import '../models/user_expense_data.dart';

class MultiUserInputScreen extends StatefulWidget {
  const MultiUserInputScreen({super.key});

  @override
  State<MultiUserInputScreen> createState() => _MultiUserInputScreenState();
}

class _MultiUserInputScreenState extends State<MultiUserInputScreen> {
  final List<UserExpenseData> users = [
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
      backgroundColor: const Color(0xFFF5F6FA), // 🔥 modern bg
      appBar: AppBar(
        title: const Text('Multi-User Expenses'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) =>
            _buildUserCard(users[index], index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔥 UPDATED CARD UI
  Widget _buildUserCard(UserExpenseData user, int index) {
    final totalExpense =
        user.expenses.values.fold<double>(0, (p, c) => p + c);
    final savings = user.income - totalExpense;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: const Icon(Icons.person,
                          color: Colors.deepPurple),
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

            // 💰 METRICS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Income', '₹${user.income}'),
                _buildMetric(
                    'Expenses', '₹${totalExpense.toStringAsFixed(0)}'),
                _buildMetric(
                  'Savings',
                  '₹${savings.toStringAsFixed(0)}',
                  color: savings > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📊 BREAKDOWN
            Text(
              'Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            ...user.expenses.entries.map(
              (e) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.toUpperCase()),
                    Text('₹${e.value.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _viewAIReport(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
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
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
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

// 🔥 USER INPUT DIALOG (unchanged logic, just slight UI polish)
class _UserInputDialog extends StatefulWidget {
  final UserExpenseData? initialUser;
  final Function(UserExpenseData) onSave;

  const _UserInputDialog({
    super.key,
    this.initialUser,
    required this.onSave,
  });

  @override
  State<_UserInputDialog> createState() =>
      _UserInputDialogState();
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
              decoration:
                  const InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ...['rent', 'food', 'shopping', 'travel'].map((cat) {
              expenseControllers.putIfAbsent(
                  cat, () => TextEditingController());
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: expenseControllers[cat],
                  decoration:
                      InputDecoration(labelText: cat),
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
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final expenses = <String, double>{};
            expenseControllers.forEach((key, controller) {
              final value = double.tryParse(controller.text) ?? 0;
              if (value > 0) expenses[key] = value;
            });

            widget.onSave(UserExpenseData(
              name: nameController.text,
              income:
                  double.tryParse(incomeController.text) ?? 0,
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
    expenseControllers
        .forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}