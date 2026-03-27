import '../models/goal_model.dart';
import '../models/transaction_model.dart';

import 'package:flutter/material.dart';

class AppState {
  static const double monthlyIncome = 45000;
  static const List<String> userNames = ['Hritisha', 'Siba', 'Alok'];

  static final ValueNotifier<double> balance = ValueNotifier(10000);

  static final ValueNotifier<List<TransactionModel>> transactions =
      ValueNotifier([
    TransactionModel(
      title: 'Paid Rs 500',
      subtitle: 'To Rahul',
      amount: '500',
      isDebit: true,
    ),
    TransactionModel(
      title: 'Received Rs 1000',
      subtitle: 'From Amit',
      amount: '1000',
      isDebit: false,
    ),
    TransactionModel(
      title: 'Paid Rs 250',
      subtitle: 'To Neha',
      amount: '250',
      isDebit: true,
    ),
  ]);

  static final List<double> monthlySpending = [
    28000,
    29500,
    31000,
    30000,
    32000,
    33000,
    31500,
    34000,
    35000,
    34500,
    36000,
    35500,
  ];

  static final List<GoalModel> _goals = [
    GoalModel(
      title: 'Goa trip',
      targetAmount: 25000,
      currentSaved: 8000,
      targetDate: DateTime(DateTime.now().year, DateTime.now().month + 6, 1),
    ),
    GoalModel(
      title: 'Emergency fund',
      targetAmount: 50000,
      currentSaved: 15000,
      targetDate: DateTime(DateTime.now().year + 1, DateTime.now().month, 1),
    ),
  ];

  static List<TransactionModel> get transactionList =>
      List.unmodifiable(transactions.value);
  static List<GoalModel> get goals => List.unmodifiable(_goals);

  static Map<String, double> categoryTotals = {
    'rent': 15000,
    'food': 7000,
    'shopping': 4000,
    'travel': 2500,
  };

  static void addTransaction(TransactionModel tx) {
    final updated = [tx, ...transactions.value];
    transactions.value = updated;
  }

  static void updateBalance(double newBalance) {
    balance.value = newBalance;
  }

  static void addGoal(GoalModel goal) {
    _goals.add(goal);
  }
}
