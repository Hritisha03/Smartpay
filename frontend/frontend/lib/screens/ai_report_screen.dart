import 'package:flutter/material.dart';

import '../models/user_expense_data.dart';
import '../utils/ai_insights.dart';
import '../widgets/transaction_chart.dart';
import '../widgets/category_chart.dart';

/// A comprehensive AI financial report screen with charts and insights.
///
/// This screen displays:
/// - Spending trends chart
/// - Category breakdown pie chart
/// - AI health score and risk assessment
/// - Personalized insights and recommendations
/// - What-if simulation capability
class AIReportScreen extends StatefulWidget {
  final UserExpenseData user;

  const AIReportScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<AIReportScreen> createState() => _AIReportScreenState();
}

class _AIReportScreenState extends State<AIReportScreen> {
  bool _isLoading = false;
  late AIFinancialReport _report;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    final aiSalary = widget.user.income;
    final aiTotalExpense = widget.user.totalExpense;
    final lastMonthExpense = widget.user.lastMonthExpense;
    final goal = widget.user.defaultGoal;

    _report = AIFinancialReport(
      aiSalary: aiSalary,
      aiTotalExpense: aiTotalExpense,
      categoryTotals: widget.user.expenses,
      lastMonthExpense: lastMonthExpense,
      goal: goal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportText = _report.buildReport();

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Report - ${widget.user.name}'),
        backgroundColor: Colors.deepPurple[700],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple[700]!,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'AI analyzing your financial data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metrics Cards
                    _buildKeyMetricsCards(),
                    SizedBox(height: 20),

                    // Health Score Card
                    _buildHealthScoreCard(),
                    SizedBox(height: 20),

                    // Risk Assessment Card
                    _buildRiskCard(),
                    SizedBox(height: 20),

                    // Spending Trend Chart
                    Text(
                      'Spending Trend Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TransactionTrendChart(
                        data: [
                          TransactionData(1, 32500),
                          TransactionData(2, 34000),
                          TransactionData(3, 35000),
                          TransactionData(4, 36000),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Category Breakdown Chart
                    Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CategorySpendingChart(
                        categoryData: _report.categoryTotals,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Full Report Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📊 Detailed Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            SelectableText(
                              reportText,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // What-If Simulation Button
                    ElevatedButton.icon(
                      onPressed: _showWhatIfDialog,
                      icon: Icon(Icons.trending_up),
                      label: Text('What-If Simulation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Refresh Button
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _generateReport();
                        });
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh Report'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKeyMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '💰',
            'Income',
            '₹${_report.aiSalary.toStringAsFixed(0)}',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '📊',
            'Expenses',
            '₹${_report.aiTotalExpense.toStringAsFixed(0)}',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '💵',
            'Savings',
            '₹${(_report.aiSalary - _report.aiTotalExpense).toStringAsFixed(0)}',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String icon, String label, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final healthScore = _report.healthScore;
    final color = healthScore >= 70
        ? Colors.green
        : healthScore >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💯 Financial Health Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    '${healthScore.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: healthScore / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      SizedBox(height: 8),
                      Text(
                        healthScore >= 70
                            ? 'Excellent'
                            : healthScore >= 50
                                ? 'Good'
                                : 'Needs Improvement',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard() {
    final riskLevel = _report.riskLevel;
    final color = riskLevel == 'High'
        ? Colors.red
        : riskLevel == 'Medium'
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '⚠',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        riskLevel,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWhatIfDialog() {
    String selectedCategory = 'shopping';
    double reductionPercent = 10.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('What-If Simulation'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select category to reduce:'),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: _report.categoryTotals.keys
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Reduction %',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  reductionPercent = double.tryParse(value) ?? 10.0;
                },
              ),
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
              final originalAmount =
                  _report.categoryTotals[selectedCategory] ?? 0;
              final reduction = originalAmount * (reductionPercent / 100);
              final newSavings = (_report.aiSalary -
                      (_report.aiTotalExpense - reduction))
                  .toStringAsFixed(0);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'If you reduce $selectedCategory by $reductionPercent%, your new savings would be ₹$newSavings/month',
                  ),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: Text('Simulate'),
          ),
        ],
      ),
    );
  }
}
