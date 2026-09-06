import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/utils.dart';
import '../providers/integration_providers.dart';
import '../../domain/models/models.dart';

class IntegrationsPage extends ConsumerWidget {
  const IntegrationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(connectedAccountsProvider);
    final theme = Theme.of(context);
    final isMobile = AppBreakpoints.isMobile(context);

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
            style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppLayout.spaceXL),
                    child: Text(
                      'No accounts connected yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
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
            error: (err, st) => Center(child: Text('Error: $err')),
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
    final isMobile = AppBreakpoints.isMobile(context);

    final button = SizedBox(
      width: isMobile ? double.infinity : 120,
      child: ElevatedButton(
        onPressed: isLoading ? null : onConnect,
        child: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Connect'),
      ),
    );

    if (isMobile) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.spaceM),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppLayout.spaceM),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.spaceM),
              button,
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: button,
      ),
    );
  }
}

class _ConnectedAccountCard extends ConsumerWidget {
  final IntegrationAccount account;
  const _ConnectedAccountCard({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = AppBreakpoints.isMobile(context);
    final theme = Theme.of(context);

    final disconnectButton = TextButton(
      onPressed: () => ref.read(integrationActionsProvider.notifier).disconnect(account.id),
      child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
    );

    if (isMobile) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.spaceM),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: AppLayout.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          account.email,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.spaceS),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: disconnectButton,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(account.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(account.email),
        trailing: SizedBox(
          width: 100,
          child: disconnectButton,
        ),
      ),
    );
  }
}
