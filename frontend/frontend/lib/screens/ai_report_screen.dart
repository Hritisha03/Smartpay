import 'package:flutter/material.dart';

import '../models/user_expense_data.dart';
import '../utils/ai_insights.dart';
import '../utils/financial_chat_assistant.dart';
import '../utils/app_state.dart';
import '../utils/colors.dart';
import '../widgets/category_chart.dart';
import '../widgets/transaction_chart.dart';

class AIReportScreen extends StatefulWidget {
  final UserExpenseData user;

  const AIReportScreen({
    super.key,
    required this.user,
  });

  @override
  State<AIReportScreen> createState() => _AIReportScreenState();
}

class _AIReportScreenState extends State<AIReportScreen> {
  bool _isLoading = false;
  late AIFinancialReport _report;
  final TextEditingController _chatController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _generateReport();
    AppState.balance.addListener(_handleBalanceChange);
  }

  void _handleBalanceChange() {
    setState(_generateReport);
  }

  void _generateReport() {
    final balance = AppState.balance.value;
    _report = AIFinancialReport(
      aiSalary: balance > 0 ? balance : widget.user.income,
      aiTotalExpense: widget.user.totalExpense,
      categoryTotals: widget.user.expenses,
      lastMonthExpense: widget.user.lastMonthExpense,
      goal: widget.user.defaultGoal,
    );

    if (_messages.isEmpty) {
      _messages.add(
        _ChatMessage(
          text: FinancialChatAssistant.welcomeMessage(_report),
          isUser: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportText = _report.buildReport();

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Report - ${widget.user.name}'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'AI analyzing your financial data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeyMetricsCards(),
                    const SizedBox(height: 20),
                    _buildHealthScoreCard(),
                    const SizedBox(height: 20),
                    _buildRiskCard(),
                    const SizedBox(height: 20),
                    const Text(
                      'Spending Trend Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TransactionTrendChart(
                        data: const [
                          TransactionData(1, 32500),
                          TransactionData(2, 34000),
                          TransactionData(3, 35000),
                          TransactionData(4, 36000),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CategorySpendingChart(
                        categoryData: _report.categoryTotals,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detailed Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SelectableText(
                              reportText,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAssistantChatCard(),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showWhatIfDialog,
                      icon: const Icon(Icons.trending_up),
                      label: const Text('What-If Simulation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(_generateReport);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Report'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAssistantChatCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Financial Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about spending, advice, or predictions.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              child: Text(
                FinancialChatAssistant.systemPrompt.trim(),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._messages.map(_buildMessageBubble),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FinancialChatAssistant.suggestedPrompts
                  .map(
                    (prompt) => ActionChip(
                      label: Text(prompt),
                      onPressed: () => _sendSuggested(prompt),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendChatMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask a money question',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _sendChatMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final bubbleColor =
        message.isUser ? AppColors.primary : AppColors.surface;
    final textColor = message.isUser ? AppColors.background : AppColors.textPrimary;
    final alignment =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Income',
            'Rs ${_report.aiSalary.toStringAsFixed(0)}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Expenses',
            'Rs ${_report.aiTotalExpense.toStringAsFixed(0)}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Savings',
            'Rs ${(_report.aiSalary - _report.aiTotalExpense).toStringAsFixed(0)}',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
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
        ? AppColors.success
        : healthScore >= 50
            ? AppColors.warning
            : AppColors.danger;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Health Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    '$healthScore',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: healthScore / 100,
                        minHeight: 10,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      const SizedBox(height: 8),
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
    final normalizedRisk = riskLevel.toLowerCase();
    final color = normalizedRisk.contains('high')
        ? AppColors.danger
        : normalizedRisk.contains('medium')
            ? AppColors.warning
            : AppColors.success;

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Level',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
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
      ),
    );
  }

  void _sendChatMessage() {
    final input = _chatController.text.trim();
    if (input.isEmpty) {
      return;
    }

    final reply = FinancialChatAssistant.generateReply(
      question: input,
      report: _report,
    );

    setState(() {
      _messages.add(_ChatMessage(text: input, isUser: true));
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _chatController.clear();
    });

    _scrollChatToBottom();
  }

  void _sendSuggested(String prompt) {
    final reply = FinancialChatAssistant.generateReply(
      question: prompt,
      report: _report,
    );

    setState(() {
      _messages.add(_ChatMessage(text: prompt, isUser: true));
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });

    _scrollChatToBottom();
  }

  void _showWhatIfDialog() {
    String selectedCategory = 'shopping';
    double reductionPercent = 10.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What-If Simulation'),
        content: StatefulBuilder(
          builder: (context, setLocalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select category to reduce:'),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: _report.categoryTotals.keys
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setLocalState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final originalAmount = _report.categoryTotals[selectedCategory] ?? 0;
              final reduction = originalAmount * (reductionPercent / 100);
              final newSavings = (
                _report.aiSalary - (_report.aiTotalExpense - reduction)
              ).toStringAsFixed(0);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'If you reduce $selectedCategory by $reductionPercent%, your new savings would be Rs $newSavings per month.',
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    AppState.balance.removeListener(_handleBalanceChange);
    super.dispose();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
