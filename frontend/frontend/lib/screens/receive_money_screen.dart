import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/app_state.dart';
import '../utils/colors.dart';
import '../widgets/gradient_button.dart';
import 'success_screen.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  final TextEditingController senderController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isLoading = false;

  Future<void> _receiveMoney() async {
    final sender = senderController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (sender.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a sender and amount."),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    AppState.updateBalance(AppState.balance.value + amount);
    AppState.addTransaction(
      TransactionModel(
        title: 'Received Rs ${amount.toStringAsFixed(0)}',
        subtitle: 'From $sender',
        amount: amount.toStringAsFixed(0),
        isDebit: false,
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
    senderController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receive Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: senderController,
              decoration: InputDecoration(
                labelText: "Sender ID / Phone",
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: isLoading ? null : _receiveMoney,
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
                        "Receive",
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
