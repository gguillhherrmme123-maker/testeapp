import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeesScreen extends StatelessWidget {
  final List<Employee> employees;
  final Function(String, String, String) onAddEmployee;
  final Function(String, String, String, String) onEditEmployee;

  const EmployeesScreen({
    super.key,
    required this.employees,
    required this.onAddEmployee,
    required this.onEditEmployee,
  });

  void _showEmployeeDialog(BuildContext context, {Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final roleController = TextEditingController(text: employee?.role ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(employee == null ? 'Novo Funcionário' : 'Editar Funcionário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
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
              if (nameController.text.isNotEmpty) {
                if (employee == null) {
                  onAddEmployee(
                    nameController.text,
                    roleController.text,
                    phoneController.text,
                  );
                } else {
                  onEditEmployee(
                    employee.id,
                    nameController.text,
                    roleController.text,
                    phoneController.text,
                  );
                }
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (ctx, i) {
          final emp = employees[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(emp.name),
              subtitle: Text('${emp.role} • ${emp.phone}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEmployeeDialog(context, employee: emp),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
