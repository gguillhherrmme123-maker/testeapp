import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Task> _tasks = [];
  List<Employee> _employees = [];
  List<FinancialTransaction> _transactions = [];
  List<Client> _clients = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final tasksJson = prefs.getString('tasks');
    final employeesJson = prefs.getString('employees');
    final transactionsJson = prefs.getString('transactions');
    final clientsJson = prefs.getString('clients');

    setState(() {
      if (tasksJson != null) {
        final List list = jsonDecode(tasksJson);
        _tasks = list.map((e) => Task.fromJson(e)).toList();
      }
      if (employeesJson != null) {
        final List list = jsonDecode(employeesJson);
        _employees = list.map((e) => Employee.fromJson(e)).toList();
      }
      if (transactionsJson != null) {
        final List list = jsonDecode(transactionsJson);
        _transactions = list.map((e) => FinancialTransaction.fromJson(e)).toList();
      }
      if (clientsJson != null) {
        final List list = jsonDecode(clientsJson);
        _clients = list.map((e) => Client.fromJson(e)).toList();
      }
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await prefs.setString('employees', jsonEncode(_employees.map((e) => e.toJson()).toList()));
    await prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    await prefs.setString('clients', jsonEncode(_clients.map((c) => c.toJson()).toList()));
  }

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          _saveData();
        },
        onEditTask: (id, title, desc, date) {
          setState(() {
            final task = _tasks.firstWhere((t) => t.id == id);
            // Como Task tem campos final, removemos e adicionamos de novo
            _tasks.removeWhere((t) => t.id == id);
            _tasks.add(Task(
              id: id,
              title: title,
              description: desc,
              dueDate: date,
              isCompleted: task.isCompleted,
            ));
          });
          _saveData();
        },
        onToggleTask: (id) {
          setState(() {
            final task = _tasks.firstWhere((t) => t.id == id);
            task.isCompleted = !task.isCompleted;
          });
          _saveData();
        },
        onDeleteTask: (id) {
          setState(() {
            _tasks.removeWhere((t) => t.id == id);
          });
          _saveData();
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
          _saveData();
        },
        onEditEmployee: (id, name, role, phone) {
          setState(() {
            final emp = _employees.firstWhere((e) => e.id == id);
            emp.name = name;
            emp.role = role;
            emp.phone = phone;
          });
          _saveData();
        },
        onDeleteEmployee: (id) {
          setState(() {
            _employees.removeWhere((e) => e.id == id);
          });
          _saveData();
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
          _saveData();
        },
        onDeleteTransaction: (id) {
          setState(() {
            _transactions.removeWhere((t) => t.id == id);
          });
          _saveData();
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
          _saveData();
        },
        onEditClient: (id, name, notes) {
          setState(() {
            final client = _clients.firstWhere((c) => c.id == id);
            client.name = name;
            client.notes = notes;
          });
          _saveData();
        },
        onDeleteClient: (id) {
          setState(() {
            _clients.removeWhere((c) => c.id == id);
          });
          _saveData();
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
