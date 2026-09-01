import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/integration_providers.dart';
import '../../domain/models/models.dart';

class IntegrationsPage extends ConsumerWidget {
  const IntegrationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(connectedAccountsProvider);
    final theme = Theme.of(context);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Integrations',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppLayout.spaceXS),
          Text(
            'Connect your accounts to enable real-world automations.',
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppLayout.spaceXL),
          
          // Available Integrations
          Text(
            'Available Services',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppLayout.spaceM),
          _IntegrationServiceTile(
            name: 'Google (Gmail, Sheets)',
            icon: Icons.account_circle,
            onConnect: () => ref.read(integrationActionsProvider.notifier).connectGoogle(),
          ),
          const SizedBox(height: AppLayout.spaceXL),

          // Connected Accounts
          Text(
            'Connected Accounts',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppLayout.spaceM),
          accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppLayout.spaceXL),
                    child: Text('No accounts connected yet.'),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceM),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return _ConnectedAccountCard(account: account);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}

class _IntegrationServiceTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onConnect;

  const _IntegrationServiceTile({
    required this.name,
    required this.icon,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: ElevatedButton(
          onPressed: onConnect,
          child: const Text('Connect'),
        ),
      ),
    );
  }
}

class _ConnectedAccountCard extends ConsumerWidget {
  final IntegrationAccount account;
  const _ConnectedAccountCard({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(account.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(account.email),
        trailing: TextButton(
          onPressed: () => ref.read(integrationActionsProvider.notifier).disconnect(account.id),
          child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
