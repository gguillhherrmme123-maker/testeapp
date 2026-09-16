enum TransactionType { income, expense }

class FinancialTransaction {
  String id;
  TransactionType type;
  double amount;
  String description;
  String category;
  DateTime date;

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'],
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      category: json['category'] ?? 'Outros',
      date: DateTime.parse(json['date']),
    );
  }
}
