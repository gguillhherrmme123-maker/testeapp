import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientsScreen extends StatelessWidget {
  final List<Client> clients;
  final Function(String, String) onAddClient;

  const ClientsScreen({
    super.key,
    required this.clients,
    required this.onAddClient,
  });

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Cliente'),
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
                onAddClient(nameController.text, notesController.text);
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
