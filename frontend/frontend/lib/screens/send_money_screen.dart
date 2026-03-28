import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/transaction_model.dart';
import '../utils/app_state.dart';
import '../utils/colors.dart';
import '../widgets/gradient_button.dart';
import 'success_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  static const String _apiBase = 'http://localhost:8000';
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final String correctPin = "1234";

  bool isLoading = false;

  Future<Map<String, String>> _callTransactionGuard(
    String recipient,
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse('$_apiBase/transaction-guard'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': 'user1',
        'recipient': recipient,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      return {
        'decision': 'warn',
        'reason': 'Guard service unavailable. Please review before sending.',
      };
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'decision': (data['decision'] ?? 'warn').toString().toLowerCase(),
      'reason': (data['reason'] ?? 'Please review this payment.').toString(),
    };
  }

  Future<void> handlePayment() async {
    final recipient = recipientController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (recipient.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a recipient and amount."),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> guardResult;
    try {
      guardResult = await _callTransactionGuard(recipient, amount);
    } catch (_) {
      guardResult = {
        'decision': 'warn',
        'reason': 'Network error. Please review this payment carefully.',
      };
    }

    setState(() {
      isLoading = false;
    });

    final decision = guardResult['decision'] ?? 'warn';
    final reason = guardResult['reason'] ?? '';

    if (!mounted) return;

    if (decision == 'reject') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason.isEmpty ? 'Payment rejected by Transaction Guard.' : reason),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (decision == 'warn') {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transaction Guard Warning'),
          content: Text(reason.isEmpty ? 'Are you sure you want to proceed?' : reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );

      if (proceed != true) {
        return;
      }
    }

    await _performPayment(recipient, amount);
  }

  Future<void> _performPayment(String recipient, double amount) async {
    if (pinController.text != correctPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN. Please try again."),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final newBalance = AppState.balance.value - amount;
    AppState.updateBalance(newBalance);
    AppState.addTransaction(
      TransactionModel(
        title: 'Paid Rs ${amount.toStringAsFixed(0)}',
        subtitle: 'To $recipient',
        amount: amount.toStringAsFixed(0),
        isDebit: true,
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: "Receiver ID / Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter PIN",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: isLoading ? null : handlePayment,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.background,
                        ),
                      )
                    : const Text(
                        "Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
