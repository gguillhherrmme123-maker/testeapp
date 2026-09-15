import 'package:flutter/material.dart';
import '../models/task.dart';

class TasksScreen extends StatelessWidget {
  final List<Task> tasks;
  final Function(String, String, DateTime) onAddTask;
  final Function(String) onToggleTask;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTask,
  });

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
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
              if (titleController.text.isNotEmpty) {
                onAddTask(
                  titleController.text,
                  descriptionController.text,
                  DateTime.now().add(const Duration(days: 1)),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (ctx, i) {
          final task = tasks[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggleTask(task.id),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                '${task.description}\nPrazo: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
