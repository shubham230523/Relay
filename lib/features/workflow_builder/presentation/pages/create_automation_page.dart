import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';

class CreateAutomationPage extends StatefulWidget {
  const CreateAutomationPage({super.key});

  @override
  State<CreateAutomationPage> createState() => _CreateAutomationPageState();
}

class _CreateAutomationPageState extends State<CreateAutomationPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Automation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to automate?',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppLayout.spaceS),
            Text(
              'Describe your workflow in plain English, and we\'ll help you build it.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppLayout.spaceXL),
            TextField(
              controller: _controller,
              maxLines: 6,
              minLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Example: "Whenever I receive an invoice by email, extract the details, save them to Google sheets, and notify me if the amount is above \$50,000"',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppLayout.spaceL),
            ElevatedButton(
              onPressed: () {
                // Future: Implement AI workflow generation
              },
              child: const Text('Generate Workflow'),
            ),
          ],
        ),
      ),
    );
  }
}
