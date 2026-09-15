import 'package:flutter/material.dart';
import '../models/transaction.dart';

class FinancesScreen extends StatelessWidget {
  final List<FinancialTransaction> transactions;
  final Function(TransactionType, double, String, DateTime) onAddTransaction;

  const FinancesScreen({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
  });

  void _showAddTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    TransactionType selectedType = TransactionType.income;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Movimentação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<TransactionType>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Receita'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Despesa'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedType = val);
                },
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0 && descriptionController.text.isNotEmpty) {
                  onAddTransaction(
                    selectedType,
                    amount,
                    descriptionController.text,
                    DateTime.now(),
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (ctx, i) {
          final t = transactions[i];
          final isIncome = t.type == TransactionType.income;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red,
              ),
              title: Text(t.description),
              subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}'),
              trailing: Text(
                '${isIncome ? '+' : '-'} R\$ ${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
