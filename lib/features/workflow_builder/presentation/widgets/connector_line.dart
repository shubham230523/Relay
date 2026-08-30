import 'package:flutter/material.dart';

class ConnectorLine extends StatelessWidget {
  final String? label;

  const ConnectorLine({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 2,
            height: label != null ? 12 : 24,
            color: theme.colorScheme.outlineVariant,
          ),
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                label!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 12,
              color: theme.colorScheme.outlineVariant,
            ),
          ],
        ],
      ),
    );
  }
}
