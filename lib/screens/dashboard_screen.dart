import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final int pendingTasks;
  final double monthlyBalance;
  final int totalEmployees;
  final int totalClients;

  const DashboardScreen({
    super.key,
    required this.pendingTasks,
    required this.monthlyBalance,
    required this.totalEmployees,
    required this.totalClients,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  title: 'Tarefas Pendentes',
                  value: '$pendingTasks',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'Saldo do Mês',
                  value: 'R\$ ${monthlyBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: monthlyBalance >= 0 ? Colors.green : Colors.red,
                ),
                _buildStatCard(
                  context,
                  title: 'Funcionários',
                  value: '$totalEmployees',
                  icon: Icons.people,
                  color: Colors.blueGrey,
                ),
                _buildStatCard(
                  context,
                  title: 'Clientes',
                  value: '$totalClients',
                  icon: Icons.person_pin,
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
