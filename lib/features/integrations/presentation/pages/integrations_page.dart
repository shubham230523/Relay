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

    // Log error if connection fails
    ref.listen(integrationActionsProvider, (previous, next) {
      if (next is AsyncError) {
        debugPrint('Integration Action Error: ${next.error}');
        debugPrint('Stack trace: ${next.stackTrace}');
      }
    });

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
            name: 'Make.com (Integromat)',
            icon: Icons.bolt,
            onConnect: () => _showMakeTokenDialog(context, ref),
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

  void _showMakeTokenDialog(BuildContext context, WidgetRef ref) {
    final apiTokenController = TextEditingController();
    final clientIdController = TextEditingController();
    final clientSecretController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Make.com'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your Make API Token (v2). You can find it in your Profile > API settings.'),
              const SizedBox(height: AppLayout.spaceM),
              TextField(
                controller: apiTokenController,
                decoration: const InputDecoration(
                  labelText: 'API Token',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppLayout.spaceL),
              const Text('Google Cloud Console Credentials (for Gmail/Sheets integrations):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppLayout.spaceM),
              TextField(
                controller: clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Google Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppLayout.spaceM),
              TextField(
                controller: clientSecretController,
                decoration: const InputDecoration(
                  labelText: 'Google Client Secret',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final apiToken = apiTokenController.text.trim();
              final clientId = clientIdController.text.trim();
              final clientSecret = clientSecretController.text.trim();
              
              if (apiToken.isNotEmpty) {
                final notifier = ref.read(integrationActionsProvider.notifier);
                notifier.connectMake(apiToken, clientId, clientSecret);
                Navigator.pop(context);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

class _IntegrationServiceTile extends ConsumerWidget {
  final String name;
  final IconData icon;
  final VoidCallback onConnect;

  const _IntegrationServiceTile({
    required this.name,
    required this.icon,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsState = ref.watch(integrationActionsProvider);
    final isLoading = actionsState.isLoading;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConnect,
            child: isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Connect'),
          ),
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
        trailing: SizedBox(
          width: 100,
          child: TextButton(
            onPressed: () => ref.read(integrationActionsProvider.notifier).disconnect(account.id),
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
