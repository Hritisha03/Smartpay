import 'package:flutter/material.dart';

import 'ai_report_screen.dart';
import '../models/user_expense_data.dart';

/// Multi-user input screen for adding multiple users and their expenses.
class MultiUserInputScreen extends StatefulWidget {
  const MultiUserInputScreen({Key? key}) : super(key: key);

  @override
  State<MultiUserInputScreen> createState() => _MultiUserInputScreenState();
}

class _MultiUserInputScreenState extends State<MultiUserInputScreen> {
  final List<UserExpenseData> users = [
    UserExpenseData(
      name: 'Alice',
      income: 45000,
      expenses: {'rent': 15000, 'food': 5000, 'shopping': 3000},
    ),
    UserExpenseData(
      name: 'Bob',
      income: 60000,
      expenses: {'rent': 20000, 'food': 8000, 'shopping': 5000},
    ),
    UserExpenseData(
      name: 'Charlie',
      income: 55000,
      expenses: {'rent': 18000, 'food': 10000, 'shopping': 12000},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-User Expenses'),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserCard(users[index], index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.deepPurple[700],
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserCard(UserExpenseData user, int index) {
    final totalExpense = user.expenses.values.fold<double>(
      0,
      (prev, curr) => prev + curr,
    );
    final savings = user.income - totalExpense;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '👤 ${user.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Edit'),
                      onTap: () => _editUser(index),
                    ),
                    PopupMenuItem(
                      child: Text('Delete'),
                      onTap: () => _deleteUser(index),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('💰 Income', '₹${user.income}'),
                _buildMetric('📊 Expenses', '₹${totalExpense.toStringAsFixed(0)}'),
                _buildMetric(
                  '💵 Savings',
                  '₹${savings.toStringAsFixed(0)}',
                  color: savings > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Breakdown:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...user.expenses.entries.map((e) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('  • ${e.key}'),
                  Text('₹${e.value.toStringAsFixed(0)}'),
                ],
              ),
            )),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewAIReport(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[700],
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text('View AI Report'),
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
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => _UserInputDialog(
        onSave: (user) {
          setState(() => users.add(user));
        },
      ),
    );
  }

  void _editUser(int index) {
    showDialog(
      context: context,
      builder: (context) => _UserInputDialog(
        initialUser: users[index],
        onSave: (user) {
          setState(() => users[index] = user);
        },
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
    Key? key,
    this.initialUser,
    required this.onSave,
  }) : super(key: key);

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
    nameController = TextEditingController(
      text: widget.initialUser?.name ?? '',
    );
    incomeController = TextEditingController(
      text: (widget.initialUser?.income ?? 0).toStringAsFixed(0),
    );

    for (final entry in (widget.initialUser?.expenses ?? {}).entries) {
      expenseControllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialUser == null ? 'Add User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: incomeController,
              decoration: InputDecoration(
                labelText: 'Monthly Income',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            Text('Expenses:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...['rent', 'food', 'shopping', 'travel'].map((cat) {
              if (!expenseControllers.containsKey(cat)) {
                expenseControllers[cat] = TextEditingController();
              }
              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextField(
                  controller: expenseControllers[cat],
                  decoration: InputDecoration(
                    labelText: cat,
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final expenses = <String, double>{};
            expenseControllers.forEach((key, controller) {
              final value = double.tryParse(controller.text) ?? 0;
              if (value > 0) expenses[key] = value;
            });

            widget.onSave(
              UserExpenseData(
                name: nameController.text,
                income: double.tryParse(incomeController.text) ?? 0,
                expenses: expenses,
              ),
            );
            Navigator.pop(context);
          },
          child: Text('Save'),
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
