class TransactionModel {
  final String title;
  final String subtitle;
  final String amount;
  final bool isDebit;

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
  });
}
