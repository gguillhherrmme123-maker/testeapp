import 'package:flutter/material.dart';
import '../models/transaction.dart';

class FinancesScreen extends StatefulWidget {
  final List<FinancialTransaction> transactions;
  final Function(TransactionType, double, String, String, DateTime) onAddTransaction;
  final Function(String, TransactionType, double, String, String, DateTime) onEditTransaction;
  final Function(String) onDeleteTransaction;
  final bool isPersonalMode;

  const FinancesScreen({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
    required this.isPersonalMode,
  });

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  String _filter = 'Todas'; // Todas | Receitas | Despesas
  String _search = '';

  List<String> get _categories {
    if (widget.isPersonalMode) {
      return [
        'Alimentação',
        'Transporte',
        'Moradia',
        'Lazer',
        'Saúde',
        'Educação',
        'Salário',
        'Investimentos',
        'Outros',
      ];
    } else {
      return [
        'Vendas',
        'Serviços',
        'Salários',
        'Fornecedores',
        'Impostos',
        'Aluguel',
        'Marketing',
        'Equipamentos',
        'Outros',
      ];
    }
  }

  List<FinancialTransaction> get _filtered {
    List<FinancialTransaction> list = widget.transactions;

    if (_filter == 'Receitas') {
      list = list.where((t) => t.type == TransactionType.income).toList();
    } else if (_filter == 'Despesas') {
      list = list.where((t) => t.type == TransactionType.expense).toList();
    }

    if (_search.isNotEmpty) {
      list = list.where((t) =>
          t.description.toLowerCase().contains(_search.toLowerCase()) ||
          t.category.toLowerCase().contains(_search.toLowerCase())).toList();
    }

    // Mais recentes primeiro
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _showTransactionDialog({FinancialTransaction? transaction}) {
    final amountController = TextEditingController(
      text: transaction != null ? transaction.amount.toStringAsFixed(2) : '',
    );
    final descriptionController = TextEditingController(text: transaction?.description ?? '');
    TransactionType selectedType = transaction?.type ?? TransactionType.expense;
    String selectedCategory = transaction?.category ?? _categories.first;
    DateTime selectedDate = transaction?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(transaction == null ? 'Nova Movimentação' : 'Editar Movimentação'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<TransactionType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: TransactionType.income, child: Text('Receita')),
                      DropdownMenuItem(value: TransactionType.expense, child: Text('Despesa')),
                    ],
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data'),
                    subtitle: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/'
                      '${selectedDate.month.toString().padLeft(2, '0')}/'
                      '${selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                  if (amount > 0 && descriptionController.text.isNotEmpty) {
                    if (transaction == null) {
                      widget.onAddTransaction(
                        selectedType,
                        amount,
                        descriptionController.text,
                        selectedCategory,
                        selectedDate,
                      );
                    } else {
                      widget.onEditTransaction(
                        transaction.id,
                        selectedType,
                        amount,
                        descriptionController.text,
                        selectedCategory,
                        selectedDate,
                      );
                    }
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Tem certeza que deseja excluir esta movimentação?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.onDeleteTransaction(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _filter == 'Todas',
                  onSelected: (_) => setState(() => _filter = 'Todas'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Receitas'),
                  selected: _filter == 'Receitas',
                  onSelected: (_) => setState(() => _filter = 'Receitas'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Despesas'),
                  selected: _filter == 'Despesas',
                  onSelected: (_) => setState(() => _filter = 'Despesas'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Nenhuma movimentação encontrada'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final t = list[i];
                      final isIncome = t.type == TransactionType.income;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.description),
                          subtitle: Text(
                            '${t.category} • ${t.date.day.toString().padLeft(2, '0')}/'
                            '${t.date.month.toString().padLeft(2, '0')}/${t.date.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'} R\$ ${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showTransactionDialog(transaction: t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmDelete(t.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
