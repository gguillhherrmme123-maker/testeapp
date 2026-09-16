import 'package:flutter/material.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(String, String, DateTime) onAddTask;
  final Function(String, String, String, DateTime) onEditTask;
  final Function(String) onToggleTask;
  final Function(String) onDeleteTask;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onEditTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _searchQuery = '';
  String _filter = 'Todas'; // Todas | Pendentes | Concluídas

  List<Task> get _filteredTasks {
    List<Task> list = widget.tasks;

    // Filtro
    if (_filter == 'Pendentes') {
      list = list.where((t) => !t.isCompleted).toList();
    } else if (_filter == 'Concluídas') {
      list = list.where((t) => t.isCompleted).toList();
    }

    // Busca
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return list;
  }

  void _showTaskDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');
    DateTime selectedDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data de vencimento'),
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
                        setStateDialog(() {
                          selectedDate = picked;
                        });
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
                  if (titleController.text.isNotEmpty) {
                    if (task == null) {
                      widget.onAddTask(
                        titleController.text,
                        descriptionController.text,
                        selectedDate,
                      );
                    } else {
                      widget.onEditTask(
                        task.id,
                        titleController.text,
                        descriptionController.text,
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
        title: const Text('Excluir Tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.onDeleteTask(id);
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
    final tasks = _filteredTasks;

    return Scaffold(
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tarefa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: _filter == 'Todas',
                  onTap: () => setState(() => _filter = 'Todas'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pendentes',
                  selected: _filter == 'Pendentes',
                  onTap: () => setState(() => _filter = 'Pendentes'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Concluídas',
                  selected: _filter == 'Concluídas',
                  onTap: () => setState(() => _filter = 'Concluídas'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('Nenhuma tarefa encontrada'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final task = tasks[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => widget.onToggleTask(task.id),
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
                            '${task.description}\nPrazo: ${task.dueDate.day.toString().padLeft(2, '0')}/'
                            '${task.dueDate.month.toString().padLeft(2, '0')}/'
                            '${task.dueDate.year}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showTaskDialog(task: task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmDelete(task.id),
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
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
