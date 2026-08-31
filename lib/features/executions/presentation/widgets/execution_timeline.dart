import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';

class ExecutionTimeline extends StatelessWidget {
  final List<ExecutionStep> steps;

  const ExecutionTimeline({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _TimelineStep(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
        ],
      ],
    );
  }
}

class _TimelineStep extends StatefulWidget {
  final ExecutionStep step;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.isLast,
  });

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = widget.step;
    
    IconData icon;
    Color color;
    bool isRunning = step.status == ExecutionStepStatus.running;
    
    switch (step.status) {
      case ExecutionStepStatus.pending:
        icon = Icons.schedule;
        color = AppColors.textDisabled;
        break;
      case ExecutionStepStatus.running:
        icon = Icons.sync;
        color = AppColors.info;
        break;
      case ExecutionStepStatus.success:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case ExecutionStepStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
        break;
      case ExecutionStepStatus.skipped:
        icon = Icons.skip_next;
        color = AppColors.textDisabled;
        break;
    }

    final duration = step.completedAt?.difference(step.startedAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRunning)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                          ),
                        ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          icon,
                          key: ValueKey(icon),
                          color: color,
                          size: isRunning ? 14 : 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.isLast)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2,
                    // ignore: deprecated_member_use
                    color: isRunning 
                        ? AppColors.info.withOpacity(0.3) 
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppLayout.spaceM),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppLayout.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(AppLayout.cardRadius),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              step.nodeTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                if (duration != null)
                                  Text(
                                    '${duration.inSeconds}s',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(width: AppLayout.spaceS),
                                Icon(
                                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _NodeTypeChip(type: step.nodeType),
                            const SizedBox(width: AppLayout.spaceS),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(step.status.name.toUpperCase()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                    child: _isExpanded 
                        ? _buildExpandedContent(context, step) 
                        : const SizedBox(width: double.infinity),
                  ),
                  if (step.errorMessage != null && !_isExpanded) ...[
                    const SizedBox(height: AppLayout.spaceS),
                    Text(
                      step.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ExecutionStep step) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('HH:mm:ss');
    const encoder = JsonEncoder.withIndent('  ');

    return Padding(
      padding: const EdgeInsets.only(top: AppLayout.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetadataItem(
                label: 'Started',
                value: dateFormat.format(step.startedAt),
              ),
              const SizedBox(width: AppLayout.spaceXL),
              if (step.completedAt != null)
                _MetadataItem(
                  label: 'Completed',
                  value: dateFormat.format(step.completedAt!),
                ),
            ],
          ),
          if (step.errorMessage != null) ...[
            const SizedBox(height: AppLayout.spaceM),
            _SectionTitle(title: 'Error'),
            Text(
              step.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          if (step.input != null) ...[
            const SizedBox(height: AppLayout.spaceM),
            _SectionTitle(title: 'Input'),
            _JsonCodeBlock(code: encoder.convert(step.input)),
          ],
          if (step.output != null) ...[
            const SizedBox(height: AppLayout.spaceM),
            _SectionTitle(title: 'Output'),
            _JsonCodeBlock(code: encoder.convert(step.output)),
          ],
        ],
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _JsonCodeBlock extends StatelessWidget {
  final String code;
  const _JsonCodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.spaceS),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        // ignore: deprecated_member_use
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
        ),
      ),
    );
  }
}

class _NodeTypeChip extends StatelessWidget {
  final WorkflowNodeType type;
  const _NodeTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 8,
          // ignore: deprecated_member_use
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
