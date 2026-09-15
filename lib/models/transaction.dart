enum TransactionType { income, expense }

class FinancialTransaction {
  String id;
  TransactionType type;
  double amount;
  String description;
  DateTime date;

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
}
