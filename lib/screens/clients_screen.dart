import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientsScreen extends StatelessWidget {
  final List<Client> clients;
  final Function(String, String) onAddClient;
  final Function(String, String, String) onEditClient;
  final Function(String) onDeleteClient;

  const ClientsScreen({
    super.key,
    required this.clients,
    required this.onAddClient,
    required this.onEditClient,
    required this.onDeleteClient,
  });

  void _showClientDialog(BuildContext context, {Client? client}) {
    final nameController = TextEditingController(text: client?.name ?? '');
    final notesController = TextEditingController(text: client?.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(client == null ? 'Novo Cliente' : 'Editar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Observação'),
              maxLines: 3,
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
                if (client == null) {
                  onAddClient(nameController.text, notesController.text);
                } else {
                  onEditClient(client.id, nameController.text, notesController.text);
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onDeleteClient(id);
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
    return Scaffold(
      body: clients.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (ctx, i) {
                final client = clients[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(client.name),
                    subtitle: Text(client.notes),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showClientDialog(context, client: client),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _confirmDelete(context, client.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
