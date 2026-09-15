import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/employee.dart';
import '../models/transaction.dart';
import '../models/client.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'employees_screen.dart';
import 'finances_screen.dart';
import 'clients_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Reunião de Alinhamento',
      description: 'Discutir metas do mês',
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Task(
      id: '2',
      title: 'Fechar Relatório Financeiro',
      description: 'Revisar despesas',
      dueDate: DateTime.now(),
      isCompleted: true,
    ),
  ];

  final List<Employee> _employees = [
    Employee(id: '1', name: 'Ana Silva', role: 'Gerente', phone: '(11) 98888-7777'),
    Employee(id: '2', name: 'Carlos Souza', role: 'Desenvolvedor', phone: '(11) 97777-6666'),
  ];

  final List<FinancialTransaction> _transactions = [
    FinancialTransaction(
      id: '1',
      type: TransactionType.income,
      amount: 5000.0,
      description: 'Projeto Website',
      date: DateTime.now(),
    ),
    FinancialTransaction(
      id: '2',
      type: TransactionType.expense,
      amount: 1200.0,
      description: 'Licença de Software',
      date: DateTime.now(),
    ),
  ];

  final List<Client> _clients = [
    Client(id: '1', name: 'Tech Solutions', notes: 'Cliente corporativo importante'),
    Client(id: '2', name: 'Padaria Central', notes: 'Manutenção mensal'),
  ];

  double get _monthlyBalance {
    double total = 0;
    for (var t in _transactions) {
      if (t.type == TransactionType.income) {
        total += t.amount;
      } else {
        total -= t.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        pendingTasks: _tasks.where((t) => !t.isCompleted).length,
        monthlyBalance: _monthlyBalance,
        totalEmployees: _employees.length,
        totalClients: _clients.length,
      ),
      TasksScreen(
        tasks: _tasks,
        onAddTask: (title, desc, date) {
          setState(() {
            _tasks.add(Task(
              id: DateTime.now().toString(),
              title: title,
              description: desc,
              dueDate: date,
            ));
          });
        },
        onToggleTask: (id) {
          setState(() {
            final task = _tasks.firstWhere((t) => t.id == id);
            task.isCompleted = !task.isCompleted;
          });
        },
      ),
      EmployeesScreen(
        employees: _employees,
        onAddEmployee: (name, role, phone) {
          setState(() {
            _employees.add(Employee(
              id: DateTime.now().toString(),
              name: name,
              role: role,
              phone: phone,
            ));
          });
        },
        onEditEmployee: (id, name, role, phone) {
          setState(() {
            final emp = _employees.firstWhere((e) => e.id == id);
            emp.name = name;
            emp.role = role;
            emp.phone = phone;
          });
        },
      ),
      FinancesScreen(
        transactions: _transactions,
        onAddTransaction: (type, amount, desc, date) {
          setState(() {
            _transactions.add(FinancialTransaction(
              id: DateTime.now().toString(),
              type: type,
              amount: amount,
              description: desc,
              date: date,
            ));
          });
        },
      ),
      ClientsScreen(
        clients: _clients,
        onAddClient: (name, notes) {
          setState(() {
            _clients.add(Client(
              id: DateTime.now().toString(),
              name: name,
              notes: notes,
            ));
          });
        },
      ),
    ];

    final titles = ['AdminPro', 'Tarefas', 'Funcionários', 'Finanças', 'Clientes'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tarefas'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Equipe'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Finanças'),
          NavigationDestination(icon: Icon(Icons.business), label: 'Clientes'),
        ],
      ),
    );
  }
}
