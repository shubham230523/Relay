import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../providers/workflow_builder_providers.dart';

class CreateAutomationPage extends ConsumerStatefulWidget {
  const CreateAutomationPage({super.key});

  @override
  ConsumerState<CreateAutomationPage> createState() => _CreateAutomationPageState();
}

class _CreateAutomationPageState extends ConsumerState<CreateAutomationPage> {
  late final TextEditingController _controller;
  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
    
    // Reset state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workflowGenerationProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _isInputValid => _controller.text.trim().isNotEmpty;

  Future<void> _onGenerate() async {
    if (!_isInputValid) return;

    final notifier = ref.read(workflowGenerationProvider.notifier);
    await notifier.generateWorkflow(_controller.text.trim());

    if (mounted) {
      final state = ref.read(workflowGenerationProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.error}')),
        );
      } else if (state.workflow != null) {
        context.push(AppRoutes.workflowDetails);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final generationState = ref.watch(workflowGenerationProvider);

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
              maxLength: _maxChars,
              enabled: !generationState.isLoading,
              decoration: const InputDecoration(
                hintText:
                    'Example: "Whenever I receive an invoice by email, extract the details, save them to Google sheets, and notify me if the amount is above \$50,000"',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_controller.text.length} / $_maxChars',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _controller.text.length >= _maxChars
                        ? theme.colorScheme.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.spaceL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isInputValid && !generationState.isLoading ? _onGenerate : null,
                child: generationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate Workflow'),
              ),
            ),
            const SizedBox(height: AppLayout.spaceXL),
            Text(
              'Not sure where to start?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppLayout.spaceM),
            Wrap(
              spacing: AppLayout.spaceS,
              runSpacing: AppLayout.spaceS,
              children: [
                _ExampleChip(
                  label: 'Summarize important emails every morning',
                  onTap: generationState.isLoading
                      ? null
                      : () {
                          _controller.text = 'Summarize important emails every morning';
                          _onTextChanged();
                        },
                ),
                _ExampleChip(
                  label: 'Save invoice details from emails into a spreadsheet',
                  onTap: generationState.isLoading
                      ? null
                      : () {
                          _controller.text = 'Save invoice details from emails into a spreadsheet';
                          _onTextChanged();
                        },
                ),
                _ExampleChip(
                  label: 'Create tasks from calendar meetings',
                  onTap: generationState.isLoading
                      ? null
                      : () {
                          _controller.text = 'Create tasks from calendar meetings';
                          _onTextChanged();
                        },
                ),
                _ExampleChip(
                  label: 'Send me a daily business summary',
                  onTap: generationState.isLoading
                      ? null
                      : () {
                          _controller.text = 'Send me a daily business summary';
                          _onTextChanged();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ExampleChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
