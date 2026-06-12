import 'package:flutter/material.dart';

import '../../domain/entities/inspection_item.dart';

class BeforeAfterComparison extends StatelessWidget {
  const BeforeAfterComparison({
    super.key,
    required this.preItems,
    required this.postItems,
  });

  final List<InspectionItem> preItems;
  final List<InspectionItem> postItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postByName = {for (final item in postItems) item.itemName: item};

    if (preItems.isEmpty && postItems.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No inspection data available for comparison.'),
        ),
      );
    }

    final items = preItems.isNotEmpty ? preItems : postItems;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Before / After', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...items.map((pre) {
              final post = postByName[pre.itemName];
              final changed = post != null && pre.status != post.status;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatusColumn(
                        label: 'Before',
                        itemName: pre.itemName,
                        status: pre.status,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Icon(
                      changed ? Icons.compare_arrows : Icons.arrow_forward,
                      color: changed ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                    Expanded(
                      child: _StatusColumn(
                        label: 'After',
                        itemName: pre.itemName,
                        status: post?.status ?? '—',
                        color: changed ? theme.colorScheme.primary : theme.colorScheme.outline,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({
    required this.label,
    required this.itemName,
    required this.status,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String itemName;
  final String status;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        Text(itemName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Chip(
          label: Text(status.replaceAll('_', ' ')),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
